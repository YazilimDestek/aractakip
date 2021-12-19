import 'package:http/http.dart' as httpClient;
import 'package:shared_preferences/shared_preferences.dart';

import '../ConfigFile.dart';
import 'Dart:async';
import 'Dart:convert';

const String TRANSFER_API_URL = "qrtransfer";
Map responseDataMap;

class CreateMultiMoveService {
  Future<Object> multiMoveApiRequest(
      int DestinationLocationId, int TransactionTypeId, var QRData) async {
    ConfigFile configFile = ConfigFile();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var TOKEN = sharedPreferences.getString('token');
    var qr = jsonDecode(QRData);
    var body = posttToJson(Postt(
        destinationLocationId: DestinationLocationId,
        transactionTypeId: TransactionTypeId,
        qrData: qr));

    var url = "${configFile.BASE_URL}$TRANSFER_API_URL";

    var response = await httpClient.post(url, body: body, headers: {
      "content-type": "application/json",
      "Authorization": "Bearer" + " $TOKEN"
    });

    print("response1, $response");
    print("response2, ${response.statusCode}");
    print("response3, ${response.headers}");
    print("response4, ${response.toString()}");
    print("response5, ${response.body}");
    var meta = jsonDecode(response.body)['meta']["isSuccess"];
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

Postt posttFromJson(String str) => Postt.fromJson(json.decode(str));

String posttToJson(Postt data) => json.encode(data.toJson());

class Postt {
  Postt({
    this.destinationLocationId,
    this.transactionTypeId,
    this.qrData,
  });

  int destinationLocationId;
  int transactionTypeId;
  var qrData;

  factory Postt.fromJson(Map<String, dynamic> json) => Postt(
        destinationLocationId: json["DestinationLocationId"],
        transactionTypeId: json["TransactionTypeId"],
        qrData: json["QRModel"],
      );

  Map<String, dynamic> toJson() => {
        "DestinationLocationId": destinationLocationId,
        "TransactionTypeId": transactionTypeId,
        "QRModel": qrData
      };
}
