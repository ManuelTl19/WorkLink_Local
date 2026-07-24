import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/reviews/screens/review_form_screen.dart';
import 'package:worklink_local/modules/services/components/service_request_card.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key, this.serviceId});

  final int? serviceId;

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  final ServicesService _service = ServicesService();
  bool _loading = true;
  bool _submitting = false;
  ServiceModel? _serviceModel;
  UserModel? _user;
  List<ServiceRequestModel> _requests = const [];
  final Set<int> _hiddenRequestIds = <int>{};
  final Set<int> _deleteRetryIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final user = await _getCurrentUser();
      ServiceModel? serviceModel;
      if ((widget.serviceId ?? 0) > 0) {
        serviceModel = await _service.getServiceById(widget.serviceId!);
      }

      final requests = widget.serviceId != null && widget.serviceId! > 0
          ? await _service.getServiceContractRequestsByServiceId(
              widget.serviceId!,
            )
          : await _service.getContractRequests();

      if (!mounted) return;
      setState(() {
        _user = user;
        _serviceModel = serviceModel;
        _requests = requests;
        _loading = false;
      });

      if (_deleteRetryIds.isNotEmpty) {
        _retryPendingDeletes();
      }
    } on ServiceFlowException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await _handleFlowException(e);
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

  Future<void> _contactRequester(ServiceRequestModel request) async {
    final chat = await MessageService.getOrCreateChat(
      name: request.requesterName,
      avatarSeed: request.requesterName,
      subtitle: request.accountType,
      avatarUrl: request.avatarUrl,
      relatedEntityId: request.requesterId,
      relatedEntityType: 'service_requester',
    );

    if (!mounted) return;
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  bool get _isFreelancer {
    final user = _user;
    if (user == null) return false;
    final roles = user.roles.map((item) => item.toLowerCase().trim()).toList();
    final accountType = user.tipoCuenta.toLowerCase().trim();
    return roles.contains('freelancer') || accountType == 'freelancer';
  }

  List<ServiceRequestModel> get _visibleRequests {
    final items = _requests.where((item) {
      if (_hiddenRequestIds.contains(item.id)) return false;
      if (_isFreelancer) {
        return true;
      }
      return item.requesterId == (_user?.id ?? -1);
    }).toList();
    items.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return items;
  }

  Future<void> _acceptRequest(ServiceRequestModel request) async {
    await _submitAction(() async {
      final updated = await _service.updateContractRequestStatus(
        requestId: request.id,
        status: ServiceContractRequestStatus.accepted,
      );

      _replaceRequest(updated.copyWith(status: ServiceContractRequestStatus.accepted));

      final amount = await _resolveContractAmount(updated);
      if (amount == null) {
        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: 'Aceptada sin contrato',
          message:
              'La solicitud quedo en accepted. Puedes formalizar el contrato manualmente.',
          color: Style.getPrimaryColor(),
          icon: Icons.info_outline_rounded,
        );
        return;
      }

      try {
        final contractId = await _service.createContractFromRequest(
          requestId: request.id,
          totalAmount: amount,
          startDate: DateTime.now(),
          status: 'in_process',
        );

        _replaceRequest(
          updated.copyWith(
            status: ServiceContractRequestStatus.contracted,
            contractId: contractId,
            budget: amount,
          ),
        );

        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: 'Contrato creado',
          message: 'La solicitud fue formalizada correctamente.',
          color: Style.getPrimaryColor(),
          icon: Icons.check_circle_outline_rounded,
        );
      } on ServiceFlowException catch (e) {
        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: 'Solicitud aceptada',
          message:
              'No se pudo crear el contrato. La solicitud quedo en accepted y puedes reintentar.',
          color: Style.getErrorColor(),
          icon: Icons.warning_amber_rounded,
        );
        await _handleFlowException(e, showDialog: false);
      }
    });
  }

  Future<void> _formalizeAcceptedRequest(ServiceRequestModel request) async {
    await _submitAction(() async {
      final amount = await _resolveContractAmount(request);
      if (amount == null) return;

      final contractId = await _service.createContractFromRequest(
        requestId: request.id,
        totalAmount: amount,
        startDate: DateTime.now(),
        status: 'in_process',
      );

      _replaceRequest(
        request.copyWith(
          status: ServiceContractRequestStatus.contracted,
          contractId: contractId,
          budget: amount,
        ),
      );

      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Contrato creado',
        message: 'La contratacion se formalizo con exito.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    });
  }

  Future<void> _openReviewForm(ServiceRequestModel request) async {
    if (_submitting) return;

    final contractId = request.contractId;
    final reviewedUserId = _isFreelancer ? request.requesterId : request.freelancerId;

    if (contractId == null || contractId <= 0 || reviewedUserId == null || reviewedUserId <= 0) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Calificaciones',
        message: 'No se puede abrir la reseña sin un contrato válido.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      String reviewedUserName = _isFreelancer ? request.requesterName : 'Freelancer';
      String reviewedUserType = _isFreelancer ? request.accountType : 'Freelancer';

      if (!_isFreelancer) {
        final freelancer = await FreelancersService.getFreelancerById(reviewedUserId);
        if (freelancer != null) {
          reviewedUserName = freelancer.fullName;
          reviewedUserType = freelancer.specialty.isNotEmpty
              ? freelancer.specialty
              : 'Freelancer';
        }
      }

      if (!mounted) return;
      final result = await Navigator.of(context).push(
        Transitions.slideUpTransition(
          ReviewFormScreen(
            contractId: contractId,
            reviewedUserId: reviewedUserId,
            reviewedUserName: reviewedUserName,
            reviewedUserType: reviewedUserType,
          ),
        ),
      );

      if (result != null) {
        await _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        Dialogs.showSimpleDialog(
          context,
          title: 'Calificaciones',
          message: e.toString().replaceFirst('Exception: ', ''),
          color: Style.getErrorColor(),
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _rejectRequest(ServiceRequestModel request) async {
    await _submitAction(() async {
      await _service.updateContractRequestStatus(
        requestId: request.id,
        status: ServiceContractRequestStatus.rejected,
      );

      try {
        await _service.deleteContractRequest(request.id);
      } catch (_) {
        _deleteRetryIds.add(request.id);
      }

      _hiddenRequestIds.add(request.id);
      if (mounted) setState(() {});

      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Solicitud rechazada',
        message: 'La solicitud fue removida del listado.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    });
  }

  Future<void> _cancelRequest(ServiceRequestModel request) async {
    await _submitAction(() async {
      final updated = await _service.updateContractRequestStatus(
        requestId: request.id,
        status: ServiceContractRequestStatus.canceled,
      );

      _replaceRequest(updated.copyWith(status: ServiceContractRequestStatus.canceled));

      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Solicitud cancelada',
        message: 'No se formalizara contrato para esta solicitud.',
        color: Style.getPrimaryColor(),
        icon: Icons.info_outline_rounded,
      );
    });
  }

  Future<void> _submitAction(Future<void> Function() action) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await action();
    } on ServiceFlowException catch (e) {
      await _handleFlowException(e);
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<double?> _resolveContractAmount(ServiceRequestModel request) async {
    final budget = request.budget;
    if (budget != null && budget > 0) return budget;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18.w,
            18.h,
            18.w,
            20.h + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total del contrato',
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Total a contratar',
                    hintText: 'Ej. 1200',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );
                    if (parsed == null || parsed <= 0) {
                      return 'Ingresa un monto valido.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: CustomWidgets.button(
                    onTap: () {
                      final valid = formKey.currentState?.validate() ?? false;
                      if (!valid) return;
                      final parsed = double.tryParse(
                        controller.text.trim().replaceAll(',', '.'),
                      );
                      Navigator.of(context).pop(parsed);
                    },
                    color: Style.getPrimaryColor(),
                    child: Text(
                      'Crear contrato',
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

    return result;
  }

  void _replaceRequest(ServiceRequestModel updated) {
    final index = _requests.indexWhere((item) => item.id == updated.id);
    if (index < 0) {
      _requests = [updated, ..._requests];
    } else {
      final next = List<ServiceRequestModel>.from(_requests);
      next[index] = updated;
      _requests = next;
    }
    if (mounted) setState(() {});
  }

  Future<void> _retryPendingDeletes() async {
    final retryIds = _deleteRetryIds.toList();
    for (final id in retryIds) {
      try {
        await _service.deleteContractRequest(id);
        _deleteRetryIds.remove(id);
      } catch (_) {
        // Se mantiene para siguiente refresco.
      }
    }
  }

  Future<void> _handleFlowException(
    ServiceFlowException e, {
    bool showDialog = true,
  }) async {
    if (!mounted) return;
    if (e.statusCode == 401) {
      if (showDialog) {
        Dialogs.showSimpleDialog(
          context,
          title: 'Sesion expirada',
          message: 'Debes iniciar sesion nuevamente.',
          color: Style.getErrorColor(),
          icon: Icons.lock_outline_rounded,
        );
      }
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        Transitions.slideUpTransition(const LoginScreen()),
        (route) => false,
      );
      return;
    }

    if (!showDialog) return;

    final title = e.statusCode == 403
        ? 'Sin permisos'
        : e.statusCode == 422
        ? 'Validacion'
        : 'Error';
    Dialogs.showSimpleDialog(
      context,
      title: title,
      message: e.message,
      color: Style.getErrorColor(),
      icon: Icons.error_outline_rounded,
    );
  }

  Future<UserModel?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(Constants.userEmailKey);
    if (rawUser == null || rawUser.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
    } catch (_) {}

    return null;
  }

  void _showRequesterProfile(ServiceRequestModel request) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Style.getObscureTextColor().withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28.w,
                    backgroundImage: request.avatarUrl.isNotEmpty
                        ? NetworkImage(request.avatarUrl)
                        : null,
                    backgroundColor: Style.getPrimaryColor().withValues(
                      alpha: .12,
                    ),
                    child: request.avatarUrl.isEmpty
                        ? Icon(
                            Icons.groups_rounded,
                            color: Style.getPrimaryColor(),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requesterName,
                          style: Style.getHeaderTwo(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          request.accountType,
                          style: Style.getTextStyle(
                            color: Style.getPrimaryColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _infoRow(
                MultiLanguages.of(
                      context,
                    )?.translate('services_request_date') ??
                    'Fecha de solicitud',
                DateFormat('dd MMM yyyy, HH:mm').format(request.requestedAt),
              ),
              _infoRow(
                MultiLanguages.of(
                      context,
                    )?.translate('services_account_type') ??
                    'Tipo de cuenta',
                request.accountType,
              ),
              _infoRow('ID', request.requesterId.toString()),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: CustomWidgets.button(
                  onTap: () {
                    Navigator.pop(context);
                    _contactRequester(request);
                  },
                  color: Style.getPrimaryColor(),
                  child: Text(
                    MultiLanguages.of(context)?.translate('contact') ??
                        'Contactar',
                    style: Style.getHeaderThree(
                      color: Style.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalRequests = _visibleRequests.length;
    final pendingRequests = _visibleRequests.where((request) => request.isPending).length;
    final acceptedRequests = _visibleRequests.where((request) => request.isAccepted).length;

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        actions: [
          IconButton(
            onPressed: _loadRequests,
            icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
          ),
        ],
        title: Text(
          _isFreelancer
              ? 'Solicitudes recibidas'
              : 'Mis solicitudes de contratacion',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
            : (widget.serviceId != null && (widget.serviceId ?? 0) > 0 && _serviceModel == null)
          ? Center(
              child: Text(
                MultiLanguages.of(context)?.translate('services_not_found') ??
                    'El servicio no existe.',
                style: Style.getTextStyle(color: Style.getObscureTextColor()),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(Style.horizontalPadding.w),
              children: [
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    gradient: LinearGradient(
                      colors: [
                        Style.getPrimaryColor(),
                        Style.getPrimaryColor().withValues(alpha: .82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Style.getPrimaryColor().withValues(alpha: .18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _serviceModel?.title ??
                            (_isFreelancer
                                ? 'Solicitudes para mis servicios'
                                : 'Seguimiento de solicitudes'),
                        style: Style.getHeaderTwo(
                          color: Style.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _isFreelancer
                            ? 'Revisa, acepta o rechaza solicitudes ligadas a tus servicios.'
                            : 'Consulta el estado de cada solicitud que enviaste.',
                        style: Style.getTextStyle(
                          color: Style.white.withValues(alpha: .88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: _miniStatCard(
                              'Total',
                              totalRequests.toString(),
                              Icons.inbox_rounded,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _miniStatCard(
                              'Pendientes',
                              pendingRequests.toString(),
                              Icons.timelapse_rounded,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _miniStatCard(
                              'Aceptadas',
                              acceptedRequests.toString(),
                              Icons.verified_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                if (_visibleRequests.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: Style.getCardColor(),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 46.w,
                          color: Style.getObscureTextColor().withValues(alpha: .5),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          _isFreelancer
                              ? 'Todavia no hay solicitudes recibidas.'
                              : 'Aun no has enviado solicitudes de contratacion.',
                          textAlign: TextAlign.center,
                          style: Style.getTextStyle(
                            color: Style.getObscureTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._visibleRequests.map(
                    (request) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ServiceRequestCard(
                        request: request,
                        onViewProfile: () => _showRequesterProfile(request),
                        onContact: () => _contactRequester(request),
                        actions: _buildActions(request),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _miniStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Style.white.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Style.white, size: 18.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Style.getHeaderTwo(
              color: Style.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: Style.getTextStyle(
              color: Style.white.withValues(alpha: .86),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(ServiceRequestModel request) {
    if (_submitting) {
      return <Widget>[
        SizedBox(
          width: 18.w,
          height: 18.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Style.getPrimaryColor(),
          ),
        ),
      ];
    }

    if (_isFreelancer) {
      if (request.isPending) {
        return <Widget>[
          ElevatedButton.icon(
            onPressed: () => _acceptRequest(request),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Style.getPrimaryColor(),
              foregroundColor: Style.white,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _rejectRequest(request),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Rechazar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Style.getErrorColor(),
              side: BorderSide(color: Style.getErrorColor()),
            ),
          ),
        ];
      }

      if (request.isAccepted) {
        return <Widget>[
          ElevatedButton.icon(
            onPressed: () => _formalizeAcceptedRequest(request),
            icon: const Icon(Icons.assignment_turned_in_rounded),
            label: const Text('Formalizar contrato'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Style.white,
            ),
          ),
        ];
      }

      if (request.isContracted) {
        return <Widget>[
          ElevatedButton.icon(
            onPressed: () => _openReviewForm(request),
            icon: const Icon(Icons.star_rounded),
            label: const Text('Calificar experiencia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Style.white,
            ),
          ),
        ];
      }
    } else {
      if (request.isPending) {
        return <Widget>[
          OutlinedButton.icon(
            onPressed: () => _cancelRequest(request),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar solicitud'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Style.getErrorColor(),
              side: BorderSide(color: Style.getErrorColor()),
            ),
          ),
        ];
      }
    }

    return const <Widget>[];
  }
}
