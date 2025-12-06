import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/safety_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'models/earthquake.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/settings_repository.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/background_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/onboarding/personal_info_onboarding_screen.dart';
import 'data/user_repository.dart';
import 'data/notification_repository.dart';
import 'models/user_model.dart';
import 'screens/post_detail_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Load settings from SharedPreferences
    await SettingsRepository.instance.loadSettings();
    
    // Initialize notification service
    await NotificationService.instance.initialize();
    
    // Initialize background service
    await BackgroundService.instance.initialize();
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Continue anyway - the app will show error state if needed
  }
  
  runApp(const QuakeConnectApp());
}

class QuakeConnectApp extends StatefulWidget {
  const QuakeConnectApp({super.key});

  @override
  State<QuakeConnectApp> createState() => _QuakeConnectAppState();
}

class _QuakeConnectAppState extends State<QuakeConnectApp> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  Earthquake? _mapSelection;
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    
    // Start monitoring for notifications
    NotificationRepository.instance.startMonitoring();
    
    // Listen to auth state changes
    AuthService.instance.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _isAuthenticated = user != null;
          _isCheckingAuth = false;
        });
      }
    });
    
    // Check initial auth state
    _isAuthenticated = AuthService.instance.isLoggedIn;
    _isCheckingAuth = false;
    
    NotificationService.instance.onNotificationTap.listen((payload) {
      if (payload != null && payload.startsWith('post:')) {
        final postId = payload.substring(5);
        if (postId.isNotEmpty && postId != 'null') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: postId),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    NotificationRepository.instance.stopMonitoring();
    super.dispose();
  }

  void _openOnMap(Earthquake eq) {
    setState(() {
      _previousIndex = _selectedIndex;
      _mapSelection = eq;
      _selectedIndex = 1; // Map tab
    });
  }

  void _openMapTab() {
    setState(() {
      _previousIndex = _selectedIndex;
      _mapSelection = null;
      _selectedIndex = 1;
    });
  }

  void _openSafetyTab() {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = 2;
    });
  }

  List<Widget> get _screens => [
        HomeScreen(onOpenOnMap: _openOnMap, onOpenMapTab: _openMapTab, onOpenSafetyTab: _openSafetyTab),
        MapScreen(initialSelection: _mapSelection),
        const SafetyScreen(),
        const DiscoverScreen(),
        const ProfileScreen(),
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: SettingsRepository.instance.locale,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: SettingsRepository.instance.themeMode,
          builder: (context, themeMode, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'QuakeConnect',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('tr')],
              locale: locale,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return supportedLocales.first;
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              routes: {
                '/': (context) => _buildAuthWrapper(context),
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAuthWrapper(BuildContext context) {
    // Show login screen if not authenticated
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!_isAuthenticated) {
      return const LoginScreen();
    }
    
    // Check if email is verified
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null && !currentUser.emailVerified) {
      return EmailVerificationScreen(email: currentUser.email ?? '');
    }
    
    // Check if user needs onboarding
    return FutureBuilder<UserModel?>(
      future: AuthService.instance.getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        // Check if user needs onboarding (age, height, or weight is null)
        final needsOnboarding = user == null || 
            user.age == null || 
            user.heightCm == null || 
            user.weightKg == null;
        
        if (needsOnboarding) {
          return const PersonalInfoOnboardingScreen();
        }
        
        final t = AppLocalizations.of(context);
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Determine slide direction based on index change
              final isMovingRight = _selectedIndex > _previousIndex;
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(isMovingRight ? 0.1 : -0.1, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            onTap: (index) {
              setState(() {
                _previousIndex = _selectedIndex;
                _selectedIndex = index;
              });
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
          ),
        );
      },
    );
  }
}
