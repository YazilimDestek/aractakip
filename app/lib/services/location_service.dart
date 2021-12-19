import 'dart:async';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

var LOCATION_API_URL = "location";

class LocationService {
  Future<Object> getLocationInfo() async {
    try {
      ConfigFile configFile = ConfigFile();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var TOKEN = sharedPreferences.getString('token');

      http.Response response = await http
          .get(configFile.BASE_URL + LOCATION_API_URL, headers: {
        "accept": "application/json",
        "Authorization": "Bearer" + " $TOKEN"
      });

      print("local api");

      if (response.statusCode == 200) {
        print("localtype");
        // print(response.body);
        var peopleData = modelFromJson(response.body);
        print(peopleData);
        return peopleData;
      } else {
        throw Exception("Something gone wrong, ${response.statusCode}");
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
