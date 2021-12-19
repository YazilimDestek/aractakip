import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

const String SAYAC_ITEMS_API_URL = "stock";

class SayacItemService {
  Future<List<Map<String, dynamic>>> sayacItemRequest(
      int sayacItemStatusID, List date) async {
    ConfigFile configFile = ConfigFile();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    http.Response response = await http.post(
        Uri.encodeFull(configFile.BASE_URL + SAYAC_ITEMS_API_URL),
        body: json.encode({
          "stockStartDate": "2021-02-07T21:00:00.000Z",
          "stockEndDate": "2021-02-17T21:00:00.000Z",
          "pageSize": 20,
          "page": 1
        }),
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
