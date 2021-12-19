import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

final String STORED_LEVEL_API_URL = "item";

class StoredLevelService {
  Future<Object> storedLevelFilterApiRequest(var keyword) async {
    ConfigFile configFile = ConfigFile();

    Map responseDataMap;
    List<dynamic> responseDataList;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    http.Response response = await http.post(
        Uri.encodeFull(configFile.BASE_URL + STORED_LEVEL_API_URL),
        body: json.encode({"keyword": keyword}),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer" + " $token"
        });

    if (response.statusCode == 200) {
      responseDataMap = jsonDecode(response.body);
      responseDataList = responseDataMap["entities"];
      print("Responseee : $responseDataMap");
      return responseDataList;
    } else {
      throw Exception("Something gone wrong, ${response.statusCode}");
    }
  }
}
