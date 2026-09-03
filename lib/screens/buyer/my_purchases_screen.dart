import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MyPurchasesScreen extends StatelessWidget {
  const MyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
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
                    'Active & Past Purchases',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '3 orders',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Purchase 1: In Transit
            const Card(
              child: ListTile(
                title: Text(
                  'Wheat — 100 qtl',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Farmer Location: Meerut\nAgreed Price: ₹2,450/qtl\nTotal Value: ₹2,45,000',
                ),
                trailing: Text(
                  'In Transit',
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
            const Card(
              child: ListTile(
                title: Text(
                  'Wheat — 150 qtl',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Farmer Location: Muzaffarnagar\nAgreed Price: ₹2,460/qtl\nTotal Value: ₹3,69,000',
                ),
                trailing: Text(
                  'Delivered',
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
            const Card(
              child: ListTile(
                title: Text(
                  'Rice — 80 qtl',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Farmer Location: Hapur\nAgreed Price: ₹3,050/qtl\nTotal Value: ₹2,44,000',
                ),
                trailing: Text(
                  'Payment Pending',
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