import 'package:flutter/material.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellNavigatorKey => _shellNavigatorKey;

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String vartaWall = '/varta-wall';
  static const String trustCircle = '/trust-circle';
  static const String chatList = '/chat-list';
  static const String events = '/events';
  static const String emergency = '/emergency';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'Onboarding'),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'Login'),
          settings: settings,
        );
      case otpVerification:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'OTP Verification'),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'Home'),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
          settings: settings,
        );
    }
  }

  static void pushNamed(String routeName, {Object? arguments}) {
    _rootNavigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static void pushReplacementNamed(String routeName, {Object? arguments}) {
    _rootNavigatorKey.currentState
        ?.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pushNamedAndClearStack(String routeName, {Object? arguments}) {
    _rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop([Object? result]) {
    _rootNavigatorKey.currentState?.pop(result);
  }

  static bool canPop() {
    return _rootNavigatorKey.currentState?.canPop() ?? false;
  }
}

// Placeholder pages (to be implemented)
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Page - To be implemented'),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title - To be implemented'),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text('404 - Page Not Found'),
      ),
    );
  }
}
