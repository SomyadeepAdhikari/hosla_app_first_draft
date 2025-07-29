import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['isLiked'] ?? false;
    likeCount = widget.post['likes'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfig.mediumSpacing,
        vertical: AppConfig.smallSpacing,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppConfig.primaryTeal,
                  backgroundImage: post['userAvatar'] != null
                      ? NetworkImage(post['userAvatar'])
                      : null,
                  child: post['userAvatar'] == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppConfig.mediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['userName'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: AppConfig.mediumFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        post['timeAgo'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(context),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),

            // Post content
            if (post['content'] != null && post['content'].isNotEmpty) ...[
              const SizedBox(height: AppConfig.mediumSpacing),
              Text(
                post['content'],
                style: const TextStyle(
                  fontSize: AppConfig.mediumFontSize,
                  height: 1.4,
                ),
              ),
            ],

            // Media content
            if (post['imageUrl'] != null) ...[
              const SizedBox(height: AppConfig.mediumSpacing),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ],

            if (post['videoUrl'] != null) ...[
              const SizedBox(height: AppConfig.mediumSpacing),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.play_circle_filled,
                        size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ],

            if (post['audioUrl'] != null) ...[
              const SizedBox(height: AppConfig.mediumSpacing),
              Container(
                padding: const EdgeInsets.all(AppConfig.mediumSpacing),
                decoration: BoxDecoration(
                  color: AppConfig.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: AppConfig.primaryTeal),
                    const SizedBox(width: AppConfig.mediumSpacing),
                    Expanded(
                      child: Text(
                        'Voice Note • 0:45',
                        style: const TextStyle(
                          fontSize: AppConfig.mediumFontSize,
                          color: AppConfig.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Play/pause audio
                      },
                      icon: const Icon(Icons.play_arrow,
                          color: AppConfig.primaryTeal),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConfig.mediumSpacing),

            // Engagement stats
            Row(
              children: [
                Text(
                  '${post['views']} views',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showSeenBy(context),
                  child: Text(
                    '${localizations.seenBy} ${post['views']} people',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: AppConfig.mediumSpacing),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '$likeCount ${localizations.like}',
                    color: isLiked ? AppConfig.sosRed : Colors.grey[600]!,
                    onTap: _toggleLike,
                  ),
                ),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.comment,
                    label: '${post['comments']} ${localizations.comment}',
                    color: Colors.grey[600]!,
                    onTap: () => _showComments(context),
                  ),
                ),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share,
                    label: localizations.share,
                    color: Colors.grey[600]!,
                    onTap: () => _sharePost(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConfig.smallSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppConfig.smallSpacing),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    // TODO: Send like/unlike request to backend
  }

  void _showComments(BuildContext context) {
    // TODO: Implement comments view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _sharePost(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _showSeenBy(BuildContext context) {
    // TODO: Show list of people who viewed the post
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seen by feature coming soon!')),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConfig.mediumSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit post
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete post
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report post
              },
            ),
          ],
        ),
      ),
    );
  }
}
