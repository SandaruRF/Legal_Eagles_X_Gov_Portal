class FormFieldModel {
  final String type;
  final String label;
  final bool required;
  final String? placeholder;
  final int? maxLength;
  final int? maxValue;
  final int? minValue;
  final List<String>? options;

  FormFieldModel({
    required this.type,
    required this.label,
    required this.required,
    this.placeholder,
    this.maxLength,
    this.maxValue,
    this.minValue,
    this.options,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      type: json['type'] as String,
      label: json['label'] as String,
      required: json['required'] as bool? ?? false,
      placeholder: json['placeholder'] as String?,
      maxLength: json['maxLength'] as int?,
      maxValue: json['maxValue'] as int?,
      minValue: json['minValue'] as int?,
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'required': required,
      'placeholder': placeholder,
      'maxLength': maxLength,
      'maxValue': maxValue,
      'minValue': minValue,
      'options': options,
    };
  }
}
