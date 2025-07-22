import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/marathon_model.dart';

/// 馬拉松賽事搜索條件
class MarathonSearchFilter {
  final String? keyword;
  final List<MarathonDistance>? distances;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final List<String>? tags;
  final MarathonStatus? status;
  final double? maxDistance; // 最大距離（公里）
  final double? minDistance; // 最小距離（公里）

  const MarathonSearchFilter({
    this.keyword,
    this.distances,
    this.startDate,
    this.endDate,
    this.location,
    this.tags,
    this.status,
    this.maxDistance,
    this.minDistance,
  });

  MarathonSearchFilter copyWith({
    String? keyword,
    List<MarathonDistance>? distances,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    List<String>? tags,
    MarathonStatus? status,
    double? maxDistance,
    double? minDistance,
  }) {
    return MarathonSearchFilter(
      keyword: keyword ?? this.keyword,
      distances: distances ?? this.distances,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      maxDistance: maxDistance ?? this.maxDistance,
      minDistance: minDistance ?? this.minDistance,
    );
  }

  /// 清除所有過濾條件
  MarathonSearchFilter clear() {
    return const MarathonSearchFilter();
  }

  /// 檢查是否有任何過濾條件
  bool get hasFilters {
    return keyword?.isNotEmpty == true ||
        distances?.isNotEmpty == true ||
        startDate != null ||
        endDate != null ||
        location?.isNotEmpty == true ||
        tags?.isNotEmpty == true ||
        status != null ||
        maxDistance != null ||
        minDistance != null;
  }
}

/// 馬拉松賽事服務
class MarathonService extends ChangeNotifier {
  final List<MarathonEvent> _events = [];
  final List<MarathonRegistration> _registrations = [];
  MarathonSearchFilter _currentFilter = const MarathonSearchFilter();
  bool _isLoading = false;

  List<MarathonEvent> get events => List.unmodifiable(_events);
  List<MarathonRegistration> get registrations => List.unmodifiable(_registrations);
  MarathonSearchFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;

