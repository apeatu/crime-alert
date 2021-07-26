import 'dart:io';
import 'package:path/path.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:crime_alert/model/crime_location.dart';
import 'package:crime_alert/model/user.dart' as CAUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserCredential? _currentUser;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //user class
  CAUser.User user = CAUser.User();

  UserCredential? getCurrentUser() {
    return _currentUser;
  }

  Future<UserCredential?> googleSignIn() async {
    var _signInAccount = await _googleSignIn.signIn();
    print('ccaa signinaccount ' + _signInAccount!.displayName.toString());
    var _signInAuthentication = await _signInAccount.authentication;
    print(
        'ccaa signinauthToken ' + _signInAuthentication.accessToken.toString());

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);
    print('ccaa credential ' + credential.asMap().toString());

    _currentUser = await _auth.signInWithCredential(credential);
    print('ccaa current user ' + _currentUser!.user!.displayName.toString());

    return _currentUser;
  }

  Future<bool> authenticateUser(UserCredential user) async {
    DocumentSnapshot result =
        await firestore.collection('users').doc(user.user!.uid).get();

    return result.exists;
  }

  Future<void> addUserDataToDb(User userDetails) async {
    user = CAUser.User(
      uid: userDetails.uid,
      email: userDetails.email,
      name: userDetails.displayName,
    );

    await firestore.collection('users').doc(userDetails.uid).set(user.toJson());
  }

  Future<CrimeLocation?> addCrimeLocaionDataToDb(
      BuildContext context, CrimeLocation crimeSpot) async {
    var newCrimeLocation;
    var at;
    try {
      var _exists = false;
      var resultRef = firestore.collection('crime_location');
      var resultDoc = await resultRef.get();

      for (var i = 0; i < resultDoc.size; i++) {
        if (resultDoc.docs[i].data()['name'] == crimeSpot.name) {
          _exists = true;
          at = i;
        }
      }
      if (!_exists) {
        await firestore
            .collection('crime_location')
            .doc()
            .set(crimeSpot.toJson());
        await Flushbar(
          title: 'Crime Alert',
          message: 'Crime Spot Uploaded Successfully',
          duration: Duration(seconds: 3),
          backgroundGradient:
              LinearGradient(colors: [Colors.blue, Colors.teal]),
          backgroundColor: Colors.deepOrange,
          boxShadows: [
            BoxShadow(
              color: Colors.blue.shade800,
              offset: Offset(0.0, 2.0),
              blurRadius: 3.0,
            )
          ],
        ).show(context);
        return crimeSpot;
      } else {
        crimeSpot.reportNumber = resultDoc.docs[at].data()['reportNumber'] + 1;
        await firestore
            .collection('crime_location')
            .doc(resultDoc.docs[at].id).update(crimeSpot.toJson());
        await Flushbar(
          title: 'Crime Alert',
          message: 'Crime Spot Uploaded Successfully',
          duration: Duration(seconds: 3),
          backgroundGradient:
              LinearGradient(colors: [Colors.blue, Colors.teal]),
          backgroundColor: Colors.deepOrange,
          boxShadows: [
            BoxShadow(
              color: Colors.blue.shade800,
              offset: Offset(0.0, 2.0),
              blurRadius: 3.0,
            )
          ],
        ).show(context);
        return CrimeLocation.fromJson(resultDoc.docs[at].data());
      }
    } catch (e, s) {
      print(s);
      print('Failed to add new crime location! $e');
    }
    return newCrimeLocation;
  }

  Future<UploadTask?> uploadImage(BuildContext context, dynamic file) async {
    var fileName = basename(file.path);
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    UploadTask uploadTask;

    // Create a Reference to the file
    var ref = FirebaseStorage.instance.ref().child('uploads/$fileName');

    final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path});

    uploadTask = ref.putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  Future<CAUser.User> getUser(UserCredential userCredential) async {
    var user =
        await firestore.collection('users').doc(userCredential.user!.uid).get();
    print('get user ' + user.data.toString());
    return CAUser.User.fromJson(user.data()!);
  }

  Future<List<CrimeLocation>> getCrimeSpots(LatLng currentLocation) async {
    var crimeLocations = <CrimeLocation>[];

    var querySnapshot = await firestore.collection('crime_locations').get();
    for (var i = 0; i < querySnapshot.size; i++) {
      crimeLocations.add(CrimeLocation.fromJson(querySnapshot.docs[i].data()));
    }
    return crimeLocations;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    print('current user ' + _currentUser.toString());
    print('current app ' + _auth.app.name);
    _currentUser = null;
  }

  Future<List<CAUser.User>> fetchAllUsers(UserCredential currentUser) async {
    var userList = <CAUser.User>[];

    var querySnapshot = await firestore.collection('users').get();
    for (var i = 0; i < querySnapshot.size; i++) {
      if (querySnapshot.docs[i].id != currentUser.user!.uid) {
        userList.add(CAUser.User.fromJson(querySnapshot.docs[i].data()));
      }
    }
    return userList;
  }
}
