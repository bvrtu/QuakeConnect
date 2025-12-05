import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../l10n/app_localizations.dart';
import '../../data/user_repository.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'app_onboarding_screen.dart';

class ProfileSetupOnboardingScreen extends StatefulWidget {
  const ProfileSetupOnboardingScreen({super.key});

  @override
  State<ProfileSetupOnboardingScreen> createState() => _ProfileSetupOnboardingScreenState();
}

class _ProfileSetupOnboardingScreenState extends State<ProfileSetupOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  
  File? _pickedImageFile;
  int _selectedGradientIndex = 0;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;
  bool _isLoading = false;

  final List<List<Color>> _gradients = [
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

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) return;

    final userRepo = UserRepository.instance;
    final user = await userRepo.getUser(userId);
    if (user != null && mounted) {
      setState(() {
        _usernameController.text = user.username.replaceAll('@', '');
        _selectedGradientIndex = user.gradientIndex;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _isUsernameAvailable = true;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = true;
    });

    try {
      final fullUsername = '@$username';
      final available = await UserRepository.instance.isUsernameAvailable(fullUsername);
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = available;
      });
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          _pickedImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        return;
      }

      final userRepo = UserRepository.instance;
      final currentUser = await userRepo.getUser(userId);
      if (currentUser == null) return;

      String? photoURL = currentUser.photoURL;

      // Handle image upload if selected
      if (_pickedImageFile != null) {
        try {
          final imageBytes = await _pickedImageFile!.readAsBytes();
          final originalImage = img.decodeImage(imageBytes);

          if (originalImage != null) {
            final resizedImage = img.copyResize(
              originalImage,
              width: 400,
              height: 400,
              maintainAspect: true,
            );

            final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
            final base64Image = base64Encode(compressedBytes);

            if (base64Image.length > 500000) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image too large. Please choose a smaller image.')),
                );
                setState(() {
                  _isLoading = false;
                });
              }
              return;
            }

            photoURL = 'data:image/jpeg;base64,$base64Image';
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing image: $e')),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
      }

      final username = '@${_usernameController.text.trim()}';
      final updatedUser = currentUser.copyWith(
        username: username,
        photoURL: photoURL,
        gradientIndex: _selectedGradientIndex,
      );

      await userRepo.updateUser(updatedUser);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AppOnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarPreview() {
    if (_pickedImageFile != null) {
      return ClipOval(
        child: Image.file(
          _pickedImageFile!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    final colors = _gradients[_selectedGradientIndex % _gradients.length];
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      alignment: Alignment.center,
      child: Text(
        _usernameController.text.isNotEmpty
            ? _usernameController.text[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  t.profileSetupTitle ?? 'One More Step',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.profileSetupSubtitle ?? 'Set up your profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                // Avatar Preview
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildAvatarPreview(),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: InkWell(
                          onTap: _pickImage,
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
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: Text(t.chooseImage ?? 'Choose Image'),
                  ),
                ),
                const SizedBox(height: 8),
                // Gradient Colors
                Text(
                  t.chooseColor ?? 'Choose Color',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < _gradients.length; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGradientIndex = i;
                            _pickedImageFile = null; // Clear image when color selected
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: _gradients[i]),
                            border: Border.all(
                              color: i == _selectedGradientIndex ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => _checkUsernameAvailability(),
                  decoration: InputDecoration(
                    labelText: t.usernameLabel ?? 'Username',
                    hintText: 'username',
                    prefixText: '@',
                    prefixIcon: const Icon(Icons.alternate_email),
                    suffixIcon: _isCheckingUsername
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _usernameController.text.trim().isNotEmpty
                            ? Icon(
                                _isUsernameAvailable ? Icons.check_circle : Icons.cancel,
                                color: _isUsernameAvailable ? Colors.green : Colors.red,
                              )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _usernameController.text.trim().isNotEmpty && !_isUsernameAvailable
                        ? t.usernameTaken ?? 'Username is already taken'
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.usernameRequired ?? 'Username is required';
                    }
                    if (value.length < 5) {
                      return t.usernameTooShort ?? 'Username must be at least 5 characters';
                    }
                    if (value.length > 10) {
                      return 'Username must be at most 10 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    if (!_isUsernameAvailable) {
                      return t.usernameTaken ?? 'Username is already taken';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Continue Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          t.continue_ ?? 'Continue',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

