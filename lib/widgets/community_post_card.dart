import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/community_post.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';

class Comment {
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
  final List<Comment> replies;

  Comment({
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
    List<Comment>? replies,
  }) : replies = replies ?? <Comment>[];

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

  const CommunityPostCard({super.key, required this.post, this.onUpdated});

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  final List<Comment> _comments = <Comment>[];

  void _toggleLike() {
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      widget.post.likes += widget.post.isLiked ? 1 : -1;
    });
    widget.onUpdated?.call();
  }

  void _toggleRepost() {
    setState(() {
      widget.post.isReposted = !widget.post.isReposted;
      widget.post.reposts += widget.post.isReposted ? 1 : -1;
    });
    widget.onUpdated?.call();
    if (widget.post.isReposted) {
      _showSnackBar('Post added to your updates');
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
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
          icon: widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
          activeIcon: Icons.favorite,
          label: widget.post.likes,
          isActive: widget.post.isLiked,
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
          label: widget.post.reposts,
          isActive: widget.post.isReposted,
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
            setState(() {
              widget.post.shares += 1;
            });
            widget.onUpdated?.call();
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

        return StatefulBuilder(
          builder: (context, modalSetState) {

            Widget buildCommentTile(Comment c, {double indent = 0}) {
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
                                Text(formatTimeAgo(context, c.timestamp), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ]),
                              const SizedBox(height: 4),
                              Text(c.text, style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 6),
                              Row(children: [
                                _buildActionButton(icon: c.liked ? Icons.favorite : Icons.favorite_border, activeIcon: Icons.favorite, label: c.likes, isActive: c.liked, activeColor: const Color(0xFFE53935), onTap: () { modalSetState(() { c.liked = !c.liked; c.likes += c.liked ? 1 : -1; }); }),
                                _buildActionButton(
                                    icon: Icons.mode_comment_outlined,
                                    activeIcon: Icons.mode_comment,
                                    label: c.replies.length,
                                    onTap: () {
                                      modalSetState(() {
                                        replyingTo = c;
                                      });
                                      // Focus composer after state set
                                      FocusScope.of(context)
                                          .requestFocus(focusNode);
                                    }),
                                _buildActionButton(icon: Icons.repeat, activeIcon: Icons.repeat, label: c.retweets, isActive: c.retweeted, activeColor: const Color(0xFF1E88E5), onTap: () { modalSetState(() { c.retweeted = !c.retweeted; c.retweets += c.retweeted ? 1 : -1; }); }),
                                _buildActionButton(icon: Icons.share_outlined, activeIcon: Icons.share, label: 0, showLabel: false, onTap: () async { await Share.share(c.text, subject: 'QuakeConnect Reply'); }),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (c.replies.isNotEmpty)
                      ...c.replies.map((r) => buildCommentTile(r, indent: indent + 24)),
                  ],
                ),
              );
            }

            final viewInsets = MediaQuery.of(context).viewInsets;
            return Padding(
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
                      child: _comments.isEmpty
                          ? Center(child: Text(AppLocalizations.of(context).noRepliesYet, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600)))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: _comments.length,
                              separatorBuilder: (_, __) => const Divider(height: 20),
                              itemBuilder: (context, index) {
                                final c = _comments[index];
                                return buildCommentTile(c);
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
                            decoration: InputDecoration(
                              hintText: replyingTo == null ? AppLocalizations.of(context).reply : '${AppLocalizations.of(context).replyingTo} @' + replyingTo!.handle.substring(1),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onSubmitted: (_) {
                              final text = controller.text.trim();
                              if (text.isEmpty) return;
                              modalSetState(() {
                                if (replyingTo == null) {
                                  _comments.insert(0, Comment(id: DateTime.now().millisecondsSinceEpoch.toString(), authorName: 'You', handle: '@you', text: text, timestamp: DateTime.now()));
                                } else {
                                  replyingTo!.replies.add(Comment(id: DateTime.now().millisecondsSinceEpoch.toString(), authorName: 'You', handle: '@you', text: text, timestamp: DateTime.now()));
                                  replyingTo = null;
                                }
                              });
                              setState(() { widget.post.comments += 1; });
                              widget.onUpdated?.call();
                              controller.clear();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            modalSetState(() {
                              if (replyingTo == null) {
                                _comments.insert(0, Comment(id: DateTime.now().millisecondsSinceEpoch.toString(), authorName: 'You', handle: '@you', text: text, timestamp: DateTime.now()));
                              } else {
                                replyingTo!.replies.add(Comment(id: DateTime.now().millisecondsSinceEpoch.toString(), authorName: 'You', handle: '@you', text: text, timestamp: DateTime.now()));
                                replyingTo = null;
                              }
                            });
                            setState(() { widget.post.comments += 1; });
                            widget.onUpdated?.call();
                            controller.clear();
                          },
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(12), backgroundColor: Colors.black, foregroundColor: Colors.white),
                          child: const Icon(Icons.send, size: 18),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
