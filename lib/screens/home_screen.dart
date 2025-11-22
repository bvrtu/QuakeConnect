import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import '../l10n/app_localizations.dart';
import '../widgets/earthquake_card.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilterIndex = 0;
  final List<Earthquake> _allEarthquakes = Earthquake.getSampleData();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get filtered earthquakes based on current filter
  List<Earthquake> get _filteredEarthquakes {
    List<Earthquake> result;

    // First apply the selected filter
    switch (_selectedFilterIndex) {
      case 0: // All Quakes
        result = _allEarthquakes;
        break;
      case 1: // Nearby (within 100 km)
        result = _allEarthquakes.where((e) => e.distance <= 100).toList();
        break;
      case 2: // Major (5.0+)
        result = _allEarthquakes.where((e) => e.magnitude >= 5.0).toList();
        break;
      default:
        result = _allEarthquakes;
    }

    // Then apply search filter
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return result;
    }

    return result.where((earthquake) {
      return earthquake.location.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Filter Buttons
            _buildFilterButtons(),
            
            // Earthquake List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: _filteredEarthquakes.length,
                itemBuilder: (context, index) {
                  return EarthquakeCard(earthquake: _filteredEarthquakes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/quakeconnect.png',
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 12),
          // App Name and Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('QuakeConnect',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  )),
              Text(
                AppLocalizations.of(context).homeSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Spacer to push notification to the right
          const Spacer(),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Theme.of(context).colorScheme.onSurface,
                iconSize: 28,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchHint,
          prefixIcon: Icon(Icons.search,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
          ),
          // Use theme InputDecoration (light/dark friendly)
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(AppLocalizations.of(context).filtersAll, 0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(AppLocalizations.of(context).filtersNearby, 1, icon: Icons.location_on),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(AppLocalizations.of(context).filtersMajor, 2, icon: Icons.warning_amber_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int index, {IconData? icon}) {
    final isSelected = _selectedFilterIndex == index;

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? cs.primary : cs.surface,
        foregroundColor: isSelected ? cs.onPrimary : cs.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? cs.primary
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
