import 'Dart:async';
import 'Dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as httpClient;
import 'package:shared_preferences/shared_preferences.dart';
import '../ConfigFile.dart';

const String TRANSFER_API_URL = "transfer";
Map responseDataMap;

class CreateSingleMoveService {
  Future<Object> singleMoveApiRequest(int DestinationLocationId,
      int TransactionTypeId, dynamic SerialNumbers) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var TOKEN = sharedPreferences.getString('token');
    dynamic serialNum = jsonDecode(SerialNumbers);
    ConfigFile configFile = ConfigFile();
    var url = "${configFile.BASE_URL}$TRANSFER_API_URL";
    var body = json.encode({
      "DestinationLocationId": DestinationLocationId,
      "TransactionTypeId": TransactionTypeId,
      "SerialNumbers": serialNum,
    });
    var response = await httpClient.post(url, body: body, headers: {
      "content-type": "application/json",
      "Authorization": "Bearer" + " $TOKEN"
    });

    print("response1, $response");
    print("response2, ${response.statusCode}");
    print("response3, ${response.headers}");
    print("response4, ${response.toString()}");
    print("response5, ${response.body}");
    bool meta = jsonDecode(response.body)['meta']["isSuccess"];
    print(meta.toString() + response.statusCode.toString());

    if (response.statusCode == 200 && meta == false) {
      return 401;
    } else if (response.statusCode == 200 && meta == true) {
      print(response.body);
      return response.body;
    } else {
      print(response.body);
      return response.body;
    }
  }
}

Postt posttFromJson(dynamic str) => Postt.fromJson(json.decode(str));

dynamic posttToJson(Postt data) => json.encode(data.toJson());

class Postt {
  Postt({
    this.destinationLocationId,
    this.transactionTypeId,
    this.serialNumbers,
  });

  int destinationLocationId;
  int transactionTypeId;
  List<dynamic> serialNumbers;

  factory Postt.fromJson(Map<String, dynamic> json) => Postt(
        destinationLocationId: json["DestinationLocationId"],
        transactionTypeId: json["TransactionTypeId"],
        serialNumbers: List<String>.from(json["SerialNumbers"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "DestinationLocationId": destinationLocationId,
        "TransactionTypeId": transactionTypeId,
        "SerialNumbers": List<String>.from(serialNumbers.map((x) => x)),
      };
}
