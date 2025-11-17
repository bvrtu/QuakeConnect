import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import 'all_community_updates_screen.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

enum PostCategory { needHelp, info, safe }

class _SafetyScreenState extends State<SafetyScreen> {
  bool _hasMarkedSafe = false;
  final TextEditingController _postController = TextEditingController();
  PostCategory? _selectedCategory;
  late List<CommunityPost> _communityPosts;
  OverlayEntry? _bannerEntry;

  @override
  void initState() {
    super.initState();
    _communityPosts = List<CommunityPost>.from(CommunityPost.sampleData())
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  void dispose() {
    _postController.dispose();
    _removeBanner();
    super.dispose();
  }

  bool get _canPost =>
      _postController.text.trim().isNotEmpty && _selectedCategory != null;

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
            tween: Tween(begin: -80, end: 0),
            duration: const Duration(milliseconds: 250),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
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

  Future<void> _handleMarkSafePressed() async {
    if (_hasMarkedSafe) {
      setState(() {
        _hasMarkedSafe = false;
      });
      _showTopBanner(
        'Safety status cleared',
        background: Colors.black87,
        icon: Icons.info_outline,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark as Safe?'),
          content: const Text(
            'We will notify your emergency contacts that you are safe. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _hasMarkedSafe = true;
    });

    _showTopBanner(
      'Safety status sent to emergency contacts',
      background: const Color(0xFF2E7D32),
      icon: Icons.check_circle,
    );
  }

  void _handlePost() {
    if (!_canPost) return;
    final category = _selectedCategory!;
    final type = switch (category) {
      PostCategory.needHelp => CommunityPostType.needHelp,
      PostCategory.info => CommunityPostType.info,
      PostCategory.safe => CommunityPostType.safe,
    };

    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'You',
      handle: '@you',
      type: type,
      message: _postController.text.trim(),
      location: 'Kadıköy, İstanbul',
      timestamp: DateTime.now(),
    );

    setState(() {
      _communityPosts.insert(0, newPost);
      _postController.clear();
      _selectedCategory = null;
    });

    _showTopBanner('Your update has been shared with the community');
  }

  void _navigateToAllUpdates() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllCommunityUpdatesScreen(
          posts: _communityPosts,
          onPostsUpdated: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Safety & Community',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share your status and local updates',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 24),
              _buildSafetyStatusCard(),
              const SizedBox(height: 24),
              _buildShareInformationCard(),
              const SizedBox(height: 24),
              _buildCommunityUpdatesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyStatusCard() {
    final background = _hasMarkedSafe ? const Color(0xFFE8F5E9) : Colors.white;
    final borderColor = _hasMarkedSafe
        ? const Color(0xFF2E7D32)
        : Colors.grey.shade200;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasMarkedSafe
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield,
                  color: _hasMarkedSafe ? Colors.white : Colors.grey.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasMarkedSafe
                          ? 'You\'ve marked yourself as safe'
                          : 'Your Safety Status',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hasMarkedSafe
                          ? 'Notification sent to emergency contacts'
                          : 'Let others know you\'re safe',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleMarkSafePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasMarkedSafe
                    ? const Color(0xFF2E7D32)
                    : Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _hasMarkedSafe ? "I'm Safe" : 'Mark as Safe',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareInformationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share Local Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _postController,
            minLines: 3,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Report local conditions, road status, or emergency needs...',
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  category: PostCategory.needHelp,
                  label: 'Need Help',
                  icon: Icons.warning_amber_rounded,
                  activeColor: const Color(0xFFE53935),
                  compact: true,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCategoryButton(
                  category: PostCategory.info,
                  label: 'Share Info',
                  icon: Icons.info_outline,
                  activeColor: const Color(0xFF1E88E5),
                  compact: true,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCategoryButton(
                  category: PostCategory.safe,
                  label: "I'm Safe",
                  icon: Icons.shield_outlined,
                  activeColor: const Color(0xFF2E7D32),
                  compact: true,
                ),
              ),
              const SizedBox(width: 6),
              _buildPostButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityUpdatesSection() {
    final topPosts = _communityPosts.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Community Updates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton(
              onPressed: _navigateToAllUpdates,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (topPosts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('No updates yet. Be the first to share!'),
          )
        else
          Column(
            children: topPosts
                .map(
                  (post) => CommunityPostCard(
                    post: post,
                    onUpdated: () => setState(() {}),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPostButton() {
    return ElevatedButton(
      onPressed: _canPost ? _handlePost : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _canPost ? Colors.black : Colors.grey.shade200,
        foregroundColor: _canPost ? Colors.white : Colors.grey.shade500,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(42, 42),
      ),
      child: const Icon(Icons.send, size: 20),
    );
  }

  Widget _buildCategoryButton({
    required PostCategory category,
    required String label,
    required IconData icon,
    required Color activeColor,
    bool compact = false,
  }) {
    final isSelected = _selectedCategory == category;
    final borderColor = isSelected ? activeColor : Colors.grey.shade300;
    final background = isSelected
        ? activeColor.withValues(alpha: 0.12)
        : Colors.white;
    final textColor = isSelected ? activeColor : Colors.grey.shade700;
    final horizontalPadding = compact ? 10.0 : 14.0;
    final verticalPadding = compact ? 10.0 : 12.0;
    final iconSize = compact ? 16.0 : 18.0;
    final labelStyle = TextStyle(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: compact ? 12.0 : 13.5,
    );

    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      icon: Icon(icon, size: iconSize, color: textColor),
      label: Text(label, style: labelStyle),
      style: OutlinedButton.styleFrom(
        backgroundColor: background,
        side: BorderSide(color: borderColor),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
