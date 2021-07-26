import 'package:crime_alert/model/crime_location.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class CrimeAlertEvent extends Equatable {
  CrimeAlertEvent();
}

class CrimeAlertStartEvent extends CrimeAlertEvent {
  @override
  List<Object> get props => List.empty();
}

class LocationSelectedEvent extends CrimeAlertEvent {
  LocationSelectedEvent({required this.destination});
  final LatLng destination;

  @override
  List<Object> get props => [destination];
}

class DetailsSubmittedEvent extends CrimeAlertEvent {
  DetailsSubmittedEvent(
      {required this.location,});
  
  final CrimeLocation location;

  @override
  List<Object> get props => [location];
}

class CrimeAlertSelectedEvent extends CrimeAlertEvent {
  CrimeAlertSelectedEvent(
      {required this.location,});
  
  final CrimeLocation location;

  @override
  List<Object> get props => [location];
}

class BackPressedEvent extends CrimeAlertEvent {
  @override
  List<Object> get props => List.empty();
}

class CrimeAlertCancelEvent extends CrimeAlertEvent {
  @override
  List<Object> get props => List.empty();
}
