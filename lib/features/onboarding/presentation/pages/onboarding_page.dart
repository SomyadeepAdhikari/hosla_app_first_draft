import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      icon: Icons.elderly,
      title: 'होसला वार्ता में आपका स्वागत है',
      description:
          'वरिष्ठ नागरिकों के लिए विशेष रूप से डिज़ाइन किया गया सामाजिक मंच',
      color: AppConfig.primaryTeal,
    ),
    OnboardingItem(
      icon: Icons.group,
      title: 'अपना ट्रस्ट सर्कल बनाएं',
      description:
          'परिवार और दोस्तों के साथ सुरक्षित रूप से जुड़ें और बातचीत करें',
      color: AppConfig.successGreen,
    ),
    OnboardingItem(
      icon: Icons.mic,
      title: 'आवाज़ के साथ साझा करें',
      description: 'आसानी से वॉयस नोट्स भेजें और अपने विचार साझा करें',
      color: AppConfig.warningOrange,
    ),
    OnboardingItem(
      icon: Icons.emergency,
      title: 'आपातकालीन सहायता',
      description: 'SOS बटन के साथ तुरंत मदद मांगें और सुरक्षित रहें',
      color: AppConfig.sosRed,
    ),
    OnboardingItem(
      icon: Icons.celebration,
      title: 'प्रशंसा और प्रेरणा',
      description:
          'दैनिक प्रेरणादायक संदेश पाएं और अपनी उपलब्धियों का जश्न मनाएं',
      color: AppConfig.primaryTeal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppConfig.mediumSpacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.appName,
                    style: const TextStyle(
                      fontSize: AppConfig.mediumFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppConfig.primaryTeal,
                    ),
                  ),
                  if (_currentPage < _onboardingItems.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: AppConfig.mediumFontSize,
                          color: AppConfig.primaryTeal,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppConfig.largeSpacing),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 64,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: AppConfig.extraLargeSpacing),

                        // Title
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: AppConfig.extraLargeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConfig.mediumSpacing),

                        // Description
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: AppConfig.mediumFontSize,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(AppConfig.largeSpacing),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppConfig.primaryTeal
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConfig.largeSpacing),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentPage > 0)
                        const SizedBox(width: AppConfig.mediumSpacing),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentPage == _onboardingItems.length - 1
                              ? _completeOnboarding
                              : _nextPage,
                          child: Text(
                            _currentPage == _onboardingItems.length - 1
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    AppRouter.pushReplacementNamed(AppRouter.login);
  }

  void _completeOnboarding() {
    AppRouter.pushReplacementNamed(AppRouter.login);
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
