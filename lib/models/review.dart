import 'package:mealmapper/models/google/nearby_search_response.dart';

class Review {
  late double rating;
  late String summary;
  late NearbySearchResponseResult area;

  Review(
    this.rating,
    this.summary,
    this.area,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['summary'] = summary;
    data['area'] = area.toJson();
    return data;
  }

  Review.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    summary = json['summary'];
    area = NearbySearchResponseResult.fromJson(json['area']);
  }
}
