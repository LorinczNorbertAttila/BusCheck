import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeService {
  int currentTime = 5;

  void addTime() {
    if (currentTime < 15) {
      currentTime += 5;
    }
  }
}



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? currentPosition;
  TimeService timeService = TimeService();

  Set<Marker> markers = {};
  bool showUserTimeMarker = false;

  List<LatLng?> busStopLocations = [];
  List<String?> busStopNames = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadBusStopLocations();
  }

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
              print('Hiányzó vagy érvénytelen adatok a Firestore dokumentumban: $doc');
              return null;
            }
          } catch (e) {
            print('Hiba a Firestore adatok feldolgozásakor: $e');
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
      appBar: AppBar(
        title: Text('Térkép a Geolokációval'),
      ),
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
            top: 450.0,
            right: 5.0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _getLocation();
                  },
                  tooltip: 'Hely megadása',
                  child: Icon(Icons.location_searching),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    _addUserTime();
                  },
                  tooltip: 'Idő hozzáadása',
                  child: Icon(Icons.timer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      // Helyezzünk el egy egyszerű markert a térképen
      markers.add(
        Marker(
          markerId: MarkerId("SampleMarker"),
          position: LatLng(0.0, 0.0),
          infoWindow: InfoWindow(title: "Sample Marker"),
        ),
      );

      // Frissítsük a markereket
      _updateMarkers();
    });
  }

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

  void _updateMarkers() {
    setState(() {
      markers.clear();

      for (int i = 0; i < busStopLocations.length; i++) {
        if (busStopLocations[i] != null) {
          markers.add(
            Marker(
              markerId: MarkerId("Buszmegálló $i"),
              position: busStopLocations[i]!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                title: busStopNames[i]!, // Buszmegálló nevének megjelenítése címként
                snippet: "Megálló #$i",
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
            infoWindow: InfoWindow(title: "Az aktuális helyed"),
          ),
        );

        if (showUserTimeMarker && timeService.currentTime > 0) {
          markers.add(
            Marker(
              markerId: MarkerId("userTime"),
              position: LatLng(currentPosition!.latitude + 0.001, currentPosition!.longitude + 0.001),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
              infoWindow: InfoWindow(
                title: "Felhasználói idő",
                snippet: "Hátralévő idő: ${timeService.currentTime} perc",
              ),
            ),
          );
        }
      }

      // Térkép frissítése
      if (mapController != null && busStopLocations.isNotEmpty && busStopLocations[0] != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(busStopLocations[0]!));
      }
    });
  }

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
      }

      _updateMarkers();
    });
  } catch (e) {
    print('Hiba az aktuális hely lekérdezésekor: $e');
  }
 }
} 