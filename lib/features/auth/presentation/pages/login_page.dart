import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../shared/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOTPSent) {
            AppRouter.pushNamed(
              AppRouter.otpVerification,
              arguments: {'phoneNumber': state.phoneNumber},
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConfig.errorRed,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.largeSpacing),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo and name
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppConfig.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.elderly,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConfig.largeSpacing),

                  Text(
                    localizations.appName,
                    style: const TextStyle(
                      fontSize: AppConfig.extraLargeFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppConfig.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: AppConfig.smallSpacing),

                  Text(
                    'वरिष्ठ नागरिकों के लिए सामाजिक मंच',
                    style: TextStyle(
                      fontSize: AppConfig.mediumFontSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConfig.extraLargeSpacing),

                  // Phone number input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: localizations.phoneNumber,
                      hintText: '+91 XXXXX XXXXX',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    style: const TextStyle(fontSize: AppConfig.mediumFontSize),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConfig.largeSpacing),

                  // Login button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _loginWithPhone,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(localizations.login),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConfig.largeSpacing),

                  // Language selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: AppConfig.primaryTeal),
                      const SizedBox(width: AppConfig.smallSpacing),
                      DropdownButton<Locale>(
                        value: Localizations.localeOf(context),
                        underline: Container(),
                        items: AppConfig.supportedLocales.map((locale) {
                          final Map<String, String> languageNames = {
                            'en': 'English',
                            'hi': 'हिंदी',
                            'bn': 'বাংলা',
                            'ta': 'தமிழ்',
                            'te': 'తెలుగు',
                          };

                          return DropdownMenuItem<Locale>(
                            value: locale,
                            child: Text(
                              languageNames[locale.languageCode] ?? 'English',
                              style: const TextStyle(
                                fontSize: AppConfig.mediumFontSize,
                                color: AppConfig.primaryTeal,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (locale) {
                          if (locale != null) {
                            // TODO: Implement language change
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginWithPhone() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _phoneController.text.trim();
      context.read<AuthBloc>().add(AuthLoginRequested(phoneNumber));
    }
  }
}
