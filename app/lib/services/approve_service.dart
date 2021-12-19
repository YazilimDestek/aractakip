import 'Dart:async';
import 'Dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

class ApproveService {
  Future<List<Map<String, dynamic>>> approveRequest(
      int id, bool isCreate, String numberOfPackage) async {
    ConfigFile configFile = ConfigFile();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    final response = await http.get(
        configFile.BASE_URL +
            "orderitem" +
            "/" +
            "approveOrderItem" +
            "/" +
            id.toString() +
            "/" +
            isCreate.toString() +
            "/" +
            numberOfPackage,
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer" + " $token"
        });

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
          json.decode(response.body)['entities']);
    } else {
      throw Exception("Something gone wrong, ${response.statusCode}");
    }
  }
}
