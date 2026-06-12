import 'package:flutter/cupertino.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
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
          color: Style.getSecondaryColor(),
          onTap: () {
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
              child: const Center(child: Text('Pantalla en desarrollo')),
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
              child: const Center(child: Text('Pantalla en desarrollo')),
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
              child: const Center(child: Text('Pantalla en desarrollo')),
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
    required Function onTap,
  }) {
    return Padding(
      padding: Style.getPaddingAll(5),
      child: Card(
        color: Style.getCardColor(),
        elevation: 5,
        shadowColor: Style.getShadowColor(),
        shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
        child: InkWell(
          onTap: () => onTap(),
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
