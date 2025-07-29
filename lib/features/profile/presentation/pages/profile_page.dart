import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Edit profile
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.mediumSpacing),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.largeSpacing),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConfig.primaryTeal,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: AppConfig.mediumSpacing),
                    const Text(
                      'रमेश कुमार',
                      style: TextStyle(
                        fontSize: AppConfig.largeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConfig.smallSpacing),
                    Text(
                      '+91 98765 43210',
                      style: TextStyle(
                        fontSize: AppConfig.mediumFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: AppConfig.smallSpacing),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.mediumSpacing,
                        vertical: AppConfig.smallSpacing,
                      ),
                      decoration: BoxDecoration(
                        color: AppConfig.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: AppConfig.warningOrange,
                            size: 16,
                          ),
                          const SizedBox(width: AppConfig.smallSpacing),
                          Text(
                            '${localizations.rewardPoints}: 250',
                            style: const TextStyle(
                              fontSize: AppConfig.smallFontSize,
                              color: AppConfig.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.mediumSpacing),

            // Profile details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Details',
                      style: const TextStyle(
                        fontSize: AppConfig.mediumFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConfig.mediumSpacing),
                    _buildDetailRow(
                        Icons.cake, localizations.dateOfBirth, '15 जनवरी 1955'),
                    _buildDetailRow(
                        Icons.person, localizations.gender, 'पुरुष'),
                    _buildDetailRow(
                        Icons.location_on, 'Address', 'दिल्ली, भारत'),
                    _buildDetailRow(Icons.info, localizations.bio,
                        'खुशमिजाज इंसान, बागवानी का शौक'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.mediumSpacing),

            // Health tracking
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.healthTracker,
                      style: const TextStyle(
                        fontSize: AppConfig.mediumFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConfig.mediumSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMoodButton('😊', 'खुश', true),
                        _buildMoodButton('😐', 'ठीक', false),
                        _buildMoodButton('😞', 'उदास', false),
                        _buildMoodButton('🩺', 'डॉक्टर', false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.mediumSpacing),

            // Settings and options
            Card(
              child: Column(
                children: [
                  _buildSettingsTile(
                    Icons.notifications,
                    'Notifications',
                    'Manage your notifications',
                    () {},
                  ),
                  _buildSettingsTile(
                    Icons.language,
                    'Language',
                    'हिंदी',
                    () {},
                  ),
                  _buildSettingsTile(
                    Icons.dark_mode,
                    'Theme',
                    'Light Mode',
                    () {},
                  ),
                  _buildSettingsTile(
                    Icons.privacy_tip,
                    'Privacy',
                    'Privacy settings',
                    () {},
                  ),
                  _buildSettingsTile(
                    Icons.help,
                    'Help & Support',
                    'Get help and contact us',
                    () {},
                  ),
                  _buildSettingsTile(
                    Icons.logout,
                    'Logout',
                    'Sign out of your account',
                    () {},
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConfig.smallSpacing),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConfig.primaryTeal),
          const SizedBox(width: AppConfig.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppConfig.smallFontSize,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppConfig.mediumFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String label, bool isSelected) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? AppConfig.primaryTeal.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            border: Border.all(
              color: isSelected ? AppConfig.primaryTeal : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: AppConfig.smallSpacing),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppConfig.primaryTeal : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppConfig.errorRed : AppConfig.primaryTeal,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppConfig.mediumFontSize,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppConfig.errorRed : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: AppConfig.smallFontSize),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
