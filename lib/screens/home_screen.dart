import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/earthquake.dart';
import '../l10n/app_localizations.dart';
import '../widgets/earthquake_card.dart';
import 'notifications_screen.dart';
import '../data/notification_repository.dart';
import '../data/settings_repository.dart';
import 'map_screen.dart';
import '../services/earthquake_api_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_functions/cloud_functions.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Earthquake earthquake)? onOpenOnMap;
  final VoidCallback? onOpenMapTab;
  final VoidCallback? onOpenSafetyTab;
  const HomeScreen({super.key, this.onOpenOnMap, this.onOpenMapTab, this.onOpenSafetyTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedFilterIndex = 0;
  List<Earthquake> _allEarthquakes = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _filterChangeKey = 0; // Used to trigger animations when filter changes
  int _newsRefreshKey = 0; // Used to trigger news refresh in earthquake cards
  bool _isLoading = true;
  String? _errorMessage;
  bool _previousLocationServicesState = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _previousLocationServicesState = SettingsRepository.instance.locationServices;
    _loadEarthquakes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if location services setting changed
      final currentState = SettingsRepository.instance.locationServices;
      if (currentState != _previousLocationServicesState) {
        _previousLocationServicesState = currentState;
        _loadEarthquakes(); // Reload to update distances
      }
    }
  }

  Future<void> _loadEarthquakes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch earthquakes and news in parallel
      final results = await Future.wait([
        EarthquakeApiService.fetchRecentEarthquakes(limit: 100),
        _fetchEarthquakeNews(), // Fetch news in background
      ]);
      
      final earthquakes = results[0] as List<Earthquake>;
      
      // Get user location to calculate distances
      // Only get location if location services are enabled in settings
      Position? userLocation;
      if (SettingsRepository.instance.locationServices) {
        userLocation = await LocationService.getCurrentLocation();
        
        // Debug: Print location info
        if (userLocation != null) {
          print('HomeScreen: User location obtained: ${userLocation.latitude}, ${userLocation.longitude}');
        } else {
          print('HomeScreen: User location: NULL (permission denied or location services disabled)');
          // Don't use last known position if location services are disabled in settings
          if (SettingsRepository.instance.locationServices) {
            print('HomeScreen: Trying to get last known position as fallback...');
            try {
              final lastKnown = await Geolocator.getLastKnownPosition();
              if (lastKnown != null) {
                print('HomeScreen: Using last known position: ${lastKnown.latitude}, ${lastKnown.longitude}');
                userLocation = lastKnown;
              } else {
                print('HomeScreen: Last known position also unavailable');
              }
            } catch (e) {
              print('HomeScreen: Error getting last known position: $e');
            }
          }
        }
      } else {
        print('HomeScreen: Location services disabled in settings, not getting location');
      }
      
      // Calculate distances for each earthquake
      final earthquakesWithDistance = earthquakes.map((eq) {
        double calculatedDistance = 0.0;
        
        if (userLocation != null) {
          calculatedDistance = LocationService.calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            eq.latitude,
            eq.longitude,
          );
        } else {
          // If location not available, use API distance if available, otherwise 0
          calculatedDistance = eq.distance > 0 ? eq.distance : 0.0;
        }
        
        // Create new earthquake with calculated distance
        return Earthquake(
          magnitude: eq.magnitude,
          location: eq.location,
          timeAgo: eq.timeAgo,
          depth: eq.depth,
          distance: calculatedDistance,
          latitude: eq.latitude,
          longitude: eq.longitude,
          earthquakeId: eq.earthquakeId,
          provider: eq.provider,
          dateTime: eq.dateTime,
        );
      }).toList();
      
      setState(() {
        _allEarthquakes = earthquakesWithDistance;
        _isLoading = false;
        _filterChangeKey++; // Trigger animation
        _newsRefreshKey++; // Trigger news refresh in cards
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        // Fallback to sample data on error
        _allEarthquakes = Earthquake.getSampleData();
      });
    }
  }

  Future<void> _fetchEarthquakeNews() async {
    try {
      print('HomeScreen: Triggering news fetch...');
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('fetchEarthquakeNewsManual');
      
      final result = await callable.call();
      print('HomeScreen: News fetch result: ${result.data}');
      
      if (result.data != null && result.data['matched'] != null) {
        print('HomeScreen: Matched ${result.data['matched']} news articles');
      }
    } catch (e) {
      print('HomeScreen: Error fetching news: $e');
      // Don't show error to user, news fetching is not critical
    }
  }

  // Get filtered earthquakes based on current filter
  List<Earthquake> get _filteredEarthquakes {
    List<Earthquake> result;

    // First apply the selected filter
    switch (_selectedFilterIndex) {
      case 0: // All Quakes
        result = _allEarthquakes;
        break;
      case 1: // Nearby (within 200 km)
        result = _allEarthquakes.where((e) => e.distance <= 200).toList();
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
    // Check if location services setting changed while screen is visible
    final currentLocationState = SettingsRepository.instance.locationServices;
    if (currentLocationState != _previousLocationServicesState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _previousLocationServicesState = currentLocationState;
          });
          _loadEarthquakes(); // Reload to update distances
        }
      });
    }
    
    return GestureDetector(
      onTap: () {
        // Unfocus search bar when tapping outside
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null && _allEarthquakes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load earthquakes',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadEarthquakes,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEarthquakes,
                          child: _filteredEarthquakes.isEmpty
                              ? Center(
                                  child: Text(
                                    'No earthquakes found',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                )
                              : ListView.builder(
                                  key: ValueKey<int>(_filterChangeKey), // Trigger rebuild on filter change
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredEarthquakes.length,
                itemBuilder: (context, index) {
                                    final eq = _filteredEarthquakes[index];
                                    return _buildAnimatedCard(eq, index);
                },
                                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/quakeconnect.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 10),
          // App Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QuakeConnect',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppLocalizations.of(context).homeSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Theme.of(context).colorScheme.onSurface,
                iconSize: 24,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(
                        onOpenMapTab: widget.onOpenMapTab,
                        onOpenSafetyTab: widget.onOpenSafetyTab,
                        onOpenOnMap: widget.onOpenOnMap,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              if (NotificationRepository.instance.unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      NotificationRepository.instance.unreadCount > 99
                          ? '99+'
                          : '${NotificationRepository.instance.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
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
          // Stronger outline for visibility in light/dark
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        HapticFeedback.lightImpact();
        setState(() {
          _selectedFilterIndex = index;
          _filterChangeKey++; // Trigger animation
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? cs.primary : cs.surface,
        foregroundColor: isSelected ? cs.onPrimary : cs.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? cs.primary
                : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            width: 1.2,
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(Earthquake eq, int index) {
    // Delay based on index for staggered animation
    final delay = index * 50; // 50ms delay per card
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // Slide up from 20px below
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: EarthquakeCard(
          key: ValueKey('${eq.earthquakeId}_$_newsRefreshKey'), // Force rebuild when news refresh key changes
          earthquake: eq,
          onTap: () {
            if (widget.onOpenOnMap != null) {
              widget.onOpenOnMap!(eq);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MapScreen(initialSelection: eq),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
