class Review {
  late int rating;
  late String summary;
  late String placeId;
  late double latitude;
  late double longitude;

  Review(
    this.rating,
    this.summary,
    this.placeId,
    this.latitude,
    this.longitude,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['summary'] = summary;
    data['placeId'] = placeId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }

  Review.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    summary = json['summary'];
    placeId = json['placeId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }
}
