import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';


// Class TimeService  give time to markel 
class TimeService {
  int currentTime = 5;

  void addTime() {
    if (currentTime < 15) {
      currentTime += 5;
    }
  }
}

// Class MapData stores data for the map, using ChangeNotifier
class MapData with ChangeNotifier {
  Position? currentPosition;
  List<LatLng?> busStopLocations = [];
  List<String?> busStopNames = [];

// Function to update data
  void updateData({
    required Position currentPosition,
    required List<LatLng?> busStopLocations,
    required List<String?> busStopNames,
  }) {
    this.currentPosition = currentPosition;
    this.busStopLocations = busStopLocations;
    this.busStopNames = busStopNames;

    notifyListeners();
  }
}

// Class MapScreen1 displays the map
class MapScreen1 extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen1> {
  GoogleMapController? mapController;
  Position? currentPosition;
  TimeService timeService = TimeService();
  List<String?> busStopNames = []; 
  Set<Marker> markers = {};
  bool showUserTimeMarker = false;

  List<LatLng?> busStopLocations = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadBusStopLocations();
  }

 // Check and handle location permission
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      if (status.isDenied) {
        _showPermissionDeniedDialog();
      } else {
        var result = await Permission.location.request();

        if (result.isGranted) {
          print('Permission granted');
        } else {
          _showPermissionDeniedDialog();
        }
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission denied"),
          content: Text("The application requires location permission to function."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("I understand"),
            ),
          ],
        );
      },
    );
  }

// Load bus stop locations from Firestore
  Future<void> _loadBusStopLocations() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Bus stops').get();

      if (snapshot.docs.isNotEmpty) {
        final List<LatLng?> busStopLocations = snapshot.docs.map((doc) {
          try {
            final double? latitude = doc['Latitude'] != null ? double.tryParse(doc['Latitude'] as String) : null;
            final double? longitude = doc['Longitude'] != null ? double.tryParse(doc['Longitude'] as String) : null;
            final String? name = doc['Name'] != null ? doc['Name'] as String : "";

            if (latitude != null && longitude != null && name != null && name.isNotEmpty) {
              print('Buszmegálló szélessége: $latitude, hosszúsága: $longitude, Név: $name');
              busStopNames.add(name);
              return LatLng(latitude, longitude);
            } else {
              print('Missing or invalid data in the Firestore document: $doc');
              return null;
            }
          } catch (e) {
            print('Error processing Firestore data: $e');
            return null;
          }
        }).where((location) => location != null).toList();

        print('Buszmegállók pozíciói: $busStopLocations');

        setState(() {
          this.busStopLocations = busStopLocations;
          _updateMarkers();
        });
      } else {
        print('Nincsenek buszmegállók a Firestore-ban.');
      }
    } catch (e) {
      print('Hiba a buszmegállók betöltésekor: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0.0, 0.0),
              zoom: 1.0,
            ),
            myLocationEnabled: false,
            markers: markers,
          ),
          Positioned(
            top: 350.0,
            right: 5.0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _getLocation();
                  },
                  tooltip: 'Specify location',
                  child: Icon(Icons.location_searching),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    _addUserTime();
                  },
                  tooltip: 'Add time',
                  child: Icon(Icons.timer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Operations after map creation
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      markers.add(
        Marker(
          markerId: MarkerId("SampleMarker"),
          position: LatLng(0.0, 0.0),
          infoWindow: InfoWindow(title: "Sample Marker"),
        ),
      );

      _updateMarkers();

      _getLocation();
    });
  }

 // Add or update user time
  void _addUserTime() {
    setState(() {
      if (!showUserTimeMarker) {
        showUserTimeMarker = true;
        _updateMarkers();

        timer = Timer.periodic(Duration(minutes: 1), (timer) {
          if (timeService.currentTime <= 0) {
            showUserTimeMarker = false;
            _updateMarkers();
            timer.cancel();
          } else {
            timeService.currentTime -= 1;
            _updateMarkers();
          }
        });
      } else {
        timeService.addTime();
        _updateMarkers();
      }
    });
  }

 // Update markers
  void _updateMarkers() {
    setState(() {
      markers.clear();

      for (int i = 0; i < busStopLocations.length; i++) {
        if (busStopLocations[i] != null) {
          markers.add(
            Marker(
              markerId: MarkerId("Station $i"),
              position: busStopLocations[i]!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                title: busStopNames[i]!,
                snippet: "Bus Stop #$i",
              ),
            ),
          );
        }
      }

      if (currentPosition != null) {
        markers.add(
          Marker(
            markerId: MarkerId("aktuálisHely"),
            position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
            infoWindow: InfoWindow(title: "Your current location"),
          ),
        );

        if (showUserTimeMarker && timeService.currentTime > 0) {
          markers.add(
            Marker(
              markerId: MarkerId("ControllerTime"),
              position: LatLng(currentPosition!.latitude + 0.001, currentPosition!.longitude + 0.001),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
              infoWindow: InfoWindow(
                title: "Controller",
                snippet: "Remaining time: ${timeService.currentTime} min",
              ),
            ),
          );
        }
      }
    });
  }

 // Get current location
  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Aktuális hely: $position');

      setState(() {
        currentPosition = position;

        if (showUserTimeMarker) {
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0,
              ),
            ),
          );
        } else {
          _updateMarkers();
        }
      });
    } catch (e) {
      print('Hiba az aktuális hely lekérdezésekor: $e');
    }
  }
}