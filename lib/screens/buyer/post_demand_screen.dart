import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PostDemandScreen extends StatefulWidget {
  const PostDemandScreen({super.key});

  @override
  State<PostDemandScreen> createState() => _PostDemandScreenState();
}

class _PostDemandScreenState extends State<PostDemandScreen> {
  final _cropController = TextEditingController();
  final _quantityController = TextEditingController();
  final _qualityController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _locationController = TextEditingController();
  final _requiredByController = TextEditingController();

  @override
  void dispose() {
    _cropController.dispose();
    _quantityController.dispose();
    _qualityController.dispose();
    _targetPriceController.dispose();
    _locationController.dispose();
    _requiredByController.dispose();
    super.dispose();
  }

  void _onPostDemand() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demand posted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Demand'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell Farmers What You Need',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Post your crop requirements to connect directly with farmers ready to supply.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cropController,
              decoration: const InputDecoration(
                labelText: 'Crop',
                hintText: 'e.g. Wheat, Rice',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.eco_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity (qtl)',
                hintText: 'e.g. 100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _qualityController,
              decoration: const InputDecoration(
                labelText: 'Quality',
                hintText: 'e.g. Good Quality, Premium Grade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _targetPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Price (₹/qtl)',
                hintText: 'e.g. 2450',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Delivery Location',
                hintText: 'e.g. Meerut Mandi, Uttar Pradesh',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _requiredByController,
              decoration: const InputDecoration(
                labelText: 'Required By',
                hintText: 'e.g. Within 7 days, 15 Sep 2026',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onPostDemand,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Post Demand',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}