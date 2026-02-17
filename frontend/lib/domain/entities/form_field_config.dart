import 'package:equatable/equatable.dart';

enum FieldType {
  text,
  textarea,
  number,
  dropdown,
  multiselect,
  url,
  pincode,
}

class FormFieldConfigEntity extends Equatable {
  const FormFieldConfigEntity({
    required this.id,
    required this.fieldKey,
    required this.label,
    required this.fieldType,
    required this.isRequired,
    required this.isEnabled,
    required this.displayOrder,
    this.validation,
    this.options,
    this.placeholder,
    this.hint,
    this.step,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String fieldKey;
  final String label;
  final FieldType fieldType;
  final bool isRequired;
  final bool isEnabled;
  final int displayOrder;
  final Map<String, dynamic>? validation;
  final List<String>? options;
  final String? placeholder;
  final String? hint;
  final String? step; // basic_info, location, amenities, review
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        fieldKey,
        label,
        fieldType,
        isRequired,
        isEnabled,
        displayOrder,
        validation,
        options,
        placeholder,
        hint,
        step,
        createdAt,
        updatedAt,
      ];
}

