import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'buyer_dashboard.dart';
import 'my_offers_screen.dart';

class OfferSubmittedScreen extends StatelessWidget {

  /// '40' or '40 qtl' -> '40 qtl'
  static String _formatQuantity(String value) {
    final qty = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final text = qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
    return '$text qtl';
  }

  /// '2450' or '₹2,450/qtl' -> '₹2,450/qtl'
  static String _formatPrice(String value) {
    final price =
        double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final whole =
        price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
    final grouped = whole.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
      (m) => '${m[1]},',
    );
    return '₹$grouped/qtl';
  }

  /// 'LOT-50D956F8' from a lot UUID, matching the My Lots screen.
  static String _shortLotId(String rawId) {
    if (rawId.isEmpty) return 'LOT-N/A';
    final id = rawId.replaceAll('-', '');
    if (id.length >= 8) return 'LOT-${id.substring(0, 8).toUpperCase()}';
    return 'LOT-${id.toUpperCase()}';
  }

  final String lotId;
  final String crop;
  final String quantity;
  final String offerPrice;
  final String location;
  final String askingPrice;

  const OfferSubmittedScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.offerPrice,
    required this.location,
    required this.askingPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BuyerDashboard()),
          (route) => false,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    LanguageToggleButton(isLightSurface: true),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('offer_submitted_title'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('offer_submitted_desc'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              crop,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // A full lot UUID does not fit next to the crop
                            // name; show the short form used on My Lots.
                            Flexible(
                              child: Text(
                                context.trWithArgs(
                                  'lot_id_prefix',
                                  {'id': _shortLotId(lotId)},
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.outlineVariant),
                        _SummaryRow(
                          label: context.tr('lot_quantity'),
                          value: _formatQuantity(quantity),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: context.tr('offered_price_label'),
                          value: _formatPrice(offerPrice),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: context.tr('mandi_location_label'),
                          value: location,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyOffersScreen()),
                    );
                  },
                  child: Text(context.tr('view_my_offers_btn')),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const BuyerDashboard()),
                      (route) => false,
                    );
                  },
                  child: Text(context.tr('back_to_dashboard_btn')),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}