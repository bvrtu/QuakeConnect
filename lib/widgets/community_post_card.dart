import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/community_post.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';
import '../data/post_repository.dart';
import '../data/comment_repository.dart' show Comment, CommentRepository;
import '../services/auth_service.dart';
import '../data/user_repository.dart';

class LocalComment {
  final String id;
  final String authorName;
  final String handle;
  String text;
  DateTime timestamp;
  int likes;
  bool liked;
  int retweets;
  bool retweeted;
  int reposts;
  bool reposted;
  final List<LocalComment> replies;

  LocalComment({
    required this.id,
    required this.authorName,
    required this.handle,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.liked = false,
    this.retweets = 0,
    this.retweeted = false,
    this.reposts = 0,
    this.reposted = false,
    List<LocalComment>? replies,
  }) : replies = replies ?? <LocalComment>[];

  String get timeAgo {
    final d = DateTime.now().difference(timestamp);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class CommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback? onUpdated;
  final void Function(String message, {Color background, IconData icon})? showBanner;

  const CommunityPostCard({super.key, required this.post, this.onUpdated, this.showBanner});

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  final PostRepository _postRepo = PostRepository.instance;
  final CommentRepository _commentRepo = CommentRepository.instance;
  final UserRepository _userRepo = UserRepository.instance;
  String? _currentUserId;
  
  // Local state for optimistic updates
  bool? _optimisticIsLiked;
  bool? _optimisticIsReposted;
  int? _optimisticLikes;
  int? _optimisticReposts;
  bool _hasOptimisticLike = false;
  bool _hasOptimisticRepost = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.instance.currentUserId;
  }

  @override
  void didUpdateWidget(CommunityPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync optimistic state with StreamBuilder updates
    // Only sync if we haven't made optimistic changes
    if (!_hasOptimisticLike) {
      _optimisticIsLiked = widget.post.isLiked;
      _optimisticLikes = widget.post.likes;
    }
    if (!_hasOptimisticRepost) {
      _optimisticIsReposted = widget.post.isReposted;
      _optimisticReposts = widget.post.reposts;
    }
  }

  bool get _isLiked => _optimisticIsLiked ?? widget.post.isLiked;
  bool get _isReposted => _optimisticIsReposted ?? widget.post.isReposted;
  int get _likes => _optimisticLikes ?? widget.post.likes;
  int get _reposts => _optimisticReposts ?? widget.post.reposts;

