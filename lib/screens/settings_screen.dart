import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/settings_repository.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../data/notification_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String language;
  final _settingsRepo = SettingsRepository.instance;

  bool pushNotifications = true;
  double minMagnitude = 4.0;
  bool nearbyAlerts = true;
  bool communityUpdates = true;
  bool locationServices = true;
  bool _previousPushNotificationsState = true;
  bool _previousLocationServicesState = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsRepo.loadSettings();
    setState(() {
      pushNotifications = _settingsRepo.pushNotifications;
      minMagnitude = _settingsRepo.minMagnitude;
      nearbyAlerts = _settingsRepo.nearbyAlerts;
      communityUpdates = _settingsRepo.communityUpdates;
      locationServices = _settingsRepo.locationServices;
      _previousPushNotificationsState = pushNotifications;
      _previousLocationServicesState = locationServices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _settingsRepo.locale.value;
    language = currentLocale.languageCode == 'tr' ? 'Türkçe' : 'English';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).settingsTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).settingsCustomize,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    fontSize: 15),
              ),
              const SizedBox(height: 16),
              _section(
                child: _rowHeader(AppLocalizations.of(context).appearance)
                  ..add(const SizedBox(height: 12))
                  ..add(_switchTile(
                    icon: Icons.brightness_5_outlined,
                    title: AppLocalizations.of(context).darkMode,
                    subtitle: AppLocalizations.of(context).toggleDarkTheme,
                    value: isDarkMode,
                    onChanged: (v) {
                      _settingsRepo.saveThemeMode(v);
                      setState(() {});
                    },
                  )),
              ),
              _section(
                child: _rowHeader(AppLocalizations.of(context).language)
                  ..add(const SizedBox(height: 12))
                  ..add(_languagePicker()),
              ),
              _section(
                child: [
                  ..._rowHeader(AppLocalizations.of(context).notificationSettings),
                  const SizedBox(height: 12),
                  _switchTile(
                    icon: Icons.notifications_outlined,
                    title: AppLocalizations.of(context).pushNotifications,
                    subtitle: AppLocalizations.of(context).receiveAlerts,
                    value: pushNotifications,
                    onChanged: (v) async {
                      // Always request permission when enabling (even if previously granted)
                      // This ensures permission is requested when toggling off and on
                      if (v) {
                        // Request notification permission when enabling
                        final androidPlugin = await NotificationService.instance.notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
                        if (androidPlugin != null) {
                          final granted = await androidPlugin.requestNotificationsPermission();
                          if (granted != true) {
                            // Permission denied, don't enable
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).notificationPermissionDenied),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                            return;
                          }
                        }
                        // For iOS, check if notifications are enabled
                        final iosPlugin = await NotificationService.instance.notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
                        if (iosPlugin != null) {
                          final settings = await iosPlugin.requestPermissions(
                            alert: true,
                            badge: true,
                            sound: true,
                          );
                          if (settings != true) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).notificationPermissionDenied),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                            return;
                          }
                        }
                      }
                      setState(() {
                        pushNotifications = v;
                        _previousPushNotificationsState = v;
                      });
                      await _settingsRepo.savePushNotifications(v);
                      // Refresh notifications to apply new settings
                      NotificationRepository.instance.refresh();
                    },
                  ),
                  const Divider(height: 24),
                  _minMagnitudeSlider(),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).onlyNotifyFor(minMagnitude.toStringAsFixed(1)),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Divider(height: 24),
                  _switchTile(
                    icon: Icons.radar_outlined,
                    title: AppLocalizations.of(context).nearbyAlerts,
                    subtitle: AppLocalizations.of(context).withinKm,
                    value: nearbyAlerts,
                  onChanged: (v) {
                    setState(() => nearbyAlerts = v);
                    _settingsRepo.saveNearbyAlerts(v);
                    // Refresh notifications to apply new settings
                    NotificationRepository.instance.refresh();
                  },
                  ),
                  const Divider(height: 24),
                  _switchTile(
                    icon: Icons.forum_outlined,
                    title: AppLocalizations.of(context).communityUpdates,
                    subtitle: AppLocalizations.of(context).localReports,
                    value: communityUpdates,
                  onChanged: (v) {
                    setState(() => communityUpdates = v);
                    _settingsRepo.saveCommunityUpdates(v);
                    // No need to refresh notifications for community updates
                    // This only affects future notifications
                  },
                  ),
                ],
              ),
              _section(
                child: [
                  ..._rowHeader(AppLocalizations.of(context).locationPrivacy),
                  const SizedBox(height: 12),
                  _switchTile(
                    icon: Icons.location_on_outlined,
                    title: AppLocalizations.of(context).locationServices,
                    subtitle: AppLocalizations.of(context).showNearby,
                    value: locationServices,
                    onChanged: (v) async {
                      // Always request permission when enabling (even if previously granted)
                      // This ensures permission is requested when toggling off and on
                      if (v) {
                        // Always request location permission when enabling
                        final permission = await Permission.location.status;
                        if (!permission.isGranted) {
                          final result = await Permission.location.request();
                          if (!result.isGranted) {
                            // Permission denied, don't enable
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).locationPermissionDenied),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                            return;
                          }
                        }
                        
                        // Also check if location services are enabled on device
                        final serviceEnabled = await LocationService.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).locationServicesDisabled),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                          return;
                        }
                      } else {
                        // When disabling location services, clear the cache
                        LocationService.clearCache();
                      }
                      setState(() {
                        locationServices = v;
                        _previousLocationServicesState = v;
                      });
                      await _settingsRepo.saveLocationServices(v);
                    },
                  ),
                ],
              ),
              _section(
                child: [
                  ..._rowHeader(AppLocalizations.of(context).about),
                  const SizedBox(height: 12),
                  _aboutRow(AppLocalizations.of(context).version, '1.0.0'),
                ],
              ),
              const SizedBox(height: 8),
              _signOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _rowHeader(String title) => [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ];

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          child: Icon(icon, color: onSurface),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: onSurface)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          activeTrackColor: isDark
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          inactiveThumbColor: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          inactiveTrackColor: isDark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _languagePicker() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              child: Icon(Icons.language, color: onSurface),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).appLanguage,
                      style: TextStyle(fontWeight: FontWeight.w600, color: onSurface)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context).chooseLanguage,
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: language,
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Türkçe', child: Text('Türkçe')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => language = v);
            _settingsRepo.saveLocale(v == 'Türkçe' ? 'tr' : 'en');
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _minMagnitudeSlider() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).minMagnitudeAlert,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: minMagnitude,
                  min: 2.0,
                  max: 7.0,
                  divisions: 10,
                  onChanged: (v) {
                    setState(() => minMagnitude = v);
                    _settingsRepo.saveMinMagnitude(v);
                    // Refresh notifications to apply new settings
                    NotificationRepository.instance.refresh();
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(minMagnitude.toStringAsFixed(1),
              style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        ),
      ],
    );
  }

  Widget _aboutRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade400, width: 1.2),
      ),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                  fontSize: 15)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context).signOut),
              content: Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context).signOut),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            try {
              await AuthService.instance.signOut();
              // Auth state change listener in main.dart will handle navigation
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(AppLocalizations.of(context).signOut),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _section({required List<Widget> child}) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade400, width: 1.2),
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
        children: child,
      ),
    );
  }
}


