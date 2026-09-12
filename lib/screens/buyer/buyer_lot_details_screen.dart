import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'make_offer_screen.dart';

class BuyerLotDetailsScreen extends StatelessWidget {
  final String lotId;
  final String crop;
  final String quantity;
  final String quality;
  final String askingPrice;
  final String location;
  final dynamic distance;

  const BuyerLotDetailsScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.askingPrice,
    required this.location,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void navigateToMakeOffer() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MakeOfferScreen(
            lotId: lotId,
            crop: crop,
            quantity: quantity,
            askingPrice: askingPrice,
            location: location,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('lot_details_title')),
        actions: const [
          Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  crop,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  context.tr('status_active'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 24,
                            color: AppColors.outlineVariant,
                          ),
                          _DetailRow(
                            icon: Icons.tag_rounded,
                            label: context.tr('lot_id_label'),
                            value: lotId,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.scale_rounded,
                            label: context.tr('available_quantity'),
                            value: quantity,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.currency_rupee_rounded,
                            label: context.tr('asking_price'),
                            value: askingPrice,
                            isBold: true,
                            valueColor: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.verified_outlined,
                            label: context.tr('quality_grade'),
                            value: quality,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: context.tr('produce_location'),
                            value: location,
                          ),
                          // Distance is not known for every lot; skip the row
                          // instead of showing a blank value.
                          if ((distance?.toString() ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.route_rounded,
                              label: context.tr('lot_distance'),
                              value: distance!.toString(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: navigateToMakeOffer,
                  child: Text(
                    context.tr('make_an_offer'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.outline,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}