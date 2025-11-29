import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/safety_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'models/earthquake.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/settings_repository.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load settings from SharedPreferences
  await SettingsRepository.instance.loadSettings();
  // Initialize notification service
  await NotificationService.instance.initialize();
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
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  Earthquake? _mapSelection;

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
        const ProfileScreen(),
        SettingsScreen(
          darkMode: _isDarkMode,
          onDarkModeChanged: (v) => setState(() => _isDarkMode = v),
          languageCode: _locale.languageCode,
          onLanguageChanged: (code) => setState(() => _locale = Locale(code)),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuakeConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tr')],
      locale: _locale,
      home: Builder(builder: (context) {
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
            BottomNavigationBarItem(icon: const Icon(Icons.person), label: t.navProfile),
            BottomNavigationBarItem(icon: const Icon(Icons.settings), label: t.navSettings),
          ],
        ),
      );}),
    );
  }
}
