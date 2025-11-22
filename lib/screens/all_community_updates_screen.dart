import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';

class AllCommunityUpdatesScreen extends StatefulWidget {
  final List<CommunityPost> posts;
  final VoidCallback? onPostsUpdated;

  const AllCommunityUpdatesScreen({
    super.key,
    required this.posts,
    this.onPostsUpdated,
  });

  @override
  State<AllCommunityUpdatesScreen> createState() =>
      _AllCommunityUpdatesScreenState();
}

class _AllCommunityUpdatesScreenState extends State<AllCommunityUpdatesScreen> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    widget.onPostsUpdated?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Updates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.posts.length,
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            return CommunityPostCard(
              post: post,
              onUpdated: () {
                widget.onPostsUpdated?.call();
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
