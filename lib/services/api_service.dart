import 'dart:convert';

import 'package:http/http.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/result.dart';

class ApiService {
  final Client _client;
  final String _googleApiKey = "AIzaSyB1v58k0o8ROj9lE_y5780lPC_CqBLD_kc";

  ApiService(this._client);

  Future<Result<NearbySearchResponse, String>> getGoogleNearbySearch(
    double latitude,
    double longitude,
  ) async {
    var response = await _client.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude%2C$longitude&radius=1&key=$_googleApiKey"));

    if (response.statusCode == 200) {
      print(jsonDecode(response.body) as Map<String, dynamic>);
      return Result(success: NearbySearchResponse());
    } else if (response.statusCode == 204) {
      return Result(failure: "Oops");
    }
    return Result(failure: "Crap");
  }
}
