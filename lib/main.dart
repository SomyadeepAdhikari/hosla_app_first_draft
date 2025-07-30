import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'services/auth_service.dart'; // TODO: Temporarily commented out
// import 'screens/splash_screen.dart'; // TODO: Temporarily commented out
import 'core/theme/senior_friendly_theme.dart';
import 'screens/profile_page.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for better visibility
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5C7C98), // Warm blue to match senior theme
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize authentication service
  // TODO: Temporarily commented out for testing
  // await AuthService().initialize();

  runApp(const HoslaVartaApp());
}

class HoslaVartaApp extends StatelessWidget {
  const HoslaVartaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hosla Varta',
      debugShowCheckedModeBanner: false,
      // NEW SENIOR-FRIENDLY THEME - better for older adults
      theme: SeniorFriendlyTheme.warmTheme,
      
      // OLD TEAL THEME (commented out)
      // theme: ThemeData(
      //   primarySwatch: Colors.teal,
      //   scaffoldBackgroundColor:
      //       const Color(0xFFFFF8E1), // Warm cream background
      //   appBarTheme: const AppBarTheme(
      //     backgroundColor: Colors.teal,
      //     foregroundColor: Colors.white,
      //     elevation: 2,
      //     centerTitle: true,
      //   ),
      //   textTheme: const TextTheme(
      //     headlineLarge: TextStyle(
      //         fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
      //     headlineMedium: TextStyle(
      //         fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
      //     bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
      //     bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       minimumSize: const Size(double.infinity, 56),
      //       textStyle:
      //           const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      //       shape:
      //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //       elevation: 3,
      //     ),
      //   ),
      //   cardTheme: const CardThemeData(
      //     elevation: 4,
      //     shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.all(Radius.circular(12))),
      //     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //   ),
      //   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      //     backgroundColor: Colors.white,
      //     elevation: 8,
      //     selectedItemColor: Colors.teal,
      //     unselectedItemColor: Colors.grey,
      //     type: BottomNavigationBarType.fixed,
      //   ),
      // ),
      
      // TODO: Temporarily bypass authentication - go directly to HomePage
      home: const HomePage(),
      // home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _emergencyAnimationController;
  late Animation<double> _emergencyPulseAnimation;

  final List<Widget> _pages = [
    const VartaWallPage(),
    const TrustCirclePage(),
    const ChatPage(),
    const EventsPage(),
    const EmergencyPage(),
  ];

