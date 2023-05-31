import 'package:mealmapper/models/google/nearby_search_response.dart';

class GoogleTextSearchResponse {
  List<SearchResponseResults>? results;
  String? status;

  GoogleTextSearchResponse({this.results, this.status});

  GoogleTextSearchResponse.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <SearchResponseResults>[];
      json['results'].forEach((v) {
        results!.add(new SearchResponseResults.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class SearchResponseResults {
  String? formattedAddress;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;
  String? placeId;
  String? reference;
  List<String>? types;

  SearchResponseResults(
      {this.formattedAddress,
      this.geometry,
      this.icon,
      this.iconBackgroundColor,
      this.iconMaskBaseUri,
      this.name,
      this.placeId,
      this.reference,
      this.types});

  SearchResponseResults.fromJson(Map<String, dynamic> json) {
    formattedAddress = json['formatted_address'];
    geometry = json['geometry'] != null
        ? new Geometry.fromJson(json['geometry'])
        : null;
    icon = json['icon'];
    iconBackgroundColor = json['icon_background_color'];
    iconMaskBaseUri = json['icon_mask_base_uri'];
    name = json['name'];
    placeId = json['place_id'];
    reference = json['reference'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['formatted_address'] = this.formattedAddress;
    if (this.geometry != null) {
      data['geometry'] = this.geometry!.toJson();
    }
    data['icon'] = this.icon;
    data['icon_background_color'] = this.iconBackgroundColor;
    data['icon_mask_base_uri'] = this.iconMaskBaseUri;
    data['name'] = this.name;
    data['place_id'] = this.placeId;
    data['reference'] = this.reference;
    data['types'] = this.types;
    return data;
  }
}
