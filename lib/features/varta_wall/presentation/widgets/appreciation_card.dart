import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class AppreciationCard extends StatelessWidget {
  const AppreciationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      color: AppConfig.lightCream,
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: AppConfig.primaryTeal,
                  size: 24,
                ),
                const SizedBox(width: AppConfig.smallSpacing),
                Text(
                  localizations.appreciationCorner,
                  style: const TextStyle(
                    fontSize: AppConfig.largeFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.mediumSpacing),
            Container(
              padding: const EdgeInsets.all(AppConfig.mediumSpacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                border:
                    Border.all(color: AppConfig.primaryTeal.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildAppreciationItem(
                    icon: Icons.visibility,
                    text: '5 लोगों ने आपकी आज की पोस्ट देखी',
                    color: AppConfig.talkBlue,
                  ),
                  const SizedBox(height: AppConfig.smallSpacing),
                  _buildAppreciationItem(
                    icon: Icons.favorite,
                    text: 'रमेश जी ने आपके वॉयस नोट को पसंद किया',
                    color: AppConfig.sosRed,
                  ),
                  const SizedBox(height: AppConfig.smallSpacing),
                  _buildAppreciationItem(
                    icon: Icons.star,
                    text: 'आपको आज 10 होसला पॉइंट्स मिले!',
                    color: AppConfig.warningOrange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppreciationItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppConfig.smallSpacing),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: AppConfig.mediumFontSize,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
