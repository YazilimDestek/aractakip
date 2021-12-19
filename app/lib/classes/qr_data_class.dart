import 'package:flutter/material.dart';

class ScanModel {

  int id;
  int destinationLocationId;
  int transactionTypeId;
  var qrModel;
  String multiorSingle;
  String createTime;
  String errorMessage;
  bool isSuccess;

  ScanModel(this.destinationLocationId, this.transactionTypeId, this.qrModel, this.multiorSingle, this.createTime, this.errorMessage, this.isSuccess);
  // Constructor'ımızı oluşturduk.
  //Ekleme işlemlerinde direkt olarak id atadığı için id yok.
  ScanModel.withId(this.id ,this.destinationLocationId, this.transactionTypeId, this.qrModel, this.multiorSingle, this.createTime, this.errorMessage, this.isSuccess);
  //QRScanModel.withId(this.qrModel);
  // Silme işlemi için id'li constructor .

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["_id"] = id;
    map["DestinationLocationId"] = destinationLocationId;
    map["TransactionTypeId"] = transactionTypeId;
    map["QRModel"] = qrModel;
    map["MultiorSingle"] = multiorSingle;
    map["CreateTime"] = createTime;
    map["ErrorMessage"] = errorMessage;
    map["IsSuccess"] = this.isSuccess ? 1 : 0;
    return map; //Bu mapimizi döndürüyoruz.
  }

  ScanModel.fromMap(Map<String, dynamic> map) {
    this.id = map["_id"];
    this.destinationLocationId = map["DestinationLocationId"];
    this.transactionTypeId = map["TransactionTypeId"];
    this.qrModel = map["QRModel"];
    this.multiorSingle = map["MultiorSingle"];
    this.createTime = map["CreateTime"];
    this.errorMessage = map["ErrorMessage"];
    if(map["IsSuccess"] == 1){
      this.isSuccess = true;
    }else{this.isSuccess = false;}

  }
}