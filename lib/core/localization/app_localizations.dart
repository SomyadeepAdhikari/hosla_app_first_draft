import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => [
        const Locale('en', 'US'),
        const Locale('hi', 'IN'),
        const Locale('bn', 'IN'),
        const Locale('ta', 'IN'),
        const Locale('te', 'IN'),
      ];

  // Common texts
  String get appName => _localizedStrings['app_name'] ?? 'Hosla Varta';
  String get loading => _localizedStrings['loading'] ?? 'Loading...';
  String get error => _localizedStrings['error'] ?? 'Error';
  String get retry => _localizedStrings['retry'] ?? 'Retry';
  String get cancel => _localizedStrings['cancel'] ?? 'Cancel';
  String get save => _localizedStrings['save'] ?? 'Save';
  String get delete => _localizedStrings['delete'] ?? 'Delete';
  String get edit => _localizedStrings['edit'] ?? 'Edit';
  String get ok => _localizedStrings['ok'] ?? 'OK';
  String get yes => _localizedStrings['yes'] ?? 'Yes';
  String get no => _localizedStrings['no'] ?? 'No';

  // Navigation
  String get home => _localizedStrings['home'] ?? 'Home';
  String get circle => _localizedStrings['circle'] ?? 'Circle';
  String get chat => _localizedStrings['chat'] ?? 'Chat';
  String get events => _localizedStrings['events'] ?? 'Events';
  String get emergency => _localizedStrings['emergency'] ?? 'Emergency';

  // Varta Wall
  String get vartaWall => _localizedStrings['varta_wall'] ?? 'Varta Wall';
  String get shareYourThoughts =>
      _localizedStrings['share_your_thoughts'] ?? 'Share your thoughts...';
  String get recordVoiceNote =>
      _localizedStrings['record_voice_note'] ?? 'Record Voice Note';
  String get addPhoto => _localizedStrings['add_photo'] ?? 'Add Photo';
  String get addVideo => _localizedStrings['add_video'] ?? 'Add Video';
  String get post => _localizedStrings['post'] ?? 'Post';
  String get like => _localizedStrings['like'] ?? 'Like';
  String get comment => _localizedStrings['comment'] ?? 'Comment';
  String get share => _localizedStrings['share'] ?? 'Share';
  String get seenBy => _localizedStrings['seen_by'] ?? 'Seen by';

  // Trust Circle
  String get trustCircle => _localizedStrings['trust_circle'] ?? 'Trust Circle';
  String get addMember => _localizedStrings['add_member'] ?? 'Add Member';
  String get scanQR => _localizedStrings['scan_qr'] ?? 'Scan QR Code';
  String get enterPhoneNumber =>
      _localizedStrings['enter_phone_number'] ?? 'Enter Phone Number';
  String get myQRCode => _localizedStrings['my_qr_code'] ?? 'My QR Code';

  // Emergency
  String get sosAlert => _localizedStrings['sos_alert'] ?? 'SOS Alert';
  String get notFeelingWell =>
      _localizedStrings['not_feeling_well'] ?? 'Not feeling well';
  String get needHelp => _localizedStrings['need_help'] ?? 'Need help';
  String get wantToTalk => _localizedStrings['want_to_talk'] ?? 'Want to talk';
  String get emergencyAlertSent =>
      _localizedStrings['emergency_alert_sent'] ??
      'Emergency alert sent to your Trust Circle';

  // Events
  String get upcomingEvents =>
      _localizedStrings['upcoming_events'] ?? 'Upcoming Events';
  String get interested => _localizedStrings['interested'] ?? 'Interested';
  String get attending => _localizedStrings['attending'] ?? 'Attending';
  String get pastEvents => _localizedStrings['past_events'] ?? 'Past Events';

  // Profile
  String get profile => _localizedStrings['profile'] ?? 'Profile';
  String get editProfile => _localizedStrings['edit_profile'] ?? 'Edit Profile';
  String get name => _localizedStrings['name'] ?? 'Name';
  String get dateOfBirth =>
      _localizedStrings['date_of_birth'] ?? 'Date of Birth';
  String get gender => _localizedStrings['gender'] ?? 'Gender';
  String get bio => _localizedStrings['bio'] ?? 'Bio';
  String get rewardPoints =>
      _localizedStrings['reward_points'] ?? 'Reward Points';

  // Authentication
  String get login => _localizedStrings['login'] ?? 'Login';
  String get phoneNumber => _localizedStrings['phone_number'] ?? 'Phone Number';
  String get otp => _localizedStrings['otp'] ?? 'OTP';
  String get verifyOTP => _localizedStrings['verify_otp'] ?? 'Verify OTP';
  String get resendOTP => _localizedStrings['resend_otp'] ?? 'Resend OTP';

  // Appreciation Corner
  String get appreciationCorner =>
      _localizedStrings['appreciation_corner'] ?? 'Appreciation Corner';
  String get dailyAppreciation =>
      _localizedStrings['daily_appreciation'] ?? 'Daily Appreciation';

  // Learning Corner
  String get learningCorner =>
      _localizedStrings['learning_corner'] ?? 'Learning Corner';
  String get tutorials => _localizedStrings['tutorials'] ?? 'Tutorials';

  // Health Tracker
  String get dailyMood =>
      _localizedStrings['daily_mood'] ?? 'How are you feeling today?';
  String get healthTracker =>
      _localizedStrings['health_tracker'] ?? 'Health Tracker';

  // Hosla Points
  String get hoslaPoints => _localizedStrings['hosla_points'] ?? 'Hosla Points';
  String get nearbyVolunteers =>
      _localizedStrings['nearby_volunteers'] ?? 'Nearby Volunteers';
  String get meetAtThisPoint =>
      _localizedStrings['meet_at_this_point'] ?? 'Meet at this point';

  Map<String, String> get _localizedStrings {
    switch (locale.languageCode) {
      case 'hi':
        return _hindiStrings;
      case 'bn':
        return _bengaliStrings;
      case 'ta':
        return _tamilStrings;
      case 'te':
        return _teluguStrings;
      default:
        return _englishStrings;
    }
  }

  static const Map<String, String> _englishStrings = {
    'app_name': 'Hosla Varta',
    'loading': 'Loading...',
    'error': 'Error',
    'retry': 'Retry',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',
    'home': 'Home',
    'circle': 'Circle',
    'chat': 'Chat',
    'events': 'Events',
    'emergency': 'Emergency',
    'varta_wall': 'Varta Wall',
    'share_your_thoughts': 'Share your thoughts...',
    'record_voice_note': 'Record Voice Note',
    'add_photo': 'Add Photo',
    'add_video': 'Add Video',
    'post': 'Post',
    'like': 'Like',
    'comment': 'Comment',
    'share': 'Share',
    'seen_by': 'Seen by',
    'trust_circle': 'Trust Circle',
    'add_member': 'Add Member',
    'scan_qr': 'Scan QR Code',
    'enter_phone_number': 'Enter Phone Number',
    'my_qr_code': 'My QR Code',
    'sos_alert': 'SOS Alert',
    'not_feeling_well': 'Not feeling well',
    'need_help': 'Need help',
    'want_to_talk': 'Want to talk',
    'emergency_alert_sent': 'Emergency alert sent to your Trust Circle',
    'upcoming_events': 'Upcoming Events',
    'interested': 'Interested',
    'attending': 'Attending',
    'past_events': 'Past Events',
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'name': 'Name',
    'date_of_birth': 'Date of Birth',
    'gender': 'Gender',
    'bio': 'Bio',
    'reward_points': 'Reward Points',
    'login': 'Login',
    'phone_number': 'Phone Number',
    'otp': 'OTP',
    'verify_otp': 'Verify OTP',
    'resend_otp': 'Resend OTP',
    'appreciation_corner': 'Appreciation Corner',
    'daily_appreciation': 'Daily Appreciation',
    'learning_corner': 'Learning Corner',
    'tutorials': 'Tutorials',
    'daily_mood': 'How are you feeling today?',
    'health_tracker': 'Health Tracker',
    'hosla_points': 'Hosla Points',
    'nearby_volunteers': 'Nearby Volunteers',
    'meet_at_this_point': 'Meet at this point',
  };

  static const Map<String, String> _hindiStrings = {
    'app_name': 'होसला वार्ता',
    'loading': 'लोड हो रहा है...',
    'error': 'त्रुटि',
    'retry': 'पुनः प्रयास करें',
    'cancel': 'रद्द करें',
    'save': 'सहेजें',
    'delete': 'हटाएं',
    'edit': 'संपादित करें',
    'ok': 'ठीक है',
    'yes': 'हाँ',
    'no': 'नहीं',
    'home': 'होम',
    'circle': 'सर्कल',
    'chat': 'चैट',
    'events': 'कार्यक्रम',
    'emergency': 'आपातकाल',
    'varta_wall': 'वार्ता वॉल',
    'share_your_thoughts': 'अपने विचार साझा करें...',
    'record_voice_note': 'वॉयस नोट रिकॉर्ड करें',
    'add_photo': 'फोटो जोड़ें',
    'add_video': 'वीडियो जोड़ें',
    'post': 'पोस्ट',
    'like': 'लाइक',
    'comment': 'टिप्पणी',
    'share': 'साझा करें',
    'seen_by': 'देखा गया',
    'trust_circle': 'ट्रस्ट सर्कल',
    'add_member': 'सदस्य जोड़ें',
    'scan_qr': 'QR कोड स्कैन करें',
    'enter_phone_number': 'फोन नंबर दर्ज करें',
    'my_qr_code': 'मेरा QR कोड',
    'sos_alert': 'SOS अलर्ट',
    'not_feeling_well': 'तबीयत ठीक नहीं',
    'need_help': 'मदद चाहिए',
    'want_to_talk': 'बात करना चाहते हैं',
    'emergency_alert_sent': 'आपातकालीन अलर्ट आपके ट्रस्ट सर्कल को भेजा गया',
    'upcoming_events': 'आगामी कार्यक्रम',
    'interested': 'रुचि',
    'attending': 'उपस्थित',
    'past_events': 'पिछले कार्यक्रम',
    'profile': 'प्रोफाइल',
    'edit_profile': 'प्रोफाइल संपादित करें',
    'name': 'नाम',
    'date_of_birth': 'जन्म तिथि',
    'gender': 'लिंग',
    'bio': 'बायो',
    'reward_points': 'पुरस्कार अंक',
    'login': 'लॉगिन',
    'phone_number': 'फोन नंबर',
    'otp': 'OTP',
    'verify_otp': 'OTP सत्यापित करें',
    'resend_otp': 'OTP पुनः भेजें',
    'appreciation_corner': 'प्रशंसा कॉर्नर',
    'daily_appreciation': 'दैनिक प्रशंसा',
    'learning_corner': 'शिक्षा कॉर्नर',
    'tutorials': 'ट्यूटोरियल',
    'daily_mood': 'आज आप कैसा महसूस कर रहे हैं?',
    'health_tracker': 'स्वास्थ्य ट्रैकर',
    'hosla_points': 'होसला पॉइंट्स',
    'nearby_volunteers': 'नजदीकी स्वयंसेवक',
    'meet_at_this_point': 'इस बिंदु पर मिलें',
  };

  // Bengali translations (sample - would need proper translation)
  static const Map<String, String> _bengaliStrings = {
    'app_name': 'হোসলা বার্তা',
    'loading': 'লোড হচ্ছে...',
    'home': 'হোম',
    'circle': 'সার্কেল',
    'chat': 'চ্যাট',
    'events': 'ইভেন্ট',
    'emergency': 'জরুরি',
    // Add more Bengali translations...
  };

  // Tamil translations (sample - would need proper translation)
  static const Map<String, String> _tamilStrings = {
    'app_name': 'ஹோஸ்லா வார்த்தா',
    'loading': 'ஏற்றுகிறது...',
    'home': 'முகப்பு',
    'circle': 'வட்டம்',
    'chat': 'அரட்டை',
    'events': 'நிகழ்வுகள்',
    'emergency': 'அவசரம்',
    // Add more Tamil translations...
  };

  // Telugu translations (sample - would need proper translation)
  static const Map<String, String> _teluguStrings = {
    'app_name': 'హోస్లా వార్తా',
    'loading': 'లోడ్ అవుతోంది...',
    'home': 'హోమ్',
    'circle': 'సర్కిల్',
    'chat': 'చాట్',
    'events': 'ఈవెంట్లు',
    'emergency': 'అత్యవసరం',
    // Add more Telugu translations...
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'bn', 'ta', 'te'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
