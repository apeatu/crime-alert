import 'package:crime_alert/resources/firebase_repository.dart';
import 'package:flutter/material.dart';

import 'ui/home.dart';
import 'ui/login.dart';

String loginViewRoute = '/login';
String homeViewRoute = '/home';
String newCrimeViewRoute = '/new-crime';

class CARouter {

  static var routes = {
    loginViewRoute: (_) => LoginScreen(),
    homeViewRoute: (_) => HomeScreen(),
  };

  static Builder navigate(BuildContext context) {
   return Builder(builder: (BuildContext context) {
        if (FirebaseRepository().getCurrentUser() != null) {
           return HomeScreen();
       } else {
         return LoginScreen();
       }
   },);
 }
}