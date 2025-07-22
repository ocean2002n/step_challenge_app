import 'package:flutter/foundation.dart';

/// 馬拉松賽事距離類型
enum MarathonDistance {
  twoK,
  fiveK,
  tenK,
  halfMarathon,
  fullMarathon,
  ultraMarathon,
  custom
}

/// 馬拉松賽事狀態
enum MarathonStatus {
  upcoming,
  registrationOpen,
  registrationClosed,
  ongoing,
  completed,
  cancelled
}

/// 馬拉松賽事地點信息
@immutable
class MarathonLocation {
  final String address;
  final double latitude;
  final double longitude;
  final String? landmark;

  const MarathonLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.landmark,
  });

  Map<String, dynamic> toJson() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'landmark': landmark,
  };

  factory MarathonLocation.fromJson(Map<String, dynamic> json) => MarathonLocation(
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    landmark: json['landmark'] as String?,
  );

  MarathonLocation copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? landmark,
  }) {
    return MarathonLocation(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landmark: landmark ?? this.landmark,
    );
  }

  @override
  String toString() => address;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarathonLocation &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          landmark == other.landmark;

  @override
  int get hashCode =>
      address.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      landmark.hashCode;
}

/// 馬拉松賽事項目（不同距離和日期的組合）
@immutable
class MarathonRace {
  final String id;
  final MarathonDistance distance;
  final double? customDistance; // 自定義距離（公里）
  final DateTime raceDate;
  final DateTime? registrationDeadline;
  final int maxParticipants;
  final int currentParticipants;
  final double entryFee; // 美金
  final double? earlyBirdFee; // 早鳥價格（美金）
  final DateTime? earlyBirdDeadline; // 早鳥截止日期
  final String? notes;

  const MarathonRace({
    required this.id,
    required this.distance,
    this.customDistance,
    required this.raceDate,
    this.registrationDeadline,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.entryFee = 0.0,
    this.earlyBirdFee,
    this.earlyBirdDeadline,
    this.notes,
  });

  String getDistanceText() {
    switch (distance) {
      case MarathonDistance.twoK:
        return '2K';
      case MarathonDistance.fiveK:
        return '5K';
      case MarathonDistance.tenK:
        return '10K';
      case MarathonDistance.halfMarathon:
        return 'Half Marathon (21K)';
      case MarathonDistance.fullMarathon:
        return 'Full Marathon (42K)';
      case MarathonDistance.ultraMarathon:
        return 'Ultra Marathon (50K+)';
      case MarathonDistance.custom:
        return customDistance != null ? '${customDistance}K' : 'Custom';
    }
  }

  double getDistanceInKm() {
    switch (distance) {
      case MarathonDistance.twoK:
        return 2.0;
      case MarathonDistance.fiveK:
        return 5.0;
      case MarathonDistance.tenK:
        return 10.0;
      case MarathonDistance.halfMarathon:
        return 21.1;
      case MarathonDistance.fullMarathon:
        return 42.2;
      case MarathonDistance.ultraMarathon:
        return 50.0;
      case MarathonDistance.custom:
        return customDistance ?? 0.0;
    }
  }

  bool get isRegistrationOpen {
    final now = DateTime.now();
    return registrationDeadline == null || now.isBefore(registrationDeadline!) &&
        currentParticipants < maxParticipants;
  }

  bool get isFull => currentParticipants >= maxParticipants;

  /// 是否在早鳥期間
  bool get isEarlyBirdPeriod {
    if (earlyBirdDeadline == null) return false;
    return DateTime.now().isBefore(earlyBirdDeadline!);
  }

  /// 獲取當前應該收取的費用
  double get currentFee {
    return isEarlyBirdPeriod ? (earlyBirdFee ?? entryFee) : entryFee;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'distance': distance.name,
    'customDistance': customDistance,
    'raceDate': raceDate.toIso8601String(),
    'registrationDeadline': registrationDeadline?.toIso8601String(),
    'maxParticipants': maxParticipants,
    'currentParticipants': currentParticipants,
    'entryFee': entryFee,
    'earlyBirdFee': earlyBirdFee,
    'earlyBirdDeadline': earlyBirdDeadline?.toIso8601String(),
    'notes': notes,
  };

