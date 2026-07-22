import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_availability_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancer_availability_service.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class FreelancerAvailabilityScreen extends StatefulWidget {
  const FreelancerAvailabilityScreen({super.key});

  @override
  State<FreelancerAvailabilityScreen> createState() =>
      _FreelancerAvailabilityScreenState();
}

class _FreelancerAvailabilityScreenState
    extends State<FreelancerAvailabilityScreen> {
  static const List<String> _allowedStatuses = [
    'available',
    'busy',
    'vacation',
  ];

  bool _isLoading = true;
  bool _isSaving = false;

  UserModel? _user;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'available';
  String _statusFilter = 'all';
  String _dateFilter = 'all';

  List<FreelancerAvailabilityModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUser = prefs.getString(Constants.userEmailKey);

      if (rawUser == null || rawUser.trim().isEmpty) {
        throw Exception('No se encontro la sesion del usuario.');
      }

      final parsedUser = UserModel.fromJson(
        jsonDecode(rawUser) as Map<String, dynamic>,
      );

      final list = await FreelancerAvailabilityService.getByFreelancer(
        parsedUser.id,
      );

      if (!mounted) return;
      setState(() {
        _user = parsedUser;
        _items = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Fecha de inicio' : 'Fecha final',
      cancelText: MultiLanguages.of(context)!.translate('cancel'),
      confirmText: MultiLanguages.of(context)!.translate('save'),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }

  Future<void> _saveAvailability() async {
    if (_user == null || _isSaving) return;

    if (_endDate.isBefore(_startDate)) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Rango invalido',
        message: 'La fecha final debe ser mayor o igual a la fecha inicial.',
        color: Style.getErrorColor(),
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final request = FreelancerAvailabilityModel(
        freelancerId: _user!.id,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
      );

      final saved = await FreelancerAvailabilityService.create(request);

      if (!mounted) return;

      setState(() {
        _items = [saved, ..._items];
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 7));
        _status = 'available';
        _isSaving = false;
      });

      Dialogs.showSimpleDialog(
        context,
        title: 'Disponibilidad guardada',
        message: 'Se registro correctamente tu disponibilidad.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _openEditModal(FreelancerAvailabilityModel item) async {
    if (item.id == null) return;

    DateTime modalStartDate = item.startDate;
    DateTime modalEndDate = item.endDate;
    String modalStatus = item.status;
    bool modalIsSaving = false;

    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate({required bool isStart}) async {
              final selected = await showDatePicker(
                context: context,
                initialDate: isStart ? modalStartDate : modalEndDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText: isStart ? 'Fecha de inicio' : 'Fecha final',
                cancelText: MultiLanguages.of(context)!.translate('cancel'),
                confirmText: MultiLanguages.of(context)!.translate('save'),
              );

              if (selected == null) return;

              setModalState(() {
                if (isStart) {
                  modalStartDate = DateTime(
                    selected.year,
                    selected.month,
                    selected.day,
                  );
                  if (modalEndDate.isBefore(modalStartDate)) {
                    modalEndDate = modalStartDate;
                  }
                } else {
                  modalEndDate = DateTime(
                    selected.year,
                    selected.month,
                    selected.day,
                  );
                }
              });
            }

            Future<void> saveEdit() async {
              if (modalEndDate.isBefore(modalStartDate)) {
                Dialogs.showSimpleDialog(
                  context,
                  title: 'Rango invalido',
                  message:
                      'La fecha final debe ser mayor o igual a la fecha inicial.',
                  color: Style.getErrorColor(),
                  icon: Icons.warning_amber_rounded,
                );
                return;
              }

              setModalState(() => modalIsSaving = true);

              try {
                final updated = await FreelancerAvailabilityService.update(
                  item.id!,
                  item.copyWith(
                    startDate: modalStartDate,
                    endDate: modalEndDate,
                    status: modalStatus,
                  ),
                );

                if (!mounted) return;

                setState(() {
                  _items = _items
                      .map((element) => element.id == updated.id ? updated : element)
                      .toList();
                });

                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }

                Dialogs.showSimpleDialog(
                  context,
                  title: 'Disponibilidad actualizada',
                  message: 'Se actualizo correctamente tu disponibilidad.',
                  color: Style.getPrimaryColor(),
                  icon: Icons.check_circle_outline_rounded,
                );
              } catch (e) {
                if (!mounted) return;
                setModalState(() => modalIsSaving = false);
                Dialogs.showSimpleDialog(
                  context,
                  title: 'Error',
                  message: e.toString().replaceFirst('Exception: ', ''),
                  color: Style.getErrorColor(),
                  icon: Icons.error_outline_rounded,
                );
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  14.h,
                  16.w,
                  MediaQuery.of(context).viewInsets.bottom + 14.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar disponibilidad',
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _dateField(
                      label: 'Fecha inicio',
                      value: _formatDate(modalStartDate),
                      icon: Icons.event_available_rounded,
                      onTap: () => pickDate(isStart: true),
                    ),
                    SizedBox(height: 10.h),
                    _dateField(
                      label: 'Fecha fin',
                      value: _formatDate(modalEndDate),
                      icon: Icons.event_rounded,
                      onTap: () => pickDate(isStart: false),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Style.getObscureTextColor().withValues(alpha: .24),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: modalStatus,
                          items: _allowedStatuses
                              .map(
                                (value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    _statusLabel(value),
                                    style: Style.getTextStyle(
                                      color: Style.getTextColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setModalState(() => modalStatus = value);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomWidgets.button(
                        onTap: modalIsSaving ? () {} : saveEdit,
                        color: Style.getPrimaryColor(),
                        shape: 1,
                        child: modalIsSaving
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Style.white,
                                ),
                              )
                            : Text(
                                'Guardar cambios',
                                style: Style.getHeaderThree(
                                  color: Style.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAvailability(FreelancerAvailabilityModel item) async {
    if (item.id == null) return;

    final confirmed = await Dialogs.showConfirmDialog(
      context,
      title: 'Eliminar disponibilidad',
      message: 'Esta accion quitara este rango de fechas. Deseas continuar?',
      svg: Assets.svgWarningIcon,
      confirmText: MultiLanguages.of(context)!.translate('delete'),
      cancelText: MultiLanguages.of(context)!.translate('cancel'),
    );

    if (!confirmed || !mounted) return;

    try {
      await FreelancerAvailabilityService.delete(item.id!);

      if (!mounted) return;
      setState(() {
        _items.removeWhere((element) => element.id == item.id);
      });
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: _isLoading
            ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: Style.getBackgroundColor(),
                    surfaceTintColor: Style.transparent,
                    pinned: true,
                    elevation: 0,
                    titleSpacing: 0,
                    toolbarHeight: 58.h,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Style.getTextColor(),
                      ),
                    ),
                    title: Text(
                      'Disponibilidad',
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Style.horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.h),
                          _formCard(),
                          SizedBox(height: 16.h),
                          Text(
                            'Registros',
                            style: Style.getHeaderTwo(
                              color: Style.getTextColor(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _filtersBar(),
                          SizedBox(height: 10.h),
                          if (_filteredItems.isEmpty)
                            _emptyState()
                          else
                            ..._filteredItems.map(_availabilityCard),
                          SizedBox(height: 110.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _formCard() {
    return Card(
      color: Style.getCardColor(),
      elevation: 5,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            _dateField(
              label: 'Fecha inicio',
              value: _formatDate(_startDate),
              icon: Icons.event_available_rounded,
              onTap: () => _selectDate(isStart: true),
            ),
            SizedBox(height: 10.h),
            _dateField(
              label: 'Fecha fin',
              value: _formatDate(_endDate),
              icon: Icons.event_rounded,
              onTap: () => _selectDate(isStart: false),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: Style.getObscureTextColor().withValues(alpha: .24),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  items: _allowedStatuses
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            _statusLabel(value),
                            style: Style.getTextStyle(
                              color: Style.getTextColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                ),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: CustomWidgets.button(
                onTap: _isSaving ? () {} : _saveAvailability,
                color: Style.getPrimaryColor(),
                shape: 1,
                child: _isSaving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Style.white,
                        ),
                      )
                    : Text(
                      'Guardar disponibilidad',
                        style: Style.getHeaderThree(
                          color: Style.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Style.getObscureTextColor().withValues(alpha: .24),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.w, color: Style.getPrimaryColor()),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Style.getTextStyle(
                      color: Style.getObscureTextColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_month_rounded,
              size: 18.w,
              color: Style.getObscureTextColor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'No hay disponibilidades para los filtros seleccionados.',
        style: Style.getTextStyle(color: Style.getObscureTextColor()),
      ),
    );
  }

  Widget _filtersBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            label: 'Todos',
            selected: _statusFilter == 'all',
            onTap: () => setState(() => _statusFilter = 'all'),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            label: 'Disponible',
            selected: _statusFilter == 'available',
            onTap: () => setState(() => _statusFilter = 'available'),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            label: 'Ocupado',
            selected: _statusFilter == 'busy',
            onTap: () => setState(() => _statusFilter = 'busy'),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            label: 'Vacaciones',
            selected: _statusFilter == 'vacation',
            onTap: () => setState(() => _statusFilter = 'vacation'),
          ),
          SizedBox(width: 14.w),
          _filterChip(
            label: 'Cualquier fecha',
            selected: _dateFilter == 'all',
            onTap: () => setState(() => _dateFilter = 'all'),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            label: 'Activos hoy',
            selected: _dateFilter == 'active',
            onTap: () => setState(() => _dateFilter = 'active'),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            label: 'Futuros',
            selected: _dateFilter == 'future',
            onTap: () => setState(() => _dateFilter = 'future'),
          ),
          SizedBox(width: 8.w),
          _filterChip(
            label: 'Pasados',
            selected: _dateFilter == 'past',
            onTap: () => setState(() => _dateFilter = 'past'),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? Style.getPrimaryColor().withValues(alpha: .14)
              : Style.getCardColor(),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(
            color: selected
                ? Style.getPrimaryColor()
                : Style.getObscureTextColor().withValues(alpha: .24),
          ),
        ),
        child: Text(
          label,
          style: Style.getTextStyle(
            color: selected ? Style.getPrimaryColor() : Style.getTextColor(),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _availabilityCard(FreelancerAvailabilityModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Style.getShadowColor().withValues(alpha: .14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
                  style: Style.getTextStyle(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor(item.status).withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: Style.getTextStyle(
                      color: _statusColor(item.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openEditModal(item),
            icon: Icon(
              Icons.edit_rounded,
              color: Style.getPrimaryColor(),
              size: 20.w,
            ),
          ),
          IconButton(
            onPressed: () => _deleteAvailability(item),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Style.getErrorColor(),
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'busy':
        return 'Ocupado';
      case 'vacation':
        return 'Vacaciones';
      default:
        return 'Disponible';
    }
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'busy':
        return Colors.orange;
      case 'vacation':
        return Colors.blue;
      default:
        return Style.getPrimaryColor();
    }
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  List<FreelancerAvailabilityModel> get _filteredItems {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _items.where((item) {
      if (_statusFilter != 'all' && item.status.toLowerCase() != _statusFilter) {
        return false;
      }

      final start = DateTime(item.startDate.year, item.startDate.month, item.startDate.day);
      final end = DateTime(item.endDate.year, item.endDate.month, item.endDate.day);

      switch (_dateFilter) {
        case 'active':
          return !today.isBefore(start) && !today.isAfter(end);
        case 'future':
          return start.isAfter(today);
        case 'past':
          return end.isBefore(today);
        default:
          return true;
      }
    }).toList();
  }
}
