import 'package:crime_alert/bloc/crime_alert_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'routes.dart';
import 'ui/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    runApp(MultiBlocProvider(providers: [
      BlocProvider<CrimeAlertBloc>(create: (context) => CrimeAlertBloc()),
    ], child: CrimeAlertApp()));
  });
}

class CrimeAlertApp extends StatefulWidget {
  @override
  _CrimeAlertAppState createState() => _CrimeAlertAppState();
}

class _CrimeAlertAppState extends State<CrimeAlertApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: CARouter.routes,
      home: SplashScreen(
        key: UniqueKey(),
        onInitializationComplete: CARouter.navigate(context)
      ),
    );
  }
}