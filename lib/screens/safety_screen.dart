import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import 'all_community_updates_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../data/post_repository.dart';
import '../services/auth_service.dart';
import '../data/user_repository.dart';
import '../services/location_service.dart';
import '../data/settings_repository.dart';
import '../data/emergency_contact_repository.dart';
import '../models/emergency_contact.dart';
import 'profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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
  OverlayEntry? _bannerEntry;
  final PostRepository _postRepo = PostRepository.instance;
  final UserRepository _userRepo = UserRepository.instance;
  final EmergencyContactRepository _contactRepo = EmergencyContactRepository.instance;
  String? _currentUserId;
  String _userLocation = 'Unknown Location';
  StreamSubscription<List<EmergencyContact>>? _contactsSub;
  List<EmergencyContact> _emergencyContacts = [];

  @override
  void dispose() {
    _postController.dispose();
    _postFocusNode.dispose();
    _removeBanner();
    _contactsSub?.cancel();
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
    final t = AppLocalizations.of(context);

    if (_hasMarkedSafe) {
      setState(() {
        _hasMarkedSafe = false;
      });
      _showTopBanner(
        t.safetyStatusCleared,
        background: Colors.black87,
        icon: Icons.info_outline,
      );
      return;
    }

    if (_currentUserId == null) {
      _showTopBanner('Please sign in again', background: Colors.red);
      return;
    }

    if (_emergencyContacts.isEmpty) {
      await _promptToAddContacts();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.markSafeTitle),
          content: Text(t.markSafePrompt(_emergencyContacts.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.confirm),
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
      t.safetyStatusSent,
      background: const Color(0xFF2E7D32),
      icon: Icons.check_circle,
    );
    await _openSafetyShareSheet();
  }

  Future<void> _promptToAddContacts() async {
    final t = AppLocalizations.of(context);
    final goToProfile = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emergencyContacts),
        content: Text(t.noEmergencyContacts),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.manageContacts),
          ),
        ],
      ),
    );

    if (goToProfile == true) {
      _navigateToProfileForContacts();
    }
  }

  void _navigateToProfileForContacts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final t = AppLocalizations.of(context);
          return Scaffold(
            body: const ProfileScreen(),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 4,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              onTap: (_) => Navigator.of(context).pop(),
              selectedItemColor: Colors.red,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.navHome),
                BottomNavigationBarItem(icon: const Icon(Icons.map), label: t.navMap),
                BottomNavigationBarItem(icon: const Icon(Icons.shield), label: t.navSafety),
                BottomNavigationBarItem(icon: const Icon(Icons.explore), label: t.navDiscover),
                BottomNavigationBarItem(icon: const Icon(Icons.person), label: t.navProfile),
                BottomNavigationBarItem(icon: const Icon(Icons.settings), label: t.navSettings),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openSafetyShareSheet() async {
    if (!mounted || _emergencyContacts.isEmpty) return;
    final t = AppLocalizations.of(context);
    final message = _buildSafetyStatusMessage();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.shareSafetyStatus,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.contactsWillBeNotified(_emergencyContacts.length),
                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ..._emergencyContacts
                    .map((contact) => _buildShareContactTile(contact, message, isDark))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareContactTile(EmergencyContact contact, String message, bool isDark) {
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFF6B00),
                child: Text(
                  _initials(contact.name),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.phone,
                      style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callNumber(contact.phone),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(t.call),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendSafetySms(contact.phone, message),
                  icon: const Icon(Icons.sms_outlined, size: 18),
                  label: Text(t.sendSms),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final t = AppLocalizations.of(context);
    final uri = Uri(scheme: 'tel', path: _sanitizePhone(phone));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showTopBanner(t.callUnavailable, background: Colors.red);
    }
  }

  Future<void> _sendSafetySms(String phone, String message) async {
    final t = AppLocalizations.of(context);
    final uri = Uri.parse('sms:${_sanitizePhone(phone)}?body=${Uri.encodeComponent(message)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showTopBanner(t.smsUnavailable, background: Colors.red);
    }
  }

  String _sanitizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned.isEmpty ? phone : cleaned;
  }

  String _buildSafetyStatusMessage() {
    final t = AppLocalizations.of(context);
    final timestamp = _formatTimestamp(DateTime.now());
    return t.safetyStatusMessage(_userLocation, timestamp);
  }

  String _formatTimestamp(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$day.$month.${time.year} $hour:$minute';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  Future<void> _handlePost() async {
    if (!_canPost || _currentUserId == null) return;
    HapticFeedback.lightImpact();
    final category = _selectedCategory!;
    final type = switch (category) {
      PostCategory.needHelp => CommunityPostType.needHelp,
      PostCategory.info => CommunityPostType.info,
      PostCategory.safe => CommunityPostType.safe,
    };

    // Save message before clearing controller
    final messageText = _postController.text.trim();

    // Get user info
    final user = await _userRepo.getUser(_currentUserId!);
    if (user == null) {
      _showTopBanner('Error: User not found', background: Colors.red);
      return;
    }

          // Get location (only if location services are enabled)
          String location = _userLocation;
          if (location == 'Unknown Location' && SettingsRepository.instance.locationServices) {
            try {
              final position = await LocationService.getCurrentLocation();
              if (position != null) {
                location = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
              }
            } catch (e) {
              // Use default location
            }
          } else if (!SettingsRepository.instance.locationServices) {
            location = 'Location services disabled';
          }

    final newPost = CommunityPost(
      id: '', // Will be set by Firebase
      authorName: user.displayName,
      handle: user.username,
      type: type,
      message: messageText,
      location: location,
      timestamp: DateTime.now(),
    );

    try {
      await _postRepo.createPost(
        post: newPost,
        userId: _currentUserId!,
    );

    setState(() {
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
    } catch (e) {
      _showTopBanner('Error posting: $e', background: Colors.red);
    }
  }

  void _navigateToAllUpdates() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllCommunityUpdatesScreen(
          userId: _currentUserId,
        ),
      ),
    );
  }

         Future<void> _loadUserInfo() async {
           _currentUserId = AuthService.instance.currentUserId;
           if (_currentUserId != null) {
             // Get user location (only if location services are enabled)
             if (SettingsRepository.instance.locationServices) {
               try {
                 final position = await LocationService.getCurrentLocation();
                 if (position != null) {
                   setState(() {
                     _userLocation = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
                   });
                 } else {
                   setState(() {
                     _userLocation = 'Location unavailable';
                   });
                 }
               } catch (e) {
                 setState(() {
                   _userLocation = 'Location unavailable';
                 });
               }
             } else {
               setState(() {
                 _userLocation = 'Location services disabled';
               });
             }
      _listenEmergencyContacts();
           }
         }

  void _listenEmergencyContacts() {
    final userId = _currentUserId;
    if (userId == null) return;
    _contactsSub?.cancel();
    _contactsSub = _contactRepo.watchContacts(userId).listen((contacts) {
      if (!mounted) return;
      setState(() {
        _emergencyContacts = contacts;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
    final t = AppLocalizations.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = _hasMarkedSafe
        ? (isDark ? const Color(0xFF15361B) : const Color(0xFFE8F5E9))
        : surface;
    final subtitle = _hasMarkedSafe
        ? t.emergencyTip
        : (_emergencyContacts.isEmpty ? t.addContactTip : t.contactsWillBeNotified(_emergencyContacts.length));

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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _hasMarkedSafe ? t.imSafe : t.yourSafetyStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              label: Flexible(
                child: Text(
                  _hasMarkedSafe ? AppLocalizations.of(context).imSafe : AppLocalizations.of(context).markAsSafe,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            Expanded(
              child: Text(
                AppLocalizations.of(context).followingUpdatesTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _navigateToAllUpdates,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context).viewAll,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<CommunityPost>>(
          stream: _currentUserId != null 
              ? _postRepo.getFollowingPosts(_currentUserId!, _currentUserId)
              : Stream.value(<CommunityPost>[]),
          builder: (context, snapshot) {
            // Only show loading on initial load, not on subsequent updates
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final posts = snapshot.data ?? [];
            final topPosts = posts.take(3).toList();
            
            if (topPosts.isEmpty) {
              return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(AppLocalizations.of(context).noUpdatesYet),
              );
            }
            
            return Column(
            children: topPosts
                .map(
                  (post) => CommunityPostCard(
                    post: post,
                      onUpdated: null, // StreamBuilder will handle updates automatically
                      showBanner: (msg, {Color background = Colors.black87, IconData icon = Icons.check_circle}) {
                        _showTopBanner(msg, background: background, icon: icon);
                      },
                  ),
                )
                .toList(),
            );
          },
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
    final horizontalPadding = compact ? 6.0 : 14.0;
    final verticalPadding = compact ? 10.0 : 14.0;
    final iconSize = compact ? 14.0 : 18.0;
    
    if (isSelected) {
      // Selected state: ElevatedButton with theme color
      return ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        icon: Icon(icon, size: iconSize, color: Colors.white),
        label: Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11.0 : 13.5,
              ),
              maxLines: 1,
            ),
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
      label: Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
          ),
        ),
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
