import 'package:crime_alert/model/crime_location.dart';
import 'package:crime_alert/model/user.dart' as CAUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'firebase_methods.dart';

class FirebaseRepository {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();

  UserCredential? getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<UserCredential?> signIn() => _firebaseMethods.googleSignIn();

  Future<bool> authenticateUser(UserCredential user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addUserDataToDb(User userDetails) =>
      _firebaseMethods.addUserDataToDb(userDetails);

  Future<void> addNewCrimeLocationtoDb(
          BuildContext context, CrimeLocation crimeLocation) =>
      _firebaseMethods.addCrimeLocaionDataToDb(context, crimeLocation);

  Future<void> uploadImage(BuildContext context, dynamic file) => _firebaseMethods.uploadImage(context, file);

  Future<CAUser.User> getUser(UserCredential user) =>
      _firebaseMethods.getUser(user);

  Future<List<CrimeLocation>> getCrimeSpots(LatLng currentLocation) =>
      _firebaseMethods.getCrimeSpots(currentLocation);

  Future<void> signOut() => _firebaseMethods.signOut();
}
