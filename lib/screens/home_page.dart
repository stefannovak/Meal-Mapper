import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealmapper/bloc/bloc/map_bloc.dart';
import 'package:mealmapper/screens/detailed_bottom_sheet.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _controller;
  late double userLatitude;
  late double userLongitude;

  Set<Marker> markers = HashSet<Marker>();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MapBloc>(context).add(const GetCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FetchedNearbyArea) {
            print("Fetched");
            state.nearbySearchResponse.results?.forEach(
              (area) => markers.add(
                Marker(
                  markerId: MarkerId(area.placeId),
                  position: LatLng(
                    area.geometry.location.lat,
                    area.geometry.location.lng,
                  ),
                  infoWindow: InfoWindow(title: area.name),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                  onTap: () async {
                    await _controller?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            area.geometry.location.lat - 0.005,
                            area.geometry.location.lng,
                          ),
                          zoom: await _controller?.getZoomLevel() ?? 16,
                        ),
                      ),
                    );

                    // ignore: use_build_context_synchronously
                    showBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return DetailedBottomSheet(area: area);
                      },
                    );
                  },
                ),
              ),
            );

            return _buildMap();
          }

          if (state is FetchedLocation) {
            userLatitude = state.latitude;
            userLongitude = state.longitude;
            return _buildMap();
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMap() {
    return SafeArea(
      child: GoogleMap(
        mapType: MapType.hybrid,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(userLatitude, userLongitude),
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
    );
  }
}
