import '../../domain/entities/form_field_config.dart';

class FormFieldConfigModel extends FormFieldConfigEntity {
  const FormFieldConfigModel({
    required super.id,
    required super.fieldKey,
    required super.label,
    required super.fieldType,
    required super.isRequired,
    required super.isEnabled,
    required super.displayOrder,
    super.validation,
    super.options,
    super.placeholder,
    super.hint,
    super.step,
    super.createdAt,
    super.updatedAt,
  });

  factory FormFieldConfigModel.fromJson(Map<String, dynamic> json) {
    FieldType fieldType;
    final fieldTypeStr = json['fieldType']?.toString().toLowerCase();
    switch (fieldTypeStr) {
      case 'text':
        fieldType = FieldType.text;
        break;
      case 'textarea':
        fieldType = FieldType.textarea;
        break;
      case 'number':
        fieldType = FieldType.number;
        break;
      case 'dropdown':
        fieldType = FieldType.dropdown;
        break;
      case 'multiselect':
        fieldType = FieldType.multiselect;
        break;
      case 'url':
        fieldType = FieldType.url;
        break;
      case 'pincode':
        fieldType = FieldType.pincode;
        break;
      default:
        fieldType = FieldType.text;
    }

    List<String>? options;
    if (json['options'] != null) {
      if (json['options'] is List) {
        options = (json['options'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    Map<String, dynamic>? validation;
    if (json['validation'] != null) {
      if (json['validation'] is Map) {
        validation = Map<String, dynamic>.from(json['validation']);
      }
    }

    return FormFieldConfigModel(
      id: json['id']?.toString() ?? '',
      fieldKey: json['fieldKey']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fieldType: fieldType,
      isRequired: json['isRequired'] == true,
      isEnabled: json['isEnabled'] == true,
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : 0,
      validation: validation,
      options: options,
      placeholder: json['placeholder']?.toString(),
      hint: json['hint']?.toString(),
      step: json['step']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fieldKey': fieldKey,
        'label': label,
        'fieldType': fieldType.name,
        'isRequired': isRequired,
        'isEnabled': isEnabled,
        'displayOrder': displayOrder,
        'validation': validation,
        'options': options,
        'placeholder': placeholder,
        'hint': hint,
        'step': step,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

