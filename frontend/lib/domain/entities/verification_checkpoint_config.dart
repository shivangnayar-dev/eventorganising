import 'package:equatable/equatable.dart';

enum CheckpointType {
  boolean,
  text,
  textarea,
  rating,
  image,
  video,
  multiImage,
  dropdown,
  number;

  static CheckpointType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'boolean':
        return CheckpointType.boolean;
      case 'text':
        return CheckpointType.text;
      case 'textarea':
        return CheckpointType.textarea;
      case 'rating':
        return CheckpointType.rating;
      case 'image':
        return CheckpointType.image;
      case 'video':
        return CheckpointType.video;
      case 'multi_image':
        return CheckpointType.multiImage;
      case 'dropdown':
        return CheckpointType.dropdown;
      case 'number':
        return CheckpointType.number;
      default:
        return CheckpointType.text;
    }
  }

  String get value {
    switch (this) {
      case CheckpointType.boolean:
        return 'boolean';
      case CheckpointType.text:
        return 'text';
      case CheckpointType.textarea:
        return 'textarea';
      case CheckpointType.rating:
        return 'rating';
      case CheckpointType.image:
        return 'image';
      case CheckpointType.video:
        return 'video';
      case CheckpointType.multiImage:
        return 'multi_image';
      case CheckpointType.dropdown:
        return 'dropdown';
      case CheckpointType.number:
        return 'number';
    }
  }
}

class VerificationCheckpointConfigEntity extends Equatable {
  final String id;
  final String checkpointKey;
  final String label;
  final CheckpointType checkpointType;
  final String? description;
  final bool isRequired;
  final bool isEnabled;
  final int displayOrder;
  final Map<String, dynamic>? validation;
  final List<String>? options;
  final String? placeholder;
  final String? hint;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VerificationCheckpointConfigEntity({
    required this.id,
    required this.checkpointKey,
    required this.label,
    required this.checkpointType,
    this.description,
    this.isRequired = true,
    this.isEnabled = true,
    this.displayOrder = 0,
    this.validation,
    this.options,
    this.placeholder,
    this.hint,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        checkpointKey,
        label,
        checkpointType,
        description,
        isRequired,
        isEnabled,
        displayOrder,
        validation,
        options,
        placeholder,
        hint,
        category,
        createdAt,
        updatedAt,
      ];
}

