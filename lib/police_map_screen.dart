import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PoliceMapScreen extends StatefulWidget {
  @override
  _PoliceMapScreenState createState() => _PoliceMapScreenState();
}

class _PoliceMapScreenState extends State<PoliceMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  String get googleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getUserLocation();
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("⚠️ Location services are disabled.");
      // FALLBACK: Set a default location (e.g., New Delhi) so map loads
      _setDefaultLocation();
      return;
    }

    // 2. Check Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("⚠️ Location permission denied.");
        _setDefaultLocation(); // FALLBACK
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("⚠️ Location permission denied forever.");
      _setDefaultLocation(); // FALLBACK
      return;
    }

    // 3. Get Position
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
      });

      _fetchNearbyPoliceStations(position.latitude, position.longitude);

    } catch (e) {
      print("❌ Error getting location: $e");
      _setDefaultLocation();
    }
  }

  // Add this helper function
  void _setDefaultLocation() {
    setState(() {
      // Default to New Delhi (28.6139, 77.2090) or your preferred default
      _currentPosition = Position(
          latitude: 28.6139,
          longitude: 77.2090,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found. Using default location."))
    );
  }

  Future<void> _fetchNearbyPoliceStations(double lat, double lng) async {
    print("🔍 Fetching nearby police stations for location: ($lat, $lng)");

    try {
      // Using NEW Places API
      final String url = 'https://places.googleapis.com/v1/places:searchNearby';
      
      final requestBody = json.encode({
        "includedTypes": ["police"],
        "maxResultCount": 10,
        "locationRestriction": {
          "circle": {
            "center": {
              "latitude": lat,
              "longitude": lng
            },
            "radius": 2000.0
          }
        }
      });

      print("🌐 API URL: $url");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': googleApiKey,
          'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.location,places.id',
        },
        body: requestBody,
      );

    print("📡 Response status: ${response.statusCode}");
    print("📄 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['places'] != null && data['places'].isNotEmpty) {
        print("✅ Found ${data['places'].length} police stations");

        double minDistance = double.infinity;
        Map<String, dynamic>? nearestPlace;

        for (var place in data['places']) {
          try {
            final placeLat = place['location']?['latitude'];
            final placeLng = place['location']?['longitude'];
            final name = place['displayName']?['text'] ?? 'Unknown Police Station';
            final vicinity = place['formattedAddress'] ?? 'No address';
            final placeId = place['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';

            if (placeLat == null || placeLng == null) {
              print("⚠️ Skipping place with missing location data");
              continue;
            }

            final distance = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              placeLat,
              placeLng,
            );

            print("📍 Station: $name, Vicinity: $vicinity, Distance: ${distance.toStringAsFixed(2)} m");

            // Add blue marker for each
            final marker = Marker(
              markerId: MarkerId(placeId),
              position: LatLng(placeLat, placeLng),
              infoWindow: InfoWindow(
                title: name,
                snippet: vicinity,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            );

            setState(() => _markers.add(marker));

            if (distance < minDistance) {
              minDistance = distance;
              nearestPlace = place;
            }
          } catch (e) {
            print("⚠️ Error processing place: $e");
            continue;
          }
        }

        if (nearestPlace != null) {
          final nearestLat = nearestPlace['location']?['latitude'];
          final nearestLng = nearestPlace['location']?['longitude'];
          final nearestName = nearestPlace['displayName']?['text'] ?? 'Nearest Police Station';
          final nearestAddress = nearestPlace['formattedAddress'] ?? 'No address';

          if (nearestLat != null && nearestLng != null) {
            print("🎯 Nearest police station: $nearestName at ($nearestLat, $nearestLng)");

          // Add RED marker for nearest
          final nearestMarker = Marker(
            markerId: MarkerId('nearest'),
            position: LatLng(nearestLat, nearestLng),
            infoWindow: InfoWindow(
              title: '🚨 Nearest Police Station',
              snippet: nearestAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );

          setState(() => _markers.add(nearestMarker));

          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(nearestLat, nearestLng), 15),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Nearest: $nearestName"),
              duration: Duration(seconds: 3),
            ),
          );
          } else {
            print("⚠️ Nearest place has missing location data.");
          }
        } else {
          print("⚠️ No nearest place found.");
        }
      } else {
        print("❌ No police stations found in API response.");
      }
    } else {
      print("❌ Failed to fetch places: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
    } catch (e) {
      print("❌ Error fetching police stations: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load police stations")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
