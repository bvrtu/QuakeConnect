import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import '../l10n/app_localizations.dart';
import '../data/post_repository.dart';
import '../services/auth_service.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost? post;
  final String? postId;

  const PostDetailScreen({super.key, this.post, this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<CommunityPost?> _postFuture;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _postFuture = Future.value(widget.post);
    } else if (widget.postId != null) {
      final userId = AuthService.instance.currentUserId;
      _postFuture = PostRepository.instance.getPostWithStatus(widget.postId!, userId);
    } else {
      _postFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).posts),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: FutureBuilder<CommunityPost?>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'Post not found'));
          }
          return SingleChildScrollView(
            child: CommunityPostCard(
              post: snapshot.data!,
              isDetail: true,
            ),
          );
        },
      ),
    );
  }
}
