import 'package:json_annotation/json_annotation.dart';

part 'crime_location.g.dart';

@JsonSerializable()
class CrimeLocation {
  CrimeLocation(
    this.name,
    this.address,
    this.reportNumber,
    this.crimeImage,
    this.lat,
    this.lng,
  );

  factory CrimeLocation.fromJson(Map<String, dynamic> json) =>
      _$CrimeLocationFromJson(json);
  Map<String, dynamic> toJson() => _$CrimeLocationToJson(this);

  final String name;
  final String address;
  final double lat;
  final double lng;
  int reportNumber;
  final String crimeImage;
}
