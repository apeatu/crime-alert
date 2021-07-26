import 'package:crime_alert/constants/assets.dart';
import 'package:crime_alert/resources/auth.dart';
import 'package:crime_alert/resources/firebase_repository.dart';
import 'package:crime_alert/routes.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements AuthStateListener{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange.shade600,
      body: Center(
        child: Container(
          height: 230,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(Assets.appLogo),
              InkWell(
                onTap: () {
                  FirebaseRepository().signIn().then((value) {
                    if (value != null) {
                      Future.delayed(Duration(milliseconds: 1500), () {
                        if (mounted) {
                          Navigator.pushReplacementNamed(
                              context, homeViewRoute);
                        }
                      });
                    }
                  });
                },
                child: Ink(
                  color: Colors.white,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          Assets.googleLight,
                          scale: 2,
                        ),
                      ),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.deepOrange.shade700),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onAuthStateChanged(BuildContext context, AuthState state) {
    if(state == AuthState.loggedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil(homeViewRoute, (Route<dynamic> route) => false);
    }
  }
}
