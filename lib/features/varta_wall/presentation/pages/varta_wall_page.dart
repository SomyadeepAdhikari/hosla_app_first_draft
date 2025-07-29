import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_widget.dart';
import '../widgets/appreciation_card.dart';

class VartaWallPage extends StatelessWidget {
  const VartaWallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.vartaWall),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to profile
            },
            icon: const Icon(Icons.account_circle, size: 28),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: CustomScrollView(
          slivers: [
            // Appreciation Corner Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(AppConfig.mediumSpacing),
                child: const AppreciationCard(),
              ),
            ),

            // Create Post Widget
            const SliverToBoxAdapter(
              child: CreatePostWidget(),
            ),

            // Posts List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(
                  post: _samplePosts[index % _samplePosts.length],
                ),
                childCount: 20, // Sample data
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sample data (would come from API/BLoC in real implementation)
final List<Map<String, dynamic>> _samplePosts = [
  {
    'id': '1',
    'userName': 'रमेश जी',
    'userAvatar': null,
    'timeAgo': '2 घंटे पहले',
    'content': 'आज बहुत अच्छा मौसम है। बगीचे में टहलने गया था।',
    'imageUrl': null,
    'videoUrl': null,
    'audioUrl': null,
    'likes': 12,
    'comments': 3,
    'views': 45,
    'isLiked': false,
  },
  {
    'id': '2',
    'userName': 'सुनीता देवी',
    'userAvatar': null,
    'timeAgo': '4 घंटे पहले',
    'content': 'अपने पोते के साथ खेल रही थी। बहुत मजा आया!',
    'imageUrl': 'sample_image.jpg',
    'videoUrl': null,
    'audioUrl': null,
    'likes': 18,
    'comments': 7,
    'views': 62,
    'isLiked': true,
  },
  {
    'id': '3',
    'userName': 'विनोद जी',
    'userAvatar': null,
    'timeAgo': '6 घंटे पहले',
    'content': '',
    'imageUrl': null,
    'videoUrl': null,
    'audioUrl': 'voice_note.mp3',
    'likes': 8,
    'comments': 2,
    'views': 28,
    'isLiked': false,
  },
];
