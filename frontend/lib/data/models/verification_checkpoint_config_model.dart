import '../../domain/entities/verification_checkpoint_config.dart';

class VerificationCheckpointConfigModel extends VerificationCheckpointConfigEntity {
  const VerificationCheckpointConfigModel({
    required super.id,
    required super.checkpointKey,
    required super.label,
    required super.checkpointType,
    super.description,
    super.isRequired,
    super.isEnabled,
    super.displayOrder,
    super.validation,
    super.options,
    super.placeholder,
    super.hint,
    super.category,
    super.createdAt,
    super.updatedAt,
  });

  factory VerificationCheckpointConfigModel.fromJson(Map<String, dynamic> json) {
    return VerificationCheckpointConfigModel(
      id: json['_id'] ?? json['id'] ?? '',
      checkpointKey: json['checkpointKey'] ?? '',
      label: json['label'] ?? '',
      checkpointType: CheckpointType.fromString(json['checkpointType'] ?? 'text'),
      description: json['description'],
      isRequired: json['isRequired'] ?? true,
      isEnabled: json['isEnabled'] ?? true,
      displayOrder: json['displayOrder'] ?? 0,
      validation: json['validation'] != null
          ? Map<String, dynamic>.from(json['validation'])
          : null,
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      placeholder: json['placeholder'],
      hint: json['hint'],
      category: json['category'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkpointKey': checkpointKey,
      'label': label,
      'checkpointType': checkpointType.value,
      if (description != null) 'description': description,
      'isRequired': isRequired,
      'isEnabled': isEnabled,
      'displayOrder': displayOrder,
      if (validation != null) 'validation': validation,
      if (options != null) 'options': options,
      if (placeholder != null) 'placeholder': placeholder,
      if (hint != null) 'hint': hint,
      if (category != null) 'category': category,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

