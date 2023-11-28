import 'dart:async';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
 
class TimeService {
  int currentTime = 5; 
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
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late LatLng _currentPosition = const LatLng(0.0, 0.0);
  final Completer<GoogleMapController> _controller = Completer();
  Position? currentPosition;
  TimeService timeService =
      TimeService(); // Új időszolgáltatás példány létrehozása
  bool showUserTimeMarker = false;
  late String _darkMapStyle;
  late String _lightMapStyle;

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
    _loadMapStyles();
    WidgetsBinding.instance.addObserver(this);
    setMapStyle();
    _getCurrentLocation();
  }

  Future _loadMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('lib/assets/map_styles/dark.json');
    _lightMapStyle =
        await rootBundle.loadString('lib/assets/map_styles/light.json');
  }

  Future<void> setMapStyle() async {
    final controller = await _controller.future;
    // ignore: use_build_context_synchronously
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = WidgetsBinding.instance.window.platformBrightness;
    if (themeProvider.themeMode == ThemeMode.dark || theme == Brightness.dark) {
      await controller.setMapStyle(_darkMapStyle);
    } else {
      await controller.setMapStyle(_lightMapStyle);
    }
  }

// Inside didChangeDependencies
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setMapStyle();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setMapStyle();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // Inside _MapScreenState build method
    return SizedBox(
      height: height * 0.7,
      width: width,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 16.0,
                ),
                myLocationEnabled: false,
                markers: _createMarkers(),
              ),
              Positioned(
                top: 450.0,
                right: 5.0,
                child: FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  tooltip: 'Get Location',
                  child: const Icon(Icons.location_searching),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
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
          position:
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
    }

    if (showUserTimeMarker && currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("userTime"),
          position: LatLng(currentPosition!.latitude + 0.001,
              currentPosition!.longitude + 0.001),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta),
          infoWindow: InfoWindow(
            title: "User Time",
            snippet: "Time Remaining: ${timeService.currentTime} minutes",
          ),
        ),
      );
    }

    return markers;
  }

  // Check location permission
  Future<bool> _checkLocationPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  void _getCurrentLocation() async {
    GoogleMapController controller = await _controller.future;
    // Check for location permission
    if (await _checkLocationPermission()) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double lat = position.latitude;
        double long = position.longitude;

        LatLng location = LatLng(lat, long);

        setState(() {
          currentPosition = position;
          _currentPosition = location;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0,
              ),
            ),
          );
        });
      } catch (e) {
        // Handle errors while getting the location
        print('Error getting location: $e');
      }
    } else {
      // Show a message or UI indicating that location permission is required
      // You may want to request permission again or guide the user to settings
      print('Location permission denied');
    }
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
