import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../l10n/app_localizations.dart';
import '../../data/user_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _displayNameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _displayNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty || !username.startsWith('@')) return;

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = true;
    });

    try {
      final available = await UserRepository.instance.isUsernameAvailable(username);
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameAvailable) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.lightImpact();
      final user = await AuthService.instance.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (user != null && mounted) {
        // Navigation will be handled by auth state listener in main.dart
        Navigator.of(context).pop(); // Close register screen
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
        _displayNameFocusNode.unfocus();
        _usernameFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).register ?? 'Register'),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo or App Name
                  Text(
                    'QuakeConnect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).createAccount ?? 'Create your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Display Name Field
                  TextFormField(
                    controller: _displayNameController,
                    focusNode: _displayNameFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _usernameFocusNode.requestFocus(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).nameLabel ?? 'Full Name',
                      hintText: 'John Doe',
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).nameRequired ?? 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                    onChanged: (_) => _checkUsernameAvailability(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).usernameLabel ?? 'Username',
                      hintText: '@username',
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
                          ? AppLocalizations.of(context).usernameTaken ?? 'Username is already taken'
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).usernameRequired ?? 'Username is required';
                      }
                      if (!value.startsWith('@')) {
                        return AppLocalizations.of(context).usernameMustStartWithAt ?? 'Username must start with @';
                      }
                      if (value.length < 4) {
                        return AppLocalizations.of(context).usernameTooShort ?? 'Username must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).emailLabel ?? 'Email',
                      hintText: 'example@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).emailRequired ?? 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return AppLocalizations.of(context).invalidEmail ?? 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).password ?? 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).passwordRequired ?? 'Password is required';
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context).passwordTooShort ?? 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleRegister(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).confirmPassword ?? 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).confirmPasswordRequired ?? 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return AppLocalizations.of(context).passwordsDoNotMatch ?? 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Register Button
                  ElevatedButton(
                    onPressed: _isLoading || !_isUsernameAvailable ? null : _handleRegister,
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
                            AppLocalizations.of(context).register ?? 'Register',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context).alreadyHaveAccount ?? 'Already have an account? ',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context).login ?? 'Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

