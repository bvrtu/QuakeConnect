import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/earthquake.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';
import '../services/earthquake_api_service.dart';

class MapScreen extends StatefulWidget {
  final Earthquake? initialSelection;
  const MapScreen({super.key, this.initialSelection});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  List<Earthquake> _earthquakes = [];
  Earthquake? _selectedEarthquake;
  final LatLng _turkeyCenter = const LatLng(39.0, 35.0);
  final double _zoomLevel = 6.0;
  MapType _currentMapType = MapType.normal;
  bool _appliedDark = false;
  bool _pendingInitialAnimation = false;
  bool _isLoading = true;

  // Minimal dark map style for better night readability
  static const String _darkMapStyle = '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#ffffff"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d6d6d6"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]}]';

  @override
  void initState() {
    super.initState();
    _loadEarthquakes();
  }

  Future<void> _loadEarthquakes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final earthquakes = await EarthquakeApiService.fetchRecentEarthquakes(limit: 100);
      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
        
        if (widget.initialSelection != null) {
          // Try to find matching earthquake by earthquakeId first, then by coordinates
          Earthquake? matched;
          if (widget.initialSelection!.earthquakeId != null) {
            try {
              matched = _earthquakes.firstWhere(
                (e) => e.earthquakeId == widget.initialSelection!.earthquakeId,
              );
            } catch (e) {
              // If not found by ID, try coordinates
              try {
                matched = _earthquakes.firstWhere(
                  (e) => (e.latitude - widget.initialSelection!.latitude).abs() < 0.001 &&
                         (e.longitude - widget.initialSelection!.longitude).abs() < 0.001,
                );
              } catch (e2) {
                // If still not found, use the initialSelection itself
                matched = widget.initialSelection;
              }
            }
          } else {
            // Fallback to coordinate matching if no ID
            try {
              matched = _earthquakes.firstWhere(
                (e) => (e.latitude - widget.initialSelection!.latitude).abs() < 0.001 &&
                       (e.longitude - widget.initialSelection!.longitude).abs() < 0.001,
              );
            } catch (e) {
              // If not found, use the initialSelection itself
              matched = widget.initialSelection;
            }
          }
          _selectedEarthquake = matched;
          _pendingInitialAnimation = true;
        } else if (_earthquakes.isNotEmpty) {
    _selectedEarthquake = _earthquakes.first;
        }
        