  /// 初始化服務，載入示例數據
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadMockData();
    } catch (e) {
      debugPrint('Error initializing marathon service: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 載入模擬數據
  Future<void> _loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模擬網絡延遲

    final now = DateTime.now();
    
    // 台北馬拉松
    final taipeiMarathon = MarathonEvent(
      id: 'taipei_marathon_2024',
      name: '2024台北馬拉松',
      description: '台北市年度最大型的國際馬拉松賽事，路線經過台北市各大地標，讓跑者在奔跑中欣賞台北之美。',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
      location: const MarathonLocation(
        address: '台北市信義區市府路1號',
        latitude: 25.0329694,
        longitude: 121.5654177,
        landmark: '台北市政府',
      ),
      startPoint: const MarathonLocation(
        address: '台北市信義區市府路1號',
        latitude: 25.0329694,
        longitude: 121.5654177,
        landmark: '台北市政府廣場',
      ),
      finishPoint: const MarathonLocation(
        address: '台北市信義區仁愛路四段505號',
        latitude: 25.0329694,
        longitude: 121.5654177,
        landmark: '國父紀念館',
      ),
      races: [
        MarathonRace(
          id: 'taipei_full',
          distance: MarathonDistance.fullMarathon,
          raceDate: now.add(const Duration(days: 30)),
          registrationDeadline: now.add(const Duration(days: 15)),
          maxParticipants: 25000,
          currentParticipants: 18500,
          entryFee: 45.0, // 美金
          earlyBirdFee: 35.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 7)),
          notes: '全程馬拉松，經過台北101、總統府、中正紀念堂等地標',
        ),
        MarathonRace(
          id: 'taipei_half',
          distance: MarathonDistance.halfMarathon,
          raceDate: now.add(const Duration(days: 30)),
          registrationDeadline: now.add(const Duration(days: 15)),
          maxParticipants: 15000,
          currentParticipants: 12300,
          entryFee: 30.0, // 美金
          earlyBirdFee: 25.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 7)),
          notes: '半程馬拉松，適合初次參賽者',
        ),
        MarathonRace(
          id: 'taipei_5k',
          distance: MarathonDistance.fiveK,
          raceDate: now.add(const Duration(days: 30)),
          registrationDeadline: now.add(const Duration(days: 15)),
          maxParticipants: 8000,
          currentParticipants: 6200,
          entryFee: 20.0, // 美金
          earlyBirdFee: 15.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 7)),
          notes: '5公里健康路跑，全家大小都適合',
        ),
      ],
      routeMapUrl: 'https://example.com/taipei_marathon_route.jpg',
      organizer: '台北市政府體育局',
      website: 'https://www.taipeimmarathon.org.tw',
      contactEmail: 'info@taipeimarathon.org.tw',
      contactPhone: '02-2725-5200',
      termsAndConditions: '''Terms and Conditions

1. Participation Eligibility
• Participants must be at least 18 years old (except 5K run, minors require parental consent)
• Participants must be in good health with no heart disease, high blood pressure, or other conditions unsuitable for long-distance running
• Health check-up is recommended before participation

2. Registration Rules
• No refunds after registration deadline
• In case of event cancellation due to force majeure (natural disasters), 70% of registration fee will be refunded
• Registration slots are non-transferable

3. Race Rules
• Must follow the designated race route, no shortcuts allowed
• Must wear the provided race bib and timing chip
• Follow traffic control and staff instructions

4. Safety Notice
• Stop immediately and seek assistance if feeling unwell
• Medical support will be provided, but participants are responsible for their own safety
• Recommended to carry personal medication if needed

5. Liability Disclaimer
Participants agree to assume all risks of participation. The organizer is not liable for any accidental injuries that may occur during the event.''',
      tags: ['國際賽事', '城市馬拉松', '地標路線'],
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );

    // 日月潭環湖路跑
    final sunMoonLakeRun = MarathonEvent(
      id: 'sun_moon_lake_2024',
      name: '2024日月潭環湖路跑',
      description: '在台灣最美麗的湖泊邊奔跑，享受湖光山色的絕美景致，是一場結合運動與觀光的完美賽事。',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      location: const MarathonLocation(
        address: '南投縣魚池鄉中山路599號',
        latitude: 23.8569,
        longitude: 120.9195,
        landmark: '日月潭國家風景區',
      ),
      startPoint: const MarathonLocation(
        address: '南投縣魚池鄉中山路599號',
        latitude: 23.8569,
        longitude: 120.9195,
        landmark: '向山遊客中心',
      ),
      finishPoint: const MarathonLocation(
        address: '南投縣魚池鄉中山路599號',
        latitude: 23.8569,
        longitude: 120.9195,
        landmark: '向山遊客中心',
      ),
      races: [
        MarathonRace(
          id: 'sml_29k',
          distance: MarathonDistance.custom,
          customDistance: 29.0,
          raceDate: now.add(const Duration(days: 45)),
          registrationDeadline: now.add(const Duration(days: 25)),
          maxParticipants: 3000,
          currentParticipants: 2100,
          entryFee: 38.0, // 美金
          earlyBirdFee: 30.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 10)),
          notes: '環湖一圈約29公里，挑戰山路起伏',
        ),
        MarathonRace(
          id: 'sml_half',
          distance: MarathonDistance.halfMarathon,
          raceDate: now.add(const Duration(days: 45)),
          registrationDeadline: now.add(const Duration(days: 25)),
          maxParticipants: 2000,
          currentParticipants: 1650,
          entryFee: 28.0, // 美金
          earlyBirdFee: 22.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 10)),
          notes: '半程環湖路線，沿途風景優美',
        ),
      ],
      routeMapUrl: 'https://example.com/sun_moon_lake_route.jpg',
      organizer: '日月潭國家風景區管理處',
      website: 'https://www.sunmoonlake.gov.tw',
      contactEmail: 'run@sunmoonlake.gov.tw',
      contactPhone: '049-285-5668',
      termsAndConditions: '''Sun Moon Lake Run Participation Notice

1. Participation Requirements
• Must be at least 16 years old and in good health suitable for long-distance running
• Lake route includes mountain terrain with elevation changes, relevant training experience recommended
• Participants must bring their own eco-friendly water bottles

2. Environmental Protection
• Strictly prohibited to litter, maintain Sun Moon Lake's natural environment
• Please follow National Scenic Area regulations
• Keep noise levels low during the race to avoid disturbing wildlife

3. Route Characteristics
• Aid stations are available along the lake route but spaced farther apart
• Please pay attention to safety on mountain sections and follow designated routes
• Event organizers reserve the right to adjust routes or cancel the race in adverse weather

4. Accommodation and Transportation
• Advance booking of local accommodation recommended
• Traffic control will be in effect on race day
• Free shuttle service provided by the organizers

5. Emergency Response
• Mountain area signal may be unstable, please inform family of race information
• Contact nearest staff immediately in case of emergency
• Recommended to carry emergency contact information and basic medication''',
      tags: ['風景路跑', '環湖賽事', '山路挑戰'],
      createdAt: now.subtract(const Duration(days: 45)),
      updatedAt: now.subtract(const Duration(days: 3)),
    );

    // 墾丁海岸馬拉松
    final kentingMarathon = MarathonEvent(
      id: 'kenting_marathon_2024',
      name: '2024墾丁海岸馬拉松',
      description: '在台灣最南端的美麗海岸線奔跑，感受海風與陽光，享受獨特的熱帶風情跑步體驗。',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      location: const MarathonLocation(
        address: '屏東縣恆春鎮墾丁路596號',
        latitude: 22.0025,
        longitude: 120.7398,
        landmark: '墾丁國家公園',
      ),
      startPoint: const MarathonLocation(
        address: '屏東縣恆春鎮墾丁路596號',
        latitude: 22.0025,
        longitude: 120.7398,
        landmark: '墾丁大街',
      ),
      finishPoint: const MarathonLocation(
        address: '屏東縣恆春鎮燈塔路90號',
        latitude: 21.9018,
        longitude: 120.8485,
        landmark: '鵝鑾鼻燈塔',
      ),
      races: [
        MarathonRace(
          id: 'kenting_half',
          distance: MarathonDistance.halfMarathon,
          raceDate: now.add(const Duration(days: 60)),
          registrationDeadline: now.add(const Duration(days: 40)),
          maxParticipants: 2500,
          currentParticipants: 1200,
          entryFee: 32.0, // 美金
          earlyBirdFee: 26.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 20)),
          notes: '海岸線半程馬拉松，終點在鵝鑾鼻燈塔',
        ),
        MarathonRace(
          id: 'kenting_10k',
          distance: MarathonDistance.tenK,
          raceDate: now.add(const Duration(days: 61)),
          registrationDeadline: now.add(const Duration(days: 40)),
          maxParticipants: 1500,
          currentParticipants: 890,
          entryFee: 22.0, // 美金
          earlyBirdFee: 18.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 20)),
          notes: '10K海岸休閒跑，適合全家參與',
        ),
        MarathonRace(
          id: 'kenting_5k',
          distance: MarathonDistance.fiveK,
          raceDate: now.add(const Duration(days: 61)),
          registrationDeadline: now.add(const Duration(days: 40)),
          maxParticipants: 1000,
          currentParticipants: 650,
          entryFee: 15.0, // 美金
          earlyBirdFee: 12.0, // 早鳥價格（美金）
          earlyBirdDeadline: now.add(const Duration(days: 20)),
          notes: '5K親子路跑，歡迎親子一同參與',
        ),
      ],
      organizer: '墾丁國家公園管理處',
      website: 'https://www.ktnp.gov.tw',
      contactEmail: 'marathon@ktnp.gov.tw',
      contactPhone: '08-886-2720',
      termsAndConditions: '''Kenting Coastal Marathon Terms

1. Coastal Running Special Notice
• Race route runs along the coastline, please pay attention to sun protection and hydration
• Strong sea winds, please wear appropriate athletic clothing
• Some sections are sandy terrain, trail running shoes recommended

2. Family Participation Rules
• 5K family category welcomes children 12 years and above (with parental accompaniment)
• Parents must accompany minors throughout the entire race
• Family category has more flexible time limits

3. Climate Adaptation
• Kenting climate is hot, please assess personal physical condition
• Event provides sun hats and sunscreen products
• Recommended to arrive early to adapt to local climate

4. Marine Life Protection
• Please do not touch or disturb marine life
• Prohibited to step on coral reef areas
• Please dispose of trash in designated recycling points

5. Accommodation and Transportation
• Kenting accommodation requires advance booking, especially during holidays
• Free parking provided at race start/finish area
• Recommended to use public transportation to reach the venue''',
      tags: ['海岸路跑', '親子友善', '熱帶風情'],
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    _events.clear();
    _events.addAll([taipeiMarathon, sunMoonLakeRun, kentingMarathon]);
  }

  /// 搜索馬拉松賽事
  List<MarathonEvent> searchEvents({MarathonSearchFilter? filter}) {
    final searchFilter = filter ?? _currentFilter;
    
    return _events.where((event) {
      // 關鍵字搜索
      if (searchFilter.keyword?.isNotEmpty == true) {
        final keyword = searchFilter.keyword!.toLowerCase();
        if (!event.name.toLowerCase().contains(keyword) &&
            !event.description.toLowerCase().contains(keyword) &&
            !event.location.address.toLowerCase().contains(keyword) &&
            !event.organizer.toLowerCase().contains(keyword)) {
          return false;
        }
      }

      // 狀態過濾
      if (searchFilter.status != null && event.status != searchFilter.status) {
        return false;
      }

      // 距離過濾
      if (searchFilter.distances?.isNotEmpty == true) {
        final hasMatchingDistance = event.races.any((race) =>
            searchFilter.distances!.contains(race.distance));
        if (!hasMatchingDistance) return false;
      }

      // 日期範圍過濾
      if (searchFilter.startDate != null) {
        final earliestDate = event.earliestRaceDate;
        if (earliestDate == null || earliestDate.isBefore(searchFilter.startDate!)) {
          return false;
        }
      }

      if (searchFilter.endDate != null) {
        final latestDate = event.latestRaceDate;
        if (latestDate == null || latestDate.isAfter(searchFilter.endDate!)) {
          return false;
        }
      }

      // 地點過濾
      if (searchFilter.location?.isNotEmpty == true) {
        final location = searchFilter.location!.toLowerCase();
        if (!event.location.address.toLowerCase().contains(location)) {
          return false;
        }
      }

      // 標籤過濾
      if (searchFilter.tags?.isNotEmpty == true) {
        final hasMatchingTag = searchFilter.tags!.any((tag) =>
            event.tags.any((eventTag) => eventTag.toLowerCase().contains(tag.toLowerCase())));
        if (!hasMatchingTag) return false;
      }

      // 距離範圍過濾
      if (searchFilter.minDistance != null || searchFilter.maxDistance != null) {
        final hasMatchingDistance = event.races.any((race) {
          final distance = race.getDistanceInKm();
          if (searchFilter.minDistance != null && distance < searchFilter.minDistance!) {
            return false;
          }
          if (searchFilter.maxDistance != null && distance > searchFilter.maxDistance!) {
            return false;
          }
          return true;
        });
        if (!hasMatchingDistance) return false;
      }

      return true;
    }).toList();
  }

  /// 更新搜索過濾條件
  void updateFilter(MarathonSearchFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// 清除搜索條件
  void clearFilter() {
    _currentFilter = const MarathonSearchFilter();
    notifyListeners();
  }

  /// 根據ID獲取賽事
  MarathonEvent? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根據ID獲取賽事項目
  MarathonRace? getRaceById(String eventId, String raceId) {
    final event = getEventById(eventId);
    if (event == null) return null;
    
    try {
      return event.races.firstWhere((race) => race.id == raceId);
    } catch (e) {
      return null;
    }
  }

  /// 報名賽事
  Future<bool> registerForRace({
    required String eventId,
    required String raceId,
    required String userId,
    required String participantName,
    required String participantEmail,
    String? participantPhone,
    String? emergencyContact,
    String? emergencyPhone,
    String? medicalInfo,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final event = getEventById(eventId);
      final race = getRaceById(eventId, raceId);
      
      if (event == null || race == null) {
        debugPrint('Event or race not found');
        return false;
      }

      if (!race.isRegistrationOpen) {
        debugPrint('Registration is closed for this race');
        return false;
      }

      if (race.isFull) {
        debugPrint('Race is full');
        return false;
      }

      // 檢查是否已經報名
      final existingRegistration = _registrations.any((reg) =>
          reg.eventId == eventId && reg.raceId == raceId && reg.userId == userId);
      
      if (existingRegistration) {
        debugPrint('User already registered for this race');
        return false;
      }

      // 模擬報名處理
      await Future.delayed(const Duration(seconds: 1));

      final registration = MarathonRegistration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: eventId,
        raceId: raceId,
        userId: userId,
        participantName: participantName,
        participantEmail: participantEmail,
        participantPhone: participantPhone,
        registrationDate: DateTime.now(),
        amountPaid: race.entryFee,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        medicalInfo: medicalInfo,
        additionalInfo: additionalInfo,
      );

      _registrations.add(registration);

      // 更新參賽人數
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final raceIndex = _events[eventIndex].races.indexWhere((r) => r.id == raceId);
        if (raceIndex != -1) {
          final updatedRace = _events[eventIndex].races[raceIndex].copyWith(
            currentParticipants: _events[eventIndex].races[raceIndex].currentParticipants + 1,
          );
          
          final updatedRaces = List<MarathonRace>.from(_events[eventIndex].races);
          updatedRaces[raceIndex] = updatedRace;
          
          _events[eventIndex] = _events[eventIndex].copyWith(races: updatedRaces);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error registering for race: $e');
      return false;
    }
  }

  /// 取消報名
  Future<bool> cancelRegistration(String registrationId) async {
    try {
      final registrationIndex = _registrations.indexWhere((reg) => reg.id == registrationId);
      if (registrationIndex == -1) {
        debugPrint('Registration not found');
        return false;
      }

      final registration = _registrations[registrationIndex];
      
      // 模擬取消處理
      await Future.delayed(const Duration(milliseconds: 500));

      _registrations.removeAt(registrationIndex);

      // 更新參賽人數
      final eventIndex = _events.indexWhere((e) => e.id == registration.eventId);
      if (eventIndex != -1) {
        final raceIndex = _events[eventIndex].races.indexWhere((r) => r.id == registration.raceId);
        if (raceIndex != -1) {
          final updatedRace = _events[eventIndex].races[raceIndex].copyWith(
            currentParticipants: math.max(0, _events[eventIndex].races[raceIndex].currentParticipants - 1),
          );
          
          final updatedRaces = List<MarathonRace>.from(_events[eventIndex].races);
          updatedRaces[raceIndex] = updatedRace;
          
          _events[eventIndex] = _events[eventIndex].copyWith(races: updatedRaces);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error canceling registration: $e');
      return false;
    }
  }

  /// 獲取用戶的報名記錄
  List<MarathonRegistration> getUserRegistrations(String userId) {
    return _registrations.where((reg) => reg.userId == userId).toList();
  }

  /// 檢查用戶是否已報名某個賽事
  bool isUserRegistered(String userId, String eventId, String raceId) {
    return _registrations.any((reg) =>
        reg.userId == userId && reg.eventId == eventId && reg.raceId == raceId);
  }

  /// 獲取所有可用的標籤
  List<String> getAllTags() {
    final allTags = <String>{};
    for (final event in _events) {
      allTags.addAll(event.tags);
    }
    return allTags.toList()..sort();
  }

  /// 獲取所有可用的地點
  List<String> getAllLocations() {
    final locations = <String>{};
    for (final event in _events) {
      locations.add(event.location.address);
    }
    return locations.toList()..sort();
  }

  /// 刷新數據
  Future<void> refresh() async {
    await initialize();
  }
}