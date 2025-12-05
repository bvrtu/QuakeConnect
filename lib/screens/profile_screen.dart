import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../data/user_repository.dart';
import '../data/post_repository.dart';
import '../models/user_model.dart';
import '../data/emergency_contact_repository.dart';
import '../models/emergency_contact.dart';
import '../data/settings_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'safety_screen.dart';
import 'discover_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // If null, shows current user's profile
  
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepo = UserRepository.instance;
  final PostRepository _postRepo = PostRepository.instance;
  final EmergencyContactRepository _contactRepo = EmergencyContactRepository.instance;
  String? _currentUserId;
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  final ScrollController _postScrollController = ScrollController();
  OverlayEntry? _bannerEntry;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _postScrollController.addListener(_onPostScroll);
  }

  bool get _isViewingOwnProfile => widget.userId == null || widget.userId == AuthService.instance.currentUserId;
  
  Future<void> _loadCurrentUser() async {
    final targetUserId = widget.userId ?? AuthService.instance.currentUserId;
    _currentUserId = AuthService.instance.currentUserId;
    
    if (targetUserId != null) {
      final user = await _userRepo.getUser(targetUserId);
      if (user == null && _isViewingOwnProfile && AuthService.instance.isLoggedIn) {
        // User is authenticated but document doesn't exist in Firestore
        // This shouldn't happen, but if it does, sign out
        await AuthService.instance.signOut();
      }
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    } else {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }
  Widget _buildPostsSection() {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId == null) {
      return const SizedBox.shrink();
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).posts, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => _UserPostsScreen(userId: targetUserId ?? _currentUserId ?? '')));
                  },
                  child: Text(AppLocalizations.of(context).viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<CommunityPost>>(
              stream: _postRepo.getPostsByUserId(targetUserId, _currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                final posts = snapshot.data ?? [];
                
                if (posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).noUpdatesYet,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                
                final displayPosts = posts.take(3).toList();
                
                return Column(
                  children: displayPosts.map((post) => CommunityPostCard(
                    post: post,
                    onUpdated: () => setState(() {}),
                    showBanner: (msg, {Color background = Colors.black87, IconData icon = Icons.check_circle}) {
                      _showTopBanner(msg, background: background, icon: icon);
                    },
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postScrollController.dispose();
    _removeBanner();
    super.dispose();
  }
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
            builder: (context, t, child) => Transform.translate(offset: Offset(0, (1 - t) * -40), child: Opacity(opacity: t, child: child)),
            child: Material(
              color: Colors.transparent,
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    _bannerEntry = entry;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _removeBanner();
    });
  }

  void _onPostScroll() {
    // Infinite scroll handled by StreamBuilder
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_currentUser == null) {
      // If user is not authenticated, main.dart will handle showing login screen
      // If user is authenticated but document not found, we already signed out in _loadCurrentUser
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopHeader()),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildHeaderCard()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildCountsSection()),
            if (_isViewingOwnProfile) ...[
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildEmergencySection()),
            ],
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildPostsSection()),
          ],
          controller: _postScrollController,
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          if (canPop) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            AppLocalizations.of(context).profileTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId == null) {
      return const SizedBox.shrink();
    }
    
    return StreamBuilder<UserModel?>(
      stream: _userRepo.getUserStream(targetUserId),
      initialData: _currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? _currentUser;
        if (user == null) {
          return const SizedBox.shrink();
        }
        
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: 1.2,
          ),
          boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatar(),
                        if (_isViewingOwnProfile)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: InkWell(
                        onTap: _openChangePicture,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.photo_camera_outlined,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          Text(
                            user.displayName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                                letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.alternate_email,
                                size: 14, color: Color(0xFF6246EA)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                user.username.startsWith('@')
                                    ? user.username.substring(1)
                                    : user.username,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                    Expanded(child: _buildInfoTile(Localizations.localeOf(context).languageCode == 'tr' ? 'Yaş' : 'Age', '${user.age ?? 0} ${Localizations.localeOf(context).languageCode == 'tr' ? 'yıl' : 'years'}', 0xFFE3F2FD)),
                const SizedBox(width: 12),
                    Expanded(child: _buildInfoTile(Localizations.localeOf(context).languageCode == 'tr' ? 'Boy' : 'Height', '${user.heightCm ?? 0} cm', 0xFFE8F5E9)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                    Expanded(child: _buildInfoTile(Localizations.localeOf(context).languageCode == 'tr' ? 'Kilo' : 'Weight', '${user.weightKg ?? 0} kg', 0xFFFFF3E0)),
                const SizedBox(width: 12),
                    Expanded(child: _buildInfoTile(
                      AppLocalizations.of(context).disabilityStatus,
                      _disabilitiesLabel(context, user.disabilities, user.disabilityOther),
                      0xFFF3E5F5,
                      onTap: user.disabilities.isNotEmpty 
                          ? () => _showDisabilitiesDialog(context, user.disabilities, user.disabilityOther) 
                          : null,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.location_on,
                    size: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    user.location ?? 'Unknown',
                        style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                        fontSize: 15),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.alternate_email,
                    size: 18, color: Color(0xFF6246EA)),
                const SizedBox(width: 6),
                Expanded(
                        child: Text(
                          _isViewingOwnProfile 
                              ? (AuthService.instance.currentUser?.email ?? user.email ?? 'No email')
                              : (user.email ?? 'No email'),
                        style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                            fontSize: 15))),
              ],
            ),
            const SizedBox(height: 16),
                if (_isViewingOwnProfile)
            SizedBox(
              width: double.infinity,
                    child: ElevatedButton.icon(
                onPressed: _openEditProfile,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: Text(
                        AppLocalizations.of(context).editProfile,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                  shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                  ),
                        shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
                  )
                else
                  _buildFollowButton(),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildCountsRow() {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId == null) {
      return const SizedBox.shrink();
    }
    
    return StreamBuilder<UserModel?>(
      stream: _userRepo.getUserStream(targetUserId),
      initialData: _currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? _currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _CountTile(
              color: const Color(0xFFF3E8FF),
              icon: Icons.groups,
              label: AppLocalizations.of(context).followers,
                  value: user?.followers ?? 0,
              onTap: () => _openFollowList(isFollowers: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CountTile(
              color: const Color(0xFFE3F2FD),
              icon: Icons.person_add,
              label: AppLocalizations.of(context).following,
                  value: user?.following ?? 0,
              onTap: () => _openFollowList(isFollowers: false),
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildCountsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: _buildCountsRow(),
      ),
    );
  }

  Widget _buildEmergencySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = _currentUserId;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: StreamBuilder<List<EmergencyContact>>(
          stream: _contactRepo.watchContacts(userId),
          builder: (context, snapshot) {
            final contacts = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
        children: [
          const Icon(Icons.phone_in_talk, color: Colors.redAccent),
          const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.emergencyContacts,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
          const SizedBox(width: 8),
          IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: _openAddContactForm,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
          )
                else if (contacts.isEmpty)
                  _buildEmptyContactsState(isDark)
                else
                  Column(
                    children: contacts
                        .map(
                          (c) => _buildContactCard(
                            contact: c,
                            isDark: isDark,
                          ),
                        )
                        .toList(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyContactsState(bool isDark) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.noContactsSaved,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t.tapToAddContact,
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openAddContactForm,
              icon: const Icon(Icons.person_add_alt),
              label: Text(t.addEmergencyContact),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({required EmergencyContact contact, required bool isDark}) {
    final t = AppLocalizations.of(context);
    return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
                ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
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
                          Row(
                            children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                              const SizedBox(width: 8),
                              Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                          child: Text(
                            localizedRelationStatic(context, contact.relation),
                            style: const TextStyle(fontSize: 12),
                          ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                    Text(
                      contact.phone,
                              style: TextStyle(
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                        ],
                      ),
                    ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDeleteContact(contact);
                  } else if (value == 'edit') {
                    _openEditContact(contact);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(t.editContact),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(t.deleteContact),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _callContact(contact.phone),
              icon: const Icon(Icons.call),
              label: Text(t.call),
            ),
          ),
        ],
      ),
    );
  }

  String _sanitizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned.isEmpty ? phone : cleaned;
  }

  Future<void> _callContact(String phone) async {
    final t = AppLocalizations.of(context);
    final uri = Uri(scheme: 'tel', path: _sanitizePhone(phone));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showTopBanner(t.callUnavailable, background: Colors.red);
    }
  }

  Future<void> _confirmDeleteContact(EmergencyContact contact) async {
    final userId = _currentUserId;
    if (userId == null) return;
    final t = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.deleteContact),
        content: Text('${t.deleteContact}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(t.deleteContact),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _contactRepo.deleteContact(userId: userId, contactId: contact.id);
      _showTopBanner(t.contactDeleted, background: Colors.black87, icon: Icons.check_circle);
    } catch (e) {
      _showTopBanner('Error: $e', background: Colors.red);
    }
  }

  Widget _buildAvatar() {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId == null) {
      return const SizedBox.shrink();
    }
    
    return StreamBuilder<UserModel?>(
      stream: _userRepo.getUserStream(targetUserId),
      initialData: _currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? _currentUser;
    final gradients = [
      [const Color(0xFF7B61FF), const Color(0xFF36C2FF)],
      [const Color(0xFF00C853), const Color(0xFF1DE9B6)],
      [const Color(0xFFFF6D00), const Color(0xFFFFD180)],
      [const Color(0xFF2979FF), const Color(0xFF7C4DFF)],
          [const Color(0xFFFF4081), const Color(0xFFFFAB40)],
          [const Color(0xFF00BCD4), const Color(0xFF448AFF)],
          [const Color(0xFF26C6DA), const Color(0xFF00ACC1)],
          [const Color(0xFFFFA726), const Color(0xFFFF7043)],
          [const Color(0xFF7E57C2), const Color(0xFFAB47BC)],
          [const Color(0xFF66BB6A), const Color(0xFF43A047)],
          [const Color(0xFF42A5F5), const Color(0xFF1E88E5)],
          [const Color(0xFFEC407A), const Color(0xFFAB47BC)],
        ];
        final colors = gradients[(user?.gradientIndex ?? 0) % gradients.length];
        
        // Check if photoURL is a data URI (base64)
        final photoURL = user?.photoURL;
        ImageProvider? imageProvider;
        
        if (photoURL != null && photoURL.isNotEmpty) {
          if (photoURL.startsWith('data:image')) {
            // Base64 data URI
            try {
              final base64String = photoURL.split(',')[1];
              final imageBytes = base64Decode(base64String);
              imageProvider = MemoryImage(imageBytes);
            } catch (e) {
              debugPrint('Error decoding base64 image: $e');
            }
          } else {
            // Regular URL
            imageProvider = NetworkImage(photoURL);
          }
        }
        
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
            image: imageProvider != null
                ? DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: imageProvider == null ? LinearGradient(colors: colors) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
          alignment: imageProvider == null ? Alignment.center : null,
          child: imageProvider == null
              ? Text(
                  _initials(user?.displayName ?? 'Unknown'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
                )
              : null,
        );
      },
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    final first = p.isNotEmpty ? p.first[0] : '?';
    final second = p.length > 1 ? p[1][0] : '';
    return (first + second).toUpperCase();
  }

  static String localizedRelationStatic(BuildContext context, String relation) {
    final l = AppLocalizations.of(context);
    final r = relation.toLowerCase();
    if (r.contains('spouse') || r.contains('eş')) return l.spouse;
    if (r.contains('brother') || r.contains('erkek') || r.contains('kardeş')) return l.brother;
    if (r.contains('sister') || r.contains('kız')) return l.sister;
    if (r.contains('friend') || r.contains('arkadaş')) return l.friend;
    if (r.contains('family') || r.contains('aile')) return l.family;
    return relation;
  }

  String _disabilitiesLabel(BuildContext context, List<String> keys, String? otherText) {
    if (keys.isEmpty) return AppLocalizations.of(context).noneOption;
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final labels = {
      'physical': isTr ? 'Fiziksel' : 'Physical',
      'visual': isTr ? 'Görme' : 'Visual',
      'hearing': isTr ? 'İşitme' : 'Hearing',
      'speech': isTr ? 'Konuşma' : 'Speech',
      'mental': isTr ? 'Zihinsel' : 'Mental',
      'other': (otherText != null && otherText.trim().isNotEmpty)
          ? otherText.trim()
          : (isTr ? 'Diğer' : 'Other'),
    };
    return keys.map((k) => labels[k] ?? k).join(', ');
  }

  Color _accentFromBg(int bg) {
    final base = Color(bg);
    final hsl = HSLColor.fromColor(base);
    final sat = (hsl.saturation + 0.25).clamp(0.0, 1.0) as double;
    final light = (hsl.lightness - 0.15).clamp(0.0, 1.0) as double;
    return hsl.withSaturation(sat).withLightness(light).toColor();
  }

  Color _accentFromColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    final sat = (hsl.saturation + 0.25).clamp(0.0, 1.0) as double;
    final light = (hsl.lightness - 0.15).clamp(0.0, 1.0) as double;
    return hsl.withSaturation(sat).withLightness(light).toColor();
  }

  Widget _buildInfoTile(String title, String value, int bg, {VoidCallback? onTap}) {
    final base = Color(bg);
    final accent = _accentFromBg(bg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? base.withValues(alpha: 0.12) : base.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
              style: TextStyle(
                fontSize: 14,
                  fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: tile,
      );
    }
    return tile;
  }

  void _showDisabilitiesDialog(BuildContext context, List<String> disabilities, String? other) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).disabilityStatus),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: disabilities.map((key) {
                  String label = key;
                  if (key == 'physical') label = Localizations.localeOf(context).languageCode == 'tr' ? 'Fiziksel' : 'Physical';
                  else if (key == 'visual') label = Localizations.localeOf(context).languageCode == 'tr' ? 'Görme' : 'Visual';
                  else if (key == 'hearing') label = Localizations.localeOf(context).languageCode == 'tr' ? 'İşitme' : 'Hearing';
                  else if (key == 'speech') label = Localizations.localeOf(context).languageCode == 'tr' ? 'Konuşma' : 'Speech';
                  else if (key == 'mental') label = Localizations.localeOf(context).languageCode == 'tr' ? 'Zihinsel' : 'Mental';
                  else if (key == 'other') label = Localizations.localeOf(context).languageCode == 'tr' ? 'Diğer' : 'Other';
                  
                  return Chip(
                    label: Text(label),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  );
                }).toList(),
              ),
              if (other != null && other.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${AppLocalizations.of(context).otherSpecify}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(other),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).confirm), // Using confirm as 'Close' or 'OK'
          ),
        ],
      ),
    );
  }

  void _openEditProfile() async {
    if (_currentUser == null) return;
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EditProfileScreen(
          fullName: _currentUser!.displayName,
          username: _currentUser!.username,
          location: _currentUser!.location ?? '',
          age: _currentUser!.age ?? 0,
          heightCm: _currentUser!.heightCm ?? 0,
          weightKg: _currentUser!.weightKg ?? 0,
          disabilities: _currentUser!.disabilities,
          disabilityOther: _currentUser!.disabilityOther,
        ),
      ),
    ).then((value) async {
      if (value is Map<String, dynamic> && _currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          displayName: value['fullName'] as String?,
          username: value['username'] as String?,
          location: value['location'] as String?,
          age: value['age'] as int?,
          heightCm: value['heightCm'] as int?,
          weightKg: value['weightKg'] as int?,
          disabilities: value['disabilities'] as List<String>?,
          disabilityOther: value['disabilityOther'] as String?,
        );
        
        try {
          await _userRepo.updateUser(updatedUser);
        setState(() {
            _currentUser = updatedUser;
          });
          _showTopBanner(AppLocalizations.of(context).profileUpdated, background: const Color(0xFF2E7D32), icon: Icons.check_circle);
        } catch (e) {
          _showTopBanner('Error updating profile: $e', background: Colors.red);
        }
      }
    });
  }

  Widget _buildFollowButton() {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId == null || _currentUserId == null) {
      return const SizedBox.shrink();
    }
    
    return FutureBuilder<bool>(
      future: _userRepo.isFollowing(_currentUserId!, targetUserId),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleFollowToggle(targetUserId, isFollowing),
            icon: Icon(isFollowing ? Icons.person_remove_outlined : Icons.person_add_outlined, size: 20),
            label: Text(
              isFollowing ? AppLocalizations.of(context).followingBtn : AppLocalizations.of(context).follow,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing 
                  ? Colors.grey.shade200 
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isFollowing 
                  ? Colors.black 
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: isFollowing ? 0 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadowColor: isFollowing 
                  ? Colors.transparent 
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFollowToggle(String targetUserId, bool currentlyFollowing) async {
    if (_currentUserId == null) return;
    
    try {
      // Fetch target user for the name
      final targetUser = await _userRepo.getUser(targetUserId);
      final targetName = targetUser?.displayName ?? 'User';

      if (currentlyFollowing) {
        await _userRepo.unfollowUser(_currentUserId!, targetUserId);
      } else {
        await _userRepo.followUser(_currentUserId!, targetUserId);
      }
      // Reload user to update follower/following counts
      await _loadCurrentUser();
      _showTopBanner(
        currentlyFollowing 
            ? AppLocalizations.of(context).unfollowedUser(targetName)
            : AppLocalizations.of(context).followedUser(targetName),
        background: currentlyFollowing ? Colors.grey.shade700 : const Color(0xFF2E7D32),
        icon: currentlyFollowing ? Icons.person_remove : Icons.person_add,
      );
    } catch (e) {
      _showTopBanner('Error: $e', background: Colors.red);
    }
  }

  void _openFollowList({required bool isFollowers}) {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FollowListScreen(
          userId: targetUserId,
          isFollowers: isFollowers,
        ),
      ),
    );
  }

  void _navigateToProfileFromFollowList(String userId) {
    // Don't pop, just push the new profile screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  void _openChangePicture() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        int tab = 0; // 0: Upload Image, 1: Choose Color
        File? pickedImageFile;
        int tempGradientIndex = _currentUser?.gradientIndex ?? 0;
        final int initialGradientIndex = _currentUser?.gradientIndex ?? 0;

        final gradients = [
          [const Color(0xFF7B61FF), const Color(0xFF36C2FF)],
          [const Color(0xFF00C853), const Color(0xFF1DE9B6)],
          [const Color(0xFFFF6D00), const Color(0xFFFFD180)],
          [const Color(0xFF2979FF), const Color(0xFF7C4DFF)],
          [const Color(0xFFFF4081), const Color(0xFFFFAB40)],
          [const Color(0xFF00BCD4), const Color(0xFF448AFF)],
          [const Color(0xFF26C6DA), const Color(0xFF00ACC1)],
          [const Color(0xFFFFA726), const Color(0xFFFF7043)],
          [const Color(0xFF7E57C2), const Color(0xFFAB47BC)],
          [const Color(0xFF66BB6A), const Color(0xFF43A047)],
        ];

        Widget previewAvatar() {
          if (pickedImageFile != null) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(pickedImageFile!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            );
          }

          if (tab == 1) {
            final colors = gradients[tempGradientIndex % gradients.length];
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(_currentUser?.displayName ?? 'Unknown'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            );
          }

          ImageProvider? imageProvider;
          final photoURL = _currentUser?.photoURL;
          
          if (photoURL != null && photoURL.isNotEmpty) {
            if (photoURL.startsWith('data:image')) {
              try {
                final base64String = photoURL.split(',')[1];
                imageProvider = MemoryImage(base64Decode(base64String));
              } catch (e) {
                debugPrint('Error decoding base64 image: $e');
              }
            } else {
              imageProvider = NetworkImage(photoURL);
            }
          }

          if (imageProvider != null) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            );
          }

          final colors = gradients[(_currentUser?.gradientIndex ?? 0) % gradients.length];
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: colors),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(_currentUser?.displayName ?? 'Unknown'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          );
        }
        
        bool hasChanges() {
          if (tab == 0) {
            return pickedImageFile != null;
          } else {
            return tempGradientIndex != initialGradientIndex;
          }
        }

        return StatefulBuilder(builder: (context, setSheet) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera_outlined, color: isDark ? Colors.white : Colors.black87),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).changeProfilePicture,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            onPressed: () => Navigator.pop(context),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Center(child: previewAvatar()),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setSheet(() => tab = 0),
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: tab == 0 ? (isDark ? Colors.grey.shade700 : Colors.white) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: tab == 0
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.file_upload_outlined,
                                          size: 18,
                                          color: tab == 0 ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey.shade400 : Colors.black87)),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context).uploadImageTab,
                                          style: TextStyle(fontWeight: FontWeight.w600, color: tab == 0 ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey.shade400 : Colors.black87))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => setSheet(() => tab = 1),
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: tab == 1 ? (isDark ? Colors.grey.shade700 : Colors.white) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: tab == 1
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.color_lens_outlined,
                                          size: 18,
                                          color: tab == 1 ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey.shade400 : Colors.black87)),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context).chooseColor,
                                          style: TextStyle(fontWeight: FontWeight.w600, color: tab == 1 ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey.shade400 : Colors.black87))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: tab == 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context).uploadPhotoInstruction,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final ImagePicker picker = ImagePicker();
                                        try {
                                          final XFile? image = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1024,
                                            maxHeight: 1024,
                                            imageQuality: 85,
                                          );
                                          if (image != null) {
                                            final croppedFile = await ImageCropper().cropImage(
                                              sourcePath: image.path,
                                              uiSettings: [
                                                AndroidUiSettings(
                                                  toolbarTitle: 'Edit Photo',
                                                  toolbarColor: Colors.black,
                                                  toolbarWidgetColor: Colors.white,
                                                  initAspectRatio: CropAspectRatioPreset.original,
                                                  lockAspectRatio: false,
                                                ),
                                                IOSUiSettings(
                                                  title: 'Edit Photo',
                                                ),
                                              ],
                                            );
                                            if (croppedFile != null) {
                                              setSheet(() {
                                                pickedImageFile = File(croppedFile.path);
                                              });
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error picking image: $e')),
                                            );
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.file_upload_outlined, color: isDark ? Colors.white : Colors.black),
                                      label: Text(AppLocalizations.of(context).chooseImage, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        minimumSize: const Size.fromHeight(52),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                  if (pickedImageFile != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Image selected: ${pickedImageFile!.path.split('/').last}',
                                        style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context).maxFileSizeInfo,
                                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context).chooseGradientInstruction,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      for (int i = 0; i < gradients.length; i++)
                                        GestureDetector(
                                          onTap: () => setSheet(() => tempGradientIndex = i),
                                          child: Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(colors: gradients[i]),
                                              border: Border.all(
                                                color: i == tempGradientIndex ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
                                                width: 3,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4)),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                                foregroundColor: isDark ? Colors.white : Colors.black,
                              ),
                              child: Text(AppLocalizations.of(context).cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: hasChanges() ? () async {
                                if (tab == 0 && pickedImageFile != null) {
                                  // Save image as base64 in Firestore (since Storage requires billing)
                                  try {
                                    final userId = AuthService.instance.currentUserId;
                                    if (userId == null) {
                                      if (context.mounted) {
                                  Navigator.pop(context);
                                        _showTopBanner('User not logged in', background: Colors.red);
                                      }
                                      return;
                                    }
                                    
                                    // Read and compress image
                                    final imageBytes = await pickedImageFile!.readAsBytes();
                                    final originalImage = img.decodeImage(imageBytes);
                                    
                                    if (originalImage == null) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _showTopBanner('Error processing image', background: Colors.red);
                                      }
                                      return;
                                    }
                                    
                                    // Resize to max 400x400 to keep file size small
                                    final resizedImage = img.copyResize(
                                      originalImage,
                                      width: 400,
                                      height: 400,
                                      maintainAspect: true,
                                    );
                                    
                                    // Encode as JPEG with quality 85
                                    final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
                                    
                                    // Convert to base64
                                    final base64Image = base64Encode(compressedBytes);
                                    
                                    // Check size (Firestore document limit is 1MB, but we'll keep it smaller)
                                    if (base64Image.length > 500000) { // ~500KB base64 = ~375KB binary
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _showTopBanner('Image too large. Please choose a smaller image.', background: Colors.red);
                                      }
                                      return;
                                    }
                                    
                                    // Update user photoURL with data URI
                                    if (_currentUser != null) {
                                      final dataUri = 'data:image/jpeg;base64,$base64Image';
                                      final updatedUser = _currentUser!.copyWith(
                                        photoURL: dataUri,
                                      );
                                      await _userRepo.updateUser(updatedUser);
                                      setState(() {
                                        _currentUser = updatedUser;
                                      });
                                    }
                                    
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showTopBanner(
                                        AppLocalizations.of(context).profilePhotoUpdated,
                                        background: Colors.black87,
                                        icon: Icons.photo_camera_outlined,
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showTopBanner('Error processing image: $e', background: Colors.red);
                                    }
                                  }
                                } else if (tab == 1) {
                                  if (_currentUser != null) {
                                    final updatedUser = _currentUser!.copyWith(
                                      gradientIndex: tempGradientIndex,
                                    );
                                    try {
                                      await _userRepo.updateUser(updatedUser);
                                      setState(() {
                                        _currentUser = updatedUser;
                                      });
                                      Navigator.pop(context);
                                      _showTopBanner(AppLocalizations.of(context).avatarColorUpdated, background: Colors.black87, icon: Icons.brush);
                                    } catch (e) {
                                      Navigator.pop(context);
                                      _showTopBanner('Error updating avatar: $e', background: Colors.red);
                                    }
                                } else {
                                  Navigator.pop(context);
                                }
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasChanges() ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                                foregroundColor: hasChanges() ? (isDark ? Colors.black : Colors.white) : Colors.white70,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(AppLocalizations.of(context).saveChangesBtn),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _openAddContactForm() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const _AddEmergencyContactScreen()))
        .then((value) {
      final userId = _currentUserId;
      if (value is _EmergencyContactDraft && userId != null) {
        _contactRepo
            .addContact(
              userId: userId,
              name: value.name,
              phone: value.phone,
              relation: value.relation,
            )
            .then((_) {
          _showTopBanner(AppLocalizations.of(context).contactAdded, background: const Color(0xFF1E88E5), icon: Icons.person_add_alt);
        }).catchError((e) {
          _showTopBanner('Error: $e', background: Colors.red);
        });
      }
    });
  }

  void _openEditContact(EmergencyContact contact) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => _AddEmergencyContactScreen(initialContact: contact)))
        .then((value) {
      final userId = _currentUserId;
      if (value is _EmergencyContactDraft && userId != null) {
        _contactRepo
            .updateContact(
              userId: userId,
              contactId: contact.id,
              name: value.name,
              phone: value.phone,
              relation: value.relation,
            )
            .then((_) {
          _showTopBanner(AppLocalizations.of(context).editContact,
              background: const Color(0xFF1E88E5), icon: Icons.edit);
        }).catchError((e) {
          _showTopBanner('Error: $e', background: Colors.red);
        });
      }
    });
  }
}

