import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EarthquakeInfoScreen extends StatefulWidget {
  const EarthquakeInfoScreen({super.key});

  @override
  State<EarthquakeInfoScreen> createState() => _EarthquakeInfoScreenState();
}

class _EarthquakeInfoScreenState extends State<EarthquakeInfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).earthquakeInfoTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).beforeEarthquake, icon: const Icon(Icons.warning_amber_rounded)),
            Tab(text: AppLocalizations.of(context).duringEarthquake, icon: const Icon(Icons.shield)),
            Tab(text: AppLocalizations.of(context).afterEarthquake, icon: const Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBeforeEarthquake(isDark),
          _buildDuringEarthquake(isDark),
          _buildAfterEarthquake(isDark),
        ],
      ),
    );
  }

  Widget _buildBeforeEarthquake(bool isDark) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.home,
            title: t.homePreparations,
            items: [
              t.homePrep1,
              t.homePrep2,
              t.homePrep3,
              t.homePrep4,
              t.homePrep5,
              t.homePrep6,
            ],
            color: const Color(0xFF1E88E5),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.emergency,
            title: t.emergencyKit,
            items: [
              t.emergencyKit1,
              t.emergencyKit2,
              t.emergencyKit3,
              t.emergencyKit4,
              t.emergencyKit5,
              t.emergencyKit6,
              t.emergencyKit7,
              t.emergencyKit8,
              t.emergencyKit9,
            ],
            color: const Color(0xFFE53935),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.family_restroom,
            title: t.familyPlan,
            items: [
              t.familyPlan1,
              t.familyPlan2,
              t.familyPlan3,
              t.familyPlan4,
              t.familyPlan5,
            ],
            color: const Color(0xFF2E7D32),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildWarningCard(
            title: t.doNotDo,
            items: [
              t.doNotBefore1,
              t.doNotBefore2,
              t.doNotBefore3,
              t.doNotBefore4,
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDuringEarthquake(bool isDark) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.door_sliding,
            title: t.ifIndoors,
            items: [
              t.indoors1,
              t.indoors2,
              t.indoors3,
              t.indoors4,
              t.indoors5,
              t.indoors6,
            ],
            color: const Color(0xFFE53935),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.directions_walk,
            title: t.ifOutdoors,
            items: [
              t.outdoors1,
              t.outdoors2,
              t.outdoors3,
              t.outdoors4,
              t.outdoors5,
            ],
            color: const Color(0xFF1E88E5),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.drive_eta,
            title: t.ifInVehicle,
            items: [
              t.vehicle1,
              t.vehicle2,
              t.vehicle3,
              t.vehicle4,
            ],
            color: const Color(0xFF2E7D32),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildWarningCard(
            title: t.doNotDo,
            items: [
              t.doNotDuring1,
              t.doNotDuring2,
              t.doNotDuring3,
              t.doNotDuring4,
              t.doNotDuring5,
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAfterEarthquake(bool isDark) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.check_circle,
            title: t.immediatelyAfter,
            items: [
              t.immediatelyAfter1,
              t.immediatelyAfter2,
              t.immediatelyAfter3,
              t.immediatelyAfter4,
              t.immediatelyAfter5,
              t.immediatelyAfter6,
            ],
            color: const Color(0xFF2E7D32),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.phone,
            title: t.communication,
            items: [
              t.communication1,
              t.communication2,
              t.communication3,
              t.communication4,
              t.communication5,
            ],
            color: const Color(0xFF1E88E5),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.home_repair_service,
            title: t.safetyCheck,
            items: [
              t.safetyCheck1,
              t.safetyCheck2,
              t.safetyCheck3,
              t.safetyCheck4,
              t.safetyCheck5,
            ],
            color: const Color(0xFFE53935),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.people,
            title: t.helpAndSupport,
            items: [
              t.helpSupport1,
              t.helpSupport2,
              t.helpSupport3,
              t.helpSupport4,
            ],
            color: const Color(0xFFFF9800),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildWarningCard(
            title: t.doNotDo,
            items: [
              t.doNotAfter1,
              t.doNotAfter2,
              t.doNotAfter3,
              t.doNotAfter4,
              t.doNotAfter5,
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => _buildListItem(item, isDark)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard({
    required String title,
    required List<String> items,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0).withValues(alpha: isDark ? 0.1 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => _buildListItem(item, isDark, isWarning: true)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String item, bool isDark, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isWarning ? const Color(0xFFFF9800) : Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

