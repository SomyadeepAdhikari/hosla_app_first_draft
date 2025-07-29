import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class CreatePostWidget extends StatefulWidget {
  const CreatePostWidget({super.key});

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(AppConfig.mediumSpacing),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.mediumSpacing),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppConfig.primaryTeal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: AppConfig.mediumSpacing),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isExpanded = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConfig.mediumSpacing,
                          vertical: AppConfig.smallSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius:
                              BorderRadius.circular(AppConfig.borderRadius),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _isExpanded ? '' : localizations.shareYourThoughts,
                          style: TextStyle(
                            fontSize: AppConfig.mediumFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: AppConfig.mediumSpacing),
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  maxLength: AppConfig.maxPostLength,
                  decoration: InputDecoration(
                    hintText: localizations.shareYourThoughts,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConfig.borderRadius),
                    ),
                  ),
                  style: const TextStyle(fontSize: AppConfig.mediumFontSize),
                ),
                const SizedBox(height: AppConfig.mediumSpacing),

                // Media options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMediaButton(
                      icon: Icons.mic,
                      label: localizations.recordVoiceNote,
                      color: AppConfig.primaryTeal,
                      onTap: _recordVoiceNote,
                    ),
                    _buildMediaButton(
                      icon: Icons.photo_camera,
                      label: localizations.addPhoto,
                      color: AppConfig.successGreen,
                      onTap: _addPhoto,
                    ),
                    _buildMediaButton(
                      icon: Icons.videocam,
                      label: localizations.addVideo,
                      color: AppConfig.warningOrange,
                      onTap: _addVideo,
                    ),
                  ],
                ),
                const SizedBox(height: AppConfig.mediumSpacing),

                // Post button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createPost,
                        child: Text(localizations.post),
                      ),
                    ),
                    const SizedBox(width: AppConfig.mediumSpacing),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                          _textController.clear();
                        });
                      },
                      child: Text(localizations.cancel),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            border: Border.all(color: color),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: AppConfig.smallSpacing),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _recordVoiceNote() {
    // TODO: Implement voice recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording feature coming soon!')),
    );
  }

  void _addPhoto() {
    // TODO: Implement photo picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo picker feature coming soon!')),
    );
  }

  void _addVideo() {
    // TODO: Implement video picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video picker feature coming soon!')),
    );
  }

  void _createPost() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something to post!')),
      );
      return;
    }

    // TODO: Implement post creation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created successfully!')),
    );

    setState(() {
      _isExpanded = false;
      _textController.clear();
    });
  }
}
