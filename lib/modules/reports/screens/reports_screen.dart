import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/reports/models/report_model.dart';
import 'package:worklink_local/modules/reports/screens/report_detail_screen.dart';
import 'package:worklink_local/modules/reports/services/reports_service.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsService _service = ReportsService();
  final TextEditingController _searchController = TextEditingController();

  UserModel? _user;
  bool _loading = true;
  bool _isAdmin = false;
  ReportSummaryModel? _summary;
  List<UserReportModel> _reports = const [];
  ReportStatus? _selectedStatus;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChange);
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      await _loadCurrentUser();

      final reports = await _loadReports();
      final summary = _isAdmin ? await _loadSummary() : null;

      if (!mounted) return;
      setState(() {
        _reports = reports;
        _summary = summary;
        _loading = false;
      });
    } on ReportFlowException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: _friendlyError(e),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString(Constants.userEmailKey);
    if (userRaw == null || userRaw.isEmpty) return;

    final user = UserModel.fromJson(
      jsonDecode(userRaw) as Map<String, dynamic>,
    );
    _user = user;
    _isAdmin = _hasRole('admin', user: user);
  }

  Future<List<UserReportModel>> _loadReports() {
    return _service.getReports(
      status: _selectedStatus?.apiValue,
      search: _searchController.text,
      perPage: 100,
    );
  }

  Future<ReportSummaryModel> _loadSummary() {
    return _service.getReportsSummary();
  }

  void _handleSearchChange() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      if (mounted) {
        _loadData();
      }
    });
  }

  bool _hasRole(String role, {UserModel? user}) {
    final currentUser = user ?? _user;
    if (currentUser == null) return false;

    final normalizedRoles = currentUser.roles
        .map((value) => value.toLowerCase().trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final roleName = role.toLowerCase().trim();
    final currentType = currentUser.tipoCuenta.toLowerCase().trim();

    if (normalizedRoles.contains(roleName) || currentType == roleName) {
      return true;
    }

    if (roleName == 'admin') {
      return normalizedRoles.contains('administrador') ||
          currentType == 'administrador';
    }

    return false;
  }

  String _friendlyError(ReportFlowException error) {
    switch (error.statusCode) {
      case 403:
        return error.message.isNotEmpty
            ? error.message
            : 'No tienes permiso para acceder a esta información.';
      case 409:
        return error.message.isNotEmpty
            ? error.message
            : 'No se pudo completar la operación.';
      default:
        return error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Style.getPrimaryColor(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Style.getBackgroundColor(),
              surfaceTintColor: Style.transparent,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Style.getTextColor(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _loadData,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Style.getTextColor(),
                  ),
                ),
              ],
              title: Text(
                _isAdmin ? 'Panel de reportes' : 'Mis reportes',
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (_isAdmin)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    12.h,
                    Style.horizontalPadding.w,
                    0,
                  ),
                  child: _summarySection(),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  14.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _filtersSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            if (_loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                ),
              )
            else if (_reports.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      _isAdmin
                          ? 'No hay reportes para los filtros seleccionados.'
                          : 'Aún no has enviado reportes.',
                      textAlign: TextAlign.center,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                      ).copyWith(height: 1.45),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  6.h,
                  Style.horizontalPadding.w,
                  20.h,
                ),
                sliver: SliverList.separated(
                  itemCount: _reports.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return _ReportCard(
                      report: report,
                      isAdmin: _isAdmin,
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            ReportDetailScreen(
                              reportId: report.id,
                              isAdmin: _isAdmin,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection() {
    final summary = _summary;
    if (summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen administrativo',
          style: Style.getHeaderThree(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total',
                summary.total.toString(),
                Icons.report_rounded,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _summaryCard(
                'Pendientes',
                summary.pending.toString(),
                Icons.schedule_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Revisados',
                summary.reviewed.toString(),
                Icons.visibility_rounded,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _summaryCard(
                'Resueltos',
                summary.resolved.toString(),
                Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        if (summary.topReportedUsers.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Text(
            'Usuarios más reportados',
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: summary.topReportedUsers
                .take(6)
                .map(
                  (item) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Style.getCardColor(),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Style.getObscureTextColor().withValues(
                          alpha: .12,
                        ),
                      ),
                    ),
                    child: Text(
                      '${item.name.isEmpty ? 'Usuario ${item.userId}' : item.name} · ${item.reportsCount}',
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: Style.getBorderRadius(),
        border: Border.all(
          color: Style.getObscureTextColor().withValues(alpha: .10),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Style.getPrimaryColor(), size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  title,
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: _isAdmin
                ? 'Buscar por motivo, descripción o usuario'
                : 'Buscar en mis reportes',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Style.getObscureTextColor(),
            ),
            filled: true,
            fillColor: Style.getCardColor(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: Style.getObscureTextColor().withValues(alpha: .12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: Style.getObscureTextColor().withValues(alpha: .12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: Style.getPrimaryColor(),
                width: 1.3,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _statusChip(label: 'Todos', status: null),
            _statusChip(label: 'Pending', status: ReportStatus.pending),
            _statusChip(label: 'Reviewed', status: ReportStatus.reviewed),
            _statusChip(label: 'Resolved', status: ReportStatus.resolved),
          ],
        ),
      ],
    );
  }

  Widget _statusChip({required String label, required ReportStatus? status}) {
    final selected = _selectedStatus == status;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        _loadData();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? Style.getPrimaryColor().withValues(alpha: .14)
              : Style.getCardColor(),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Style.getPrimaryColor().withValues(alpha: .35)
                : Style.getObscureTextColor().withValues(alpha: .12),
          ),
        ),
        child: Text(
          label,
          style: Style.getTextStyle(
            color: selected ? Style.getPrimaryColor() : Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.isAdmin,
    required this.onTap,
  });

  final UserReportModel report;
  final bool isAdmin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Style.getCardColor(),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: Style.getObscureTextColor().withValues(alpha: .10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Style.getHeaderThree(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                _statusBadge(report.statusLabel, report.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              isAdmin
                  ? 'Reportado: ${report.reportedName.isNotEmpty ? report.reportedName : 'Usuario ${report.reportedId}'}'
                  : 'Usuario reportado: ${report.reportedName.isNotEmpty ? report.reportedName : 'Usuario ${report.reportedId}'}',
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
              ).copyWith(height: 1.45),
            ),
            SizedBox(height: 10.h),
            Text(
              DateFormat('dd MMM, yyyy • HH:mm').format(report.createdAt),
              style: Style.getTextStyle(color: Style.getObscureTextColor()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, ReportStatus status) {
    final color = switch (status) {
      ReportStatus.pending => Style.getSecondaryColor(),
      ReportStatus.reviewed => Style.getSecondaryColor(),
      ReportStatus.resolved => Style.getPrimaryColor(),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Style.getTextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