class _CountTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int value;
  final VoidCallback onTap;
  const _CountTile(
      {required this.color,
      required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Derive a stronger border color similar to info tiles
    Color accentFrom(Color base) {
      final hsl = HSLColor.fromColor(base);
      final sat = (hsl.saturation + 0.25).clamp(0.0, 1.0) as double;
      final light = (hsl.lightness - 0.15).clamp(0.0, 1.0) as double;
      return hsl.withSaturation(sat).withLightness(light).toColor();
    }
    final accent = accentFrom(color);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accent,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                      style: TextStyle(
                        fontSize: 16,
                          fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowListScreen extends StatefulWidget {
  final String userId;
  final bool isFollowers;
  const _FollowListScreen({
    required this.userId,
    required this.isFollowers,
  });

  @override
  State<_FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<_FollowListScreen> {
  final UserRepository _userRepo = UserRepository.instance;
  String? _currentUserId;
  OverlayEntry? _bannerEntry;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.instance.currentUserId;
  }

  @override
  void dispose() {
    _removeBanner();
    super.dispose();
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      if (mounted) _removeBanner();
    });
  }

  Future<void> _handleFollowToggle(String targetUserId, bool currentlyFollowing) async {
    if (_currentUserId == null) return;
    
    try {
      // Get user details for the snackbar message
      final userDoc = await _userRepo.getUser(targetUserId);
      final displayName = userDoc?.displayName ?? 'User';

      if (currentlyFollowing) {
        await _userRepo.unfollowUser(_currentUserId!, targetUserId);
        if (mounted) {
          _showTopBanner(
            AppLocalizations.of(context).unfollowedUser(displayName),
            background: Colors.grey.shade700,
            icon: Icons.person_remove,
          );
        }
      } else {
        await _userRepo.followUser(_currentUserId!, targetUserId);
        if (mounted) {
          _showTopBanner(
            AppLocalizations.of(context).followedUser(displayName),
            background: const Color(0xFF2E7D32),
            icon: Icons.person_add,
          );
        }
      }
      setState(() {}); // Refresh to update follow status
    } catch (e) {
      if (mounted) {
        _showTopBanner('Error: $e', background: Colors.red, icon: Icons.error);
      }
    }
  }

  void _navigateToProfile(String userId) {
    // Simply push the profile screen without custom navigation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFollowers
              ? AppLocalizations.of(context).followers
              : AppLocalizations.of(context).following,
        ),
        elevation: 0.5,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: widget.isFollowers
            ? _userRepo.getFollowers(widget.userId)
            : _userRepo.getFollowing(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          
          final users = snapshot.data ?? [];
          
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    widget.isFollowers
                        ? 'No followers yet'
                        : 'Not following anyone yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          
          return ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
              final user = users[index];
              final isFollowing = _currentUserId != null
                  ? _userRepo.isFollowing(_currentUserId!, user.id).then((value) => value)
                  : Future.value(false);
              
              return FutureBuilder<bool>(
                future: isFollowing,
                builder: (context, followSnapshot) {
                  final following = followSnapshot.data ?? false;
                  
          return ListTile(
            onTap: () => _navigateToProfile(user.id),
            leading: StreamBuilder<UserModel?>(
              stream: _userRepo.getUserStream(user.id),
              initialData: user,
              builder: (context, userSnapshot) {
                final updatedUser = userSnapshot.data ?? user;
                
                // Check if photoURL is a data URI (base64) or regular URL
                final photoURL = updatedUser.photoURL;
                ImageProvider? imageProvider;
                
                if (photoURL != null && photoURL.isNotEmpty) {
                  if (photoURL.startsWith('data:image')) {
                    // Base64 data URI
                    try {
                      final base64String = photoURL.split(',')[1];
                      final imageBytes = base64Decode(base64String);
                      imageProvider = MemoryImage(imageBytes);
                    } catch (e) {
                      debugPrint('Error decoding base64 image: $e');
                    }
                  } else {
                    // Regular URL
                    imageProvider = NetworkImage(photoURL);
                  }
                }
                
                final gradients = [
                  [const Color(0xFF7B61FF), const Color(0xFF36C2FF)],
                  [const Color(0xFF00C853), const Color(0xFF1DE9B6)],
                  [const Color(0xFFFF6D00), const Color(0xFFFFD180)],
                  [const Color(0xFF2979FF), const Color(0xFF7C4DFF)],
                  [const Color(0xFFFF4081), const Color(0xFFFFAB40)],
                  [const Color(0xFF00BCD4), const Color(0xFF448AFF)],
                  [const Color(0xFF26C6DA), const Color(0xFF00ACC1)],
                  [const Color(0xFFFFA726), const Color(0xFFFF7043)],
                  [const Color(0xFF7E57C2), const Color(0xFFAB47BC)],
                  [const Color(0xFF66BB6A), const Color(0xFF43A047)],
                  [const Color(0xFF42A5F5), const Color(0xFF1E88E5)],
                  [const Color(0xFFEC407A), const Color(0xFFAB47BC)],
                ];
                final colors = gradients[updatedUser.gradientIndex % gradients.length];
                
                return CircleAvatar(
                  radius: 24,
                  backgroundImage: imageProvider,
                  backgroundColor: imageProvider == null ? Colors.transparent : null,
                  child: imageProvider == null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: colors),
                          ),
                          child: Center(
                            child: Text(
                              _initials(updatedUser.displayName),
                  style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
                    title: Text(user.displayName),
                    subtitle: Text(user.username),
                    trailing: _currentUserId != null && _currentUserId != user.id
                        ? OutlinedButton(
                            onPressed: () => _handleFollowToggle(user.id, following),
              style: OutlinedButton.styleFrom(
                              backgroundColor: following ? Colors.black : Colors.white,
                              foregroundColor: following ? Colors.white : Colors.black,
                              side: BorderSide(
                                color: following ? Colors.black : Colors.grey.shade300,
                              ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
                            child: Text(
                              following
                                  ? AppLocalizations.of(context).followingBtn
                                  : AppLocalizations.of(context).follow,
            ),
                          )
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _EditProfileScreen extends StatefulWidget {
  final String fullName;
  final String username;
  final String location;
  final int age;
  final int heightCm;
  final int weightKg;
  final List<String> disabilities;
  final String? disabilityOther;
  const _EditProfileScreen({
    required this.fullName,
    required this.username,
    required this.location,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.disabilities,
    required this.disabilityOther,
  });

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  late final TextEditingController fullNameCtrl;
  late final TextEditingController usernameCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController ageCtrl;
  late final TextEditingController heightCtrl;
  late final TextEditingController weightCtrl;
  bool hasDisability = false;
  bool _isLocationFromList = true;
  Set<String> selectedDisabilityKeys = <String>{};
  final TextEditingController otherCtrl = TextEditingController();
  TextEditingController? _typeAheadController; // Store TypeAheadField's controller
  final _formKey = GlobalKey<FormState>();
  OverlayEntry? _bannerEntry;

  @override
  void initState() {
    super.initState();
    fullNameCtrl = TextEditingController(text: widget.fullName);
    usernameCtrl = TextEditingController(text: widget.username.replaceAll('@', ''));
    locationCtrl = TextEditingController(text: widget.location);
    ageCtrl = TextEditingController(text: widget.age.toString());
    heightCtrl = TextEditingController(text: widget.heightCm.toString());
    weightCtrl = TextEditingController(text: widget.weightKg.toString());
    hasDisability = widget.disabilities.isNotEmpty;
    selectedDisabilityKeys = widget.disabilities.toSet();
    otherCtrl.text = widget.disabilityOther ?? '';
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    usernameCtrl.dispose();
    locationCtrl.dispose();
    ageCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    otherCtrl.dispose();
    _removeBanner();
    super.dispose();
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      if (mounted) _removeBanner();
    });
  }

  bool get _hasChanges {
    if (fullNameCtrl.text.trim() != widget.fullName) return true;
    if (('@' + usernameCtrl.text.trim()) != widget.username) return true;
    if (locationCtrl.text.trim() != widget.location) return true;
    if ((int.tryParse(ageCtrl.text.trim()) ?? widget.age) != widget.age) return true;
    if ((int.tryParse(heightCtrl.text.trim()) ?? widget.heightCm) != widget.heightCm) return true;
    if ((int.tryParse(weightCtrl.text.trim()) ?? widget.weightKg) != widget.weightKg) return true;
    final currentDis = hasDisability ? selectedDisabilityKeys : <String>{};
    if (currentDis.length != widget.disabilities.length || !currentDis.containsAll(widget.disabilities)) return true;
    final other = hasDisability && selectedDisabilityKeys.contains('other') ? otherCtrl.text.trim() : null;
    if ((other ?? '') != (widget.disabilityOther ?? '')) return true;
    return false;
  }

  Future<void> _confirmAndSave() async {
    if (!_isLocationFromList && locationCtrl.text.trim().isNotEmpty) {
      _showTopBanner(
        Localizations.localeOf(context).languageCode == 'tr' 
            ? 'Lütfen listeden bir konum seçin' 
            : 'Please select a location from the list',
        background: Colors.red,
        icon: Icons.error_outline,
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).saveChangesTitle),
        content: Text(AppLocalizations.of(context).saveChangesPrompt),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context).cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context).confirm)),
        ],
      ),
    );
    if (ok == true) {
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).editProfile),
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _hasChanges ? _confirmAndSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.9)
                        : Theme.of(context).colorScheme.primary)
                    : null,
                foregroundColor: _hasChanges ? Colors.white : null,
                elevation: _hasChanges ? (Theme.of(context).brightness == Brightness.dark ? 4 : 2) : 0,
                shadowColor: _hasChanges && Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: _hasChanges && Theme.of(context).brightness == Brightness.dark
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : BorderSide.none,
                ),
              ),
              child: Text(
                AppLocalizations.of(context).save,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _section(
            '${AppLocalizations.of(context).nameLabel} *',
            TextField(
              controller: fullNameCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),
          _section(
            '${AppLocalizations.of(context).usernameLabel} *',
            Row(children: [
              const Text('@  ', style: TextStyle(color: Colors.grey)),
              Expanded(
                child: TextField(
                  controller: usernameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
            ]),
          ),
          _section(
            AppLocalizations.of(context).locationLabel,
            TypeAheadField<String>(
              suggestionsCallback: (pattern) async {
                if (pattern.length < 2) return [];
                return await _searchTurkishLocations(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on, size: 20),
                  title: Text(suggestion),
                  dense: true,
                );
              },
              onSelected: (suggestion) {
                // Update both controllers when a suggestion is selected
                locationCtrl.text = suggestion;
                if (_typeAheadController != null) {
                  _typeAheadController!.text = suggestion;
                  _typeAheadController!.selection = TextSelection.fromPosition(
                    TextPosition(offset: suggestion.length),
                  );
                }
                _isLocationFromList = true;
                setState(() {});
              },
              builder: (context, controller, focusNode) {
                // Store the controller reference
                _typeAheadController = controller;
                
                // Initialize controller with location value if empty
                if (controller.text.isEmpty && locationCtrl.text.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && controller.text != locationCtrl.text) {
                      controller.text = locationCtrl.text;
                    }
                  });
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) {
                    locationCtrl.text = value;
                    _isLocationFromList = false;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                );
              },
              emptyBuilder: (context) => const SizedBox.shrink(),
              loadingBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              errorBuilder: (context, error) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $error', style: TextStyle(color: Colors.red.shade700)),
              ),
            ),
          ),
          _section(
            AppLocalizations.of(context).personalInfo,
            Form(
              key: _formKey,
              child: Column(
              children: [
                const SizedBox(height: 8),
                  TextFormField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).ageYears + ' ' + (Localizations.localeOf(context).languageCode == 'tr' ? 'gerekli' : 'required');
                      }
                      final age = int.tryParse(value.trim());
                      if (age == null) {
                        return Localizations.localeOf(context).languageCode == 'tr' ? 'Geçerli bir yaş girin' : 'Enter a valid age';
                      }
                      if (age < 1 || age > 150) {
                        return Localizations.localeOf(context).languageCode == 'tr' ? 'Yaş 1-150 arasında olmalı' : 'Age must be between 1-150';
                      }
                      return null;
                    },
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context).ageYears} *',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 1.2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                  TextFormField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).heightCm + ' ' + (Localizations.localeOf(context).languageCode == 'tr' ? 'gerekli' : 'required');
                      }
                      final height = int.tryParse(value.trim());
                      if (height == null) {
                        return Localizations.localeOf(context).languageCode == 'tr' ? 'Geçerli bir boy girin' : 'Enter a valid height';
                      }
                      if (height < 50 || height > 300) {
                        return Localizations.localeOf(context).languageCode == 'tr' ? 'Boy 50-300 cm arasında olmalı' : 'Height must be between 50-300 cm';
                      }
                      return null;
                    },
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context).heightCm} *',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 1.2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                  TextFormField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).weightKg + ' ' + (Localizations.localeOf(context).languageCode == 'tr' ? 'gerekli' : 'required');
                      }
                      final weight = int.tryParse(value.trim());
                      if (weight == null) {
                        return Localizations.localeOf(context).languageCode == 'tr' ? 'Geçerli bir kilo girin' : 'Enter a valid weight';
                      }
                      if (weight < 10 || weight > 500) {
                        return Localizations.localeOf(context).languageCode == 'tr' ? 'Kilo 10-500 kg arasında olmalı' : 'Weight must be between 10-500 kg';
                      }
                      return null;
                    },
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context).weightKg} *',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 1.2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _disabilitySelector(),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _disabilitySelector() {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final chips = <Map<String, String>>[
      {'key': 'physical', 'label': isTr ? 'Fiziksel' : 'Physical'},
      {'key': 'visual', 'label': isTr ? 'Görme' : 'Visual'},
      {'key': 'hearing', 'label': isTr ? 'İşitme' : 'Hearing'},
      {'key': 'speech', 'label': isTr ? 'Konuşma' : 'Speech'},
      {'key': 'mental', 'label': isTr ? 'Zihinsel' : 'Mental'},
      {'key': 'other', 'label': isTr ? 'Diğer' : 'Other'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).disabilityStatus,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              selected: !hasDisability,
              label: Text(AppLocalizations.of(context).noneOption),
              onSelected: (_) => setState(() {
                hasDisability = false;
                selectedDisabilityKeys.clear();
              }),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              selected: hasDisability,
              label: Text(AppLocalizations.of(context).presentOption),
              onSelected: (_) => setState(() {
                hasDisability = true;
              }),
            ),
          ],
        ),
        if (hasDisability) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in chips)
                FilterChip(
                  label: Text(m['label']!),
                  selected: selectedDisabilityKeys.contains(m['key']!),
                  onSelected: (sel) => setState(() {
                    if (sel) {
                      selectedDisabilityKeys.add(m['key']!);
                    } else {
                      selectedDisabilityKeys.remove(m['key']!);
                    }
                  }),
                ),
            ],
          ),
          if (selectedDisabilityKeys.contains('other')) ...[
            const SizedBox(height: 10),
            TextField(
              controller: otherCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).otherSpecify,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ]
      ],
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade400,
            width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Future<List<String>> _searchTurkishLocations(String query) async {
    try {
      // Google Places API Autocomplete - Türkiye için şehir ve ilçe araması
      // Using the same API key from AndroidManifest (Google Maps API key)
      // Make sure Places API is enabled in Google Cloud Console
      const apiKey = 'AIzaSyClgydmQ7UOYcLEHdvSBkMJM2kwJvTapGo';

      final encodedQuery = Uri.encodeComponent('$query, Turkey');
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$encodedQuery&'
        'components=country:tr&'
        'types=geocode&'
        'language=tr&'
        'key=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          debugPrint('Google Places API error: ${data['status']}');
          return [];
        }

        final List<dynamic> predictions = data['predictions'] ?? [];
        final List<String> locations = [];

        for (var prediction in predictions) {
          final description = prediction['description'] as String?;
          final structuredFormatting = prediction['structured_formatting'] as Map<String, dynamic>?;
          
          if (description == null) continue;

          String locationName = '';
          
          // Use structured_formatting if available (usually cleaner and more accurate)
          if (structuredFormatting != null) {
            final mainText = structuredFormatting['main_text'] as String?;
            final secondaryText = structuredFormatting['secondary_text'] as String?;
            
            if (mainText != null) {
              // Remove country from secondary text
              String secondary = '';
              if (secondaryText != null) {
                secondary = secondaryText
                    .replaceAll(RegExp(r',\s*Türkiye$', caseSensitive: false), '')
                    .replaceAll(RegExp(r',\s*Turkey$', caseSensitive: false), '')
                    .trim();
              }
              
              // Format: "İlçe, Şehir" or just "Şehir"
              if (secondary.isNotEmpty && secondary != mainText && !secondary.contains('Türkiye') && !secondary.contains('Turkey')) {
                locationName = '$mainText, $secondary';
              } else {
                locationName = mainText;
              }
            }
          }
          
          // Fallback to description if structured_formatting didn't work
          if (locationName.isEmpty) {
            locationName = description
                .replaceAll(RegExp(r',\s*Türkiye$', caseSensitive: false), '')
                .replaceAll(RegExp(r',\s*Turkey$', caseSensitive: false), '')
                .trim();
          }

          // Filter out results that are too generic or not relevant
          if (locationName.isNotEmpty && 
              !locationName.toLowerCase().contains('türkiye') &&
              !locationName.toLowerCase().contains('turkey') &&
              !locations.contains(locationName)) {
            locations.add(locationName);
          }
        }

        return locations;
      }
    } catch (e) {
      // Hata durumunda boş liste döndür
      debugPrint('Location search error: $e');
    }
    return [];
  }

  void _save() {
    // Validate form before saving
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    Navigator.pop(context, {
      'fullName': fullNameCtrl.text.trim(),
      'username': '@' + usernameCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'age': int.tryParse(ageCtrl.text.trim()) ?? widget.age,
      'heightCm': int.tryParse(heightCtrl.text.trim()) ?? widget.heightCm,
      'weightKg': int.tryParse(weightCtrl.text.trim()) ?? widget.weightKg,
      'disabilities': hasDisability ? selectedDisabilityKeys.toList() : <String>[],
      'disabilityOther': hasDisability && selectedDisabilityKeys.contains('other')
          ? otherCtrl.text.trim()
          : null,
    });
  }
}

