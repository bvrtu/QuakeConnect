import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import '../l10n/app_localizations.dart';
import '../data/post_repository.dart';
import '../services/auth_service.dart';

class AllCommunityUpdatesScreen extends StatefulWidget {
  final String? userId;

  const AllCommunityUpdatesScreen({
    super.key,
    this.userId,
  });

  @override
  State<AllCommunityUpdatesScreen> createState() =>
      _AllCommunityUpdatesScreenState();
}

class _AllCommunityUpdatesScreenState extends State<AllCommunityUpdatesScreen> {
  OverlayEntry? _bannerEntry;
  final ScrollController _controller = ScrollController();
  final PostRepository _postRepo = PostRepository.instance;

  void _removeBanner() {
    _bannerEntry?.remove();
    _bannerEntry = null;
  }

  void _showTopBanner(
    String message, {
    Color background = Colors.black87,
    IconData icon = Icons.check_circle,
  }) {
    _removeBanner();
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPadding + 16,
          left: 16,
          right: 16,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) {
              return Transform.translate(
                offset: Offset(0, (1 - t) * -40),
                child: Opacity(opacity: t, child: child),
              );
            },
            child: Material(
              color: Colors.transparent,
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _bannerEntry = entry;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _removeBanner();
      }
    });
  }

  Future<void> _handleRefresh() async {
    // Refresh is handled automatically by StreamBuilder
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _removeBanner();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).followingUpdatesTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: StreamBuilder<List<CommunityPost>>(
          stream: widget.userId != null
              ? _postRepo.getFollowingPosts(widget.userId!, widget.userId)
              : Stream.value(<CommunityPost>[]),
          builder: (context, snapshot) {
            // Only show loading on initial load, not on subsequent updates
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }
            
            final posts = snapshot.data ?? [];
            
            if (posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).noUpdatesYet,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
          itemBuilder: (context, index) {
                final post = posts[index];
            return CommunityPostCard(
              post: post,
                  onUpdated: null, // StreamBuilder will handle updates automatically
                  showBanner: (msg, {Color background = Colors.black87, IconData icon = Icons.check_circle}) {
                    _showTopBanner(msg, background: background, icon: icon);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
