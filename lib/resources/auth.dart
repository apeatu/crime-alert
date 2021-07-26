import 'package:crime_alert/data/database_helper.dart';
import 'package:flutter/material.dart';

enum AuthState{ loggedIn, loggedOut }

abstract class AuthStateListener {
  void onAuthStateChanged(BuildContext context, AuthState state);
}

// A naive implementation of Observer/Subscriber Pattern. Will do for now.
class AuthStateProvider {
    factory AuthStateProvider(BuildContext context) => _instance;
  AuthStateProvider.internal({BuildContext? context}) {
    _subscribers = [];
    initState(context!);
  }
  static final AuthStateProvider _instance = AuthStateProvider.internal();

  List<AuthStateListener>? _subscribers;

  void initState(BuildContext context) async {
    var db = DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if(isLoggedIn) {
      notify(context, AuthState.loggedIn);
    } else {
      notify(context, AuthState.loggedOut);
    }
  }

  void subscribe(AuthStateListener listener) {
    _subscribers!.add(listener);
  }

  void dispose(AuthStateListener listener) {
    for(var l in _subscribers!) {
      if(l == listener) {
        _subscribers!.remove(l);
      }
    }
  }

  void notify(BuildContext context, AuthState state) {
    _subscribers!.forEach((AuthStateListener s) => s.onAuthStateChanged(context, state));
  }
}