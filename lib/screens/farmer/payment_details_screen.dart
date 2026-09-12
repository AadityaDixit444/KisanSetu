import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';

class PaymentDetailsScreen extends StatelessWidget {
  /// Values of the deal this screen is showing. They come from the
  /// transaction row, so the screen no longer displays sample figures.
  final String transactionId;
  final String buyerName;
  final String crop;
  final String quantity;
  final String agreedPrice;
  final String grossValue;
  final String transportCost;
  final String finalPayable;

  /// Dispatch status of the transaction ('pickup_scheduled', 'in_transit',
  /// 'delivered', 'completed'…). Drives the timeline below.
  final String dispatchStatus;

  const PaymentDetailsScreen({
    super.key,
    required this.transactionId,
    required this.buyerName,
    required this.crop,
    required this.quantity,
    required this.agreedPrice,
    required this.grossValue,
    this.transportCost = '',
    required this.finalPayable,
    this.dispatchStatus = '',
  });

  bool get _isDelivered {
    final status = dispatchStatus.toLowerCase().trim();
    return status == 'delivered' || status == 'completed' || status == 'paid';
  }

  bool get _isPaid => dispatchStatus.toLowerCase().trim() == 'paid';

  /// 'KS-TXN-FE840AEF' from a transaction UUID.
  String get _referenceId {
    final id = transactionId.replaceAll('-', '');
    if (id.isEmpty) return 'KS-TXN';
    return 'KS-TXN-${id.substring(0, id.length < 8 ? id.length : 8).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('payment_details_title')),
        actions: const [
          Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Status Card
            Card(
              color: AppColors.warning.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('status_payment_pending'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('expected_within_24h'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settlement Breakdown Card
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
                          context.tr('payment_breakdown'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Text(
                            _referenceId,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PaymentItemRow(
                      label: context.tr('role_buyer'),
                      value: buyerName,
                    ),
                    const SizedBox(height: 8),
                    _PaymentItemRow(
                      label: context.tr('payment_produce'),
                      value: '$crop • $quantity',
                    ),
                    const SizedBox(height: 8),
                    _PaymentItemRow(
                      label: context.tr('payment_agreed_price'),
                      value: agreedPrice,
                    ),
                    const SizedBox(height: 8),
                    _PaymentItemRow(
                      label: context.tr('payment_gross_sale_value'),
                      value: grossValue,
                    ),
                    const SizedBox(height: 8),
                    _PaymentItemRow(
                      label: context.tr('payment_transport_cost'),
                      value: transportCost.isEmpty
                          ? context.tr('payment_transport_pending')
                          : '-$transportCost',
                      isDeduction: transportCost.isNotEmpty,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('final_payable_amount'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            finalPayable,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PaymentItemRow(
                      label: context.tr('payment_method_label'),
                      value: context.tr('payment_method_bank_transfer'),
                    ),
                  ],
                ),
              ),
            ),

            // Payment Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('payment_timeline'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TimelineTile(
                      stepNumber: 1,
                      title: context.tr('payment_step_delivery_verified'),
                      isCompleted: _isDelivered,
                      isLast: false,
                    ),
                    _TimelineTile(
                      stepNumber: 2,
                      title: context.tr('payment_step_initiated'),
                      isCompleted: _isDelivered,
                      isLast: false,
                    ),
                    _TimelineTile(
                      stepNumber: 3,
                      title: context.tr('payment_step_received'),
                      isCompleted: _isPaid,
                      isLast: true,
                    ),
                    if (!_isDelivered) ...[
                      const SizedBox(height: 12),
                      Text(
                        context.tr('payment_awaiting_delivery'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Note Card
            Card(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('payment_auto_update_desc'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PaymentItemRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDeduction;

  const _PaymentItemRow({
    required this.label,
    required this.value,
    this.isDeduction = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDeduction ? AppColors.error : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;
  final bool isLast;

  const _TimelineTile({
    required this.stepNumber,
    required this.title,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCompleted
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.6),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.onPrimary,
                    )
                  : Text(
                      '$stepNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: isCompleted ? AppColors.onSurface : AppColors.outline,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryContainer
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCompleted
                      ? context.tr('status_completed')
                      : context.tr('status_pending'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? AppColors.onPrimaryContainer
                        : AppColors.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}