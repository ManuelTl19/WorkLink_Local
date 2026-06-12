// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';


import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
class CollaboratorService {
  static Map<String, dynamic> allData = [] as Map<String, dynamic>;

  static Future<void> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    // Simula un retraso de red
    await Future.delayed(const Duration(seconds: 1));

    // Valida credenciales simuladas
    if (email == 'example@gmail.com' && password == 'admin') {
      AppSettings.isSignedIn = true;
      AppSettings.loginDate = DateTime.now().toString();

      Dialogs.showSimpleDialog(
        context,
        title:
            '${MultiLanguages.of(context)!.translate('login_success_title')} ${"Manu"}!',
        message: MultiLanguages.of(context)!.translate('login_success_message'),
        color: Style.getPrimaryColor(),
        svg: Assets.svgCheckIcon,
        duration: 2000,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        push(context, const DashboardScreen(), replace: true);
      }
    } else {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('login_error_title'),
        message: MultiLanguages.of(context)!.translate('login_wrong_password'),
        color: Style.getErrorColor(),
        svg: Assets.svgErrorIcon,
      );
    }
  }
}
