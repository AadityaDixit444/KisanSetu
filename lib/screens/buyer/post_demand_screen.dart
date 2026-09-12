import 'package:flutter/material.dart';
import '../../services/demand_service.dart';
import '../../theme/app_colors.dart';

class PostDemandScreen extends StatefulWidget {
  const PostDemandScreen({super.key});

  @override
  State<PostDemandScreen> createState() => _PostDemandScreenState();
}

class _PostDemandScreenState extends State<PostDemandScreen> {
  final _formKey = GlobalKey<FormState>();
  final DemandService _demandService = DemandService();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _targetPriceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCrop = 'Wheat';
  String _selectedQuality = 'Grade A';
  DateTime? _selectedRequiredBy;
  bool _isSubmitting = false;

  final List<String> _cropOptions = const [
    'Wheat',
    'Basmati Rice',
    'Mustard',
    'Chana (Gram)',
    'Maize',
    'Soybean',
  ];

  final List<String> _qualityOptions = const [
    'Grade A',
    'Grade B',
    'Standard',
    'Fair Average Quality (FAQ)',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _targetPriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedRequiredBy ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedRequiredBy = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _submitDemand() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final targetPrice = double.tryParse(_targetPriceController.text.trim()) ?? 0.0;
    final location = _locationController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _demandService.createDemand(
        crop: _selectedCrop,
        quantity: quantity,
        quality: _selectedQuality,
        targetPrice: targetPrice,
        location: location,
        requiredBy: _selectedRequiredBy,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase demand broadcasted successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post demand: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Commodity Demand'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Procurement Requirements',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24, color: AppColors.outlineVariant),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCrop,
                              decoration: const InputDecoration(
                                labelText: 'Commodity Crop',
                                prefixIcon: Icon(Icons.agriculture_rounded),
                              ),
                              items: _cropOptions.map((crop) {
                                return DropdownMenuItem(value: crop, child: Text(crop));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCrop = val);
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Required Volume (Quintals)',
                                prefixIcon: Icon(Icons.scale_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter quantity';
                                final parsed = double.tryParse(val.trim());
                                if (parsed == null || parsed <= 0) return 'Must be greater than 0';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedQuality,
                              decoration: const InputDecoration(
                                labelText: 'Target Quality Standard',
                                prefixIcon: Icon(Icons.verified_outlined),
                              ),
                              items: _qualityOptions.map((q) {
                                return DropdownMenuItem(value: q, child: Text(q));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedQuality = val);
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _targetPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Target Buying Price (₹/Quintal)',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter target price';
                                final parsed = double.tryParse(val.trim());
                                if (parsed == null || parsed <= 0) return 'Must be greater than 0';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Delivery Location / Depot',
                                prefixIcon: Icon(Icons.location_on_outlined),
                                hintText: 'e.g., Meerut Depot, Partapur',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter delivery location';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Required By Date',
                                  prefixIcon: Icon(Icons.calendar_today_outlined),
                                ),
                                child: Text(
                                  _selectedRequiredBy == null
                                      ? 'Select required-by date (optional)'
                                      : _formatDate(_selectedRequiredBy!),
                                  style: TextStyle(
                                    color: _selectedRequiredBy == null
                                        ? AppColors.onSurfaceVariant
                                        : AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
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
                    top: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitDemand,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text(
                            'Broadcast Demand',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}