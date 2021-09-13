/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'QRScreen.dart';
import 'ReportScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(MyApp());
}
String qrdata = "test";

/// The example application class
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
        title: 'QR.Flutter',
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: HomePage());
  }
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;

  final _pageOptions = [
    QRScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), title: Text('QR Code')),
            BottomNavigationBarItem(icon: Icon(Icons.receipt, size: 30), title: Text('Reports')),
          ],
          selectedItemColor: Colors.cyan,
          elevation: 5.0,
          unselectedItemColor: Colors.cyan[900],
          currentIndex: selectedPage,
          backgroundColor: Colors.white,
          onTap: (index){
            setState(() {
              selectedPage = index;
            });
          },
        )
    );
  }
}

