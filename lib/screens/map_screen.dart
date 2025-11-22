import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/earthquake.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final List<Earthquake> _earthquakes = Earthquake.getSampleData();
  Earthquake? _selectedEarthquake;
  final LatLng _turkeyCenter = const LatLng(39.0, 35.0);
  final double _zoomLevel = 6.0;
  MapType _currentMapType = MapType.normal;
  bool _appliedDark = false;

  // Minimal dark map style for better night readability
  static const String _darkMapStyle = '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#ffffff"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d6d6d6"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]}]';

  @override
  void initState() {
    super.initState();
    _selectedEarthquake = _earthquakes.first;
  }

  Set<Marker> _createMarkers() {
    return _earthquakes.map((earthquake) {
      return Marker(
        markerId: MarkerId(earthquake.location),
        position: LatLng(earthquake.latitude, earthquake.longitude),
        onTap: () {
          setState(() {
            _selectedEarthquake = earthquake;
          });
          _animateToEarthquake(earthquake);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMagnitudeHue(earthquake.magnitude),
        ),
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
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(earthquake.latitude, earthquake.longitude),
          10.0,
        ),
      );
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
                title: const Text('Normal'),
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
                title: const Text('Satellite'),
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
                title: const Text('Terrain'),
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
                title: const Text('Hybrid'),
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
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    _applyMapStyle();
                    },
                    markers: _createMarkers(),
                    mapType: _currentMapType,
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  ),

                  // Earthquake Info Card Overlay
                  if (_selectedEarthquake != null)
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
          Text('Map',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          const Spacer(),
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
                      earthquake.timeAgo,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.layers, size: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${earthquake.depth.toStringAsFixed(1)} km",
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${earthquake.distance.toStringAsFixed(0)} km",
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
