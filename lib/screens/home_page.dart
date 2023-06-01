import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/models/google/google_text_search_response.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/screens/authentication_screen.dart';
import 'package:mealmapper/screens/detailed_bottom_sheet.dart';
import 'package:mealmapper/screens/profile_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _controller;
  double? _userLatitude;
  double? _userLongitude;
  bool _isSearchBarActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Review>? reviews;

  Set<Marker> markers = HashSet<Marker>();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FirebaseBloc>(context).add(GetUserPinsOnLoad());
    BlocProvider.of<MapBloc>(context).add(const GetCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<FirebaseBloc, FirebaseState>(
        listener: (context, state) async {
          if (state is UnauthenticatedUserError) {
            await showDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                  title: Text("Something went wrong"),
                  actions: [
                    TextButton(
                      child: const Text('Okay'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );

            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AuthenticationScreen(),
                ),
              );
            }
          }
          if (state is FetchedUserSavedPins) {
            reviews = state.reviews;
            for (var review in state.reviews) {
              var existingMarker = markers.firstWhere(
                (x) => x.markerId.value == review.area.placeId,
                orElse: () => const Marker(
                  markerId: MarkerId("-1"),
                ),
              );

              setState(() {
                if (existingMarker.markerId.value == "-1") {
                  markers.add(
                    _createSavedMarker(review, context),
                  );
                  return;
                }

                markers.remove(existingMarker);
                markers.add(
                  _createSavedMarker(review, context),
                );
              });
            }
          }
        },
        child: BlocConsumer<MapBloc, MapState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is FetchedSearchResponse) {
              for (var response in state.response.results!) {
                markers.add(
                  Marker(
                    markerId: MarkerId(response.placeId ?? "-1"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueMagenta),
                    position: LatLng(
                      response.geometry?.location?.lat ?? 0,
                      response.geometry?.location?.lng ?? 0,
                    ),
                    infoWindow: InfoWindow(title: response.name),
                    onTap: () async {
                      await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return DetailedBottomSheet(
                            area: NearbySearchResponseResult(
                              geometry: response.geometry!,
                              placeId: response.placeId ?? "-1",
                              name: response.name,
                              rating: 4.1,
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              var future = _controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                        state.response.results![0].geometry?.location?.lat ??
                            0.005 - 0.005,
                        state.response.results![0].geometry?.location?.lng ??
                            0),
                    zoom: 16,
                  ),
                ),
              );

              return _userLatitude != null && _userLongitude != null
                  ? _buildMap(_userLatitude!, _userLongitude!, future: future)
                  : const Center(child: CircularProgressIndicator());
            }

            if (state is FetchedNearbyArea) {
              print("Fetched");

              var area = state.nearbySearchResponse.results!.first;

              // TODO: - Future problem, clicked near the marker shows an unreviewed version of that marker.
              // try {
              //   var existingMarker = markers.firstWhere(
              //     (x) => x.markerId.value == area.placeId,
              //   );
              // } catch (e) {}

              _controller
                  ?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      area.geometry.location.lat - 0.005,
                      area.geometry.location.lng,
                    ),
                    zoom: 16,
                  ),
                ),
              )
                  .then((value) {
                var future = showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return DetailedBottomSheet(area: area);
                  },
                );

                future.then((value) async {
                  await _controller?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          area.geometry.location.lat,
                          area.geometry.location.lng,
                        ),
                        zoom: await _controller?.getZoomLevel() ?? 16,
                      ),
                    ),
                  );
                });
              });

              return _userLatitude != null && _userLongitude != null
                  ? _buildMap(_userLatitude!, _userLongitude!)
                  : const Center(child: CircularProgressIndicator());
            }

            if (state is FetchedLocation) {
              _userLatitude = state.latitude;
              _userLongitude = state.longitude;
              return _buildMap(state.latitude, state.longitude);
            }

            if (state is UpdateMapWithNewReview) {
              markers.add(
                _createSavedMarker(state.review, context),
              );

              // var existingMarker = markers.firstWhere(
              //   (x) => x.markerId.value == state.review.area.placeId,
              // );

              // markers.remove(existingMarker);
              // markers.add(
              //   _createSavedMarker(state.review, context),
              // );

              return _userLatitude != null && _userLongitude != null
                  ? _buildMap(_userLatitude!, _userLongitude!)
                  : const Center(child: CircularProgressIndicator());
            }

            return _userLatitude != null && _userLongitude != null
                ? _buildMap(_userLatitude!, _userLongitude!)
                : const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  //SECTION - Private Methods

  Marker _createLocalMarker(
    NearbySearchResponseResult area,
    BuildContext context,
  ) {
    return Marker(
      markerId: MarkerId(area.placeId),
      position: LatLng(
        area.geometry.location.lat,
        area.geometry.location.lng,
      ),
      infoWindow: InfoWindow(title: area.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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
        var future = showModalBottomSheet(
          backgroundColor: Colors.transparent,
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return DetailedBottomSheet(area: area);
          },
        );

        future.then((value) async {
          await _controller?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  area.geometry.location.lat,
                  area.geometry.location.lng,
                ),
                zoom: await _controller?.getZoomLevel() ?? 16,
              ),
            ),
          );

          print(value);
        });
      },
    );
  }

  Marker _createSavedMarker(
    Review review,
    BuildContext context,
  ) {
    return Marker(
      markerId: MarkerId(review.area.placeId),
      position: LatLng(
        review.area.geometry.location.lat,
        review.area.geometry.location.lng,
      ),
      infoWindow: InfoWindow(title: review.area.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () async {
        await _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                review.area.geometry.location.lat - 0.005,
                review.area.geometry.location.lng,
              ),
              zoom: await _controller?.getZoomLevel() ?? 16,
            ),
          ),
        );

        // ignore: use_build_context_synchronously
        var future = showModalBottomSheet(
          backgroundColor: Colors.transparent,
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return DetailedBottomSheet(area: review.area, review: review);
          },
        );

        future.then(
          (value) async => await _controller?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  review.area.geometry.location.lat,
                  review.area.geometry.location.lng,
                ),
                zoom: await _controller?.getZoomLevel() ?? 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMap(
    double latitude,
    double longitude, {
    Future<void>? future,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Mapper"),
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(reviews: reviews),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearchBarActive) {
            setState(() {
              _isSearchBarActive = false;
              FocusScope.of(context).requestFocus(FocusNode());
            });
          }
        },
        child: Stack(
          children: [
            FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                return GoogleMap(
                  mapType: MapType.hybrid,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _controller = controller;
                  },
                  markers: markers,
                  onTap: (loc) async {
                    if (!_isSearchBarActive) {
                      print("ONTAP");
                      BlocProvider.of<MapBloc>(context).add(
                        UserClickedMap(loc.latitude, loc.longitude),
                      );
                    }
                  },
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _searchFocusNode.unfocus(),
                child: AnimatedContainer(
                  padding: EdgeInsets.zero,
                  duration: const Duration(milliseconds: 100),
                  height: 80,
                  child: Container(
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onEditingComplete: () {
                              _searchFocusNode.unfocus();

                              if (_searchController.text.isNotEmpty &&
                                  _userLatitude != null &&
                                  _userLongitude != null) {
                                BlocProvider.of<MapBloc>(context).add(
                                  UserSearchedLocation(
                                    _searchController.text,
                                    _userLatitude!,
                                    _userLongitude!,
                                  ),
                                );
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Search',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isSearchBarActive = !_isSearchBarActive;
                                    if (_isSearchBarActive) {
                                      FocusScope.of(context)
                                          .requestFocus(_searchFocusNode);
                                    } else {
                                      _searchFocusNode.unfocus();
                                    }
                                  });

                                  if (_searchController.text.isNotEmpty &&
                                      _userLatitude != null &&
                                      _userLongitude != null) {
                                    BlocProvider.of<MapBloc>(context).add(
                                      UserSearchedLocation(
                                        _searchController.text,
                                        _userLatitude!,
                                        _userLongitude!,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.search),
                              ),
                            ),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
