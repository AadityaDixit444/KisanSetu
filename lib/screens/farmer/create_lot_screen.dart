import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CreateLotScreen extends StatefulWidget {
  const CreateLotScreen({super.key});

  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _cropOptions = const ['Wheat', 'Rice', 'Maize'];
  final List<String> _qualityOptions = const ['Good Quality', 'Premium Quality'];

  String? _selectedCrop = 'Wheat';
  String? _selectedQuality = 'Good Quality';

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: 'Meerut');
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _availableFromDate = DateTime.now();

  @override
  void dispose() {
    _quantityController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAvailableDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _availableFromDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 120)),
    );

    if (pickedDate != null) {
      setState(() {
        _availableFromDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _onCreateLot() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot created successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Lot'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produce Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCrop,
                          decoration: const InputDecoration(
                            labelText: 'Crop',
                            prefixIcon: Icon(Icons.eco_rounded, color: AppColors.primary),
                          ),
                          items: _cropOptions.map((crop) {
                            return DropdownMenuItem<String>(
                              value: crop,
                              child: Text(crop),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCrop = value;
                            });
                          },
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please select a crop' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            hintText: 'e.g. 100',
                            suffixText: 'qtl',
                            prefixIcon: Icon(Icons.scale_rounded, color: AppColors.primary),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter crop quantity';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid quantity';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedQuality,
                          decoration: const InputDecoration(
                            labelText: 'Quality Grade',
                            prefixIcon: Icon(Icons.verified_outlined, color: AppColors.primary),
                          ),
                          items: _qualityOptions.map((quality) {
                            return DropdownMenuItem<String>(
                              value: quality,
                              child: Text(quality),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedQuality = value;
                            });
                          },
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please select quality grade' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pricing & Availability',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            hintText: 'Enter mandi or village location',
                            prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Please enter location' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Minimum Expected Price',
                            hintText: 'e.g. 2400',
                            suffixText: '₹/qtl',
                            prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter minimum price';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _pickAvailableDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Available From',
                              prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                              suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                            ),
                            child: Text(
                              _availableFromDate != null
                                  ? _formatDate(_availableFromDate!)
                                  : 'Select date',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Additional Notes',
                            hintText: 'Moisture level, packaging, or mandi dispatch terms (optional)',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _onCreateLot,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Create Lot'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}