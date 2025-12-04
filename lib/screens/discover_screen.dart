import 'package:flutter/material.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../data/user_repository.dart';
import '../data/post_repository.dart';
import '../models/user_model.dart';
import '../models/community_post.dart';
import '../services/auth_service.dart';
import '../widgets/community_post_card.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'safety_screen.dart';
import 'settings_screen.dart';
import '../data/settings_repository.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final UserRepository _userRepo = UserRepository.instance;
  final PostRepository _postRepo = PostRepository.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String? _currentUserId;
  List<UserModel> _searchResults = [];
  List<UserModel> _suggestedUsers = [];
  bool _isSearching = false;
  bool _isLoadingSuggestions = true;
  OverlayEntry? _bannerEntry;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.instance.currentUserId;
    _loadSuggestedUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  Future<void> _loadSuggestedUsers() async {
    if (_currentUserId == null) return;
    
    setState(() {
      _isLoadingSuggestions = true;
    });
    
    try {
      final users = await _userRepo.getSuggestedUsers(_currentUserId!, limit: 10);
      setState(() {
        _suggestedUsers = users;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final results = await _userRepo.searchUsers(query, limit: 20);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Widget _getScreenForIndex(int index, AppLocalizations t) {
    switch (index) {
      case 0: // Home
        return HomeScreen(
          onOpenOnMap: (eq) {},
          onOpenMapTab: () {},
          onOpenSafetyTab: () {},
        );
      case 1: // Map
        return const MapScreen();
      case 2: // Safety
        return const SafetyScreen();
      case 3: // Discover
        return const DiscoverScreen();
      case 4: // Profile
        return const ProfileScreen();
      case 5: // Settings
        return SettingsScreen(
          darkMode: false,
          onDarkModeChanged: (_) {},
          languageCode: 'en',
          onLanguageChanged: (_) {},
        );
      default:
        return const ProfileScreen();
    }
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex, AppLocalizations t) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      onTap: (index) {
        final targetScreen = _getScreenForIndex(index, t);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => Scaffold(
              body: targetScreen,
              bottomNavigationBar: _buildBottomNavBar(ctx, index, t),
            ),
          ),
        );
      },
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
    );
  }

  void _navigateToProfile(String userId) {
    final t = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: ProfileScreen(userId: userId),
          bottomNavigationBar: _buildBottomNavBar(context, 4, t),
        ),
      ),
    );
  }

  String _buildInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildUserTile(UserModel user, {bool isSuggested = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final colors = gradients[user.gradientIndex % gradients.length];

    return FutureBuilder<bool>(
      future: _currentUserId != null
          ? _userRepo.isFollowing(_currentUserId!, user.id)
          : Future.value(false),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToProfile(user.id),
                child: StreamBuilder<UserModel?>(
                  stream: _userRepo.getUserStream(user.id),
                  initialData: user,
                  builder: (context, snapshot) {
                    final updatedUser = snapshot.data ?? user;
                    
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
                    
                    return Container(
                      width: 56,
                      height: 56,
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: imageProvider == null ? Alignment.center : null,
                      child: imageProvider == null
                          ? Text(
                              _buildInitials(updatedUser.displayName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(user.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            user.username,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          if (user.location != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.location!,
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${user.followers} ${AppLocalizations.of(context).followers.toLowerCase()}',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${user.following} ${AppLocalizations.of(context).following.toLowerCase()}',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_currentUserId != null && user.id != _currentUserId)
                FutureBuilder<bool>(
                  future: _userRepo.isFollowing(_currentUserId!, user.id),
                  builder: (context, snapshot) {
                    final following = snapshot.data ?? false;
                    return ElevatedButton(
                      onPressed: () async {
                        try {
                          if (following) {
                            await _userRepo.unfollowUser(_currentUserId!, user.id);
                            _showTopBanner(
                              'Unfollowed ${user.displayName}',
                              background: Colors.grey.shade700,
                              icon: Icons.person_remove,
                            );
                          } else {
                            await _userRepo.followUser(_currentUserId!, user.id);
                            _showTopBanner(
                              'Following ${user.displayName}',
                              background: const Color(0xFF2E7D32),
                              icon: Icons.person_add,
                            );
                            // Remove user from both suggested users and search results when followed
                            setState(() {
                              _suggestedUsers.removeWhere((u) => u.id == user.id);
                              _searchResults.removeWhere((u) => u.id == user.id);
                            });
                          }
                          setState(() {}); // Refresh UI
                        } catch (e) {
                          _showTopBanner(
                            'Error: $e',
                            background: Colors.red,
                            icon: Icons.error,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: following
                            ? Colors.grey.shade200
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: following
                            ? Colors.grey.shade700
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        following
                            ? AppLocalizations.of(context).followingBtn
                            : AppLocalizations.of(context).follow,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            t.searchUsers,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: t.searchUsersHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isSearching)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_searchController.text.trim().isNotEmpty)
          _searchResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      t.noUsersFound,
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: _searchResults
                      .map((user) => _buildUserTile(user))
                      .toList(),
                ),
      ],
    );
  }

  Widget _buildSuggestedSection() {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_searchController.text.trim().isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            t.suggestedUsers,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (_isLoadingSuggestions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_suggestedUsers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.noSuggestions,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ..._suggestedUsers.map((user) => _buildUserTile(user, isSuggested: true)),
      ],
    );
  }

  Widget _buildTrendingSection() {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_searchController.text.trim().isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            t.popularPosts,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        StreamBuilder<List<CommunityPost>>(
          stream: _postRepo.getPopularPosts(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }

            final posts = snapshot.data ?? [];
            // Show top 5 posts by likes
            final trendingPosts = posts
              ..sort((a, b) => b.likes.compareTo(a.likes));
            final topPosts = trendingPosts.take(5).toList();

            if (topPosts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t.noUpdatesYet,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: topPosts
                  .map(
                    (post) => CommunityPostCard(
                      post: post,
                      onUpdated: null,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSearchSection()),
              SliverToBoxAdapter(child: _buildSuggestedSection()),
              SliverToBoxAdapter(child: _buildTrendingSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

