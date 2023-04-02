import 'dart:convert';

import 'package:http/http.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/result.dart';

class ApiService {
  final Client _client;
  final String _googleApiKey = "AIzaSyB1v58k0o8ROj9lE_y5780lPC_CqBLD_kc";

  ApiService(this._client);

  /// Radius is in meters.
  Future<Result<NearbySearchResponse, String>> getGoogleNearbySearch(
    double latitude,
    double longitude, {
    int? radius = 10,
  }) async {
    var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
        "location=$latitude%2C$longitude" +
        "&radius=$radius" +
        "&type=restaurant|bar" +
        "&key=$_googleApiKey";

    var response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var nearbySearchResponse = NearbySearchResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
      return Result(success: nearbySearchResponse);
    }
    return Result(failure: "Crap");
  }
}