  @override
  void initState() {
    super.initState();
    _emergencyAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _emergencyPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _emergencyAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _emergencyAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
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
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom_rounded, size: 28),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded, size: 28),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_rounded, size: 28),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_rounded, size: 28),
              label: 'Emergency',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 4
          ? AnimatedBuilder(
              animation: _emergencyPulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _emergencyPulseAnimation.value,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showEmergencyDialog(context),
                    backgroundColor: Colors.red,
                    icon:
                        const Icon(Icons.phone, size: 24, color: Colors.white),
                    label: const Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            )
          : _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: () => _showCreatePostDialog(context),
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.add, size: 28, color: Colors.white),
                )
              : null,
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Provide haptic feedback for better user experience
    HapticFeedback.lightImpact();

    // Announce page change for accessibility
    String pageName = ['Home', 'Family', 'Chat', 'Events', 'Emergency'][index];
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('$pageName page opened', style: const TextStyle(fontSize: 16)),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    HapticFeedback.vibrate(); // Strong vibration for emergency

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            const Text(
              'Emergency Help',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Do you need immediate help?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This message will be sent to your family members',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendEmergencyAlert(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Send Help',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendEmergencyAlert(BuildContext context) {
    // Simulate sending emergency alert
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '🚨 Emergency help sent\nYour family has been notified',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Post', style: TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('What would you like to share?',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPostTypeButton(
                  context,
                  Icons.text_fields,
                  'Text',
                  Colors.blue,
                  () => _showTextPostDialog(context),
                ),
                _buildPostTypeButton(
                  context,
                  Icons.camera_alt,
                  'Photo',
                  Colors.green,
                  () => _showImagePostDialog(context),
                ),
                _buildPostTypeButton(
                  context,
                  Icons.mic,
                  'Audio',
                  Colors.orange,
                  () => _showAudioPostDialog(context),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the selection dialog
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextPostDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.text_fields, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text('Text Post'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
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
              if (textController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _createPost('text', textController.text.trim(), null);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showImagePostDialog(BuildContext context) {
    final TextEditingController captionController = TextEditingController();
    String? selectedImagePath;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text('Photo Post'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image selection area
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: selectedImagePath != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 80, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(
                              'Image Selected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'demo_image.jpg',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: () => _showImageSourceDialog(context, setState),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, 
                                  size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap to select photo',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                
                // Caption input
                TextField(
                  controller: captionController,
                  decoration: const InputDecoration(
                    labelText: 'Caption (optional)',
                    hintText: 'Write a caption for your photo...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (selectedImagePath != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedImagePath = null;
                  });
                },
                child: const Text('Remove Image'),
              ),
            ElevatedButton(
              onPressed: selectedImagePath != null
                  ? () {
                      Navigator.pop(context);
                      _createPost('image', captionController.text.trim(), selectedImagePath);
                    }
                  : null,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, StateSetter setState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              subtitle: const Text('Take a new photo'),
              onTap: () {
                Navigator.pop(context);
                _selectImageFromCamera(setState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _selectImageFromGallery(setState);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _selectImageFromCamera(StateSetter setState) {
    // Simulate camera selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo captured from camera!'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Simulate image selection delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        // Simulate having selected an image
        // selectedImagePath = 'camera_image.jpg';
      });
    });
  }

  void _selectImageFromGallery(StateSetter setState) {
    // Simulate gallery selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖼️ Photo selected from gallery!'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Simulate image selection delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        // Simulate having selected an image
        // selectedImagePath = 'gallery_image.jpg';
      });
    });
  }

  void _showAudioPostDialog(BuildContext context) {
    bool isRecording = false;
    bool hasRecording = false;
    int recordingDuration = 0;
    final TextEditingController descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.mic, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text('Audio Post'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recording area
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isRecording ? Colors.red[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecording ? Colors.red[300]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRecording) ...[
                        Icon(Icons.mic, size: 40, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Recording... ${recordingDuration}s',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ] else if (hasRecording) ...[
                        Icon(Icons.audiotrack, size: 40, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          'Audio recorded (${recordingDuration}s)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.mic_none, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to start recording',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Recording controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!isRecording && !hasRecording)
                      ElevatedButton.icon(
                        onPressed: () => _startRecording(setState, (duration) {
                          setState(() {
                            isRecording = true;
                            recordingDuration = duration;
                          });
                        }),
                        icon: const Icon(Icons.mic, size: 20),
                        label: const Text('Record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    
                    if (isRecording)
                      ElevatedButton.icon(
                        onPressed: () => _stopRecording(setState, (duration) {
                          setState(() {
                            isRecording = false;
                            hasRecording = true;
                            recordingDuration = duration;
                          });
                        }),
                        icon: const Icon(Icons.stop, size: 20),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    
                    if (hasRecording) ...[
                      ElevatedButton.icon(
                        onPressed: () => _playRecording(),
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _deleteRecording(setState, () {
                          setState(() {
                            hasRecording = false;
                            recordingDuration = 0;
                          });
                        }),
                        icon: const Icon(Icons.delete, size: 20),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description input
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Describe your audio message...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  maxLength: 150,
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
              onPressed: hasRecording
                  ? () {
                      Navigator.pop(context);
                      _createPost('audio', descriptionController.text.trim(), 'audio_recording.m4a');
                    }
                  : null,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording(StateSetter setState, Function(int) onDurationUpdate) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Recording started!'),
        duration: Duration(seconds: 1),
      ),
    );
    // Simulate recording timer
    onDurationUpdate(0);
  }

  void _stopRecording(StateSetter setState, Function(int) onComplete) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Recording stopped!'),
        duration: Duration(seconds: 1),
      ),
    );
    // Simulate final duration
    final duration = 15; // Simulate 15 seconds recording
    onComplete(duration);
  }

  void _playRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔊 Playing audio recording...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteRecording(StateSetter setState, VoidCallback onDelete) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Recording deleted'),
        duration: Duration(seconds: 1),
      ),
    );
    onDelete();
  }

  void _createPost(String type, String content, String? mediaPath) {
    // Simulate post creation
    HapticFeedback.lightImpact();
    
    String message;
    IconData icon;
    Color color;
    
    switch (type) {
      case 'text':
        message = '📝 Text post created successfully!';
        icon = Icons.text_fields;
        color = Colors.blue;
        break;
      case 'image':
        message = '📸 Photo post created successfully!';
        icon = Icons.image;
        color = Colors.green;
        break;
      case 'audio':
        message = '🎤 Audio post created successfully!';
        icon = Icons.audiotrack;
        color = Colors.orange;
        break;
      default:
        message = '✅ Post created successfully!';
        icon = Icons.check_circle;
        color = Colors.green;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (content.isNotEmpty)
                    Text(
                      content.length > 50 
                          ? '${content.substring(0, 50)}...'
                          : content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to the post or news feed
            setState(() {
              _selectedIndex = 0; // Go to home/feed page
            });
          },
        ),
      ),
    );
  }
}

