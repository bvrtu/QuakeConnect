import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import 'all_community_updates_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

enum PostCategory { needHelp, info, safe }

class _SafetyScreenState extends State<SafetyScreen> {
  bool _hasMarkedSafe = false;
  final TextEditingController _postController = TextEditingController();
  final FocusNode _postFocusNode = FocusNode();
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
    _postFocusNode.dispose();
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

  Future<void> _handleMarkSafePressed() async {
    HapticFeedback.lightImpact();
    if (_hasMarkedSafe) {
      setState(() {
        _hasMarkedSafe = false;
      });
      _showTopBanner(
        AppLocalizations.of(context).safetyStatusCleared,
        background: Colors.black87,
        icon: Icons.info_outline,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).markSafeTitle),
          content: Text(AppLocalizations.of(context).markSafePrompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).confirm),
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
      AppLocalizations.of(context).safetyStatusSent,
      background: const Color(0xFF2E7D32),
      icon: Icons.check_circle,
    );
  }

  void _handlePost() {
    if (!_canPost) return;
    HapticFeedback.lightImpact();
    final category = _selectedCategory!;
    final type = switch (category) {
      PostCategory.needHelp => CommunityPostType.needHelp,
      PostCategory.info => CommunityPostType.info,
      PostCategory.safe => CommunityPostType.safe,
    };

    // Save message before clearing controller
    final messageText = _postController.text.trim();

    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'You',
      handle: '@you',
      type: type,
      message: messageText,
      location: 'Kadıköy, İstanbul',
      timestamp: DateTime.now(),
    );

    setState(() {
      _communityPosts.insert(0, newPost);
      _postController.clear();
      _selectedCategory = null;
    });

    _showTopBanner(AppLocalizations.of(context).postShared);
    
    // Send community update notification if enabled
    final categoryName = switch (category) {
      PostCategory.needHelp => 'Need Help',
      PostCategory.info => 'Info',
      PostCategory.safe => 'I\'m Safe',
    };
    final notificationBody = messageText.length > 50 
        ? '${messageText.substring(0, 50)}...' 
        : messageText;
    NotificationService.instance.showCommunityUpdateNotification(
      'New Community Update',
      '$categoryName: $notificationBody',
    );
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
    return GestureDetector(
      onTap: () {
        // Unfocus text field when tapping outside
        _postFocusNode.unfocus();
      },
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).safetyTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).safetySubtitle,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                  fontSize: 15,
                ),
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
      ),
    );
  }

  Widget _buildSafetyStatusCard() {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = _hasMarkedSafe
        ? (isDark ? const Color(0xFF15361B) : const Color(0xFFE8F5E9))
        : surface;
    final borderColor = _hasMarkedSafe
        ? const Color(0xFF2E7D32)
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
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
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
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
                          ? AppLocalizations.of(context).imSafe
                          : AppLocalizations.of(context).yourSafetyStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hasMarkedSafe
                          ? AppLocalizations.of(context).emergencyTip
                          : AppLocalizations.of(context).letOthersKnow,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
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
            child: ElevatedButton.icon(
              onPressed: _handleMarkSafePressed,
              icon: Icon(_hasMarkedSafe ? Icons.shield : Icons.shield_outlined, size: 20),
              label: Text(
                _hasMarkedSafe ? AppLocalizations.of(context).imSafe : AppLocalizations.of(context).markAsSafe,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasMarkedSafe
                    ? const Color(0xFF2E7D32)
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: (_hasMarkedSafe
                        ? const Color(0xFF2E7D32)
                        : Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareInformationCard() {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).shareLocalInfo,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          TextField(
            controller: _postController,
            focusNode: _postFocusNode,
            minLines: 3,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).shareLocalInfo,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  category: PostCategory.needHelp,
                  label: AppLocalizations.of(context).needHelp,
                  icon: Icons.warning_amber_rounded,
                  activeColor: const Color(0xFFE53935),
                  compact: true,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCategoryButton(
                  category: PostCategory.info,
                  label: AppLocalizations.of(context).shareInfo,
                  icon: Icons.info_outline,
                  activeColor: const Color(0xFF1E88E5),
                  compact: true,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCategoryButton(
                  category: PostCategory.safe,
                  label: AppLocalizations.of(context).imSafe,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).communityUpdatesTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton(
              onPressed: _navigateToAllUpdates,
              child: Text(AppLocalizations.of(context).viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (topPosts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(AppLocalizations.of(context).noUpdatesYet),
          )
        else
          Column(
            children: topPosts
                .map(
                  (post) => CommunityPostCard(
                    post: post,
                    onUpdated: () => setState(() {}),
                      showBanner: (msg, {Color background = Colors.black87, IconData icon = Icons.check_circle}) {
                        _showTopBanner(msg, background: background, icon: icon);
                      },
                  ),
                )
                .toList(),
          ),
      ],
      ),
    );
  }

  Widget _buildPostButton() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: _canPost ? _handlePost : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _canPost
            ? cs.primary
            : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.grey.shade200),
        foregroundColor: _canPost
            ? Colors.white
            : (isDark ? Colors.grey.shade300 : Colors.grey.shade500),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(42, 42),
        elevation: _canPost ? 4 : 0,
        shadowColor: _canPost ? cs.primary.withValues(alpha: 0.3) : Colors.transparent,
        side: _canPost
            ? BorderSide.none
            : BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = compact ? 10.0 : 14.0;
    final verticalPadding = compact ? 12.0 : 14.0;
    final iconSize = compact ? 16.0 : 18.0;
    
    if (isSelected) {
      // Selected state: ElevatedButton with theme color
      return ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        icon: Icon(icon, size: iconSize, color: Colors.white),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12.0 : 13.5,
            ),
            maxLines: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: activeColor.withValues(alpha: 0.3),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // Unselected state: OutlinedButton
      final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      final textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
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
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: labelStyle, maxLines: 1),
      ),
      style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          side: BorderSide(color: borderColor, width: 1.2),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    }
  }
}