class _AddEmergencyContactScreen extends StatefulWidget {
  final EmergencyContact? initialContact;
  const _AddEmergencyContactScreen({this.initialContact});

  @override
  State<_AddEmergencyContactScreen> createState() => _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<_AddEmergencyContactScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final relationCtrl = TextEditingController();
  bool _isCustomRelation = false;
  static const _presetRelations = [
    'Spouse',
    'Parent',
    'Sibling',
    'Child',
    'Relative',
    'Friend',
    'Neighbor',
    'Coworker',
    'Doctor',
  ];
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.initialContact != null;
  String? get _dropdownRelationValue {
    final value = relationCtrl.text.trim();
    if (value.isEmpty) return null;
    if (!_presetRelations.contains(value)) return null;
    return value;
  }

  void _setRelation(String value) {
    _isCustomRelation = !_presetRelations.contains(value);
    relationCtrl.text = value;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    relationCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialContact;
    if (initial != null) {
      nameCtrl.text = initial.name;
      phoneCtrl.text = initial.phone;
      _setRelation(initial.relation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? t.editContact : t.emergencyContacts,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _isValid ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isValid ? const Color(0xFF2E7D32) : null,
                foregroundColor: Colors.white,
                elevation: _isValid ? 2 : 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_isEditing ? t.save : t.add),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    width: 1.4),
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
                    Container(
                    padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2B1313)
                          : const Color(0xFFFDECEA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD32F2F), width: 1.4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFCDD2),
                        shape: BoxShape.circle,
                      ),
                          child: const Icon(Icons.phone_in_talk, color: Color(0xFFD32F2F)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                t.addEmergencyContact,
                            style: TextStyle(
                                    fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                                t.emergencyTip,
                            style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade300
                                        : Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                    ),
                ),
                const SizedBox(height: 12),
                  TextFormField(
                  controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      labelText: '${t.fullName} *',
                    hintText: 'e.g., Elif Yılmaz',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.nameRequired;
                      }
                      return null;
                    },
                ),
                const SizedBox(height: 12),
                  TextFormField(
                  controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    ],
                  decoration: InputDecoration(
                      labelText: '${t.phoneNumber} *',
                    hintText: 'e.g., +90 532 123 4567',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: 1.2,
                  ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        tooltip: t.importContacts,
                        icon: const Icon(Icons.contact_phone_outlined),
                        onPressed: _pickFromContacts,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: _validatePhoneField,
                ),
                const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _isCustomRelation ? null : _dropdownRelationValue,
                    decoration: InputDecoration(
                      labelText: '${t.relation} *',
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    hint: Text(t.relationHint),
                    items: [
                      ..._presetRelations.map(
                        (relation) => DropdownMenuItem(
                          value: relation,
                          child: Text(
                            _ProfileScreenState.localizedRelationStatic(context, relation),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(t.otherSpecify),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        if (value == 'other') {
                          _isCustomRelation = true;
                          relationCtrl.clear();
                        } else {
                          _setRelation(value);
                        }
                      });
                    },
                    validator: (_) {
                      if (relationCtrl.text.trim().isEmpty) {
                        return t.relationRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_isCustomRelation)
                    TextFormField(
                  controller: relationCtrl,
                  decoration: InputDecoration(
                        labelText: t.otherSpecify,
                        hintText: t.relationHint,
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (_isCustomRelation && (value == null || value.trim().isEmpty)) {
                          return t.relationRequired;
                        }
                        return null;
                      },
                    )
                  else if (relationCtrl.text.isNotEmpty)
                    Text(
                      _ProfileScreenState.localizedRelationStatic(context, relationCtrl.text),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF14253B)
                        : const Color(0xFFE8F2FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF8AB4F8)
                              : const Color(0xFF1E88E5),
                          width: 1.4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF8AB4F8)
                              : const Color(0xFF1E88E5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            t.emergencyTip,
                          style: TextStyle(
                              height: 1.3,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  bool get _isValid =>
      nameCtrl.text.trim().isNotEmpty &&
      relationCtrl.text.trim().isNotEmpty &&
      _isPhoneValid(phoneCtrl.text.trim());

  void _save() {
    if (!_isValid || !(_formKey.currentState?.validate() ?? false)) {
      setState(() {});
      return;
    }
    Navigator.pop(
      context,
      _EmergencyContactDraft(nameCtrl.text.trim(), phoneCtrl.text.trim(), relationCtrl.text.trim()),
    );
  }

  Future<void> _pickFromContacts() async {
    final t = AppLocalizations.of(context);
    try {
      // Try to open the contact picker directly
      // The native picker will handle permission requests if needed
      final picked = await FlutterContacts.openExternalPick();
      if (picked == null) return; // User cancelled

      // If we got here, we have a contact, but we need permission to read its details
      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        _showSnack(t.contactsPermissionDenied);
        return;
      }

      final fullContact = await FlutterContacts.getContact(picked.id, withProperties: true);
      final contact = fullContact ?? picked;
      if (contact.phones.isEmpty) {
        _showSnack(t.contactMissingPhone);
        return;
      }

      setState(() {
        if (contact.displayName.isNotEmpty) {
          nameCtrl.text = contact.displayName;
        }
        phoneCtrl.text = contact.phones.first.number;
        if (relationCtrl.text.trim().isEmpty) {
          _setRelation('Friend');
        }
      });
      _formKey.currentState?.validate();
    } catch (e) {
      // If openExternalPick fails, it might be a permission issue
      // Try requesting permission and show appropriate message
      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        _showSnack(t.contactsPermissionDenied);
      } else {
        _showSnack('Error: $e');
      }
    }
  }

  String? _validatePhoneField(String? value) {
    final t = AppLocalizations.of(context);
    final trimmed = value?.trim() ?? '';
    if (!_isPhoneValid(trimmed)) {
      return t.invalidPhoneNumber;
    }
    return null;
  }

  bool _isPhoneValid(String value) {
    if (value.trim().isEmpty) return false;
    
    // Remove all non-digit characters except +
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Turkish phone number formats:
    // +90 5XX XXX XX XX (mobile with country code)
    // +90 XXX XXX XX XX (landline with country code)
    // 0 5XX XXX XX XX (mobile with leading 0)
    // 0 XXX XXX XX XX (landline with leading 0)
    // 5XX XXX XX XX (mobile without leading 0 or country code)
    // XXX XXX XX XX (landline without leading 0 or country code)
    
    // Check if it starts with +90
    if (digits.startsWith('+90')) {
      final withoutCountry = digits.substring(3); // Remove +90
      // Mobile: 5XX XXX XX XX (10 digits starting with 5)
      // Landline: XXX XXX XX XX (10 digits, area code 2-3 digits)
      if (withoutCountry.length == 10) {
        // Mobile numbers start with 5
        if (withoutCountry.startsWith('5')) {
          return true;
        }
        // Landline numbers (area codes: 212, 216, 232, etc.)
        return true;
      }
      return false;
    }
    
    // Check if it starts with 0
    if (digits.startsWith('0')) {
      final withoutLeadingZero = digits.substring(1); // Remove leading 0
      // Mobile: 5XX XXX XX XX (10 digits starting with 5)
      // Landline: XXX XXX XX XX (10 digits)
      if (withoutLeadingZero.length == 10) {
        if (withoutLeadingZero.startsWith('5')) {
          return true; // Mobile
        }
        return true; // Landline
      }
      return false;
    }
    
    // Check if it's just digits (no +90 or leading 0)
    if (RegExp(r'^[0-9]+$').hasMatch(digits)) {
      // Mobile: 5XX XXX XX XX (10 digits starting with 5)
      // Landline: XXX XXX XX XX (10 digits)
      if (digits.length == 10) {
        if (digits.startsWith('5')) {
          return true; // Mobile
        }
        return true; // Landline
      }
      // Also accept 11 digits (with leading 0 but user didn't type +90)
      if (digits.length == 11 && digits.startsWith('0')) {
        final withoutLeadingZero = digits.substring(1);
        if (withoutLeadingZero.length == 10) {
          return true;
        }
      }
    }
    
    // Minimum 7 digits for international numbers or other formats
    return digits.length >= 7;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmergencyContactDraft {
  final String name;
  final String phone;
  final String relation;
  _EmergencyContactDraft(this.name, this.phone, this.relation);
}

class _FollowUser {
  final String name;
  final String handle;
  bool following;
  _FollowUser(this.name, this.handle, this.following);
  String initials() {
    final p = name.split(' ');
    return (p.first[0] + (p.length > 1 ? p[1][0] : '')).toUpperCase();
  }

  static _FollowUser sample(int i) => _FollowUser(
      'User $i', '@user$i', i % 2 == 0);
}

class _UploadPanel extends StatelessWidget {
  final void Function(String path) onPicked;
  const _UploadPanel({required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => onPicked('local'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Choose Image'),
          ),
          const SizedBox(height: 8),
          Text('Max file size: 5MB. Supported: JPG, PNG, GIF',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ColorPanel extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onSelect;
  const _ColorPanel({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xFF7B61FF), const Color(0xFF36C2FF)],
      [const Color(0xFF00C853), const Color(0xFF1DE9B6)],
      [const Color(0xFFFF6D00), const Color(0xFFFFD180)],
      [const Color(0xFF2979FF), const Color(0xFF7C4DFF)],
      [const Color(0xFFFF4081), const Color(0xFFFFAB40)],
      [const Color(0xFF00BCD4), const Color(0xFF448AFF)],
      [const Color(0xFF26C6DA), const Color(0xFF00ACC1)],
      [const Color(0xFFFFA726), const Color(0xFFFF7043)],
      [const Color(0xFF7E57C2), const Color(0xFFAB47BC)],
      [const Color(0xFF66BB6A), const Color(0xFF43A047)],
      [const Color(0xFF42A5F5), const Color(0xFF1E88E5)],
      [const Color(0xFFEC407A), const Color(0xFFAB47BC)],
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (int i = 0; i < gradients.length; i++)
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradients[i]),
                  border: Border.all(
                      color: i == currentIndex ? Colors.black : Colors.white,
                      width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _seg(bool active, String text, VoidCallback onTap) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600)),
      ),
    ),
  );
}



class _UserPostsScreen extends StatefulWidget {
  final String userId;
  const _UserPostsScreen({required this.userId});

  @override
  State<_UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<_UserPostsScreen> {
  final PostRepository _postRepo = PostRepository.instance;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.instance.currentUserId;
  }

  void _showTopBanner(String message, {Color background = Colors.black87, IconData icon = Icons.check_circle}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8), Expanded(child: Text(message))]), 
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 16, right: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).posts),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StreamBuilder<List<CommunityPost>>(
        stream: _postRepo.getPostsByUserId(widget.userId, _currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).noUpdatesYet));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return CommunityPostCard(
                post: posts[index],
                onUpdated: () => setState(() {}),
                showBanner: _showTopBanner,
              );
            },
          );
        },
      ),
    );
  }
}
