import 'Dart:async';
import 'Dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

class RejectService {
  Future<Object> rejectRequest(int id) async {
    ConfigFile configFile = ConfigFile();

    List<dynamic> responseDataList;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    final response = await http.get(
        configFile.BASE_URL +
            "orderitem" +
            "/" +
            "rejectOrderItem" +
            "/" +
            id.toString(),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer" + " $token"
        });

    if (response.statusCode == 200) {
      responseDataList = jsonDecode(response.body);
      return responseDataList;
    } else {
      throw Exception("Something gone wrong, ${response.statusCode}");
    }
  }
}
