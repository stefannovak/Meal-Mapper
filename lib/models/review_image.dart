class ReviewImage {
  late String path;
  late String name;

  ReviewImage(this.path, this.name);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['name'] = name;
    return data;
  }

  ReviewImage.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    name = json['name'];
  }
}
