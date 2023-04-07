import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/bloc/map_bloc.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';

class DetailedBottomSheet extends StatefulWidget {
  final NearbySearchResponseResult area;

  const DetailedBottomSheet({super.key, required this.area});

  @override
  State<DetailedBottomSheet> createState() => _DetailedBottomSheetState();
}

class _DetailedBottomSheetState extends State<DetailedBottomSheet> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MapBloc>(context)
        .add(FetchPlaceDetails(widget.area.placeId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is FetchedPlaceDetails) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.area.name ?? "Location",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 8 * 4,
                ),
                Text(
                  "General Rating: ${widget.area.rating}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 8 * 4,
                ),
                Text("Rate this place!"),
                const SizedBox(
                  height: 8 * 4,
                ),
                Text(state.response.result?.formattedAddress ?? "address")
              ],
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.area.name ?? "Location",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 8 * 4,
              ),
              Text(
                "General Rating: ${widget.area.rating}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 8 * 4,
              ),
              Text("Rate this place!"),
              const SizedBox(
                height: 8 * 4,
              ),
              const CircularProgressIndicator(),
            ],
          );
        },
      ),
    );
  }
}
