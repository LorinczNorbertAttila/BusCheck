import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class TimeService {
  int currentTime = 5; // Kezdeti idő 5 perc

  void addTime() {
    if (currentTime < 15) {
      currentTime += 5;
    }
  }
}

//main
void main() {
  runApp(MyApp());
}

//ez inditja a map screent 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

//ez jelenit meg a terkepet es a vezerlo ellemeket/gombok
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}


//állapotkezelő osztálya, ahol a térkép és a vezérlő elemek kezelése történik.
class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? currentPosition;
  TimeService timeService = TimeService(); // Új időszolgáltatás példány létrehozása

  Set<Marker> markers = {};
  bool showUserTimeMarker = false;

  List<LatLng> busStopLocations = [
    LatLng(46.523367, 24.598844),
    LatLng(46.5434832, 24.5338982),
    LatLng(46.5461918, 24.5531005),
    LatLng(46.5395414, 24.5447104),
    LatLng(46.537588, 24.5474658),
    LatLng(46.5329167, 24.5177478),
    LatLng(46.533441, 24.5314163),
    LatLng(46.5334121, 24.5281571),
    LatLng(46.5376421, 24.4692577),
    LatLng(46.5347231, 24.546086),
  ];

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

//terkep widget
//terkep letrehozasa 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Geolocation'),
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
                  tooltip: 'Get Location',
                  child: Icon(Icons.location_searching),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    _addUserTime();
                  },
                  tooltip: 'Add Time',
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
    });
  }

  void _addUserTime() {
    setState(() {
      if (!showUserTimeMarker) {
        // Ha még nincs "User Time" pin, akkor létrehozzuk és elindítjuk az időzítőt
        showUserTimeMarker = true;
        _updateMarkers();

        timer = Timer.periodic(Duration(minutes: 1), (timer) {
          if (timeService.currentTime <= 0) {
            // Az idő lejárt, eltávolítjuk a "User Time" markert és leállítjuk az időzítőt
            showUserTimeMarker = false;
            _updateMarkers();
            timer.cancel();
          } else {
            timeService.currentTime -= 1;
            _updateMarkers();
          }
        });
      } else {
        // Ha már van "User Time" pin, csak frissítjük az időt
        timeService.addTime();
        _updateMarkers();
      }
    });
  }

  void _updateMarkers() {
    setState(() {
      markers.clear();

      for (int i = 0; i < busStopLocations.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId("BusStop $i"),
            position: busStopLocations[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: "Bus Stop",
              snippet: "Stop #$i",
            ),
          ),
        );
      }

      if (currentPosition != null) {
        markers.add(
          Marker(
            markerId: MarkerId("currentLocation"),
            position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
            infoWindow: InfoWindow(title: "Your Location"),
          ),
        );

        if (showUserTimeMarker && timeService.currentTime > 0) {
          markers.add(
            Marker(
              markerId: MarkerId("userTime"),
              position: LatLng(currentPosition!.latitude + 0.001, currentPosition!.longitude + 0.001),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
              infoWindow: InfoWindow(
                title: "User Time",
                snippet: "Time Remaining: ${timeService.currentTime} minutes",
              ),
            ),
          );
        }
      }
    });
  }

  void _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentPosition = position;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );

      _updateMarkers();
    });
  }
}