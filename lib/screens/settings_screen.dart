import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;
  const SettingsScreen({super.key, required this.darkMode, required this.onDarkModeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String language = 'English';

  bool pushNotifications = true;
  double minMagnitude = 4.0;
  bool nearbyAlerts = true;
  bool communityUpdates = true;

  bool locationServices = true;
  bool shareSafetyStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Customize your experience',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    fontSize: 15),
              ),
              const SizedBox(height: 16),
              _section(
                child: _rowHeader('Appearance')
                  ..add(const SizedBox(height: 12))
                  ..add(_switchTile(
                    icon: Icons.brightness_5_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark theme',
                    value: widget.darkMode,
                    onChanged: (v) {
                      widget.onDarkModeChanged(v);
                      setState(() {});
                    },
                  )),
              ),
              _section(
                child: _rowHeader('Language')
                  ..add(const SizedBox(height: 12))
                  ..add(_languagePicker()),
              ),
              _section(
                child: [
                  ..._rowHeader('Notification Settings'),
                  const SizedBox(height: 12),
                  _switchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive earthquake alerts',
                    value: pushNotifications,
                    onChanged: (v) => setState(() => pushNotifications = v),
                  ),
                  const Divider(height: 24),
                  _minMagnitudeSlider(),
                  const SizedBox(height: 8),
                  Text(
                    'Only notify for earthquakes of magnitude ${minMagnitude.toStringAsFixed(1)} or higher',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Divider(height: 24),
                  _switchTile(
                    icon: Icons.radar_outlined,
                    title: 'Nearby Earthquake Alerts',
                    subtitle: 'Within 100 km radius',
                    value: nearbyAlerts,
                    onChanged: (v) => setState(() => nearbyAlerts = v),
                  ),
                  const Divider(height: 24),
                  _switchTile(
                    icon: Icons.forum_outlined,
                    title: 'Community Updates',
                    subtitle: 'Local reports in your area',
                    value: communityUpdates,
                    onChanged: (v) => setState(() => communityUpdates = v),
                  ),
                ],
              ),
              _section(
                child: [
                  ..._rowHeader('Location & Privacy'),
                  const SizedBox(height: 12),
                  _switchTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location Services',
                    subtitle: 'Show nearby earthquakes',
                    value: locationServices,
                    onChanged: (v) => setState(() => locationServices = v),
                  ),
                  const Divider(height: 24),
                  _switchTile(
                    icon: Icons.shield_outlined,
                    title: 'Share Safety Status',
                    subtitle: 'Let contacts see your status',
                    value: shareSafetyStatus,
                    onChanged: (v) => setState(() => shareSafetyStatus = v),
                  ),
                ],
              ),
              _section(
                child: [
                  ..._rowHeader('About'),
                  const SizedBox(height: 12),
                  _aboutRow('Version', '1.0.0'),
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
        Switch.adaptive(value: value, onChanged: onChanged),
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
                  Text('App Language',
                      style: TextStyle(fontWeight: FontWeight.w600, color: onSurface)),
                  const SizedBox(height: 4),
                  Text('Choose your preferred language',
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
            DropdownMenuItem(value: 'Turkish', child: Text('Turkish')),
          ],
          onChanged: (v) => setState(() => language = v ?? language),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              const Text('Minimum Magnitude Alert',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
                  onChanged: (v) => setState(() => minMagnitude = v),
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
                ? Colors.grey.shade700
                : Colors.grey.shade200),
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
        onPressed: () {},
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
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
                ? Colors.grey.shade700
                : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
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


