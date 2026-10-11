/// A single entry in the public Emergency Directory (TOR Module 7).
///
/// Domain entity — pure Dart, no serialization. Mirrors the backend
/// emergency-directory contract: name, contact number, plus optional address
/// and operating hours.
class EmergencyDirectoryEntry {
  const EmergencyDirectoryEntry({
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
}

/// The agency category an [EmergencyDirectoryEntry] belongs to. [unknown] is a
/// forward-compatible fallback for any value the backend adds later.
enum EmergencyType {
  hospital,
  bfp,
  police,
  comcen,
  disasterResponse,
  unknown;

  /// Maps the backend `type` enum value to an [EmergencyType], never throwing.
  static EmergencyType fromApi(String? v) => switch (v) {
    'hospital' => EmergencyType.hospital,
    'bfp' => EmergencyType.bfp,
    'police' => EmergencyType.police,
    'comcen' => EmergencyType.comcen,
    'disaster_response' => EmergencyType.disasterResponse,
    _ => EmergencyType.unknown,
  };

  /// The backend `type` enum value; inverse of [fromApi].
  String get apiValue => switch (this) {
    EmergencyType.hospital => 'hospital',
    EmergencyType.bfp => 'bfp',
    EmergencyType.police => 'police',
    EmergencyType.comcen => 'comcen',
    EmergencyType.disasterResponse => 'disaster_response',
    EmergencyType.unknown => 'unknown',
  };
}