// Placeholder pages with senior-friendly design
class VartaWallPage extends StatelessWidget {
  const VartaWallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.home_rounded, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('News Feed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_rounded, size: 24),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_rounded, size: 24),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification feature coming soon')),
              );
            },
            icon: const Icon(Icons.notifications_rounded, size: 24),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New posts loaded')),
          );
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 8, // Increased number of demo posts
          itemBuilder: (context, index) => _buildPostCard(context, index),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    final List<Map<String, dynamic>> samplePosts = [
      {
        'name': 'Mrs. Sunita Sharma',
        'time': '2 hours ago',
        'content':
            'Beautiful flowers bloomed in the garden this morning. It made me so happy. 🌸',
        'likes': 12,
        'comments': 3,
        'type': 'text'
      },
      {
        'name': 'Mr. Ram Kumar',
        'time': '4 hours ago',
        'content':
            'Had a wonderful time with grandchildren today. Their laughter is the sweetest sound.',
        'likes': 24,
        'comments': 7,
        'type': 'text'
      },
      {
        'name': 'Mrs. Priya Devi',
        'time': '6 hours ago',
        'content':
            'Went to yoga class at the community center today. Met all my friends. 🧘‍♀️',
        'likes': 18,
        'comments': 5,
        'type': 'text'
      },
    ];

    final post = samplePosts[index % samplePosts.length];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal[100],
                  child: Text(
                    post['name'].toString().substring(0, 1),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post['time'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'report', child: Text('Report')),
                    const PopupMenuItem(value: 'hide', child: Text('Hide')),
                  ],
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value option selected')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Post content
            Text(
              post['content'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                _buildActionButton(
                  context,
                  Icons.favorite_border_rounded,
                  'Like (${post['likes']})',
                  Colors.red,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  Icons.comment_rounded,
                  'Comment (${post['comments']})',
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  Icons.share_rounded,
                  'Share',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label pressed')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 14, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class TrustCirclePage extends StatelessWidget {
  const TrustCirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.family_restroom_rounded, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Trust Circle',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_rounded, size: 24),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_rounded, size: 24),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () {
              _showAddFamilyDialog(context);
            },
            icon: const Icon(Icons.person_add_rounded, size: 24),
            tooltip: 'Add New Member',
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency alert banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.security_rounded, color: Colors.red[700], size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'These members will be notified immediately in case of emergency',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Family members list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFamilyMemberCard(
                  context,
                  'Ram Sharma',
                  'Son',
                  '+91 98765 43210',
                  Icons.person_rounded,
                  Colors.blue,
                  isOnline: true,
                ),
                _buildFamilyMemberCard(
                  context,
                  'Sunita Devi',
                  'Daughter',
                  '+91 87654 32109',
                  Icons.person_rounded,
                  Colors.pink,
                  isOnline: false,
                ),
                _buildFamilyMemberCard(
                  context,
                  'Ajay Kumar',
                  'Son-in-law',
                  '+91 76543 21098',
                  Icons.person_rounded,
                  Colors.green,
                  isOnline: true,
                ),
                _buildFamilyMemberCard(
                  context,
                  'Priya Sharma',
                  'Daughter-in-law',
                  '+91 65432 10987',
                  Icons.person_rounded,
                  Colors.orange,
                  isOnline: true,
                ),
                _buildFamilyMemberCard(
                  context,
                  'Dr. Rajesh Verma',
                  'Family Doctor',
                  '+91 54321 09876',
                  Icons.medical_services_rounded,
                  Colors.red,
                  isOnline: false,
                  isDoctor: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(
    BuildContext context,
    String name,
    String relation,
    String phone,
    IconData icon,
    Color color, {
    bool isOnline = false,
    bool isDoctor = false,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (isDoctor)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Emergency',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              relation,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              phone,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (isOnline)
              const Text(
                'Online',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _makeCall(context, name, phone),
              icon: const Icon(Icons.phone_rounded,
                  color: Colors.green, size: 28),
              tooltip: 'Call',
            ),
            IconButton(
              onPressed: () => _sendMessage(context, name),
              icon: const Icon(Icons.message_rounded,
                  color: Colors.blue, size: 24),
              tooltip: 'Send Message',
            ),
          ],
        ),
        onTap: () => _showMemberDetails(context, name, relation, phone),
      ),
    );
  }

  void _makeCall(BuildContext context, String name, String phone) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Text('Want to call?'),
          ],
        ),
        content: Text('Call $name at $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $name...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                const Text('Call', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, String name) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Messaging feature for $name coming soon')),
    );
  }

  void _showMemberDetails(
      BuildContext context, String name, String relation, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(name, style: const TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Relation: $relation', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Additional Options:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(Icons.video_call, 'Video Call'),
                _buildQuickAction(Icons.location_on, 'Location'),
                _buildQuickAction(Icons.block, 'Block'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.teal),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showAddFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Member'),
        content: const Text(
            'Feature to add new family member will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.chat_rounded, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Chat',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_rounded, size: 24),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_rounded, size: 24),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('New chat feature coming soon')),
              );
            },
            icon: const Icon(Icons.add_comment_rounded, size: 24),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickChatButton(
                    context,
                    'Family Group',
                    Icons.family_restroom_rounded,
                    Colors.teal,
                    '4 members online',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickChatButton(
                    context,
                    'Doctor',
                    Icons.medical_services_rounded,
                    Colors.red,
                    'Available now',
                  ),
                ),
              ],
            ),
          ),

          // Chat list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildChatTile(
                  context,
                  'Ram Sharma',
                  'How are you? Did you take medicine?',
                  '10 minutes ago',
                  2,
                  true,
                ),
                _buildChatTile(
                  context,
                  'Family Group',
                  'Sunita: I will come this evening',
                  '1 hour ago',
                  0,
                  false,
                ),
                _buildChatTile(
                  context,
                  'Dr. Rajesh Verma',
                  'Checked the report, everything is fine',
                  '2 hours ago',
                  1,
                  false,
                ),
                _buildChatTile(
                  context,
                  'Sunita Devi',
                  'Will meet you tomorrow mom',
                  'Yesterday',
                  0,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChatButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title chat...')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    String name,
    String lastMessage,
    String time,
    int unreadCount,
    bool isOnline,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.teal[100],
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                lastMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                  fontWeight:
                      unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening chat with $name...')),
          );
        },
      ),
    );
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.event_rounded, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Events',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_rounded, size: 24),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_rounded, size: 24),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Create new event feature coming soon')),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'Add Event',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal[50],
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: Colors.teal[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[700]),
                ),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildEventCard(
                  context,
                  'Yoga Class',
                  'Community Center',
                  'Today 7:00 AM',
                  Icons.self_improvement_rounded,
                  Colors.green,
                  true,
                ),
                _buildEventCard(
                  context,
                  'Doctor Appointment',
                  'Dr. Rajesh Verma',
                  'Tomorrow 2:00 PM',
                  Icons.medical_services_rounded,
                  Colors.red,
                  false,
                ),
                _buildEventCard(
                  context,
                  'Family Gathering',
                  'At Home',
                  'Sunday 5:00 PM',
                  Icons.family_restroom_rounded,
                  Colors.orange,
                  false,
                ),
                _buildEventCard(
                  context,
                  'Medicine Reminder',
                  'Morning Medicine',
                  'Daily 8:00 AM',
                  Icons.medication_rounded,
                  Colors.blue,
                  true,
                ),
                _buildEventCard(
                  context,
                  'Walking',
                  'In the Park',
                  'Daily 6:00 PM',
                  Icons.directions_walk_rounded,
                  Colors.purple,
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String location,
    String time,
    IconData icon,
    Color color,
    bool isRecurring,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showEventDetails(context, title, location, time);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isRecurring)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Daily',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(
      BuildContext context, String title, String location, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 16),
                const SizedBox(width: 8),
                Text(location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEventAction(Icons.edit_rounded, 'Edit'),
                _buildEventAction(Icons.notifications_rounded, 'Reminder'),
                _buildEventAction(Icons.delete_rounded, 'Delete'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.teal),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emergency_rounded, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Emergency',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_rounded, size: 24),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_rounded, size: 24),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main emergency icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emergency, size: 80, color: Colors.red[700]),
            ),
            const SizedBox(height: 24),

            const Text(
              'Emergency Help',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),

            const Text(
              'Use the buttons below to get immediate help\nYour family will be notified instantly',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Emergency buttons
            _buildEmergencyButton(
              context,
              'Need Help Immediately',
              '🚨 EMERGENCY',
              Colors.red,
              Icons.local_hospital_rounded,
              () => _handleEmergency(context, 'Immediate Help'),
            ),
            const SizedBox(height: 16),

            _buildEmergencyButton(
              context,
              'Not Feeling Well',
              'Health Related Problem',
              Colors.orange,
              Icons.sick_rounded,
              () => _handleEmergency(context, 'Health Problem'),
            ),
            const SizedBox(height: 16),

            _buildEmergencyButton(
              context,
              'Want to Talk to Someone',
              'Need Emotional Support',
              Colors.blue,
              Icons.chat_rounded,
              () => _handleEmergency(context, 'Want to Talk'),
            ),
            const SizedBox(height: 32),

            // Quick contacts section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_in_talk_rounded,
                          color: Colors.green[700], size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Quick Contacts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickContactButton(
                          context,
                          'Police',
                          '100',
                          Icons.local_police_rounded,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickContactButton(
                          context,
                          'Ambulance',
                          '108',
                          Icons.local_hospital_rounded,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickContactButton(
                          context,
                          'Fire Department',
                          '101',
                          Icons.local_fire_department_rounded,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickContactButton(
                          context,
                          'Women Helpline',
                          '1091',
                          Icons.support_agent_rounded,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Safety tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Safety Tips',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Always keep your phone charged\n• Don\'t go out alone\n• Take medicines on time\n• Keep your family informed about your condition',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactButton(
    BuildContext context,
    String label,
    String number,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () => _makeEmergencyCall(context, label, number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          side: BorderSide(color: color),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            Text(
              number,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEmergency(BuildContext context, String type) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            Text(
              'Emergency Alert',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700]),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are requesting help for "$type".',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This message will be sent immediately to all your family members.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendAlert(context, type);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Send Alert',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendAlert(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🚨 $type alert sent!\nYour family has been notified',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _makeEmergencyCall(BuildContext context, String service, String number) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Call $service?'),
        content: Text('Do you want to call $number?'),
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
                    content:
                        Text('Calling $service ($number)...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                const Text('Call', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
