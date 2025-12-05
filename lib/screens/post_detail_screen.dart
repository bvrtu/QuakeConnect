import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import '../l10n/app_localizations.dart';

class PostDetailScreen extends StatelessWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).posts),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        child: CommunityPostCard(
          post: post,
          isDetail: true,
        ),
      ),
    );
  }
}

