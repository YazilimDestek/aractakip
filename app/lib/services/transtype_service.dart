import 'dart:async';
import 'dart:convert';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

var trans = "transtype/mobilebarcode";

class TransTypeService {
  Future<Object> getTransTypeInfo() async {
    try {
      ConfigFile configFile = ConfigFile();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String TOKEN = sharedPreferences.getString('token');

      http.Response response = await http.get(configFile.BASE_URL + trans,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer" + " $TOKEN"
          });
      print("transapi");

      if (response.statusCode == 200) {
        print("transtype");
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
