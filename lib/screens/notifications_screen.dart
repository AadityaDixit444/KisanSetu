import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // Notification 1: New Buyer Offer
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'New Buyer Offer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Kisan Agro Flour Mills offered ₹2,470/qtl for your Wheat lot.\n10 min ago',
                ),
                isThreeLine: true,
              ),
            ),
            SizedBox(height: 8),

            // Notification 2: Market Alert
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.tertiaryContainer,
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.tertiary,
                  ),
                ),
                title: Text(
                  'Market Alert',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Wheat prices increased by 3.4% today in Meerut.\n1 hour ago',
                ),
                isThreeLine: true,
              ),
            ),
            SizedBox(height: 8),

            // Notification 3: Offer Update
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text(
                  'Offer Update',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Your offer for Wheat 150 qtl was accepted.\n3 hours ago',
                ),
                isThreeLine: true,
              ),
            ),
            SizedBox(height: 8),

            // Notification 4: Logistics Update
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Logistics Update',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Transport has been arranged for your Wheat shipment.\nYesterday',
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