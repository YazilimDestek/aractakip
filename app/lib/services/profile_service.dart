import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

var urlAuth = "user";

class ProfileService {
  Future<Object> getProfileInfo() async {
    ConfigFile configFile = ConfigFile();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var TOKEN = sharedPreferences.getString('token');
    SharedPreferences sharedPreferencesUserId =
        await SharedPreferences.getInstance();
    var UserId = sharedPreferencesUserId.getInt('UserId');

    http.Response response = await http
        .get(configFile.BASE_URL + urlAuth + "/" + UserId.toString(), headers: {
      "accept": "application/json",
      "Authorization": "Bearer" + " $TOKEN"
    });

    if (response.statusCode == 200) {
      var peopleData = jsonDecode(response.body);
      return peopleData;
    } else {
      throw response.statusCode;
    }
  }
}
