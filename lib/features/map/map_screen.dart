import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart' hide Marker;

class MapScreen extends StatefulWidget {
  final String pickup;
  final String drop;

  const MapScreen({super.key, required this.pickup, required this.drop});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  Position? lastPosition;
  StreamSubscription<Position>? positionStream;
  double travelledDistance = 0.0;
bool rideStarted = false;

  List<LatLng> routePoints = [];

  bool isLoading = true;

@override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadLocations();
  }


  LatLng? parseLatLng(String value) {
    try {
      final parts = value.split(",");
      if (parts.length == 2) {
        return LatLng(double.parse(parts[0]), double.parse(parts[1]));
      }
    } catch (e) {
      debugPrint("Parse error: $e");
    }
    return null;
  }

  Future<void> fetchRoute() async {
    try {
      final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/"
        "${pickupLatLng!.longitude},${pickupLatLng!.latitude};"
        "${dropLatLng!.longitude},${dropLatLng!.latitude}"
        "?overview=full&geometries=geojson",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final coords = data["routes"][0]["geometry"]["coordinates"] as List;

        routePoints = coords.map<LatLng>((point) {
          return LatLng(point[1], point[0]);
        }).toList();

        setState(() {});
      }
    } catch (e) {
      debugPrint("Route error: $e");
    }
  }

  Future<void> loadLocations() async {
    pickupLatLng = parseLatLng(widget.pickup);
    dropLatLng = parseLatLng(widget.drop);

    print("Pickup: $pickupLatLng");
    print("Drop: $dropLatLng");

    if (pickupLatLng != null && dropLatLng != null) {
      await fetchRoute();
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> requestPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}

Future<void> startRide() async {
  setState(() {
    rideStarted = true;
    travelledDistance = 0;
  });
  await requestPermission();

  positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen((Position position) {
    if (!rideStarted) return;

    final current = LatLng(position.latitude, position.longitude);

    if (lastPosition != null) {
      final distance = Distance();

      travelledDistance += distance(
        LatLng(lastPosition!.latitude, lastPosition!.longitude),
        current,
      );

      setState(() {});
    }

    lastPosition = position;
  });
}

void cancelRide() {
  rideStarted = false;

  positionStream?.cancel();
  positionStream = null;

  travelledDistance = 0;

  Navigator.pop(context);
}


void showCancelLoaderAndNavigate() {
  rideStarted = false;
  positionStream?.cancel();
  positionStream = null;

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Center(
        child: Lottie.asset(
          'assets/lottie/cancel.json',
          width: 150,
          height: 150,
        ),
      );
    },
  );

  Future.delayed(const Duration(seconds: 3), () {
    Navigator.pop(context);

    Navigator.pop(context);
  });
}


  @override
  Widget build(BuildContext context) {
    if (isLoading || pickupLatLng == null || dropLatLng == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: pickupLatLng!, initialZoom: 6),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.intern',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: pickupLatLng!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  Marker(
                    point: dropLatLng!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),

              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Column(
                  children: [

                    Text(
  "Distance travelled : ${(travelledDistance / 1000).toStringAsFixed(2)} KM",
  style: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
),
                              SizedBox(height: 10,),
                    InkWell(
                      onTap: (){
                        if(!rideStarted){
                          startRide();
                        }
                        print("ride started");
                        startRide();
                      },
                      child:rideStarted ? Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.orange,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Ride started",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              
                            ),SizedBox(width:5),SizedBox(
                              height: 45,
                              width: 45,
                              child: Lottie.asset('assets/lottie/scooter_riding.json'),
                            )
                          ],
                          
                        ),
                      ) :Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFF38B000),
                        ),
                        child: Center(
                          child: Text(
                            "Start Ride",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                       onTap: (){
                        print("ride cancelled");
                        showCancelLoaderAndNavigate();
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color.fromARGB(255, 176, 0, 0),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel Ride",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
