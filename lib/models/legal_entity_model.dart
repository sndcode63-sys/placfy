import 'package:equatable/equatable.dart';

class LegalEntityModel extends Equatable {
  final int id;
  final String entityId;
  final String name;
  final String slug;
  final String entityCode;
  final String entityType;
  final String entityTypeDisplay;
  final String country;
  final String city;
  final String currency;
  final String? contactEmail;
  final bool isDefault;
  final bool isActive;

  const LegalEntityModel({
    required this.id,
    required this.entityId,
    required this.name,
    required this.slug,
    required this.entityCode,
    this.entityType = 'private_limited',
    this.entityTypeDisplay = 'Private Limited Company',
    this.country = 'India',
    this.city = 'Bengaluru',
    this.currency = 'INR',
    this.contactEmail,
    this.isDefault = false,
    this.isActive = true,
  });

  factory LegalEntityModel.fromJson(Map<String, dynamic> json) {
    return LegalEntityModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      entityId: json['entity_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Entity',
      slug: json['slug'] as String? ?? '',
      entityCode: json['entity_code'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityTypeDisplay: json['entity_type_display'] as String? ?? 'Company',
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      contactEmail: json['contact_email'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_id': entityId,
      'name': name,
      'slug': slug,
      'entity_code': entityCode,
      'entity_type_display': entityTypeDisplay,
      'country': country,
      'city': city,
      'currency': currency,
      'is_default': isDefault,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        entityId,
        name,
        slug,
        entityCode,
        entityType,
        entityTypeDisplay,
        country,
        city,
        currency,
        contactEmail,
        isDefault,
        isActive,
      ];
}
