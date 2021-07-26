// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crime_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrimeLocation _$CrimeLocationFromJson(Map<String, dynamic> json) {
  return CrimeLocation(
    json['name'] as String,
    json['address'] as String,
    json['reportNumber'] as int,
    json['crimeImage'] as String,
    (json['lat'] as num).toDouble(),
    (json['lng'] as num).toDouble(),
  );
}

Map<String, dynamic> _$CrimeLocationToJson(CrimeLocation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'reportNumber': instance.reportNumber,
      'crimeImage': instance.crimeImage,
    };
