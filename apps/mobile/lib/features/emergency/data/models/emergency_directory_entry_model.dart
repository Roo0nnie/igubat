import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/emergency_directory_entry.dart';

/// DTO for a public emergency-directory entry. Mirrors the backend
/// `/public/emergency-directory` contract and maps to the
/// [EmergencyDirectoryEntry] entity.
class EmergencyDirectoryEntryModel {
  const EmergencyDirectoryEntryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.contactNumber,
    this.address,
    this.hours,
    this.isActive = true,
  });

  final int id;
  final String name;
  final EmergencyType type;
  final String contactNumber;
  final String? address;
  final String? hours;
  final bool isActive;

  factory EmergencyDirectoryEntryModel.fromJson(Map<String, dynamic> json) {
    return EmergencyDirectoryEntryModel(
      id: JsonUtils.asInt(json['id']),
      name: json['name'] as String? ?? '',
      type: EmergencyType.fromApi(json['type'] as String?),
      contactNumber: json['contactNumber'] as String? ?? '',
      address: json['address'] as String?,
      hours: json['hours'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory EmergencyDirectoryEntryModel.fromEntity(EmergencyDirectoryEntry e) =>
      EmergencyDirectoryEntryModel(
        id: e.id,
        name: e.name,
        type: e.type,
        contactNumber: e.contactNumber,
        address: e.address,
        hours: e.hours,
        isActive: e.isActive,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.apiValue,
    'contactNumber': contactNumber,
    'address': address,
    'hours': hours,
    'isActive': isActive,
  };

  EmergencyDirectoryEntry toEntity() => EmergencyDirectoryEntry(
    id: id,
    name: name,
    type: type,
    contactNumber: contactNumber,
    address: address,
    hours: hours,
    isActive: isActive,
  );
}
