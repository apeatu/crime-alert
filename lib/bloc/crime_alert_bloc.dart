import 'package:crime_alert/bloc/crime_alert_event.dart';
import 'package:crime_alert/bloc/crime_alert_state.dart';
import 'package:crime_alert/model/crime_location.dart';
import 'package:crime_alert/resources/firebase_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as Geo;

class CrimeAlertBloc extends Bloc<CrimeAlertEvent, CrimeAlertState> {
  CrimeAlertBloc() : super(CrimeAlertNotInitializedState());
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
// ! TO GET THE USERS LOCATION
  Future<LatLng> _getCurrentLocation() async {
    print('GET USER LOCATION METHOD RUNNING =========');
    var position = await Geo.Geolocator.getCurrentPosition(
        desiredAccuracy: Geo.LocationAccuracy.high);

    print(
        'the latitude is: ${position.longitude} and th longitude is: ${position.longitude} ');
    return LatLng(position.latitude, position.longitude);
  }

  Future<List<CrimeLocation>> getCrimeSpots() async {
    var location = await _getCurrentLocation();
    var allCrimeSpots = await _firebaseRepository.getCrimeSpots(location);
    return allCrimeSpots;
  }

  @override
  Stream<CrimeAlertState> mapEventToState(CrimeAlertEvent event) async* {
    print('CrimeAlert $event CrimeAlertBloc ==========');
    if (event is CrimeAlertStartEvent) {
      var crimeLocations = await getCrimeSpots();
      var currentLocation = await _getCurrentLocation();
      yield CrimeAlertNotSelectedState(crimeLocations: crimeLocations, currentLocation: currentLocation);
    }
    if (event is LocationSelectedEvent) {
      yield CrimeAlertLoadingState(state: DetailsNotFilledState());

      yield DetailsNotFilledState();
    }
    if (event is DetailsSubmittedEvent) {
      yield CrimeAlertLoadingState(
          state: CrimeAlertNotSelectedState(
              crimeLocations: [],
              currentLocation: LatLng(event.location.lat, event.location.lng)));
      await Future.delayed(Duration(seconds: 1));
      yield CrimeAlertNotSelectedState(
          crimeLocations: [],
          currentLocation: LatLng(event.location.lat, event.location.lng));
    }
    if (event is CrimeAlertSelectedEvent) {}
    if (event is CrimeAlertCancelEvent) {
      yield CrimeAlertCancelledState();
      await Future.delayed(Duration(milliseconds: 500));
      // List<CrimeLocation> crimeLocations = await CrimeAlertController.getCrimeAlerts();
      // yield CrimeAlertNotSelectedState(crimeLocations: crimeLocations);
    }
    if (event is BackPressedEvent) {
      switch (state.runtimeType) {
        case DetailsNotFilledState:
          // List<CrimeLocation> crimeLocations = await CrimeAlertController.getCrimeAlerts();
          // yield CrimeAlertNotSelectedState(crimeLocations: crimeLocations);
          break;
        case CrimeAlertNotSelectedState:
          yield DetailsNotFilledState();
          break;
      }
    }
  }
}