  Future<void> _toggleLike() async {
    if (_currentUserId == null) return;
    HapticFeedback.selectionClick();
    
    // Optimistic update
    final previousLiked = _isLiked;
    final previousLikes = _likes;
    setState(() {
      _hasOptimisticLike = true;
      _optimisticIsLiked = !previousLiked;
      _optimisticLikes = previousLiked ? previousLikes - 1 : previousLikes + 1;
    });
    
    try {
      await _postRepo.likePost(widget.post.id, _currentUserId!);
      // After successful update, reset flag so StreamBuilder can sync
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _hasOptimisticLike = false;
          });
        }
      });
    } catch (e) {
      // Revert on error
      setState(() {
        _hasOptimisticLike = false;
        _optimisticIsLiked = previousLiked;
        _optimisticLikes = previousLikes;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleRepost() async {
    if (_currentUserId == null) return;
    HapticFeedback.lightImpact();
    
    // Optimistic update
    final previousReposted = _isReposted;
    final previousReposts = _reposts;
    setState(() {
      _hasOptimisticRepost = true;
      _optimisticIsReposted = !previousReposted;
      _optimisticReposts = previousReposted ? previousReposts - 1 : previousReposts + 1;
    });
    
    try {
      await _postRepo.repostPost(widget.post.id, _currentUserId!);
      // After successful update, reset flag so StreamBuilder can sync
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _hasOptimisticRepost = false;
          });
        }
      });
      
      // Show banner only if we're reposting (not un-reposting)
      if (!previousReposted) {
        final t = AppLocalizations.of(context);
        widget.showBanner?.call(
          t.repostAdded,
          background: const Color(0xFF1E88E5),
          icon: Icons.repeat,
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _hasOptimisticRepost = false;
        _optimisticIsReposted = previousReposted;
        _optimisticReposts = previousReposts;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF6246EA),
                child: Text(
                  _buildInitials(widget.post.authorName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.authorName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    widget.post.handle,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatTimeAgo(context, widget.post.timestamp),
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.post.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: isDark ? Colors.grey.shade300 : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.post.location,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((element) => element.isNotEmpty)
        .toList();
    String firstRune(String word) {
      if (word.isEmpty) return '';
      final rune = word.runes.first;
      return String.fromCharCode(rune);
    }

    final first = firstRune(parts.first);
    final second = parts.length > 1 ? firstRune(parts[1]) : '';
    return (first + second).toUpperCase();
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.post.badgeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.post.badgeColor),
      ),
      child: Text(
        widget.post.type == CommunityPostType.needHelp
            ? AppLocalizations.of(context).needHelp
            : widget.post.type == CommunityPostType.info
                ? AppLocalizations.of(context).shareInfo
                : AppLocalizations.of(context).imSafe,
        style: TextStyle(
          color: widget.post.badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          activeIcon: Icons.favorite,
          label: _likes,
          isActive: _isLiked,
          activeColor: const Color(0xFFE53935),
          onTap: _toggleLike,
        ),
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          activeIcon: Icons.mode_comment,
          label: widget.post.comments,
          onTap: _openCommentsSheet,
        ),
        _buildActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          label: _reposts,
          isActive: _isReposted,
          activeColor: const Color(0xFF1E88E5),
          onTap: _toggleRepost,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          label: widget.post.shares,
          showLabel: false,
          onTap: () async {
            final shareMessage =
                '${widget.post.message}\n\nLocation: ${widget.post.location}';
            await Share.share(shareMessage, subject: 'QuakeConnect Update');
            HapticFeedback.selectionClick();
            setState(() {
              widget.post.shares += 1;
            });
            widget.onUpdated?.call();
            final t = AppLocalizations.of(context);
            widget.showBanner?.call(
              t.postSharedExternal,
              background: Colors.black87,
              icon: Icons.share,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required int label,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.black,
    bool showLabel = true,
  }) {
    final color = isActive ? activeColor : Colors.grey.shade600;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(isActive ? activeIcon : icon, size: 20, color: color),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                label.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Persist sheet state across modalSetState rebuilds
        final TextEditingController controller = TextEditingController();
        final FocusNode focusNode = FocusNode();
        Comment? replyingTo;
        // Track which comments have expanded replies (persist across rebuilds)
        final expandedComments = <String>{};

        return StatefulBuilder(
          builder: (context, modalSetState) {

            Widget buildCommentTile(Comment c, {double indent = 0}) {
              final isLiked = _currentUserId != null && c.likes.contains(_currentUserId!);
              return Padding(
                padding: EdgeInsets.only(left: indent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(c.timeAgo, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ]),
                              const SizedBox(height: 4),
                              Text(c.text, style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 6),
                              Row(children: [
                                _buildActionButton(
                                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                                  activeIcon: Icons.favorite,
                                  label: c.likesCount,
                                  isActive: isLiked,
                                  activeColor: const Color(0xFFE53935),
                                  onTap: () async {
                                    if (_currentUserId != null) {
                                      await _commentRepo.likeComment(widget.post.id, c.id, _currentUserId!);
                                    }
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.mode_comment_outlined,
                                  activeIcon: Icons.mode_comment,
                                  label: c.repliesCount,
                                  onTap: () {
                                    modalSetState(() {
                                      replyingTo = c;
                                    });
                                    FocusScope.of(context).requestFocus(focusNode);
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.share_outlined,
                                  activeIcon: Icons.share,
                                  label: 0,
                                  showLabel: false,
                                  onTap: () async {
                                    await Share.share(c.text, subject: 'QuakeConnect Reply');
                                    final t = AppLocalizations.of(context);
                                    widget.showBanner?.call(
                                      t.postSharedExternal,
                                      background: Colors.black87,
                                      icon: Icons.share,
                                    );
                                  },
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            final viewInsets = MediaQuery.of(context).viewInsets;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return GestureDetector(
              onTap: () {
                // Unfocus text field when tapping outside
                focusNode.unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(children: [
                        Icon(Icons.mode_comment_outlined, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).thread, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                        const Spacer(),
                        IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.of(context).pop()),
                      ]),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: StreamBuilder<List<Comment>>(
                        stream: _commentRepo.getComments(widget.post.id),
                        builder: (context, snapshot) {
                          // Only show loading on initial load, not on subsequent updates
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          
                          final comments = snapshot.data ?? [];
                          
                          if (comments.isEmpty) {
                            return GestureDetector(
                              onTap: () => focusNode.unfocus(),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context).noRepliesYet,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          // Twitter-style thread structure:
                          // 1. Top-level comments (parentCommentId == null)
                          // 2. Direct replies to top-level (parentCommentId == top-level id)
                          // 3. Thread replies (replies to direct replies, shown as thread)
                          
                          final topLevelComments = comments.where((c) => c.parentCommentId == null).toList();
                          
                          // Build a map of all comments by their parent ID
                          final commentsByParent = <String, List<Comment>>{};
                          for (final comment in comments) {
                            if (comment.parentCommentId != null) {
                              commentsByParent.putIfAbsent(comment.parentCommentId!, () => []).add(comment);
                            }
                          }
                          
                          // Recursive function to build thread structure
                          // Twitter-style: Shows top-level, direct replies, and thread replies
                          // Depth: 1 = direct reply, 2 = thread reply, 3+ = hidden (unless expanded)
                          Widget buildThread(Comment comment, double indent, int depth, Set<String> expandedComments) {
                            final replies = commentsByParent[comment.id] ?? [];
                            // Sort replies by timestamp (oldest first for thread)
                            replies.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                            
                            // Check if this comment's replies are expanded
                            final isExpanded = expandedComments.contains(comment.id);
                            
                            // Twitter shows max 2 levels of thread (direct reply + thread reply)
                            // depth 1 = direct reply, depth 2 = thread reply, depth 3+ = hidden (unless expanded)
                            final shouldShowReplies = replies.isNotEmpty && (depth < 3 || isExpanded);
                            final hasHiddenReplies = replies.isNotEmpty && depth >= 3 && !isExpanded;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: indent),
                                  child: buildCommentTile(comment),
                                ),
                                // Show thread replies (replies to this comment)
                                // Twitter shows thread replies with more indent
                                if (shouldShowReplies) ...[
                                  ...replies.map((reply) => Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: buildThread(reply, indent + 24, depth + 1, expandedComments),
                                  )),
                                ],
                                // If there are hidden replies (depth >= 3), show "Show more" button
                                if (hasHiddenReplies) ...[
                                  Padding(
                                    padding: EdgeInsets.only(left: indent + 24, top: 4),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        // Expand to show all replies
                                        modalSetState(() {
                                          expandedComments.add(comment.id);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.more_horiz,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      label: Text(
                                        AppLocalizations.of(context).showReplies(replies.length),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }
                          
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: topLevelComments.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final c = topLevelComments[index];
                              final directReplies = commentsByParent[c.id] ?? [];
                              // Sort direct replies by timestamp
                              directReplies.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                              
                              return GestureDetector(
                                onTap: () => focusNode.unfocus(),
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top-level comment
                                    buildCommentTile(c),
                                    // Direct replies with thread structure
                                    if (directReplies.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      ...directReplies.map((reply) => buildThread(reply, 24, 1, expandedComments)),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Composer (bottom, slightly lifted)
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -2)),
                        ],
                      ),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            minLines: 1,
                            maxLines: 4,
                            onChanged: (_) {
                              // Only update button state, don't trigger StreamBuilder rebuild
                              modalSetState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: replyingTo == null ? AppLocalizations.of(context).reply : '${AppLocalizations.of(context).replyingTo} @' + replyingTo!.handle.substring(1),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onSubmitted: (_) async {
                              final text = controller.text.trim();
                              if (text.isEmpty || _currentUserId == null) return;
                              HapticFeedback.selectionClick();
                              
                              try {
                                final user = await _userRepo.getUser(_currentUserId!);
                                await _commentRepo.addComment(
                                  postId: widget.post.id,
                                  text: text,
                                  parentCommentId: replyingTo?.id,
                                  user: user,
                                );
                                
                                controller.clear();
                                if (replyingTo != null) {
                                  modalSetState(() {
                                    replyingTo = null;
                                  });
                                }
                                
                                // StreamBuilder will automatically update the comment count
                                
                                final t = AppLocalizations.of(context);
                                widget.showBanner?.call(
                                  t.commentSent,
                                  background: const Color(0xFF424242),
                                  icon: Icons.mode_comment,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final hasText = controller.text.trim().isNotEmpty;
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            return ElevatedButton(
                              onPressed: hasText && _currentUserId != null ? () async {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                HapticFeedback.selectionClick();
                                
                                try {
                                  final user = await _userRepo.getUser(_currentUserId!);
                                  await _commentRepo.addComment(
                                    postId: widget.post.id,
                                    text: text,
                                    parentCommentId: replyingTo?.id,
                                    user: user,
                                  );
                                  
                                  controller.clear();
                                  if (replyingTo != null) {
                                    modalSetState(() {
                                      replyingTo = null;
                                    });
                                  }
                                  
                                  // StreamBuilder will automatically update the comment count
                                  
                                  final t = AppLocalizations.of(context);
                                  widget.showBanner?.call(
                                    t.commentSent,
                                    background: const Color(0xFF424242),
                                    icon: Icons.mode_comment,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                                backgroundColor: hasText
                                    ? Colors.black
                                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                foregroundColor: hasText
                                    ? Colors.white
                                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                                elevation: hasText ? 2 : 0,
                                side: !hasText && isDark
                                    ? BorderSide(color: Colors.grey.shade700, width: 1.5)
                                    : null,
                              ),
                              child: const Icon(Icons.send, size: 18),
                            );
                          },
                        ),
                      ]),
                    ),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
