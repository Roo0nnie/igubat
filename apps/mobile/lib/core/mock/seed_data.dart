class CurrentUser {
  final String name;
  final String email;
  final String barangay;
  final String verificationLevel;

  const CurrentUser({
    required this.name,
    required this.email,
    required this.barangay,
    this.verificationLevel = 'Level 2 Verified',
  });
}

class Service {
  final String title;
  final String description;
  final String icon;
  final String category;
  final int processingDays;
  final bool isPopular;
  final bool isAvailable;

  const Service({
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.processingDays = 3,
    this.isPopular = false,
    this.isAvailable = true,
  });
}

class AppNotification {
  final String title;
  final String message;
  final String type;
  final String dateSent;
  final bool isRead;

  const AppNotification({
    required this.title,
    required this.message,
    required this.type,
    required this.dateSent,
    this.isRead = false,
  });
}

class Hotline {
  final String name;
  final String number;
  final String category;

  /// Physical office/facility address. Optional so nationwide hotlines
  /// (e.g. 911) can omit it. Mirrors the eventual emergency-directory API
  /// contract (TOR Module 7: name, address, contact number, hours).
  final String? address;

  /// Operating hours, e.g. `24/7` or `Mon–Fri 8:00 AM – 5:00 PM`.
  final String? hours;

  const Hotline({
    required this.name,
    required this.number,
    required this.category,
    this.address,
    this.hours,
  });
}

class ServiceRequest {
  final String id;
  final String serviceType;
  final String citizenName;
  final String barangay;
  final String dateSubmitted;
  final String status;
  final String remarks;

  const ServiceRequest({
    required this.id,
    required this.serviceType,
    required this.citizenName,
    required this.barangay,
    required this.dateSubmitted,
    required this.status,
    required this.remarks,
  });
}

class AchievementBadge {
  final String title;
  final String icon;

  const AchievementBadge({required this.title, required this.icon});
}

class SeedData {
  static const CurrentUser currentUser = CurrentUser(
    name: 'Juan Dela Cruz',
    email: 'juan.delacruz@gubat.gov.ph',
    barangay: 'Barangay Cogon',
    verificationLevel: 'Level 2 Verified',
  );

  static const List<Service> services = [
    Service(
      title: 'Business Permits',
      description: 'Apply for or renew your business permit online.',
      icon: 'briefcase',
      category: 'Permits',
      processingDays: 5,
      isPopular: true,
    ),
    Service(
      title: 'Certificates',
      description:
          'Request barangay clearance, residency, and other certificates.',
      icon: 'file-text',
      category: 'Certificates',
      processingDays: 2,
      isPopular: true,
    ),
    Service(
      title: 'Announcements',
      description: 'Stay up to date with the latest municipal news.',
      icon: 'megaphone',
      category: 'All',
      processingDays: 1,
    ),
    Service(
      title: 'Payments',
      description: 'Pay taxes, fees, and other municipal dues.',
      icon: 'credit-card',
      category: 'All',
      processingDays: 1,
      isPopular: true,
    ),
    Service(
      title: 'Health Services',
      description: 'Schedule consultations and view health programs.',
      icon: 'heart',
      category: 'Health',
      processingDays: 3,
    ),
    Service(
      title: 'Medical Assistance',
      description:
          'Request support for medicine, consultation, or hospital assistance.',
      icon: 'heart',
      category: 'Assistance',
      processingDays: 5,
    ),
    Service(
      title: 'Transportation Assistance',
      description:
          'Request LGU transportation support for eligible citizen needs.',
      icon: 'credit-card',
      category: 'Assistance',
      processingDays: 3,
    ),
    Service(
      title: 'Facility Use',
      description:
          'Reserve municipal facilities for approved community activities.',
      icon: 'file-text',
      category: 'Facilities',
      processingDays: 4,
    ),
    Service(
      title: 'Public Documents',
      description: 'Browse public ordinances and resolutions.',
      icon: 'file-text',
      category: 'All',
      processingDays: 7,
    ),
  ];

  static const List<AppNotification> notifications = [
    AppNotification(
      title: 'Business Permit Approved',
      message:
          'Your business permit application BP-2026-0418 has been approved. You may now claim your permit.',
      type: 'Status Update',
      dateSent: '2026-05-26T14:20:00Z',
      isRead: false,
    ),
    AppNotification(
      title: 'Severe Weather Advisory',
      message:
          'A low pressure area is being monitored east of Sorsogon. Stay alert and prepare for possible heavy rains.',
      type: 'Emergency',
      dateSent: '2026-05-25T06:00:00Z',
      isRead: false,
    ),
    AppNotification(
      title: 'New Announcement Posted',
      message:
          'A new community announcement has been published. Tap to read more.',
      type: 'Announcement',
      dateSent: '2026-05-24T11:45:00Z',
      isRead: true,
    ),
    AppNotification(
      title: 'Document Ready for Pickup',
      message:
          'Your requested Barangay Clearance is ready for pickup at the barangay hall.',
      type: 'Status Update',
      dateSent: '2026-05-22T08:30:00Z',
      isRead: true,
    ),
  ];

