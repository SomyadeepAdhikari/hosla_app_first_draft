import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.events),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.upcomingEvents),
            Tab(text: localizations.pastEvents),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingEvents(context),
          _buildPastEvents(context),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.mediumSpacing),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: AppConfig.mediumSpacing),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image placeholder
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppConfig.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
                child: const Center(
                  child: Icon(
                    Icons.event,
                    size: 48,
                    color: AppConfig.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(height: AppConfig.mediumSpacing),

              // Event title
              Text(
                'योग और ध्यान सत्र ${index + 1}',
                style: const TextStyle(
                  fontSize: AppConfig.largeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConfig.smallSpacing),

              // Event details
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppConfig.primaryTeal),
                  const SizedBox(width: AppConfig.smallSpacing),
                  Text(
                    '${DateTime.now().add(Duration(days: index + 1)).day}/'
                    '${DateTime.now().add(Duration(days: index + 1)).month}/'
                    '${DateTime.now().add(Duration(days: index + 1)).year}',
                    style: const TextStyle(fontSize: AppConfig.smallFontSize),
                  ),
                  const SizedBox(width: AppConfig.mediumSpacing),
                  const Icon(Icons.access_time,
                      size: 16, color: AppConfig.primaryTeal),
                  const SizedBox(width: AppConfig.smallSpacing),
                  Text(
                    '${6 + index}:00 AM',
                    style: const TextStyle(fontSize: AppConfig.smallFontSize),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.smallSpacing),

              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppConfig.primaryTeal),
                  const SizedBox(width: AppConfig.smallSpacing),
                  Expanded(
                    child: Text(
                      index % 2 == 0
                          ? 'सामुदायिक केंद्र, दिल्ली'
                          : 'ऑनलाइन इवेंट',
                      style: const TextStyle(fontSize: AppConfig.smallFontSize),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.mediumSpacing),

              // Event description
              Text(
                'स्वास्थ्य और कल्याण के लिए एक विशेष योग सत्र। सभी उम्र के लोग आमंत्रित हैं।',
                style: TextStyle(
                  fontSize: AppConfig.smallFontSize,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppConfig.mediumSpacing),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Mark as interested
                      },
                      icon: const Icon(Icons.star_border),
                      label: Text(localizations.interested),
                    ),
                  ),
                  const SizedBox(width: AppConfig.mediumSpacing),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Mark as attending
                      },
                      icon: const Icon(Icons.check),
                      label: Text(localizations.attending),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastEvents(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.mediumSpacing),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: AppConfig.mediumSpacing),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'सामुदायिक खाना ${index + 1}',
                      style: const TextStyle(
                        fontSize: AppConfig.mediumFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConfig.smallSpacing,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppConfig.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Attended',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConfig.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.smallSpacing),
              Text(
                '${DateTime.now().subtract(Duration(days: (index + 1) * 7)).day}/'
                '${DateTime.now().subtract(Duration(days: (index + 1) * 7)).month}/'
                '${DateTime.now().subtract(Duration(days: (index + 1) * 7)).year}',
                style: TextStyle(
                  fontSize: AppConfig.smallFontSize,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppConfig.mediumSpacing),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: View event memories/photos
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('View Memories'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryTeal.withOpacity(0.1),
                  foregroundColor: AppConfig.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
