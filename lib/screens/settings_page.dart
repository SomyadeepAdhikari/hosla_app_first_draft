import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/senior_friendly_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state variables
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _emergencyAlertsEnabled = true;
  bool _largeTextMode = false;
  bool _highContrastMode = false;
  bool _voiceAssistantEnabled = false;
  bool _autoReadMessages = false;
  bool _locationSharingEnabled = true;
  bool _dataBackupEnabled = true;
  
  String _selectedTheme = 'Warm Theme'; // Default theme
  String _selectedLanguage = 'English';
  String _selectedTextSize = 'Large';
  String _selectedRingtone = 'Default';
  
  double _fontSize = 18.0;
  double _emergencyButtonSize = 60.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionCard(
            'Appearance',
            Icons.palette,
            [
              _buildThemeSelector(),
              _buildSwitchTile(
                'High Contrast Mode',
                'Better visibility with bold colors',
                _highContrastMode,
                Icons.contrast,
                (value) => setState(() => _highContrastMode = value),
              ),
              _buildSwitchTile(
                'Large Text Mode',
                'Increase text size throughout the app',
                _largeTextMode,
                Icons.text_fields,
                (value) => setState(() => _largeTextMode = value),
              ),
              _buildSliderTile(
                'Text Size',
                'Adjust reading comfort',
                _fontSize,
                14.0,
                28.0,
                Icons.format_size,
                (value) => setState(() => _fontSize = value),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notifications Section
          _buildSectionCard(
            'Notifications',
            Icons.notifications,
            [
              _buildSwitchTile(
                'Enable Notifications',
                'Receive important updates',
                _notificationsEnabled,
                Icons.notifications_active,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchTile(
                'Emergency Alerts',
                'Critical emergency notifications',
                _emergencyAlertsEnabled,
                Icons.emergency,
                (value) => setState(() => _emergencyAlertsEnabled = value),
              ),
              _buildSwitchTile(
                'Sound',
                'Play notification sounds',
                _soundEnabled,
                Icons.volume_up,
                (value) => setState(() => _soundEnabled = value),
              ),
              _buildSwitchTile(
                'Vibration',
                'Feel notifications with vibration',
                _vibrationEnabled,
                Icons.vibration,
                (value) => setState(() => _vibrationEnabled = value),
              ),
              _buildDropdownTile(
                'Ringtone',
                'Choose notification sound',
                _selectedRingtone,
                ['Default', 'Gentle Bell', 'Soft Chime', 'Nature Sounds'],
                Icons.music_note,
                (value) => setState(() => _selectedRingtone = value!),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Accessibility Section
          _buildSectionCard(
            'Accessibility',
            Icons.accessibility,
            [
              _buildSwitchTile(
                'Voice Assistant',
                'Read messages and notifications aloud',
                _voiceAssistantEnabled,
                Icons.record_voice_over,
                (value) => setState(() => _voiceAssistantEnabled = value),
              ),
              _buildSwitchTile(
                'Auto-Read Messages',
                'Automatically read incoming messages',
                _autoReadMessages,
                Icons.hearing,
                (value) => setState(() => _autoReadMessages = value),
              ),
              _buildSliderTile(
                'Emergency Button Size',
                'Adjust for easier access',
                _emergencyButtonSize,
                40.0,
                80.0,
                Icons.emergency_share,
                (value) => setState(() => _emergencyButtonSize = value),
              ),
              _buildActionTile(
                'Voice Commands Tutorial',
                'Learn voice control features',
                Icons.school,
                () => _showVoiceTutorial(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Language & Region Section
          _buildSectionCard(
            'Language & Region',
            Icons.language,
            [
              _buildDropdownTile(
                'Language',
                'Choose your preferred language',
                _selectedLanguage,
                ['English', 'Hindi', 'Bengali', 'Tamil', 'Telugu'],
                Icons.translate,
                (value) => setState(() => _selectedLanguage = value!),
              ),
              _buildActionTile(
                'Date & Time Format',
                'Customize date and time display',
                Icons.schedule,
                () => _showDateTimeSettings(context),
              ),
              _buildActionTile(
                'Region Settings',
                'Set your location preferences',
                Icons.location_on,
                () => _showRegionSettings(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Privacy & Security Section
          _buildSectionCard(
            'Privacy & Security',
            Icons.security,
            [
              _buildSwitchTile(
                'Location Sharing',
                'Share location with trust circle',
                _locationSharingEnabled,
                Icons.my_location,
                (value) => setState(() => _locationSharingEnabled = value),
              ),
              _buildActionTile(
                'Emergency Contacts',
                'Manage who gets emergency alerts',
                Icons.contact_emergency,
                () => _showEmergencyContacts(context),
              ),
              _buildActionTile(
                'Privacy Settings',
                'Control who can see your information',
                Icons.privacy_tip,
                () => _showPrivacySettings(context),
              ),
              _buildActionTile(
                'Change Password',
                'Update your account security',
                Icons.lock,
                () => _showChangePassword(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Data & Backup Section
          _buildSectionCard(
            'Data & Backup',
            Icons.backup,
            [
              _buildSwitchTile(
                'Auto Backup',
                'Automatically backup your data',
                _dataBackupEnabled,
                Icons.cloud_upload,
                (value) => setState(() => _dataBackupEnabled = value),
              ),
              _buildActionTile(
                'Backup Now',
                'Create a backup of your data',
                Icons.backup,
                () => _performBackup(context),
              ),
              _buildActionTile(
                'Restore Data',
                'Restore from previous backup',
                Icons.restore,
                () => _showRestoreOptions(context),
              ),
              _buildActionTile(
                'Export Contacts',
                'Save contacts to external storage',
                Icons.download,
                () => _exportContacts(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Help & Support Section
          _buildSectionCard(
            'Help & Support',
            Icons.help,
            [
              _buildActionTile(
                'Help Center',
                'Find answers to common questions',
                Icons.help_center,
                () => _showHelpCenter(context),
              ),
              _buildActionTile(
                'Tutorial Videos',
                'Learn how to use the app',
                Icons.play_circle,
                () => _showTutorials(context),
              ),
              _buildActionTile(
                'Contact Support',
                'Get help from our team',
                Icons.support_agent,
                () => _contactSupport(context),
              ),
              _buildActionTile(
                'Send Feedback',
                'Help us improve the app',
                Icons.feedback,
                () => _sendFeedback(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSectionCard(
            'About',
            Icons.info,
            [
              _buildActionTile(
                'App Version',
                'Hosla Varta v1.0.0',
                Icons.info_outline,
                () => _showAppInfo(context),
              ),
              _buildActionTile(
                'Terms of Service',
                'Read our terms and conditions',
                Icons.description,
                () => _showTerms(context),
              ),
              _buildActionTile(
                'Privacy Policy',
                'Learn about data protection',
                Icons.policy,
                () => _showPrivacyPolicy(context),
              ),
              _buildActionTile(
                'Licenses',
                'Third-party software licenses',
                Icons.copyright,
                () => _showLicenses(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Account Section
          _buildSectionCard(
            'Account',
            Icons.account_circle,
            [
              _buildActionTile(
                'Sign Out',
                'Log out of your account',
                Icons.logout,
                () => _showSignOutDialog(context),
                isDestructive: true,
              ),
              _buildActionTile(
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever,
                () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    IconData icon,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 24),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.zero,
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 2).round(),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.palette, size: 24),
          title: const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: const Text('Choose your preferred color theme', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption(
                'Warm Theme',
                'Comfortable colors for daily use',
                SeniorFriendlyTheme.warmBlue,
                SeniorFriendlyTheme.warmCream,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemeOption(
                'High Contrast',
                'Bold colors for better visibility',
                Colors.black,
                Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption(
                'Classic Teal',
                'Original app theme',
                Colors.teal,
                const Color(0xFFFFF8E1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(String name, String description, Color primary, Color background) {
    final isSelected = _selectedTheme == name;
    
    return InkWell(
      onTap: () {
        setState(() => _selectedTheme = name);
        _applyTheme(name);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? primary : Colors.black87,
              ),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Theme application logic
  void _applyTheme(String themeName) {
    // Show preview of the selected theme
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview: $themeName'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              // Show theme preview
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: _getThemePreviewColor(themeName),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Sample App Bar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: _getThemeBackgroundColor(themeName),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getThemeTextColor(themeName),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is how text will look with the $themeName theme.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getThemeTextColor(themeName),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Applied $themeName! Restart app to see full changes.'),
                  action: SnackBarAction(
                    label: 'Restart Later',
                    onPressed: () {},
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Apply Theme'),
          ),
        ],
      ),
    );
  }

  Color _getThemePreviewColor(String themeName) {
    switch (themeName) {
      case 'Warm Theme':
        return SeniorFriendlyTheme.warmBlue;
      case 'High Contrast':
        return Colors.black;
      case 'Classic Teal':
        return Colors.teal;
      default:
        return SeniorFriendlyTheme.warmBlue;
    }
  }

  Color _getThemeBackgroundColor(String themeName) {
    switch (themeName) {
      case 'Warm Theme':
        return SeniorFriendlyTheme.warmCream;
      case 'High Contrast':
        return Colors.white;
      case 'Classic Teal':
        return const Color(0xFFFFF8E1);
      default:
        return SeniorFriendlyTheme.warmCream;
    }
  }

  Color _getThemeTextColor(String themeName) {
    switch (themeName) {
      case 'High Contrast':
        return Colors.black;
      default:
        return SeniorFriendlyTheme.primaryText;
    }
  }

  // Dialog and action methods
  void _showVoiceTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Commands'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available voice commands:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('• "Call [name]" - Make a phone call'),
              Text('• "Send message to [name]" - Send a message'),
              Text('• "Emergency help" - Trigger emergency alert'),
              Text('• "Read messages" - Read unread messages'),
              Text('• "What time is it?" - Announce current time'),
              Text('• "Battery level" - Check battery status'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showDateTimeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date & Time Format'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('12-hour format'),
              trailing: Radio<bool>(value: false, groupValue: true, onChanged: null),
            ),
            ListTile(
              title: Text('24-hour format'),
              trailing: Radio<bool>(value: true, groupValue: true, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }

  void _showRegionSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Region Settings'),
        content: const Text('Set your region for localized features like emergency numbers and date formats.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Configure')),
        ],
      ),
    );
  }

  void _showEmergencyContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            children: [
              _buildEmergencyContactCard(
                'Primary Contact',
                'Ram Sharma (Son)',
                '+91 98765 43210',
                Icons.person,
                Colors.blue,
                true,
              ),
              const SizedBox(height: 12),
              _buildEmergencyContactCard(
                'Secondary Contact',
                'Dr. Rajesh Verma',
                '+91 87654 32109',
                Icons.medical_services,
                Colors.red,
                true,
              ),
              const SizedBox(height: 12),
              _buildEmergencyContactCard(
                'Neighbor Contact',
                'Mrs. Gupta',
                '+91 76543 21098',
                Icons.home,
                Colors.green,
                false,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddEmergencyContact(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Contact'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(
    String type,
    String name,
    String phone,
    IconData icon,
    Color color,
    bool isEnabled,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (value) {
                // Handle enabling/disabling contact
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEmergencyContact(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedType = 'Family Member';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Contact Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  'Family Member',
                  'Doctor',
                  'Neighbor',
                  'Friend',
                  'Caregiver',
                ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${nameController.text} as emergency contact'),
                    ),
                  );
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Control who can see your profile, posts, and activity status.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Configure')),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Update')),
        ],
      ),
    );
  }

  void _performBackup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating backup...'),
          ],
        ),
      ),
    );
    
    // Simulate backup process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup completed successfully!')),
      );
    });
  }

  void _showRestoreOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('Choose a backup to restore from:'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Select Backup')),
        ],
      ),
    );
  }

  void _exportContacts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacts exported to Downloads folder')),
    );
  }

  void _showHelpCenter(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Help Center...')),
    );
  }

  void _showTutorials(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial Videos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.play_circle, color: Colors.blue),
              title: Text('Getting Started'),
              subtitle: Text('Basic app navigation'),
            ),
            ListTile(
              leading: Icon(Icons.play_circle, color: Colors.blue),
              title: Text('Trust Circle Setup'),
              subtitle: Text('Adding family members'),
            ),
            ListTile(
              leading: Icon(Icons.play_circle, color: Colors.blue),
              title: Text('Emergency Features'),
              subtitle: Text('Using SOS and alerts'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Call Support'),
              subtitle: Text('+91 1800-123-4567'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Email Support'),
              subtitle: Text('support@hoslavarta.com'),
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.orange),
              title: Text('Live Chat'),
              subtitle: Text('Available 9 AM - 6 PM'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'What is this about?',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Tell us what you think...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Send')),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Hosla Varta'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            Text('Build: 2024.07.001'),
            SizedBox(height: 16),
            Text('Hosla Varta is designed to keep senior citizens connected with their loved ones in a simple and secure way.'),
            SizedBox(height: 16),
            Text('© 2024 Hosla Varta. All rights reserved.'),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Terms of Service...')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Privacy Policy...')),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Hosla Varta',
      applicationVersion: '1.0.0',
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Would handle sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type "DELETE" to confirm account deletion:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
