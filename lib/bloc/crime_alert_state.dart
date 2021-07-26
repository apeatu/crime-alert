import 'package:crime_alert/model/crime_location.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class CrimeAlertState extends Equatable {
  CrimeAlertState();
}

class CrimeAlertNotInitializedState extends CrimeAlertState {
  CrimeAlertNotInitializedState();
  @override
  List<Object> get props => List.empty();
}

class CrimeAlertNotSelectedState extends CrimeAlertState {
  CrimeAlertNotSelectedState({required this.crimeLocations, required this.currentLocation});
  final List<CrimeLocation> crimeLocations;
  final LatLng currentLocation;

  @override
  List<Object> get props => [crimeLocations, currentLocation];
}

class DetailsNotFilledState extends CrimeAlertState {
  DetailsNotFilledState();

  @override
  List<Object> get props => [];
}

class CrimeAlertCancelledState extends CrimeAlertState {
  @override
  List<Object> get props => List.empty();
}

class CrimeAlertLoadingState extends CrimeAlertState {
  CrimeAlertLoadingState({required this.state});
  final CrimeAlertState state;

  @override
  List<Object> get props => [state];
}