        // If map is already created and we have a pending animation, trigger it
        if (_mapController != null && _pendingInitialAnimation && _selectedEarthquake != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _mapController != null && _selectedEarthquake != null) {
              setState(() {}); // Update markers
              _animateToEarthquake(_selectedEarthquake!);
              _pendingInitialAnimation = false;
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _earthquakes = [];
        
        // Show error state but don't use sample data
        // The map will show empty state
        if (widget.initialSelection != null) {
          // If we have an initial selection, show it even if API fails
          _selectedEarthquake = widget.initialSelection;
        }
      });
    }
  }

  Set<Marker> _createMarkers() {
    return _earthquakes.map((earthquake) {
      // Use earthquakeId for unique marker ID, fallback to location if ID is null
      final markerId = earthquake.earthquakeId ?? 
                      '${earthquake.latitude}_${earthquake.longitude}_${earthquake.dateTime.millisecondsSinceEpoch}';
      final isSelected = _selectedEarthquake != null && 
                        (_selectedEarthquake!.earthquakeId != null 
                          ? _selectedEarthquake!.earthquakeId == earthquake.earthquakeId
                          : _selectedEarthquake!.latitude == earthquake.latitude && 
                            _selectedEarthquake!.longitude == earthquake.longitude);
      
      return Marker(
        markerId: MarkerId(markerId),
        position: LatLng(earthquake.latitude, earthquake.longitude),
        onTap: () {
          setState(() {
            _selectedEarthquake = earthquake;
          });
          _animateToEarthquake(earthquake);
        },
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet) // Purple for selected
            : BitmapDescriptor.defaultMarkerWithHue(
          _getMagnitudeHue(earthquake.magnitude),
        ),
        anchor: Offset(0.5, isSelected ? 1.2 : 1.0), // Selected marker slightly higher
        infoWindow: InfoWindow(
          title: 'M${earthquake.magnitude.toStringAsFixed(1)}',
          snippet: earthquake.location,
        ),
      );
    }).toSet();
  }

  double _getMagnitudeHue(double magnitude) {
    if (magnitude >= 5.0) return BitmapDescriptor.hueRed;
    if (magnitude >= 4.0) return BitmapDescriptor.hueOrange;
    if (magnitude >= 3.0) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueGreen;
  }

  void _animateToEarthquake(Earthquake earthquake) {
    if (_mapController != null) {
      // Smooth zoom-in effect: center, slight zoom, then closer
      final target = LatLng(earthquake.latitude, earthquake.longitude);
      // First, move to location with medium zoom
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(target, 8.0),
      );
      // Then zoom in much closer after a short delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_mapController != null && mounted) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(target, 15.0), // Much closer zoom for detailed view
          );
        }
      });
    } else {
      // If controller is not ready, wait a bit and try again
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_mapController != null && mounted) {
          _animateToEarthquake(earthquake);
        }
      });
    }
  }

  void _applyMapStyle() {
    if (_mapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark && !_appliedDark) {
      _mapController!.setMapStyle(_darkMapStyle);
      _appliedDark = true;
    } else if (!isDark && _appliedDark) {
      _mapController!.setMapStyle(null);
      _appliedDark = false;
    }
  }

  void _showMapTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: Text(AppLocalizations.of(context).mapNormal),
                trailing: _currentMapType == MapType.normal
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.normal;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.terrain),
                title: Text(AppLocalizations.of(context).mapSatellite),
                trailing: _currentMapType == MapType.satellite
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.satellite;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.terrain),
                title: Text(AppLocalizations.of(context).mapTerrain),
                trailing: _currentMapType == MapType.terrain
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.terrain;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.layers_outlined),
                title: Text(AppLocalizations.of(context).mapHybrid),
                trailing: _currentMapType == MapType.hybrid
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.hybrid;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
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

            // Map Area
            Expanded(
              child: Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _turkeyCenter,
                      zoom: _zoomLevel,
                    ),
                    onMapCreated: (GoogleMapController controller) async {
                      _mapController = controller;
                    _applyMapStyle();
                      // Wait for map to be fully ready
                      await Future.delayed(const Duration(milliseconds: 300));
                      
                      // Run initial selection animation after map is ready
                      if (_pendingInitialAnimation && _selectedEarthquake != null && mounted) {
                        // Update markers first to show selected state
                        setState(() {});
                        
                        // Wait a bit more to ensure markers are rendered
                        await Future.delayed(const Duration(milliseconds: 200));
                        
                        if (mounted && _mapController != null && _selectedEarthquake != null) {
                          _animateToEarthquake(_selectedEarthquake!);
                          _pendingInitialAnimation = false;
                        }
                      }
                    },
                    markers: _createMarkers(),
                    mapType: _currentMapType,
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  ),

                  // Loading Overlay
                  if (_isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Error State Overlay
                  if (!_isLoading && _earthquakes.isEmpty)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
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
                      ),
                  ),

                  // Earthquake Info Card Overlay
                  if (_selectedEarthquake != null && !_isLoading && _earthquakes.isNotEmpty)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildEarthquakeCard(_selectedEarthquake!),
                    ),
                ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).mapTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              if (!_isLoading && _earthquakes.isNotEmpty)
                Text(
                  '${_earthquakes.length} earthquakes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, size: 24, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _isLoading ? null : _loadEarthquakes,
            tooltip: 'Refresh',
          ),
          // Layers button
          IconButton(
            icon: Icon(Icons.layers, size: 24, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              _showMapTypeDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEarthquakeCard(Earthquake earthquake) {
    final magnitudeColor = AppTheme.getMagnitudeColor(earthquake.magnitude);
    final borderColor = AppTheme.getMagnitudeBorderColor(earthquake.magnitude);
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Magnitude Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: magnitudeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                earthquake.magnitude.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  earthquake.location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      translateRelativeFromEnglish(context, earthquake.timeAgo),
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.layers, size: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${earthquake.depth.toStringAsFixed(1)} km ${AppLocalizations.of(context).deepSuffix}",
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${earthquake.distance.toStringAsFixed(0)} km ${AppLocalizations.of(context).awaySuffix}",
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
