import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class TimeService {
  int currentTime = 5; // Kezdeti idő 5 perc
  late Timer timer;

  void startTimer(Function callback) {
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (currentTime > 0) {
        currentTime--;
        callback();
      } else {
        timer.cancel();
      }
    });
  }

  void addTime() {
    if (currentTime < 15) {
      currentTime += 5;
    }
  }
}



class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? currentPosition;
  TimeService timeService = TimeService(); // Új időszolgáltatás példány létrehozása

  bool showUserTimeMarker = false;

  List<LatLng> busStopLocations = [
    const LatLng(46.523367, 24.598844),
    const LatLng(46.5434832, 24.5338982),
    const LatLng(46.5461918, 24.5531005),
    const LatLng(46.5395414, 24.5447104),
    const LatLng(46.537588, 24.5474658),
    const LatLng(46.5329167, 24.5177478),
    const LatLng(46.533441, 24.5314163),
    const LatLng(46.5334121, 24.5281571),
    const LatLng(46.5376421, 24.4692577),
    const LatLng(46.5347231, 24.546086),
  ];

  @override
  void initState() {
    super.initState();
    timeService.startTimer(_updateMarkers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Geolocation'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0.0, 0.0),
              zoom: 1.0,
            ),
            myLocationEnabled: false,
            markers: _createMarkers(),
          ),
          Positioned(
            top: 350.0,
            right: 5.0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  tooltip: 'Get Location',
                  child: const Icon(Icons.location_searching),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _addTime,
                  tooltip: 'Add Time',
                  child: const Icon(Icons.timer),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _toggleUserTimeMarker,
                  tooltip: 'Show User Time',
                  child: const Icon(Icons.location_on),
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

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

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
          markerId: const MarkerId("currentLocation"),
          position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
    }

    if (showUserTimeMarker && currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("userTime"),
          position: LatLng(currentPosition!.latitude + 0.001, currentPosition!.longitude + 0.001),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
          infoWindow: InfoWindow(
            title: "User Time",
            snippet: "Time Remaining: ${timeService.currentTime} minutes",
          ),
        ),
      );
    }

    return markers;
  }

  void _getCurrentLocation() async {
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
    });
  }

  void _addTime() {
    setState(() {
      timeService.addTime();
      _updateMarkers();
    });
  }

  void _toggleUserTimeMarker() {
    setState(() {
      showUserTimeMarker = !showUserTimeMarker;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    setState(() {});
  }
}