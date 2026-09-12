import 'package:flutter/material.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/voice_text_field.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';

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
        SnackBar(
          content: Text(context.tr('produce_lot_listed_success')),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trWithArgs('failed_create_lot', {'error': e.toString().replaceAll('Exception: ', '')})),
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
        title: Text(context.tr('list_produce_lot_title')),
        actions: const [
          Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
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
                              context.tr('harvested_lot_details'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24, color: AppColors.outlineVariant),
                            DropdownButtonFormField<String>(
                              value: _selectedCrop,
                              decoration: InputDecoration(
                                labelText: context.tr('commodity_crop'),
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
                              decoration: InputDecoration(
                                labelText: context.tr('available_volume_quintals'),
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
                              value: _selectedQuality,
                              decoration: InputDecoration(
                                labelText: context.tr('quality_grade_standard'),
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
                              decoration: InputDecoration(
                                labelText: context.tr('farmer_asking_rate'),
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
                            // Mic button: speak the location (Hindi or English)
                            VoiceTextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: context.tr('farm_warehouse_depot'),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                hintText: context.tr('hint_farm_warehouse'),
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
                        : Text(
                            context.tr('confirm_and_list_produce'),
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