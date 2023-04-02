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
  GoogleMapController? _controller;

  Set<Marker> markers = HashSet<Marker>();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MapBloc>(context).add(const GetCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is FetchedPlaceDetails) {
          print("Fetched");
        }
      },
      builder: (context, state) {
        if (state is FetchedLocation) {
          return Scaffold(
            body: SafeArea(
              child: GoogleMap(
                mapType: MapType.hybrid,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(state.latitude, state.longitude),
                  zoom: 16,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                },
                markers: markers,
                onTap: (loc) async {
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
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
