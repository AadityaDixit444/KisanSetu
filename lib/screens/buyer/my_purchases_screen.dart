import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';

class MyPurchasesScreen extends StatelessWidget {
  const MyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('my_purchases_title')),
        actions: const [
          Center(child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Purchases Count Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('active_past_purchases'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.trWithArgs('orders_count', {'count': '3'}),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Purchase 1: In Transit
            Card(
              child: ListTile(
                title: Text(
                  '${context.tr("crop_wheat")} — 100 qtl',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('purchase_sub_1'),
                ),
                trailing: Text(
                  context.tr('status_in_transit'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 8),

            // Purchase 2: Delivered
            Card(
              child: ListTile(
                title: Text(
                  '${context.tr("crop_wheat")} — 150 qtl',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('purchase_sub_2'),
                ),
                trailing: Text(
                  context.tr('status_delivered'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 8),

            // Purchase 3: Payment Pending
            Card(
              child: ListTile(
                title: Text(
                  '${context.tr("crop_rice")} — 80 qtl',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.tr('purchase_sub_3'),
                ),
                trailing: Text(
                  context.tr('status_payment_pending'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
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