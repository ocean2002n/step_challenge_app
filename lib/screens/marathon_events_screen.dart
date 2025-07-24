import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/marathon_model.dart';
import '../services/marathon_service.dart';
import 'marathon_detail_screen.dart';

class MarathonEventsScreen extends StatefulWidget {
  const MarathonEventsScreen({super.key});

  @override
  State<MarathonEventsScreen> createState() => _MarathonEventsScreenState();
}

class _MarathonEventsScreenState extends State<MarathonEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  MarathonSearchFilter _currentFilter = const MarathonSearchFilter();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarathonService>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        _buildSearchAndFilter(l10n),
        Expanded(
          child: Consumer<MarathonService>(
            builder: (context, marathonService, child) {
              if (marathonService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = marathonService.searchEvents(filter: _currentFilter);
              
              if (events.isEmpty) {
                return _buildEmptyState(l10n);
              }

              return RefreshIndicator(
                onRefresh: marathonService.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(events[index], l10n);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchMarathonEvents,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilter(_currentFilter.copyWith(keyword: ''));
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) {
                _updateFilter(_currentFilter.copyWith(keyword: value));
              },
            ),
          ),
          const SizedBox(width: 12),
          // 篩選按鈕
          Container(
            decoration: BoxDecoration(
              color: _currentFilter.hasFilters ? Theme.of(context).primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _currentFilter.hasFilters ? Theme.of(context).primaryColor : Colors.grey[300]!,
              ),
            ),
            child: IconButton(
              onPressed: _showFilterPage,
              icon: Icon(
                _currentFilter.hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _currentFilter.hasFilters ? Colors.white : Colors.grey[600],
              ),
              tooltip: l10n.filter,
            ),
          ),
          if (_currentFilter.hasFilters) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: IconButton(
                onPressed: _clearFilter,
                icon: Icon(Icons.clear_all, color: Colors.red[600]),
                tooltip: l10n.clearFilter,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(MarathonEvent event, AppLocalizations l10n) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).toString());
    final earliestDate = event.earliestRaceDate;
    final latestDate = event.latestRaceDate;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarathonDetailScreen(eventId: event.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 代表性照片
            if (event.imageUrl != null) ...[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // 賽事標題和狀態
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(event.status, l10n),
                ],
              ),
              const SizedBox(height: 8),
              
              // 賽事描述
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 基本信息
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    earliestDate != null && latestDate != null
                        ? earliestDate == latestDate
                            ? dateFormat.format(earliestDate)
                            : '${dateFormat.format(earliestDate)} - ${dateFormat.format(latestDate)}'
                        : l10n.dateNotSet,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.organizer,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              
              // 標籤
              if (event.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: event.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(MarathonStatus status, AppLocalizations l10n) {
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noMarathonEvents,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noMarathonEventsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _updateFilter(MarathonSearchFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
    context.read<MarathonService>().updateFilter(filter);
  }

  void _clearFilter() {
    _searchController.clear();
    _updateFilter(const MarathonSearchFilter());
  }

  void _showFilterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarathonFilterScreen(
          currentFilter: _currentFilter,
          onFilterChanged: _updateFilter,
        ),
      ),
    );
  }
}

class MarathonFilterScreen extends StatefulWidget {
  final MarathonSearchFilter currentFilter;
  final ValueChanged<MarathonSearchFilter> onFilterChanged;

  const MarathonFilterScreen({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<MarathonFilterScreen> createState() => _MarathonFilterScreenState();
}

class _MarathonFilterScreenState extends State<MarathonFilterScreen> {
  late MarathonSearchFilter _filter;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _locationController = TextEditingController(text: _filter.location ?? '');
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterMarathonEvents),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filter = const MarathonSearchFilter();
                _locationController.clear();
              });
            },
            child: Text(l10n.clearAll),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 狀態過濾
            Text(l10n.status, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MarathonStatus.values.map((status) {
                return FilterChip(
                  label: Text(_getStatusText(status, l10n)),
                  selected: _filter.status == status,
                  onSelected: (selected) {
                    setState(() {
                      _filter = _filter.copyWith(
                        status: selected ? status : null,
                      );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 距離過濾
            Text(l10n.distance, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: MarathonDistance.values.map((distance) {
                final isSelected = _filter.distances?.contains(distance) ?? false;
                return FilterChip(
                  label: Text(_getDistanceText(distance)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final currentDistances = _filter.distances?.toList() ?? <MarathonDistance>[];
                      if (selected) {
                        currentDistances.add(distance);
                      } else {
                        currentDistances.remove(distance);
                      }
                      _filter = _filter.copyWith(
                        distances: currentDistances.isEmpty ? null : currentDistances,
                      );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 地點過濾
            Text(l10n.location, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: l10n.enterLocation,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                _filter = _filter.copyWith(location: value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 16),

            // 日期範圍過濾
            Text(l10n.dateRange, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(true),
                    child: Text(
                      _filter.startDate != null
                          ? DateFormat('yyyy/MM/dd').format(_filter.startDate!)
                          : l10n.startDate,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('-'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(false),
                    child: Text(
                      _filter.endDate != null
                          ? DateFormat('yyyy/MM/dd').format(_filter.endDate!)
                          : l10n.endDate,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.onFilterChanged(_filter);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.apply),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(MarathonStatus status, AppLocalizations l10n) {
    switch (status) {
      case MarathonStatus.upcoming:
        return l10n.upcoming;
      case MarathonStatus.registrationOpen:
        return l10n.registrationOpen;
      case MarathonStatus.registrationClosed:
        return l10n.registrationClosed;
      case MarathonStatus.ongoing:
        return l10n.ongoing;
      case MarathonStatus.completed:
        return l10n.completed;
      case MarathonStatus.cancelled:
        return l10n.cancelled;
    }
  }

  String _getDistanceText(MarathonDistance distance) {
    switch (distance) {
      case MarathonDistance.twoK:
        return '2K';
      case MarathonDistance.fiveK:
        return '5K';
      case MarathonDistance.tenK:
        return '10K';
      case MarathonDistance.halfMarathon:
        return 'Half Marathon';
      case MarathonDistance.fullMarathon:
        return 'Full Marathon';
      case MarathonDistance.ultraMarathon:
        return 'Ultra Marathon';
      case MarathonDistance.custom:
        return 'Custom';
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? _filter.startDate ?? DateTime.now()
          : _filter.endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _filter = _filter.copyWith(startDate: selectedDate);
        } else {
          _filter = _filter.copyWith(endDate: selectedDate);
        }
      });
    }
  }
}