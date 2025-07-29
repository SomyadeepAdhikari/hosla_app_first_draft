import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../varta_wall/presentation/pages/varta_wall_page.dart';
import '../../../trust_circle/presentation/pages/trust_circle_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../emergency/presentation/pages/emergency_page.dart';
import '../widgets/sos_button.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const VartaWallPage(),
    const TrustCirclePage(),
    const ChatListPage(),
    const EventsPage(),
    const EmergencyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // SOS Button - Always visible
          const Positioned(
            top: 50,
            right: 16,
            child: SOSButton(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: AppConfig.smallFontSize,
          unselectedFontSize: AppConfig.smallFontSize,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home, size: 28),
              label: localizations.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group, size: 28),
              label: localizations.circle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat, size: 28),
              label: localizations.chat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event, size: 28),
              label: localizations.events,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emergency, size: 28),
              label: localizations.emergency,
            ),
          ],
        ),
      ),
    );
  }
}
