import 'package:covid19/RouteObserver.dart';
import 'package:covid19/pages/help.dart';
import 'package:covid19/pages/info_screen.dart';
import 'package:covid19/pages/map.dart';
import 'package:covid19/pages/profile.dart';
import 'package:covid19/pages/rootpage.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/style/theme.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid 19',
      navigatorObservers: [MyRouteObserver()],
      initialRoute: '/',
        routes: {
          '/root': (context) => RootPage(),
          '/map' : (context) => MapPage(),
          '/info' : (context) => InfoScreen(),
          '/help': (context) => HelpPage(),
          '/profile': (context) => UserProfil(onSignOut: () {},),
        },
      theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          canvasColor: kBackgroundColor.withOpacity(0.9),
          fontFamily: "Poppins",
          textTheme: TextTheme(
            body1: TextStyle(color: kBodyTextColor),
          )),
      home: new RootPage(auth: new Auth()));
  }
}
