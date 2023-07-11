import "package:json_annotation/json_annotation.dart";

part "image.g.dart";

@JsonSerializable()
class Image {
  final int width;
  final int height;
  final String url;

  const Image(this.width, this.height, this.url);

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}
