import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/marathon_model.dart';
import '../services/marathon_service.dart';
import '../services/auth_service.dart';
import 'marathon_registration_with_participants_screen.dart';

class MarathonDetailScreen extends StatefulWidget {
  final String eventId;

  const MarathonDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<MarathonDetailScreen> createState() => _MarathonDetailScreenState();
}

class _MarathonDetailScreenState extends State<MarathonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MarathonEvent? _event;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEvent() {
    final marathonService = context.read<MarathonService>();
    _event = marathonService.getEventById(widget.eventId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.marathonEventDetails),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_event!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEventHeader(l10n),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: l10n.details),
              Tab(text: l10n.races),
              Tab(text: l10n.location),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(l10n),
                _buildRacesTab(l10n),
                _buildLocationTab(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader(AppLocalizations l10n) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final earliestDate = _event!.earliestRaceDate;
    final latestDate = _event!.latestRaceDate;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event!.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(_event!.status, l10n),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                earliestDate != null && latestDate != null
                    ? earliestDate == latestDate
                        ? dateFormat.format(earliestDate)
                        : '${DateFormat('MM/dd').format(earliestDate)} - ${DateFormat('MM/dd').format(latestDate)}'
                    : l10n.dateNotSet,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _event!.location.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _event!.organizer,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活動備註
          if (_event!.notes != null) ...[
            _buildSection(
              l10n.notes,
              Text(_event!.notes!),
            ),
            const SizedBox(height: 24),
          ],

          // 聯絡資訊
          _buildSection(
            l10n.contactInformation,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactItem(
                  Icons.business,
                  l10n.organizer,
                  _event!.organizer,
                ),
                if (_event!.contactEmail != null)
                  _buildContactItem(
                    Icons.email,
                    l10n.email,
                    _event!.contactEmail!,
                    onTap: () => _launchUrl('mailto:${_event!.contactEmail}'),
                  ),
                if (_event!.contactPhone != null)
                  _buildContactItem(
                    Icons.phone,
                    l10n.phoneNumber,
                    _event!.contactPhone!,
                    onTap: () => _launchUrl('tel:${_event!.contactPhone}'),
                  ),
                if (_event!.website != null)
                  _buildContactItem(
                    Icons.web,
                    l10n.website,
                    _event!.website!,
                    onTap: () => _launchUrl(_event!.website!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 路線圖
          _buildSection(
            l10n.routeMap,
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _event!.routeMapUrl != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _event!.routeMapUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('圖片載入失敗'),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: () => _showFullScreenImage(_event!.routeMapUrl!),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noRouteMapAvailable,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // 備註
          if (_event!.notes?.isNotEmpty == true) ...[
            _buildSection(
              l10n.notes,
              Text(_event!.notes!),
            ),
            const SizedBox(height: 24),
          ],

          // 賽事項目備註
          ..._event!.races.where((race) => race.notes?.isNotEmpty == true).map((race) => 
            Column(
              children: [
                _buildSection(
                  '${race.getDistanceText()} ${l10n.notes}',
                  Text(race.notes!),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // 標籤
          if (_event!.tags.isNotEmpty) ...[
            _buildSection(
              l10n.tags,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _event!.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRacesTab(AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _event!.races.length,
      itemBuilder: (context, index) {
        final race = _event!.races[index];
        return _buildRaceCard(race, l10n);
      },
    );
  }

  Widget _buildRaceCard(MarathonRace race, AppLocalizations l10n) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  race.getDistanceText(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildRaceStatusChip(race, l10n),
              ],
            ),
            const SizedBox(height: 12),
            _buildRaceInfoRow(
              Icons.calendar_today,
              l10n.raceDate,
              dateFormat.format(race.raceDate),
            ),
            const SizedBox(height: 8),
            _buildEnhancedEntryFeeDisplay(race, l10n),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer<MarathonService>(
                builder: (context, marathonService, child) {
                  final authService = context.read<AuthService>();
                  final userId = authService.userId ?? 'user_1'; // 使用默認用戶ID
                  final isRegistered = marathonService.isUserRegistered(userId, _event!.id, race.id);

                  if (isRegistered) {
                    return ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.registered),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    );
                  } else if (!race.isRegistrationOpen) {
                    return ElevatedButton(
                      onPressed: null,
                      child: Text(l10n.registrationClosed),
                    );
                  } else if (race.isFull) {
                    return ElevatedButton(
                      onPressed: null,
                      child: Text(l10n.raceFull),
                    );
                  } else {
                    return ElevatedButton.icon(
                      onPressed: () => _showRegistrationPage(race, l10n),
                      icon: const Icon(Icons.person_add),
                      label: Text(l10n.register),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            l10n.eventLocation,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationItem(
                  Icons.location_on,
                  l10n.address,
                  _event!.location.address,
                ),
                if (_event!.location.landmark != null)
                  _buildLocationItem(
                    Icons.place,
                    l10n.landmark,
                    _event!.location.landmark!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            l10n.startPoint,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationItem(
                  Icons.play_arrow,
                  l10n.address,
                  _event!.startPoint.address,
                ),
                if (_event!.startPoint.landmark != null)
                  _buildLocationItem(
                    Icons.place,
                    l10n.landmark,
                    _event!.startPoint.landmark!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            l10n.finishPoint,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationItem(
                  Icons.flag,
                  l10n.address,
                  _event!.finishPoint.address,
                ),
                if (_event!.finishPoint.landmark != null)
                  _buildLocationItem(
                    Icons.place,
                    l10n.landmark,
                    _event!.finishPoint.landmark!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 地圖占位符
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('地圖載入中...'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: onTap != null ? Theme.of(context).primaryColor : null,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
            if (onTap != null) Icon(Icons.launch, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildEnhancedEntryFeeDisplay(MarathonRace race, AppLocalizations l10n) {
    final currencyFormat = NumberFormat.currency(symbol: 'USD ');
    final dateFormat = DateFormat('MM/dd/yyyy');
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n.entryFee,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (race.entryFee == 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Text(
                l10n.free,
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ] else ...[
            // Early Bird Pricing Display
            if (race.earlyBirdFee != null && race.earlyBirdDeadline != null) ...[
              if (race.isEarlyBirdPeriod) ...[
                // Currently in early bird period
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[400]!, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.green[700], size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Early Bird Price',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(race.earlyBirdFee!),
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Until ${dateFormat.format(race.earlyBirdDeadline!)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Regular price info
                Text(
                  'Regular Price: ${currencyFormat.format(race.entryFee)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ] else ...[
                // Past early bird period
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(race.entryFee),
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Early Bird: ${currencyFormat.format(race.earlyBirdFee!)} (Expired ${dateFormat.format(race.earlyBirdDeadline!)})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // No early bird pricing
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Text(
                  currencyFormat.format(race.entryFee),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(MarathonStatus status, AppLocalizations l10n) {
    // 使用與 MarathonEventsScreen 相同的狀態顯示邏輯
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case MarathonStatus.upcoming:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        text = l10n.upcoming;
        break;
      case MarathonStatus.registrationOpen:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = l10n.registrationOpen;
        break;
      case MarathonStatus.registrationClosed:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = l10n.registrationClosed;
        break;
      case MarathonStatus.ongoing:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        text = l10n.ongoing;
        break;
      case MarathonStatus.completed:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.grey[800]!;
        text = l10n.completed;
        break;
      case MarathonStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        text = l10n.cancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRaceStatusChip(MarathonRace race, AppLocalizations l10n) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (race.isRegistrationOpen) {
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
      text = l10n.registrationOpen;
    } else if (race.isFull) {
      backgroundColor = Colors.red[100]!;
      textColor = Colors.red[800]!;
      text = l10n.raceFull;
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[800]!;
      text = l10n.registrationClosed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _shareEvent() {
    // 實作分享功能
    final text = '${_event!.name}\n${_event!.description}\n${_event!.location.address}';
    // 使用 share_plus 套件分享
    debugPrint('分享賽事: $text');
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('無法開啟 URL: $url, 錯誤: $e');
    }
  }

  void _showRegistrationPage(MarathonRace race, AppLocalizations l10n) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarathonRegistrationWithParticipantsScreen(
          eventId: _event!.id,
          raceId: race.id,
        ),
      ),
    ).then((_) {
      _loadEvent(); // 重新載入賽事資料
    });
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 64, color: Colors.white),
                        SizedBox(height: 16),
                        Text('圖片載入失敗', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarathonRegistrationScreen extends StatefulWidget {
  final MarathonEvent event;
  final MarathonRace race;
  final VoidCallback onRegistrationComplete;

  const MarathonRegistrationScreen({
    super.key,
    required this.event,
    required this.race,
    required this.onRegistrationComplete,
  });

  @override
  State<MarathonRegistrationScreen> createState() => _MarathonRegistrationScreenState();
}

class _MarathonRegistrationScreenState extends State<MarathonRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _medicalInfoController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _medicalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerForRace),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 賽事資訊
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.race.getDistanceText()),
                    _buildRegistrationFeeDisplay(widget.race, l10n),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 參賽者姓名
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.participantName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.pleaseEnterParticipantName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 電子郵件
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.validEmailRequired;
                  }
                  if (!value!.contains('@')) {
                    return l10n.validEmailRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 電話號碼
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // 緊急聯絡人
              TextFormField(
                controller: _emergencyContactController,
                decoration: InputDecoration(
                  labelText: l10n.emergencyContactName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 緊急聯絡人電話
              TextFormField(
                controller: _emergencyPhoneController,
                decoration: InputDecoration(
                  labelText: l10n.emergencyContactPhone,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // 醫療資訊
              TextFormField(
                controller: _medicalInfoController,
                decoration: InputDecoration(
                  labelText: l10n.medicalInformation,
                  hintText: l10n.medicalHistoryHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isRegistering ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isRegistering ? null : _register,
                child: _isRegistering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.register),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final marathonService = context.read<MarathonService>();
      final authService = context.read<AuthService>();
      final userId = authService.userId ?? 'user_1'; // 使用默認用戶ID

      final success = await marathonService.registerForRace(
        eventId: widget.event.id,
        raceId: widget.race.id,
        userId: userId,
        participantName: _nameController.text,
        participantEmail: _emailController.text,
        participantPhone: _phoneController.text.isEmpty ? null : _phoneController.text,
        emergencyContact: _emergencyContactController.text.isEmpty ? null : _emergencyContactController.text,
        emergencyPhone: _emergencyPhoneController.text.isEmpty ? null : _emergencyPhoneController.text,
        medicalInfo: _medicalInfoController.text.isEmpty ? null : _medicalInfoController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onRegistrationComplete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registrationSuccessful),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registrationFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.registrationFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Widget _buildRegistrationFeeDisplay(MarathonRace race, AppLocalizations l10n) {
    final currencyFormat = NumberFormat.currency(symbol: 'USD ');
    final dateFormat = DateFormat('MM/dd/yyyy');
    
    if (race.entryFee == 0) {
      return Text(
        '${l10n.entryFee}: ${l10n.free}',
        style: TextStyle(
          color: Colors.green[700],
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (race.earlyBirdFee != null && race.isEarlyBirdPeriod) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '${l10n.entryFee}: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: currencyFormat.format(race.earlyBirdFee!),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' (Early Bird)',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Until ${dateFormat.format(race.earlyBirdDeadline!)}',
            style: TextStyle(
              color: Colors.green[600],
              fontSize: 11,
            ),
          ),
        ],
      );
    }
    
    return Text(
      '${l10n.entryFee}: ${currencyFormat.format(race.entryFee)}',
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}