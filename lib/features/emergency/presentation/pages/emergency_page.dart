import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.emergency),
        backgroundColor: AppConfig.sosRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.mediumSpacing),
        child: Column(
          children: [
            // Emergency alert banner
            Container(
              padding: const EdgeInsets.all(AppConfig.mediumSpacing),
              decoration: BoxDecoration(
                color: AppConfig.sosRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                border: Border.all(color: AppConfig.sosRed),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppConfig.sosRed, size: 28),
                  const SizedBox(width: AppConfig.mediumSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Services',
                          style: TextStyle(
                            fontSize: AppConfig.largeFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.sosRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quick access to emergency contacts and services',
                          style: TextStyle(
                            fontSize: AppConfig.smallFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConfig.largeSpacing),

            // Emergency contact buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConfig.mediumSpacing,
                mainAxisSpacing: AppConfig.mediumSpacing,
                children: [
                  _buildEmergencyButton(
                    context,
                    icon: Icons.local_hospital,
                    title: 'Ambulance',
                    subtitle: '102',
                    color: AppConfig.sosRed,
                    onTap: () => _callEmergency(context, '102'),
                  ),
                  _buildEmergencyButton(
                    context,
                    icon: Icons.local_police,
                    title: 'Police',
                    subtitle: '100',
                    color: Colors.blue,
                    onTap: () => _callEmergency(context, '100'),
                  ),
                  _buildEmergencyButton(
                    context,
                    icon: Icons.local_fire_department,
                    title: 'Fire Service',
                    subtitle: '101',
                    color: Colors.orange,
                    onTap: () => _callEmergency(context, '101'),
                  ),
                  _buildEmergencyButton(
                    context,
                    icon: Icons.medical_services,
                    title: 'Health Helpline',
                    subtitle: '104',
                    color: AppConfig.successGreen,
                    onTap: () => _callEmergency(context, '104'),
                  ),
                  _buildEmergencyButton(
                    context,
                    icon: Icons.family_restroom,
                    title: 'Family Doctor',
                    subtitle: 'Dr. Sharma',
                    color: AppConfig.primaryTeal,
                    onTap: () => _callEmergency(context, '+91XXXXXXXXXX'),
                  ),
                  _buildEmergencyButton(
                    context,
                    icon: Icons.contact_emergency,
                    title: 'Emergency Contact',
                    subtitle: 'Son/Daughter',
                    color: AppConfig.helpOrange,
                    onTap: () => _callEmergency(context, '+91XXXXXXXXXX'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConfig.mediumSpacing),

            // SOS history
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent SOS Alerts',
                      style: TextStyle(
                        fontSize: AppConfig.mediumFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConfig.mediumSpacing),
                    _buildSOSHistoryItem(
                      'Need Help',
                      '2 hours ago',
                      'Resolved',
                      AppConfig.successGreen,
                    ),
                    _buildSOSHistoryItem(
                      'Want to Talk',
                      '1 day ago',
                      'Resolved',
                      AppConfig.successGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.mediumSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppConfig.mediumSpacing),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConfig.mediumFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConfig.smallSpacing),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppConfig.smallFontSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSHistoryItem(
    String type,
    String time,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConfig.smallSpacing),
      child: Row(
        children: [
          const Icon(Icons.history, size: 16, color: Colors.grey),
          const SizedBox(width: AppConfig.smallSpacing),
          Expanded(
            child: Text(
              '$type • $time',
              style: const TextStyle(fontSize: AppConfig.smallFontSize),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callEmergency(BuildContext context, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: Text('Do you want to call $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $number...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConfig.sosRed),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
