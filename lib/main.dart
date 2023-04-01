import 'dart:async';
import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:mealmapper/bloc/bloc/map_bloc.dart';
import 'package:mealmapper/firebase_options.dart';
import 'package:mealmapper/services/api_service.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Client httpClient;
  late ApiService apiService;

  @override
  void initState() {
    httpClient = Client();
    apiService = ApiService(httpClient);
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(create: (context) => MapBloc(apiService)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> markers = HashSet<Marker>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is FetchedPlaceDetails) {
          print("Fetched");
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: FutureBuilder(
            future: _determinePosition(),
            builder: (context, snapshot) {
              if (snapshot.data?.latitude != null &&
                  snapshot.data?.longitude != null) {
                return GoogleMap(
                  mapType: MapType.hybrid,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        snapshot.data!.latitude, snapshot.data!.longitude),
                    zoom: 10,
                  ),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  markers: markers,
                  onTap: (loc) async {
                    print(loc.latitude);
                    print(loc.longitude);
                    BlocProvider.of<MapBloc>(context)
                        .add(UserClickedMap(loc.latitude, loc.longitude));
                  },
                  onLongPress: (loc) {
                    var marker = Marker(
                      markerId: MarkerId(loc.latitude.toString()),
                      position: LatLng(loc.latitude, loc.longitude),
                      infoWindow: InfoWindow(title: "test"),
                    );
                    setState(() {
                      markers.add(marker);
                    });
                  },
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        );
      },
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
