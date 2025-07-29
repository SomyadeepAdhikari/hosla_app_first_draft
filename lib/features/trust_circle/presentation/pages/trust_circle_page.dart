import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class TrustCirclePage extends StatelessWidget {
  const TrustCirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.trustCircle),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add member functionality
            },
            icon: const Icon(Icons.person_add, size: 28),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show QR code
            },
            icon: const Icon(Icons.qr_code, size: 28),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.mediumSpacing),
        child: Column(
          children: [
            // Add member buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Scan QR code
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(localizations.scanQR),
                  ),
                ),
                const SizedBox(width: AppConfig.mediumSpacing),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add by phone number
                    },
                    icon: const Icon(Icons.phone),
                    label: Text(localizations.enterPhoneNumber),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.largeSpacing),

            // Trust circle members list
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Sample data
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppConfig.primaryTeal,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      'सदस्य ${index + 1}',
                      style:
                          const TextStyle(fontSize: AppConfig.mediumFontSize),
                    ),
                    subtitle: Text(
                      '+91 XXXXX ${(index + 1) * 11111}',
                      style: const TextStyle(fontSize: AppConfig.smallFontSize),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'call',
                          child: Row(
                            children: [
                              Icon(Icons.call),
                              SizedBox(width: 8),
                              Text('Call'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'message',
                          child: Row(
                            children: [
                              Icon(Icons.message),
                              SizedBox(width: 8),
                              Text('Message'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.remove_circle, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Remove',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        // TODO: Handle menu actions
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
