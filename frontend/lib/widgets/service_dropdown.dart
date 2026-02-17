import 'package:flutter/material.dart';

const servicesList = [
  'Wedding Planning',
  'Catering',
  'Decoration & Theme',
  'Photography & Videography',
  'Venue Booking',
  'Corporate Event Setup',
  'Birthday Party Setup',
  'Lighting & Sound',
  'Entertainment / DJ',
  'Security & Staffing',
];

class ServiceDropdown extends StatefulWidget {
  const ServiceDropdown({super.key, this.onChanged, this.initialValue});

  final ValueChanged<String?>? onChanged;
  final String? initialValue;

  @override
  State<ServiceDropdown> createState() => _ServiceDropdownState();
}

class _ServiceDropdownState extends State<ServiceDropdown> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'Poppins',
      color: const Color(0xFF2C2C2C),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a service for your event',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC6A056), width: 1.4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selected,
                hint: Text(
                  'Select a Service',
                  style: textStyle?.copyWith(color: Colors.black45),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFC6A056)),
                style: textStyle,
                isExpanded: true,
                borderRadius: BorderRadius.circular(18),
                items: servicesList
                    .map(
                      (service) => DropdownMenuItem<String>(
                        value: service,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(service),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selected = value);
                  widget.onChanged?.call(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selected == null
                ? 'Selected Service: None'
                : 'Selected Service: $_selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Poppins',
              color: const Color(0xFF2C2C2C).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
