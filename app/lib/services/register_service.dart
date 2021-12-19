import 'Dart:async';
import 'Dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

const String REGISTER_API_URL = "login/register";
Map responseDataMap;

class RegisterService {
  Future<Object> registerApiRequest(String username, String password) async {
    try {
      ConfigFile configFile = ConfigFile();
      var body = json.encode({"username": username, "password": password});

      var uri = Uri.encodeFull(configFile.BASE_URL + REGISTER_API_URL);

      var response = await http.post(uri, body: body, // bu çalışıyoor
          headers: {"content-type": "application/json"});

      var meta = jsonDecode(response.body)['meta']["isSuccess"];
      print(meta.toString() + response.statusCode.toString());

      if (response.statusCode == 200 && meta == false) {
        return 401;
      } else if (response.statusCode == 200 && meta == true) {
        var token = jsonDecode(response.body)['entity']['value'];
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('token', token);
        var UserId = jsonDecode(response.body)['entity']['user']['id'];
        SharedPreferences sharedPreferencesId =
            await SharedPreferences.getInstance();
        sharedPreferencesId.setInt('UserId', UserId);
        print(UserId.toString());

        print(token);
        return response.statusCode;
      } else {
        var token = jsonDecode(response.body)['entity']['value'];
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('token', token);
        return response.statusCode;
      }
    } catch (e) {
      return "catch";
    }
  }
}
