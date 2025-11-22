import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User basics
  String fullName = 'Ahmet Yılmaz';
  String username = '@ahmetyilmaz';
  String location = 'İstanbul, Turkey';
  String email = 'ahmet.yilmaz@example.com';
  int age = 32;
  int heightCm = 175;
  int weightKg = 75;
  String disability = 'None';

  // Avatar style
  int gradientIndex = 0; // pick from predefined gradients

  // Social counters
  int followers = 124;
  int following = 89;

  // Emergency contacts
  final List<_EmergencyContact> contacts = <_EmergencyContact>[
    _EmergencyContact('Elif Yılmaz', '+90 532 123 4567', 'Spouse'),
    _EmergencyContact('Ahmet Kaya', '+90 533 987 6543', 'Brother'),
    _EmergencyContact('Zeynep Demir', '+90 534 555 8888', 'Friend'),
  ];

  // Posts (use CommunityPost model for consistency)
  final List<CommunityPost> posts = <CommunityPost>[];
  final ScrollController _postScrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _seedInitialPosts();
    _postScrollController.addListener(_onPostScroll);
  }

  @override
  void dispose() {
    _postScrollController.dispose();
    super.dispose();
  }

  void _seedInitialPosts() {
    final samples = CommunityPost.sampleData()
        .map((e) => e.copyWith(authorName: fullName, handle: username))
        .take(2)
        .toList();
    posts.addAll(samples);
  }

  void _onPostScroll() {
    if (_isLoadingMore) return;
    if (_postScrollController.position.pixels >=
        _postScrollController.position.maxScrollExtent - 120) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final more = CommunityPost.sampleData()
        .map((e) => e.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              authorName: fullName,
              handle: username,
              timestamp: DateTime.now(),
            ))
        .take(3)
        .toList();
    setState(() {
      posts.addAll(more);
      _isLoadingMore = false;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopHeader()),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildHeaderCard()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildCountsRow()),
            SliverToBoxAdapter(child: const Divider(height: 32)),
            SliverToBoxAdapter(child: _buildEmergencyHeader()),
            SliverToBoxAdapter(child: _buildEmergencyList()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Posts',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == posts.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _isLoadingMore
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  final post = posts[index];
                  return CommunityPostCard(
                    post: post,
                    onUpdated: () => setState(() {}),
                  );
                },
                childCount: posts.length + 1,
              ),
            ),
          ],
          controller: _postScrollController,
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: const [
          Text(
            'Profile',
            style: TextStyle(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
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
                      Text(fullName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2)),
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
                          children: [
                            const Icon(Icons.alternate_email,
                                size: 14, color: Color(0xFF6246EA)),
                            const SizedBox(width: 6),
                            Text(
                              username.startsWith('@')
                                  ? username.substring(1)
                                  : username,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
                Expanded(child: _buildInfoTile('Age', '$age years', 0xFFE3F2FD)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoTile('Height', '$heightCm cm', 0xFFE8F5E9)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoTile('Weight', '$weightKg kg', 0xFFFFF3E0)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoTile('Disability', disability, 0xFFF3E5F5)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(location,
                        style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                            fontSize: 15))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.alternate_email,
                    size: 18, color: Color(0xFF6246EA)),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(email,
                        style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                            fontSize: 15))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openEditProfile,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _CountTile(
              color: const Color(0xFFF3E8FF),
              icon: Icons.groups,
              label: 'Followers',
              value: followers,
              onTap: () => _openFollowList(isFollowers: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _CountTile(
              color: const Color(0xFFE3F2FD),
              icon: Icons.person_add,
              label: 'Following',
              value: following,
              onTap: () => _openFollowList(isFollowers: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text('Emergency Contacts',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: _openAddContactMenu,
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: contacts
            .map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFF6B00),
                      child: Text(_initials(c.name),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(c.relation,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.phone,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Call'),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAvatar() {
    final gradients = [
      [const Color(0xFF7B61FF), const Color(0xFF36C2FF)],
      [const Color(0xFF00C853), const Color(0xFF1DE9B6)],
      [const Color(0xFFFF6D00), const Color(0xFFFFD180)],
      [const Color(0xFF2979FF), const Color(0xFF7C4DFF)],
    ];
    final colors = gradients[gradientIndex % gradients.length];
    return Container(
      width: 90,
      height: 90,
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
        _initials(fullName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    final first = p.isNotEmpty ? p.first[0] : '?';
    final second = p.length > 1 ? p[1][0] : '';
    return (first + second).toUpperCase();
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

  Widget _buildInfoTile(String title, String value, int bg) {
    final base = Color(bg);
    final accent = _accentFromBg(bg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  void _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EditProfileScreen(
          fullName: fullName,
          username: username,
          location: location,
          email: email,
          age: age,
          heightCm: heightCm,
          weightKg: weightKg,
          disability: disability,
        ),
      ),
    ).then((value) {
      if (value is Map<String, dynamic>) {
        setState(() {
          fullName = value['fullName'] ?? fullName;
          username = value['username'] ?? username;
          location = value['location'] ?? location;
          email = value['email'] ?? email;
          age = value['age'] ?? age;
          heightCm = value['heightCm'] ?? heightCm;
          weightKg = value['weightKg'] ?? weightKg;
          disability = value['disability'] ?? disability;
        });
        _showSnack('Profile updated');
      }
    });
  }

  void _openFollowList({required bool isFollowers}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FollowListScreen(
          title: isFollowers ? 'Followers' : 'Following',
          initial: List.generate(5, (i) => _FollowUser.sample(i)),
        ),
      ),
    );
  }

  void _openChangePicture() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        int tab = 0; // 0: Upload Image, 1: Choose Color
        String? pickedImagePath; // demo placeholder
        int tempGradientIndex = gradientIndex;

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

        Widget previewAvatar() {
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
              _initials(fullName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          );
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
                          const Icon(Icons.photo_camera_outlined),
                          const SizedBox(width: 8),
                          const Text('Change Profile Picture',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Center(child: previewAvatar()),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                    color: tab == 0 ? Colors.white : Colors.transparent,
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
                                          color: tab == 0 ? Colors.black : Colors.black87),
                                      const SizedBox(width: 8),
                                      const Text('Upload Image',
                                          style: TextStyle(fontWeight: FontWeight.w600)),
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
                                    color: tab == 1 ? Colors.white : Colors.transparent,
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
                                          color: tab == 1 ? Colors.black : Colors.black87),
                                      const SizedBox(width: 8),
                                      const Text('Choose Color',
                                          style: TextStyle(fontWeight: FontWeight.w600)),
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
                                  const Text('Upload your photo',
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setSheet(() => pickedImagePath = 'local');
                                      },
                                      icon: const Icon(Icons.file_upload_outlined),
                                      label: const Text('Choose Image'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        minimumSize: const Size.fromHeight(52),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Max file size: 5MB. Supported: JPG, PNG, GIF',
                                      style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  const Text('Choose a gradient color',
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
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
                                                color: i == tempGradientIndex ? Colors.black : Colors.white,
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
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (tab == 1) {
                                  setState(() => gradientIndex = tempGradientIndex);
                                  Navigator.pop(context);
                                  _showSnack('Avatar color updated');
                                } else {
                                  Navigator.pop(context);
                                  _showSnack(pickedImagePath == null ? 'No image selected' : 'Profile photo updated');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Save Changes'),
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

  void _openAddContactMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.import_contacts_outlined),
                title: const Text('Import from Contacts'),
                onTap: () {
                  Navigator.pop(context);
                  _openImportContacts();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('Add Manually'),
                onTap: () {
                  Navigator.pop(context);
                  _openAddContactForm();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openImportContacts() {
    final samples = <_EmergencyContact>[
      _EmergencyContact('Mehmet Arslan', '+90 532 111 2233', 'Friend'),
      _EmergencyContact('Ayşe Koç', '+90 541 987 7788', 'Sister'),
      _EmergencyContact('Mert Yıldız', '+90 555 333 5566', 'Friend'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final onSurface = Theme.of(context).colorScheme.onSurface;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: SizedBox(
            height: 420,
            child: ListView.separated(
              itemCount: samples.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = samples[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFF6B00),
                    child: Text(_initials(c.name),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(c.name, style: TextStyle(color: onSurface)),
                  subtitle: Text('${c.phone}  •  ${c.relation}',
                      style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() => contacts.add(c));
                      Navigator.pop(context);
                      _showSnack('Contact added');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openAddContactForm() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const _AddEmergencyContactScreen()))
        .then((value) {
      if (value is _EmergencyContact) {
        setState(() => contacts.add(value));
        _showSnack('Contact added');
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
        padding: const EdgeInsets.all(16),
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
          children: [
            CircleAvatar(
              backgroundColor: accent,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text('$value',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface)),
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
  final String title;
  final List<_FollowUser> initial;
  const _FollowListScreen({required this.title, required this.initial});

  @override
  State<_FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<_FollowListScreen> {
  late List<_FollowUser> users;

  @override
  void initState() {
    super.initState();
    users = List<_FollowUser>.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.5,
      ),
      body: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final u = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6246EA),
              child: Text(u.initials(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(u.name),
            subtitle: Text(u.handle),
            trailing: OutlinedButton(
              onPressed: () {
                setState(() => u.following = !u.following);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: u.following ? Colors.black : Colors.white,
                foregroundColor: u.following ? Colors.white : Colors.black,
                side: BorderSide(color: u.following ? Colors.black : Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(u.following ? 'Following' : 'Follow'),
            ),
          );
        },
      ),
    );
  }
}

class _EditProfileScreen extends StatefulWidget {
  final String fullName;
  final String username;
  final String location;
  final String email;
  final int age;
  final int heightCm;
  final int weightKg;
  final String disability;
  const _EditProfileScreen({
    required this.fullName,
    required this.username,
    required this.location,
    required this.email,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.disability,
  });

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  late final TextEditingController fullNameCtrl;
  late final TextEditingController usernameCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController ageCtrl;
  late final TextEditingController heightCtrl;
  late final TextEditingController weightCtrl;
  String disability = 'None';

  @override
  void initState() {
    super.initState();
    fullNameCtrl = TextEditingController(text: widget.fullName);
    usernameCtrl = TextEditingController(text: widget.username.replaceAll('@', ''));
    locationCtrl = TextEditingController(text: widget.location);
    emailCtrl = TextEditingController(text: widget.email);
    ageCtrl = TextEditingController(text: widget.age.toString());
    heightCtrl = TextEditingController(text: widget.heightCm.toString());
    weightCtrl = TextEditingController(text: widget.weightKg.toString());
    disability = widget.disability;
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    usernameCtrl.dispose();
    locationCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _save,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _section(
            'Profile Picture',
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF36C2FF)]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('AY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Go to your profile to change your profile picture',
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
              ],
            ),
          ),
          _section(
            'Name *',
            TextField(controller: fullNameCtrl),
          ),
          _section(
            'Username *',
            Row(children: [
              const Text('@  ', style: TextStyle(color: Colors.grey)),
              Expanded(child: TextField(controller: usernameCtrl)),
            ]),
          ),
          _section('Location', TextField(controller: locationCtrl)),
          _section('Email *', TextField(controller: emailCtrl)),
          _section(
            'Personal Information',
            Column(
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age (years) *',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm) *',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg) *',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
                const SizedBox(height: 12),
                _disabilityDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disabilityDropdown() {
    final items = [
      'None',
      'Mobility Impairment',
      'Visual Impairment',
      'Hearing Impairment',
      'Cognitive Impairment',
      'Multiple Disabilities',
      'Other',
    ];
    return DropdownButtonFormField<String>(
      value: disability,
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => disability = v ?? disability),
      decoration: const InputDecoration(labelText: 'Disability Status'),
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
                ? Colors.grey.shade700
                : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  void _save() {
    Navigator.pop(context, {
      'fullName': fullNameCtrl.text.trim(),
      'username': '@' + usernameCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'age': int.tryParse(ageCtrl.text.trim()) ?? widget.age,
      'heightCm': int.tryParse(heightCtrl.text.trim()) ?? widget.heightCm,
      'weightKg': int.tryParse(weightCtrl.text.trim()) ?? widget.weightKg,
      'disability': disability,
    });
  }
}

class _AddEmergencyContactScreen extends StatefulWidget {
  const _AddEmergencyContactScreen();

  @override
  State<_AddEmergencyContactScreen> createState() => _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<_AddEmergencyContactScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final relationCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    relationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Emergency Contact'),
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk, color: Colors.redAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Contact Details',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add someone who should be notified in emergencies',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g., Elif Yılmaz',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'e.g., +90 532 123 4567',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relationCtrl,
                  decoration: InputDecoration(
                    labelText: 'Relation *',
                    hintText: 'e.g., Spouse, Friend, Family',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                            ? const Color(0xFF2A3E59)
                            : const Color(0xFFD0E4FF)),
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
                          'Emergency contacts will be notified when you mark yourself as safe or when you need help.',
                          style: TextStyle(
                              height: 1.3,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade200
                                  : null),
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
    );
  }

  void _save() {
    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty || relationCtrl.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(
      context,
      _EmergencyContact(nameCtrl.text.trim(), phoneCtrl.text.trim(), relationCtrl.text.trim()),
    );
  }
}

class _EmergencyContact {
  final String name;
  final String phone;
  final String relation;
  _EmergencyContact(this.name, this.phone, this.relation);
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


