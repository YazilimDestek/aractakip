import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/view/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //SharedPreferences.setMockInitialValues({});

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var token = sharedPreferences.getString('token');
  print("Main token aldındı.. $token");
  runApp(
    MaterialApp(
      home: token == null ? LoginPage() : Home(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
