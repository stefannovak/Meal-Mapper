import 'package:image_picker/image_picker.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/review_image.dart';

class Review {
  late double rating;
  late String summary;
  late NearbySearchResponseResult area;
  List<ReviewImage> images = [];

  Review(
    this.rating,
    this.summary,
    this.area,
    this.images,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['summary'] = summary;
    data['area'] = area.toJson();
    data['images'] = images.map((e) => e.toJson()).toList();
    return data;
  }

  Review.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    summary = json['summary'];
    area = NearbySearchResponseResult.fromJson(json['area']);
    json['images'].forEach((e) => images.add(ReviewImage.fromJson(e)));
  }
}
