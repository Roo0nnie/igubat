enum DiscoverGubatType {
  touristSpot('tourist_spot'),
  festivalCulture('festival_culture'),
  localProduct('local_product');

  const DiscoverGubatType(this.apiValue);

  final String apiValue;
}

extension DiscoverGubatTypeX on DiscoverGubatType {
  static DiscoverGubatType fromApiValue(String value) {
    return DiscoverGubatType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => DiscoverGubatType.touristSpot,
    );
  }
}

class DiscoverGubatPhoto {
  const DiscoverGubatPhoto({
    required this.id,
    required this.imageUrl,
    this.altText,
    this.sortOrder = 0,
  });

  final int id;
  final String imageUrl;
  final String? altText;
  final int sortOrder;

  factory DiscoverGubatPhoto.fromJson(Map<String, dynamic> json) {
    return DiscoverGubatPhoto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      altText: json['altText'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'altText': altText,
    'sortOrder': sortOrder,
  };
}

class DiscoverGubatEntry {
  const DiscoverGubatEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.slug,
    required this.category,
    this.summary,
    this.body = '',
    this.status,
    this.coverImageUrl,
    this.mapLocation,
    this.whereToBuy,
    this.eventDate,
    this.metadata = const {},
    this.publishedAt,
    this.photos = const [],
  });

  final int id;
  final DiscoverGubatType type;
  final String title;
  final String slug;
  final String category;
  final String? summary;
  final String body;
  final String? status;
  final String? coverImageUrl;
  final String? mapLocation;
  final String? whereToBuy;
  final DateTime? eventDate;
  final Map<String, dynamic> metadata;
  final DateTime? publishedAt;
  final List<DiscoverGubatPhoto> photos;

  String get description => summary ?? body;

  String get detailDescription {
    final trimmedBody = body.trim();
    if (trimmedBody.isNotEmpty) return body;
    return description;
  }

  String? get primaryImageUrl {
    final cover = coverImageUrl?.trim();
    if (cover != null && cover.isNotEmpty) return cover;

    for (final photo in photos) {
      final imageUrl = photo.imageUrl.trim();
      if (imageUrl.isNotEmpty) return imageUrl;
    }
    return null;
  }

  String get detailLabel {
    switch (type) {
      case DiscoverGubatType.touristSpot:
        return 'Map location';
      case DiscoverGubatType.festivalCulture:
        return 'Culture note';
      case DiscoverGubatType.localProduct:
        return 'Where to buy';
    }
  }

  String get detailValue {
    switch (type) {
      case DiscoverGubatType.touristSpot:
        return mapLocation ?? metadata['mapLocation']?.toString() ?? '';
      case DiscoverGubatType.festivalCulture:
        return metadata['culturalNote']?.toString() ??
            (eventDate == null
                ? 'Local heritage, festival, and culture article.'
                : 'Observed around ${eventDate!.year}.');
      case DiscoverGubatType.localProduct:
        return whereToBuy ?? metadata['whereToBuy']?.toString() ?? '';
    }
  }

  factory DiscoverGubatEntry.fromJson(Map<String, dynamic> json) {
    return DiscoverGubatEntry(
      id: (json['id'] as num).toInt(),
      type: DiscoverGubatTypeX.fromApiValue(json['type'] as String),
      title: json['title'] as String,
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String?,
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: json['status'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      mapLocation: json['mapLocation'] as String?,
      whereToBuy: json['whereToBuy'] as String?,
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.tryParse(json['eventDate'].toString()),
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'].toString()),
      photos: ((json['photos'] as List?) ?? const [])
          .map(
            (item) => DiscoverGubatPhoto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.apiValue,
    'title': title,
    'slug': slug,
    'summary': summary,
    'body': body,
    'category': category,
    'status': status,
    'coverImageUrl': coverImageUrl,
    'mapLocation': mapLocation,
    'whereToBuy': whereToBuy,
    'eventDate': eventDate?.toIso8601String(),
    'metadata': metadata,
    'publishedAt': publishedAt?.toIso8601String(),
    'photos': photos.map((photo) => photo.toJson()).toList(),
  };
}
