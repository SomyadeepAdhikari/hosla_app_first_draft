import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.chat),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search chats
            },
            icon: const Icon(Icons.search, size: 28),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 8, // Sample data
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConfig.mediumSpacing,
            vertical: AppConfig.smallSpacing,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppConfig.mediumSpacing),
            leading: Stack(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppConfig.primaryTeal,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                if (index % 3 == 0) // Show online indicator for some users
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppConfig.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              index % 4 == 0 ? 'Family Group' : 'संपर्क ${index + 1}',
              style: const TextStyle(
                fontSize: AppConfig.mediumFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                index % 2 == 0 ? '🎤 Voice message' : 'नमस्ते, कैसे हैं आप?',
                style: TextStyle(
                  fontSize: AppConfig.smallFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  index % 3 == 0
                      ? '10:30 AM'
                      : '${9 + index}:${(index * 15) % 60}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (index % 5 == 0) // Show unread count for some chats
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppConfig.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to chat detail page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat detail page coming soon!')),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start new chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat feature coming soon!')),
          );
        },
        child: const Icon(Icons.chat, size: 28),
      ),
    );
  }
}
