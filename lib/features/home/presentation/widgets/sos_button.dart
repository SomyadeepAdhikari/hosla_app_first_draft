import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FloatingActionButton(
      onPressed: () => _showSOSDialog(context),
      backgroundColor: AppConfig.sosRed,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(
        Icons.emergency,
        size: 28,
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.sosAlert,
          style: const TextStyle(
            fontSize: AppConfig.largeFontSize,
            fontWeight: FontWeight.bold,
            color: AppConfig.sosRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SOSOptionButton(
              icon: Icons.sick,
              text: localizations.notFeelingWell,
              color: AppConfig.sosRed,
              onTap: () => _sendSOSAlert(context, 'not_feeling_well'),
            ),
            const SizedBox(height: AppConfig.mediumSpacing),
            _SOSOptionButton(
              icon: Icons.help,
              text: localizations.needHelp,
              color: AppConfig.helpOrange,
              onTap: () => _sendSOSAlert(context, 'need_help'),
            ),
            const SizedBox(height: AppConfig.mediumSpacing),
            _SOSOptionButton(
              icon: Icons.chat,
              text: localizations.wantToTalk,
              color: AppConfig.talkBlue,
              onTap: () => _sendSOSAlert(context, 'want_to_talk'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              localizations.cancel,
              style: const TextStyle(fontSize: AppConfig.mediumFontSize),
            ),
          ),
        ],
      ),
    );
  }

  void _sendSOSAlert(BuildContext context, String alertType) {
    Navigator.of(context).pop();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.emergencyAlertSent,
          style: const TextStyle(fontSize: AppConfig.mediumFontSize),
        ),
        backgroundColor: AppConfig.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Implement actual SOS alert sending logic
    // This would send alerts to trust circle members and admins
  }
}

class _SOSOptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _SOSOptionButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConfig.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: AppConfig.mediumFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
