import 'package:flutter/material.dart';
import '../localization/language_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notifications_title')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageToggleButton(isLightSurface: false),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notification 1: New Buyer Offer
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  context.tr('notif_buyer_offer_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('notif_buyer_offer_desc'),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 8),

            // Notification 2: Market Alert
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.tertiaryContainer,
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.tertiary,
                  ),
                ),
                title: Text(
                  context.tr('notif_market_alert_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('notif_market_alert_desc'),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 8),

            // Notification 3: Offer Update
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text(
                  context.tr('notif_offer_update_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('notif_offer_update_desc'),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 8),

            // Notification 4: Logistics Update
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  context.tr('notif_logistics_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('notif_logistics_desc'),
                ),
                isThreeLine: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}