import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import '../l10n/app_localizations.dart';

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
  OverlayEntry? _bannerEntry;
  late final ScrollController _controller;
  late List<CommunityPost> _posts;
  bool _isLoadingMore = false;

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
    await Future.delayed(const Duration(seconds: 1));
    widget.onPostsUpdated?.call();
    setState(() {});
  }

  @override
  void dispose() {
    _removeBanner();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _posts = List<CommunityPost>.from(widget.posts);
    _controller = ScrollController();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final more = CommunityPost.sampleData().take(3).map((p) => p.copyWith(
          id: 'more-${DateTime.now().microsecondsSinceEpoch}-${p.id}',
          timestamp: DateTime.now(),
        ));
    setState(() {
      _posts.addAll(more);
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).communityUpdatesTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _posts.length + 1,
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: _isLoadingMore
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const SizedBox.shrink(),
                ),
              );
            }
            final post = _posts[index];
            return CommunityPostCard(
              post: post,
              onUpdated: () {
                widget.onPostsUpdated?.call();
                setState(() {});
              },
              showBanner: (msg, {Color background = Colors.black87, IconData icon = Icons.check_circle}) {
                _showTopBanner(msg, background: background, icon: icon);
              },
            );
          },
        ),
      ),
    );
  }
}