  factory MarathonRace.fromJson(Map<String, dynamic> json) => MarathonRace(
    id: json['id'] as String,
    distance: MarathonDistance.values.firstWhere(
      (e) => e.name == json['distance'],
      orElse: () => MarathonDistance.custom,
    ),
    customDistance: json['customDistance'] as double?,
    raceDate: DateTime.parse(json['raceDate'] as String),
    registrationDeadline: json['registrationDeadline'] != null
        ? DateTime.parse(json['registrationDeadline'] as String)
        : null,
    maxParticipants: json['maxParticipants'] as int,
    currentParticipants: json['currentParticipants'] as int? ?? 0,
    entryFee: (json['entryFee'] as num?)?.toDouble() ?? 0.0,
    earlyBirdFee: (json['earlyBirdFee'] as num?)?.toDouble(),
    earlyBirdDeadline: json['earlyBirdDeadline'] != null
        ? DateTime.parse(json['earlyBirdDeadline'] as String)
        : null,
    notes: json['notes'] as String?,
  );

  MarathonRace copyWith({
    String? id,
    MarathonDistance? distance,
    double? customDistance,
    DateTime? raceDate,
    DateTime? registrationDeadline,
    int? maxParticipants,
    int? currentParticipants,
    double? entryFee,
    double? earlyBirdFee,
    DateTime? earlyBirdDeadline,
    String? notes,
  }) {
    return MarathonRace(
      id: id ?? this.id,
      distance: distance ?? this.distance,
      customDistance: customDistance ?? this.customDistance,
      raceDate: raceDate ?? this.raceDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      entryFee: entryFee ?? this.entryFee,
      earlyBirdFee: earlyBirdFee ?? this.earlyBirdFee,
      earlyBirdDeadline: earlyBirdDeadline ?? this.earlyBirdDeadline,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarathonRace &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 馬拉松賽事主要信息
@immutable
class MarathonEvent {
  final String id;
  final String name;
  final String description;
  final String? imageUrl; // 代表性照片 URL
  final MarathonLocation location;
  final MarathonLocation startPoint;
  final MarathonLocation finishPoint;
  final List<MarathonRace> races;
  final String? routeMapUrl; // 路線圖 URL
  final String? notes;
  final String organizer;
  final String? website;
  final String? contactEmail;
  final String? contactPhone;
  final String? termsAndConditions; // 條款與條件
  final List<String> tags; // 標籤，用於搜索和分類
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarathonEvent({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.startPoint,
    required this.finishPoint,
    required this.races,
    this.routeMapUrl,
    this.notes,
    required this.organizer,
    this.website,
    this.contactEmail,
    this.contactPhone,
    this.termsAndConditions,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 獲取最早的比賽日期
  DateTime? get earliestRaceDate {
    if (races.isEmpty) return null;
    return races.map((r) => r.raceDate).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// 獲取最晚的比賽日期
  DateTime? get latestRaceDate {
    if (races.isEmpty) return null;
    return races.map((r) => r.raceDate).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// 獲取所有可用的距離
  List<MarathonDistance> get availableDistances {
    return races.map((r) => r.distance).toSet().toList();
  }

  /// 檢查是否有開放報名的賽事
  bool get hasOpenRegistration {
    return races.any((race) => race.isRegistrationOpen);
  }

  /// 獲取賽事狀態
  MarathonStatus get status {
    final now = DateTime.now();
    final earliestDate = earliestRaceDate;
    final latestDate = latestRaceDate;

    if (earliestDate == null) return MarathonStatus.cancelled;

    if (now.isAfter(latestDate!)) {
      return MarathonStatus.completed;
    } else if (now.isAfter(earliestDate) && now.isBefore(latestDate)) {
      return MarathonStatus.ongoing;
    } else if (hasOpenRegistration) {
      return MarathonStatus.registrationOpen;
    } else if (now.isBefore(earliestDate)) {
      return MarathonStatus.upcoming;
    } else {
      return MarathonStatus.registrationClosed;
    }
  }

  /// 根據距離獲取賽事
  List<MarathonRace> getRacesByDistance(MarathonDistance distance) {
    return races.where((race) => race.distance == distance).toList();
  }

  /// 根據日期範圍獲取賽事
  List<MarathonRace> getRacesByDateRange(DateTime start, DateTime end) {
    return races.where((race) => 
      race.raceDate.isAfter(start) && race.raceDate.isBefore(end)
    ).toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'location': location.toJson(),
    'startPoint': startPoint.toJson(),
    'finishPoint': finishPoint.toJson(),
    'races': races.map((r) => r.toJson()).toList(),
    'routeMapUrl': routeMapUrl,
    'notes': notes,
    'organizer': organizer,
    'website': website,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
    'termsAndConditions': termsAndConditions,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MarathonEvent.fromJson(Map<String, dynamic> json) => MarathonEvent(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String?,
    location: MarathonLocation.fromJson(json['location'] as Map<String, dynamic>),
    startPoint: MarathonLocation.fromJson(json['startPoint'] as Map<String, dynamic>),
    finishPoint: MarathonLocation.fromJson(json['finishPoint'] as Map<String, dynamic>),
    races: (json['races'] as List<dynamic>)
        .map((r) => MarathonRace.fromJson(r as Map<String, dynamic>))
        .toList(),
    routeMapUrl: json['routeMapUrl'] as String?,
    notes: json['notes'] as String?,
    organizer: json['organizer'] as String,
    website: json['website'] as String?,
    contactEmail: json['contactEmail'] as String?,
    contactPhone: json['contactPhone'] as String?,
    termsAndConditions: json['termsAndConditions'] as String?,
    tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  MarathonEvent copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    MarathonLocation? location,
    MarathonLocation? startPoint,
    MarathonLocation? finishPoint,
    List<MarathonRace>? races,
    String? routeMapUrl,
    String? notes,
    String? organizer,
    String? website,
    String? contactEmail,
    String? contactPhone,
    String? termsAndConditions,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarathonEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      startPoint: startPoint ?? this.startPoint,
      finishPoint: finishPoint ?? this.finishPoint,
      races: races ?? this.races,
      routeMapUrl: routeMapUrl ?? this.routeMapUrl,
      notes: notes ?? this.notes,
      organizer: organizer ?? this.organizer,
      website: website ?? this.website,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarathonEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 馬拉松報名信息
@immutable
class MarathonRegistration {
  final String id;
  final String eventId;
  final String raceId;
  final String userId;
  final String participantName;
  final String participantEmail;
  final String? participantPhone;
  final DateTime registrationDate;
  final double amountPaid;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? medicalInfo;
  final Map<String, dynamic>? additionalInfo;

  const MarathonRegistration({
    required this.id,
    required this.eventId,
    required this.raceId,
    required this.userId,
    required this.participantName,
    required this.participantEmail,
    this.participantPhone,
    required this.registrationDate,
    required this.amountPaid,
    this.emergencyContact,
    this.emergencyPhone,
    this.medicalInfo,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'raceId': raceId,
    'userId': userId,
    'participantName': participantName,
    'participantEmail': participantEmail,
    'participantPhone': participantPhone,
    'registrationDate': registrationDate.toIso8601String(),
    'amountPaid': amountPaid,
    'emergencyContact': emergencyContact,
    'emergencyPhone': emergencyPhone,
    'medicalInfo': medicalInfo,
    'additionalInfo': additionalInfo,
  };

  factory MarathonRegistration.fromJson(Map<String, dynamic> json) => MarathonRegistration(
    id: json['id'] as String,
    eventId: json['eventId'] as String,
    raceId: json['raceId'] as String,
    userId: json['userId'] as String,
    participantName: json['participantName'] as String,
    participantEmail: json['participantEmail'] as String,
    participantPhone: json['participantPhone'] as String?,
    registrationDate: DateTime.parse(json['registrationDate'] as String),
    amountPaid: (json['amountPaid'] as num).toDouble(),
    emergencyContact: json['emergencyContact'] as String?,
    emergencyPhone: json['emergencyPhone'] as String?,
    medicalInfo: json['medicalInfo'] as String?,
    additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
  );

  MarathonRegistration copyWith({
    String? id,
    String? eventId,
    String? raceId,
    String? userId,
    String? participantName,
    String? participantEmail,
    String? participantPhone,
    DateTime? registrationDate,
    double? amountPaid,
    String? emergencyContact,
    String? emergencyPhone,
    String? medicalInfo,
    Map<String, dynamic>? additionalInfo,
  }) {
    return MarathonRegistration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      raceId: raceId ?? this.raceId,
      userId: userId ?? this.userId,
      participantName: participantName ?? this.participantName,
      participantEmail: participantEmail ?? this.participantEmail,
      participantPhone: participantPhone ?? this.participantPhone,
      registrationDate: registrationDate ?? this.registrationDate,
      amountPaid: amountPaid ?? this.amountPaid,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarathonRegistration &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}