  static const List<Hotline> hotlines = [
    Hotline(
      name: 'National Emergency Hotline',
      number: '911',
      category: 'Emergency',
      hours: '24/7',
    ),
    // COMCEN (Community Emergency Communications Center) hotlines. Listed per
    // carrier so a citizen can reach the center regardless of their SIM
    // (TOR Module 7 / User Story 7.2: Smart, TNT, Landline).
    Hotline(
      name: 'COMCEN Gubat (Smart)',
      number: '0998-555-0117',
      category: 'COMCEN',
      address: 'Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon',
      hours: '24/7',
    ),
    Hotline(
      name: 'COMCEN Gubat (TNT)',
      number: '0907-555-0117',
      category: 'COMCEN',
      address: 'Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon',
      hours: '24/7',
    ),
    Hotline(
      name: 'COMCEN Gubat (Landline)',
      number: '(056) 311-0117',
      category: 'COMCEN',
      address: 'Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon',
      hours: '24/7',
    ),
    Hotline(
      name: 'Gubat Municipal Police Station',
      number: '(056) 311-1234',
      category: 'Police',
      address: 'Brgy. Poblacion, Gubat, Sorsogon',
      hours: '24/7',
    ),
    Hotline(
      name: 'Bureau of Fire Protection - Gubat',
      number: '(056) 311-5678',
      category: 'BFP',
      address: 'National Road, Brgy. Cota Na Daco, Gubat, Sorsogon',
      hours: '24/7',
    ),
    Hotline(
      name: 'Gubat District Hospital',
      number: '(056) 311-9876',
      category: 'Hospital',
      address: 'Brgy. Manook, Gubat, Sorsogon',
      hours: '24/7 Emergency Room',
    ),
    Hotline(
      name: 'MDRRMO Gubat',
      number: '(056) 311-2468',
      category: 'Disaster',
      address: 'Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon',
      hours: '24/7',
    ),
    Hotline(
      name: 'Rural Health Unit',
      number: '(056) 311-1357',
      category: 'Hospital',
      address: 'Brgy. Poblacion, Gubat, Sorsogon',
      hours: 'Mon–Fri 8:00 AM – 5:00 PM',
    ),
  ];

  static const List<ServiceRequest> activeRequests = [
    ServiceRequest(
      id: 'BP-2026-0418',
      serviceType: 'Business Permit',
      citizenName: 'Juan Dela Cruz',
      barangay: 'Barangay Cogon',
      dateSubmitted: '2026-05-10T08:30:00Z',
      status: 'Approved',
      remarks: 'Permit is ready for claiming at the BPLO office.',
    ),
    ServiceRequest(
      id: 'BP-2026-0422',
      serviceType: 'Business Permit',
      citizenName: 'Maria Santos',
      barangay: 'Barangay Bagacay',
      dateSubmitted: '2026-05-18T10:15:00Z',
      status: 'Pending',
      remarks: 'Awaiting review of submitted documents.',
    ),
    ServiceRequest(
      id: 'BP-2026-0431',
      serviceType: 'Business Permit',
      citizenName: 'Pedro Reyes',
      barangay: 'Barangay Poblacion',
      dateSubmitted: '2026-05-23T14:00:00Z',
      status: 'Rejected',
      remarks: 'Incomplete requirements. Please re-submit missing documents.',
    ),
    ServiceRequest(
      id: 'CR-2026-0117',
      serviceType: 'Certificate of Residency',
      citizenName: 'Juan Dela Cruz',
      barangay: 'Barangay Cogon',
      dateSubmitted: '2026-05-12T09:45:00Z',
      status: 'Approved',
      remarks: 'Certificate is available for pickup.',
    ),
  ];

  static const List<AchievementBadge> achievementBadges = [
    AchievementBadge(title: 'Early Adopter', icon: 'star'),
    AchievementBadge(title: 'Verified Citizen', icon: 'verified'),
    AchievementBadge(title: 'Active Participant', icon: 'community'),
  ];

  static const List<String> serviceCategories = [
    'All',
    'Permits',
    'Certificates',
    'Health',
    'Assistance',
    'Facilities',
  ];

  /// Canonical list of barangays in the Municipality of Gubat, Sorsogon.
  /// Registration requires the citizen to pick from this list rather than
  /// free-typing, so addresses stay consistent across the LGU back office
  /// (TOR: barangay is a canonical, validated field).
  static const List<String> barangays = [
    'Ariman',
    'Bagacay',
    'Balud del Norte',
    'Balud del Sur',
    'Bentuco',
    'Beriran',
    'Bonga',
    'Buenavista',
    'Bulacao',
    'Cabigaan',
    'Cabiguhan',
    'Carriedo',
    'Casili',
    'Cogon',
    'Cota na Daco',
    'Dita',
    'Jupi',
    'Lapinig',
    'Manapao',
    'Manook',
    'Naagtan',
    'Nato',
    'Ogao',
    'Paco',
    'Pandan',
    'Panganiban (Poblacion)',
    'Paradijon (Poblacion)',
    'Patag',
    'Payawin',
    'Pinontingan (Poblacion)',
    'Rizal',
    'San Ignacio',
    'Sangat',
    'Santa Ana',
    'Tabi',
    'Tagaytay',
    'Tigkiw',
    'Togawe',
    'Union',
    'Villareal',
  ];
}
