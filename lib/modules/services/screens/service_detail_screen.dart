import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/modules/services/components/contract_request_form_dialog.dart';
import 'package:worklink_local/modules/services/screens/freelancer_service_profile_screen.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final int serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServicesService _service = ServicesService();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _submittingRequest = false;
  ServiceModel? _serviceModel;
  FreelancerModel? _freelancer;
  UserModel? _currentUser;
  ServiceRequestModel? _currentRequest;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final serviceModel = await _service.getServiceById(widget.serviceId);
    if (serviceModel == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final freelancer = await FreelancersService.getFreelancerById(
      serviceModel.freelancerId,
    );
    final currentUser = await _getCurrentUser();
    ServiceRequestModel? currentRequest;

    if (currentUser != null) {
      try {
        final requests = await _service.getServiceContractRequestsByServiceId(
          widget.serviceId,
        );
        for (final request in requests) {
          if (request.requesterId != currentUser.id) continue;
          if (request.isPending || request.isAccepted || request.isContracted) {
            currentRequest = request;
            break;
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _serviceModel = serviceModel;
      _freelancer = freelancer;
      _currentUser = currentUser;
      _currentRequest = currentRequest;
      _loading = false;
    });
  }

  Future<void> _contactFreelancer() async {
    final freelancer = _freelancer;
    if (freelancer == null) return;

    final chat = await MessageService.getOrCreateChat(
      name: freelancer.fullName,
      avatarSeed: freelancer.fullName,
      subtitle: freelancer.specialty,
      avatarUrl: freelancer.avatarUrl,
      relatedEntityId: freelancer.id,
      relatedEntityType: 'freelancer',
    );

    if (!mounted) return;
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  bool get _canRequestHiring {
    final user = _currentUser;
    if (user == null) return false;
    final roles = user.roles.map((item) => item.toLowerCase().trim()).toList();
    final accountType = user.tipoCuenta.toLowerCase().trim();
    final isFreelancer = roles.contains('freelancer') || accountType == 'freelancer';
    final isAdmin = roles.contains('admin') || roles.contains('administrador');

    if (isAdmin) return true;
    return !isFreelancer;
  }

  Future<void> _openContractRequestForm() async {
    final service = _serviceModel;
    final user = _currentUser;
    if (service == null || user == null) return;

    final payload = await Navigator.of(context).push(
      Transitions.slideUpTransition(
        ContractRequestFormDialog(serviceTitle: service.title),
      ),
    );

    if (payload is! Map<String, dynamic>) return;

    final description = payload['description']?.toString() ?? '';
    final budget = payload['budget'] as double?;

    await _submitContractRequest(
      serviceId: service.id,
      description: description,
      budget: budget,
    );
  }

  Future<void> _submitContractRequest({
    required int serviceId,
    required String description,
    double? budget,
  }) async {
    setState(() => _submittingRequest = true);
    try {
      final request = await _service.requestService(
        serviceId: serviceId,
        description: description,
        budget: budget,
      );

      if (!mounted) return;
      setState(() {
        _currentRequest = request;
      });
      Dialogs.showSimpleDialog(
        context,
        title: 'Solicitud enviada',
        message: 'Tu solicitud de contratacion se creo en estado pending.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
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
      if (mounted) setState(() => _submittingRequest = false);
    }
  }

  Future<void> _cancelCurrentRequest() async {
    final request = _currentRequest;
    if (request == null) return;

    setState(() => _submittingRequest = true);
    try {
      await _service.updateContractRequestStatus(
        requestId: request.id,
        status: ServiceContractRequestStatus.canceled,
      );

      if (!mounted) return;
      setState(() {
        _currentRequest = null;
      });
      Dialogs.showSimpleDialog(
        context,
        title: 'Solicitud cancelada',
        message: 'Ya puedes volver a solicitar este servicio.',
        color: Style.getPrimaryColor(),
        icon: Icons.info_outline_rounded,
      );
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
      if (mounted) setState(() => _submittingRequest = false);
    }
  }

  Future<void> _handleFlowException(ServiceFlowException e) async {
    if (!mounted) return;
    if (e.statusCode == 401) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Sesion expirada',
        message: 'Debes iniciar sesion para continuar.',
        color: Style.getErrorColor(),
        icon: Icons.lock_outline_rounded,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        Transitions.slideUpTransition(const LoginScreen()),
        (route) => false,
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final serviceModel = _serviceModel;
    final currentRequest = _currentRequest;
    final canRequest = _canRequestHiring && serviceModel?.isActive == true;
    final hasActiveRequest = currentRequest != null;
    final requestIsPending = currentRequest?.isPending ?? false;
    final isServiceOwner =
        _freelancer?.userId != null && _freelancer?.userId == _currentUser?.id;
    final canShowFloatingContact =
        !_loading && serviceModel != null && _freelancer != null && !isServiceOwner;

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      floatingActionButton: canShowFloatingContact
          ? FloatingActionButton.extended(
              onPressed: _contactFreelancer,
              backgroundColor: Style.getPrimaryColor(),
              icon: Icon(Icons.chat_bubble_rounded, color: Style.white),
              label: Text(
                MultiLanguages.of(context)?.translate('contact') ?? 'Contactar',
                style: Style.getTextStyle(
                  color: Style.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300.h,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.white),
            ),
            actions: [
              IconButton(
                onPressed: _loadData,
                icon: Icon(Icons.refresh_rounded, color: Style.white),
              ),
            ],
            title: Text(
              MultiLanguages.of(context)?.translate('services_detail_title') ??
                  'Detalle del servicio',
              style: Style.getHeaderTwo(
                color: Style.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _loading
                  ? Center(
                      child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                    )
                  : _hero(),
            ),
          ),
          if (_loading)
            SliverToBoxAdapter(child: SizedBox(height: 24.h))
          else if (_serviceModel == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('services_not_found') ??
                      'El servicio no existe.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  16.h,
                  Style.horizontalPadding.w,
                  12.h,
                ),
                child: Column(
                  children: [
                    if (canRequest)
                      SizedBox(
                        width: double.infinity,
                        child: CustomWidgets.button(
                          onTap: _submittingRequest
                              ? () {}
                              : hasActiveRequest
                              ? requestIsPending
                                    ? _cancelCurrentRequest
                                    : () {}
                              : _openContractRequestForm,
                          color: hasActiveRequest && !requestIsPending
                              ? Style.getObscureTextColor().withValues(alpha: .12)
                              : Style.getCardColor(),
                          isFilled: false,
                          withBorder: true,
                          child: _submittingRequest
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Style.getPrimaryColor(),
                                  ),
                                )
                              : Text(
                                  hasActiveRequest
                                      ? (requestIsPending
                                            ? 'Cancelar solicitud'
                                            : 'Ya solicitado')
                                      : 'Solicitar contratacion',
                                  style: Style.getHeaderThree(
                                    color: hasActiveRequest && !requestIsPending
                                        ? Style.getObscureTextColor()
                                        : Style.getTextColor(),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    if (_canRequestHiring && serviceModel != null && !serviceModel.isActive)
                      Container(
                        width: double.infinity,
                        height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Style.getErrorColor().withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Style.getErrorColor().withValues(alpha: .18),
                          ),
                        ),
                        child: Text(
                          'Servicio inactivo',
                          style: Style.getTextStyle(
                            color: Style.getErrorColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontalPadding.w,
                ),
                child: _infoCard(
                  title:
                      MultiLanguages.of(
                        context,
                      )?.translate('services_full_description') ??
                      'Descripción completa',
                  child: Text(
                    _serviceModel!.description,
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                    ).copyWith(height: 1.5),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _infoCard(
                  title:
                      MultiLanguages.of(
                        context,
                      )?.translate('services_information') ??
                      'Información del servicio',
                  child: Column(
                    children: [
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_category') ??
                            'Categoría',
                        _serviceModel!.category,
                      ),
                      _detailRow(
                        MultiLanguages.of(context)?.translate('location') ??
                            'Ubicación',
                        _serviceModel!.location.isEmpty
                            ? (MultiLanguages.of(
                                    context,
                                  )?.translate('not_specified') ??
                                  'No especificada')
                            : _serviceModel!.location,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_price') ??
                            'Precio',
                        _serviceModel!.priceLabel,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_modality') ??
                            'Modalidad',
                        _serviceModel!.modality.label,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_estimated_time') ??
                            'Tiempo estimado',
                        _serviceModel!.estimatedTime,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_rating') ??
                            'Calificación',
                        _serviceModel!.averageRating.toStringAsFixed(1),
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_published') ??
                            'Publicado',
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(_serviceModel!.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _galleryCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _freelancerCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: canShowFloatingContact ? 96.h : 20.h),
            ),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    final serviceModel = _serviceModel!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: serviceModel.mainImageUrl,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Style.transparent,
                Style.black.withValues(alpha: .42),
                Style.getBackgroundColor().withValues(alpha: .96),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceModel.title,
                  style: Style.getHeaderTwo(
                    color: Style.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _pill(serviceModel.category),
                    _pill(serviceModel.priceLabel),
                    _pill(serviceModel.modality.label),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _galleryCard() {
    final serviceModel = _serviceModel!;
    return _infoCard(
      title: MultiLanguages.of(context)?.translate('gallery') ?? 'Galería',
      child: SizedBox(
        height: 150.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: serviceModel.galleryImages.isEmpty
              ? 1
              : serviceModel.galleryImages.length,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (context, index) {
            final image = serviceModel.galleryImages.isEmpty
                ? serviceModel.mainImageUrl
                : serviceModel.galleryImages[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: SizedBox(
                width: 220.w,
                child: CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _freelancerCard() {
    final freelancer = _freelancer!;
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.of(context).push(
            Transitions.slideUpTransition(
              FreelancerServiceProfileScreen(freelancerId: freelancer.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.w,
                backgroundImage: NetworkImage(freelancer.avatarUrl),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.fullName,
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      freelancer.specialty,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      freelancer.shortDescription ?? freelancer.description,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                      ).copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Style.getObscureTextColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Style.getHeaderThree(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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

  Widget _pill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Style.white.withValues(alpha: .22)),
      ),
      child: Text(
        label,
        style: Style.getTextStyle(
          color: Style.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
