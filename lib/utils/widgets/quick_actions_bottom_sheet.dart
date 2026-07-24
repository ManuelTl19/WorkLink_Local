import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/widgets/dialogs.dart';
// import 'package:worklink_local/modules/clients/components/tasks/task_form_modal.dart';

// import 'package:worklink_local/modules/comercial/components/leads/leads_modal.dart';
// import 'package:worklink_local/modules/general/components/calendar/event_modal.dart';
// import 'package:worklink_local/modules/clients/components/tasks/task_modal.dart';

void showQuickActionsBottomSheet(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return const QuickActions();
    },
  );
}

class QuickActions extends StatefulWidget {
  const QuickActions({super.key});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  bool _canOpenMessages = true;

  @override
  void initState() {
    super.initState();
    _loadMessageAccess();
  }

  Future<void> _loadMessageAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString(Constants.userEmailKey);
      if (userRaw == null || userRaw.isEmpty) return;

      final user = UserModel.fromJson(
        jsonDecode(userRaw) as Map<String, dynamic>,
      );
      if (!_isFreelancerUser(user)) return;
      if (user.id <= 0) {
        if (!mounted) return;
        setState(() => _canOpenMessages = false);
        return;
      }

      final profile = await FreelancersService.getProfileByUserId(user.id);
      if (!mounted) return;
      setState(() {
        _canOpenMessages = profile?.id != null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _canOpenMessages = false);
    }
  }

  bool _isFreelancerUser(UserModel user) {
    final roles = user.roles
        .map((value) => value.toLowerCase().trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final type = user.tipoCuenta.toLowerCase().trim();
    return roles.contains('freelancer') || type == 'freelancer';
  }

  void _showFreelancerProfileRequiredDialog() {
    Dialogs.showSimpleDialog(
      context,
      title:
          MultiLanguages.of(
            context,
          )?.translate('freelancer_profile_required_title') ??
          'Perfil profesional requerido',
      message:
          MultiLanguages.of(
            context,
          )?.translate('freelancer_profile_required_message') ??
          'Primero crea tu perfil profesional para habilitar esta opción.',
      color: Style.getPrimaryColor(),
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      padding: EdgeInsets.only(bottom: 10.h),
      children: [
        card(
          label: 'Mensajes',
          icon: Icons.chat_bubble_rounded,
          color: _canOpenMessages
              ? Style.getSecondaryColor()
              : Style.getObscureTextColor(),
          onTap: () {
            if (!_canOpenMessages) {
              _showFreelancerProfileRequiredDialog();
              return;
            }
            Navigator.pop(context);
            Future.microtask(() {
              if (context.mounted) {
                push(context, const MessagesScreen());
              }
            });
          },
        ),

        card(
          label: MultiLanguages.of(context)!.translate('quick_lead'),
          icon: Icons.person_add_rounded,
          color: Style.getSecondaryColor(),
          onTap: () => showCupertinoModalPopup(
            context: context,
            barrierDismissible: true,
            builder: (context) => Container(
              height: 300,
              color: Colors.white,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('development_screen') ??
                      'Pantalla en desarrollo',
                ),
              ),
            ),
          ),
        ),

        card(
          label: MultiLanguages.of(context)!.translate('quick_event'),
          icon: Icons.calendar_month_rounded,
          color: Style.getSecondaryColor(),
          onTap: () => showCupertinoModalPopup(
            context: context,
            barrierDismissible: true,
            builder: (context) => Container(
              height: 300,
              color: Colors.white,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('development_screen') ??
                      'Pantalla en desarrollo',
                ),
              ),
            ),
          ),
        ),

        card(
          label: MultiLanguages.of(context)!.translate('quick_task'),
          icon: Icons.task_alt_rounded,
          color: Style.getSecondaryColor(),
          onTap: () => showCupertinoModalPopup(
            context: context,
            barrierDismissible: true,
            builder: (context) => Container(
              height: 300,
              color: Colors.white,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('development_screen') ??
                      'Pantalla en desarrollo',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget card({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: Style.getPaddingAll(5),
      child: Card(
        color: Style.getCardColor(),
        elevation: 5,
        shadowColor: Style.getShadowColor(),
        shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
        child: InkWell(
          onTap: onTap,
          borderRadius: Style.getBorderRadius(),
          splashColor: color.withValues(alpha: .2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(height: 5.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Style.getHeaderThree(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
