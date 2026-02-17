import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/service_controller.dart' hide ServiceStatus;
import '../../widgets/provider_dashboard_cards.dart';

class SubmitServiceScreen extends ConsumerStatefulWidget {
  const SubmitServiceScreen({super.key});

  static const routePath = '/user/submit-service';

  @override
  ConsumerState<SubmitServiceScreen> createState() =>
      _SubmitServiceScreenState();
}

class _SubmitServiceScreenState extends ConsumerState<SubmitServiceScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedPropertyType;
  final List<String> _propertyTypes = [
    'Banquet Hall',
    'Outdoor Lawn',
    'Indoor Auditorium',
    'Rooftop Terrace',
    'Garden/Farmhouse',
    'Hotel Conference Room',
    'Wedding Palace',
    'Other',
  ];

  final List<String> _selectedEventTypes = [];
  final List<String> _eventTypes = [
    'Weddings',
    'Corporate Events',
    'Birthdays',
    'Festivals & Public',
    'Conferences',
    'Exhibitions',
    'Concerts',
  ];

  final List<String> _selectedAmenities = [];
  final List<String> _amenityOptions = [
    'Parking Available',
    'AC',
    'Stage',
    'Catering',
    'WiFi',
    'Projector',
    'Sound System',
    'Generator',
  ];

  String? _selectedSeatingType;
  final List<String> _seatingTypes = [
    'Banquet Style',
    'Theatre Style',
    'Mixed',
    'U-Shape',
  ];

  String? _parkingAvailable;
  String? _cateringAvailable;

  final List<String> _photoUrls = [];
  final TextEditingController _photoUrlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _toggleEventType(String eventType) {
    setState(() {
      if (_selectedEventTypes.contains(eventType)) {
        _selectedEventTypes.remove(eventType);
      } else {
        _selectedEventTypes.add(eventType);
      }
    });
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  void _addPhoto() {
    final url = _photoUrlController.text.trim();
    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.hasAbsolutePath) {
        setState(() {
          _photoUrls.add(url);
          _photoUrlController.clear();
        });
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success =
        await ref.read(serviceControllerProvider.notifier).submitService(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              location: _locationController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              pincode: _pincodeController.text.trim().isEmpty
                  ? null
                  : _pincodeController.text.trim(),
              eventTypes: _selectedEventTypes.isEmpty
                  ? null
                  : _selectedEventTypes.join(', '),
              propertyType: _selectedPropertyType,
              capacity: _capacityController.text.trim().isEmpty
                  ? null
                  : int.tryParse(_capacityController.text.trim()),
              amenities: _selectedAmenities.isEmpty
                  ? null
                  : _selectedAmenities.join(', '),
              photos: _photoUrls.isEmpty ? null : _photoUrls,
              price: double.parse(_priceController.text.trim()),
            );
    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Venue Submitted Successfully!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Our verification team will review and contact you within 24-48 hours.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                    },
                    child: const Text('View Requests'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentStep = 0;
                        _formKey.currentState?.reset();
                        _titleController.clear();
                        _descriptionController.clear();
                        _locationController.clear();
                        _addressController.clear();
                        _pincodeController.clear();
                        _capacityController.clear();
                        _priceController.clear();
                        _photoUrls.clear();
                        _selectedEventTypes.clear();
                        _selectedAmenities.clear();
                        _selectedPropertyType = null;
                        _selectedSeatingType = null;
                        _parkingAvailable = null;
                        _cateringAvailable = null;
                      });
                    },
                    child: const Text('Add Another'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceControllerProvider);
    final isLoading = serviceState.status == ServiceControllerStatus.submitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 0
            ? 'Publish Your Property'
            : 'Step ${_currentStep + 1} of 4'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildProgressStep(0, 'Basic Info'),
                  Expanded(child: _buildProgressLine()),
                  _buildProgressStep(1, 'Location'),
                  Expanded(child: _buildProgressLine()),
                  _buildProgressStep(2, 'Amenities'),
                  Expanded(child: _buildProgressLine()),
                  _buildProgressStep(3, 'Review'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildCurrentStep(serviceState),
                  ),
                ),
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => setState(() => _currentStep--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    )
                  else
                    const SizedBox(),
                  if (_currentStep < 3)
                    FilledButton.icon(
                      onPressed: isLoading ? null : _goToNextStep,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Submit for Verification'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    return GestureDetector(
      onTap: () => setState(() => _currentStep = step),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isActive
                      ? Colors.purple
                      : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white)
                : Center(
                    child: Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Colors.purple : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildCurrentStep(ServiceState serviceState) {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2Location();
      case 2:
        return _buildStep3Amenities();
      case 3:
        return _buildStep4Review(serviceState);
      default:
        return const SizedBox();
    }
  }

  void _goToNextStep() {
    bool isValid = true;
    switch (_currentStep) {
      case 0:
        isValid = _validateStep1();
        break;
      case 1:
        isValid = _validateStep2();
        break;
      case 2:
        isValid = _validateStep3();
        break;
    }
    if (isValid) {
      setState(() => _currentStep++);
    }
  }

  bool _validateStep1() {
    return _titleController.text.trim().isNotEmpty &&
        _selectedPropertyType != null &&
        _selectedEventTypes.isNotEmpty &&
        _descriptionController.text.trim().length >= 30;
  }

  bool _validateStep2() {
    return _locationController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text.trim()) != null;
  }

  bool _validateStep3() {
    return true; // Amenities step is optional
  }

  Widget _buildStep1BasicInfo() {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Details',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about your property',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 24),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTitleField()),
              const SizedBox(width: 16),
              Expanded(child: _buildPropertyTypeField()),
            ],
          )
        else
          Column(
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildPropertyTypeField(),
            ],
          ),
        const SizedBox(height: 16),
        Text(
          'Suitable For Event Types',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _eventTypes.map((eventType) {
            final isSelected = _selectedEventTypes.contains(eventType);
            return FilterChip(
              label: Text(eventType),
              selected: isSelected,
              onSelected: (_) => _toggleEventType(eventType),
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.purple.shade50,
              checkmarkColor: Colors.purple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.purple : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            alignLabelWithHint: true,
            hintText:
                'Describe amenities, facilities, unique features... (min 30 chars)',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          minLines: 4,
          maxLines: 8,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Provide a description';
            }
            if (value.length < 30) {
              return 'Description must be at least 30 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Property/Venue Name',
        prefixIcon: Icon(Icons.business_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter property name';
        }
        return null;
      },
    );
  }

  Widget _buildPropertyTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedPropertyType,
      decoration: const InputDecoration(
        labelText: 'Property Type',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: _propertyTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _selectedPropertyType = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Select property type';
        }
        return null;
      },
    );
  }

  Widget _buildStep2Location() {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location & Pricing',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Where is your venue located?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 24),
        if (isWide)
          Row(
            children: [
              Expanded(child: _buildLocationField()),
              const SizedBox(width: 16),
              Expanded(child: _buildPincodeField()),
            ],
          )
        else
          Column(
            children: [
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildPincodeField(),
            ],
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Complete Address',
            prefixIcon: Icon(Icons.home_outlined),
          ),
          minLines: 2,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        if (isWide)
          Row(
            children: [
              Expanded(child: _buildCapacityField()),
              const SizedBox(width: 16),
              Expanded(child: _buildPriceField()),
            ],
          )
        else
          Column(
            children: [
              _buildCapacityField(),
              const SizedBox(height: 16),
              _buildPriceField(),
            ],
          ),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'City/Location',
        prefixIcon: Icon(Icons.location_city_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter location';
        }
        return null;
      },
    );
  }

  Widget _buildPincodeField() {
    return TextFormField(
      controller: _pincodeController,
      decoration: const InputDecoration(
        labelText: 'Pincode',
        prefixIcon: Icon(Icons.pin_outlined),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildCapacityField() {
    return TextFormField(
      controller: _capacityController,
      decoration: const InputDecoration(
        labelText: 'Capacity (guests)',
        prefixIcon: Icon(Icons.people_outline),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final parsed = int.tryParse(value);
          if (parsed == null || parsed <= 0) {
            return 'Invalid capacity';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Price (₹)',
        prefixIcon: Icon(Icons.currency_rupee_outlined),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter a price';
        }
        final parsed = double.tryParse(value);
        if (parsed == null || parsed <= 0) {
          return 'Enter a valid price';
        }
        return null;
      },
    );
  }

  Widget _buildStep3Amenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities & Media',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'What amenities and features does your venue offer?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Key Amenities',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenityOptions.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (_) => _toggleAmenity(amenity),
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.purple.shade50,
              checkmarkColor: Colors.purple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.purple : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Add Venue Images',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  hintText: 'Enter image URL',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _addPhoto,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_photoUrls.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photoUrls.asMap().entries.map((entry) {
              return Chip(
                label: Text('Image ${entry.key + 1}'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removePhoto(entry.key),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildStep4Review(ServiceState serviceState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Submit',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your details before submitting',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewRow('Venue Name', _titleController.text),
                _buildReviewRow('Property Type', _selectedPropertyType ?? ''),
                _buildReviewRow('Event Types', _selectedEventTypes.join(', ')),
                _buildReviewRow('Description', _descriptionController.text),
                _buildReviewRow('City', _locationController.text),
                if (_pincodeController.text.isNotEmpty)
                  _buildReviewRow('Pincode', _pincodeController.text),
                if (_addressController.text.isNotEmpty)
                  _buildReviewRow('Address', _addressController.text),
                if (_capacityController.text.isNotEmpty)
                  _buildReviewRow('Capacity', _capacityController.text),
                _buildReviewRow('Price', '₹${_priceController.text}'),
                if (_selectedAmenities.isNotEmpty)
                  _buildReviewRow('Amenities', _selectedAmenities.join(', ')),
                if (_photoUrls.isNotEmpty)
                  _buildReviewRow('Images', '${_photoUrls.length} uploaded'),
              ],
            ),
          ),
        ),
        if (serviceState.errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    serviceState.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
