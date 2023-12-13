import 'dart:async';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

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

class MapScreen extends StatefulWidget {
  final VoidCallback addUserTimeCallback;
  const MapScreen({Key? key, required this.addUserTimeCallback})
      : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late LatLng _currentPosition = const LatLng(0.0, 0.0);
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  Position? currentPosition;
  TimeService timeService = TimeService();
  List<String?> busStopNames = [];
  Set<Marker> markers = {};
  bool showUserTimeMarker = false;
  late String _darkMapStyle;
  late String _lightMapStyle;

  void addUserTimeCallback() {
    _addUserTime();
  }

  List<LatLng?> busStopLocations = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadMapStyles();
    WidgetsBinding.instance.addObserver(this);
    setMapStyle();
    _getCurrentLocation();
    _loadBusStopLocations();
  }

  // Load bus stop locations from Firestore
  Future<void> _loadBusStopLocations() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Bus stops').get();

      if (snapshot.docs.isNotEmpty) {
        final List<LatLng?> busStopLocations = snapshot.docs
            .map((doc) {
              try {
                final double? latitude = doc['Latitude'] != null
                    ? double.tryParse(doc['Latitude'] as String)
                    : null;
                final double? longitude = doc['Longitude'] != null
                    ? double.tryParse(doc['Longitude'] as String)
                    : null;
                final String name =
                    doc['Name'] != null ? doc['Name'] as String : "";

                if (latitude != null && longitude != null && name.isNotEmpty) {
                  print(
                      'Buszmegálló szélessége: $latitude, hosszúsága: $longitude, Név: $name');
                  busStopNames.add(name);
                  return LatLng(latitude, longitude);
                } else {
                  print(
                      'Missing or invalid data in the Firestore document: $doc');
                  return null;
                }
              } catch (e) {
                print('Error processing Firestore data: $e');
                return null;
              }
            })
            .where((location) => location != null)
            .toList();

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

  void addControllerTimeMarker() {
    if (showUserTimeMarker && timeService.currentTime > 0) {
      markers.add(
        Marker(
          markerId: const MarkerId("ControllerTime"),
          position: LatLng(
            currentPosition!.latitude + 0.0001,
            currentPosition!.longitude + 0.0001,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          ),
          infoWindow: InfoWindow(
            title: "Controller",
            snippet: "Remaining time: ${timeService.currentTime} min",
          ),
        ),
      );
    }
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
    // ignore: deprecated_member_use
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
    timer?.cancel();
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
                markers: markers,
              ),
              Positioned(
                top: height * 0.50,
                right: width * 0.02,
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

  // Operations after map creation
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
    });
  }

// Add or update user time
  void _addUserTime() {
    setState(() {
      if (!showUserTimeMarker) {
        showUserTimeMarker = true;
        _updateMarkers();

        timer = Timer.periodic(const Duration(minutes: 1), (timer) {
          if (timeService.currentTime <= 0) {
            showUserTimeMarker = false;
            _updateMarkers();
            timer.cancel();
          } else {
            timeService.currentTime -= 1;
            _updateMarkers();
          }
        });

        // Call the new method to add the "ControllerTime" marker
        addControllerTimeMarker();
      } else {
        timeService.addTime();
        _updateMarkers();
      }
    });

    // Call the callback provided by the parent widget
    widget.addUserTimeCallback();
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
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
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
            markerId: const MarkerId("aktuálisHely"),
            position:
                LatLng(currentPosition!.latitude, currentPosition!.longitude),
            infoWindow: const InfoWindow(title: "Your current location"),
          ),
        );
      }
    });
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
        // Obtain the current position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Check if the obtained position is not null
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

          // Update markers after obtaining the current location
          _updateMarkers();
        });
      } catch (e) {
        // Handle errors while getting the location
        print('Error getting location: $e');
      }
    } else {
      // Show a message or UI indicating that location permission is required
      print('Location permission denied');
    }
  }
}
