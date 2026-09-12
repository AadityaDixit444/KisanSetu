import 'package:flutter/material.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';

class CreateLotScreen extends StatefulWidget {
  const CreateLotScreen({super.key});

  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final LotService _lotService = LotService();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _askingPriceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCrop = 'Wheat';
  String _selectedQuality = 'Grade A';
  bool _isSubmitting = false;

  final List<String> _cropOptions = const [
    'Wheat',
    'Rice (Basmati)',
    'Mustard',
    'Sugarcane',
    'Potato',
    'Tomato',
    'Onion',
    'Maize',
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
    _askingPriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitLot() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final askingPrice = double.tryParse(_askingPriceController.text.trim()) ?? 0.0;
    final location = _locationController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _lotService.createLot(
        crop: _selectedCrop,
        quantity: quantity,
        askingPrice: askingPrice,
        location: location,
        quality: _selectedQuality,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produce lot listed successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create lot: ${e.toString().replaceAll('Exception: ', '')}'),
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
        title: const Text('List Produce Lot'),
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
                              'Harvested Lot Details',
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
                                return DropdownMenuItem(
                                  value: crop,
                                  child: Text(crop),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCrop = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Available Volume (Quintals)',
                                prefixIcon: Icon(Icons.scale_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter lot volume';
                                }
                                final parsed = double.tryParse(val.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'Volume must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedQuality,
                              decoration: const InputDecoration(
                                labelText: 'Quality Grade Standard',
                                prefixIcon: Icon(Icons.verified_outlined),
                              ),
                              items: _qualityOptions.map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedQuality = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _askingPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Farmer Asking Rate (₹/Quintal)',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter asking price';
                                }
                                final parsed = double.tryParse(val.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'Asking price must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Farm Warehouse / Village Depot',
                                prefixIcon: Icon(Icons.location_on_outlined),
                                hintText: 'e.g., Farm Warehouse, Daurala',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter pickup location';
                                }
                                return null;
                              },
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
                    onPressed: _isSubmitting ? null : _submitLot,
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
                            'Confirm & List Produce Lot',
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
      ),
    );
  }
}