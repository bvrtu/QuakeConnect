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
  double _zoomLevel = 6.0;
  MapType _currentMapType = MapType.normal;

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
          const Text(
            'Map',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Layers button
          IconButton(
            icon: const Icon(Icons.layers, size: 24),
            color: Colors.black87,
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      earthquake.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.layers, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${earthquake.depth.toStringAsFixed(1)} km",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${earthquake.distance.toStringAsFixed(0)} km",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
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
