import 'package:crime_alert/constants/assets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required Key key,
    required this.onInitializationComplete,
  }) : super(key: key);

  final Widget onInitializationComplete;

 @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    await Firebase.initializeApp();
    Future.delayed(
      Duration(milliseconds: 1500), () {
        if(mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
            return widget.onInitializationComplete;},));
        }
      }
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: ElevatedButton(
          onPressed: () => main(),
          child: Text('retry'),
        ),
      );
    }
    return Container(color: Colors.white, child: Center(
      child: Container(
        height: 250.0,
        child: Column(
          children: [
            Image.asset(Assets.appLogo, color: Colors.deepOrange.shade400,),
            Container(width: 100.0,child: LinearProgressIndicator()),
          ],
        ),
      ),
    ),);
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

}