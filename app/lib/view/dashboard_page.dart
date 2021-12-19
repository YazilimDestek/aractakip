import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:hesap.co_app/classes/db_save.dart';
import 'package:hesap.co_app/classes/localdb/database_crud.dart';
import 'package:hesap.co_app/classes/qr_data_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hesap.co_app/classes/qr_data_class.dart';
import 'package:hesap.co_app/services/location_service.dart';
import 'package:hesap.co_app/services/transtype_qr_service.dart';
import 'package:hesap.co_app/services/transtype_service.dart';
import 'package:hesap.co_app/utils/dbHelper.dart';
import 'package:hesap.co_app/view/create_single_move_page.dart';
import 'package:hesap.co_app/view/login_page.dart';
import 'package:hesap.co_app/view/my_moves.dart';
import 'package:hesap.co_app/view/post_multi_move_page.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sayac_item_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

final TransTypeService transTypeService = TransTypeService();
final LocationService locationService = LocationService();

int pageNumber = -1;

class ChangePage {
  int page;

  int get pageNum => page;

  set pageNum(int pages) => this.page = pages;
}

ChangePage _changePage = new ChangePage();

class _DashboardState extends State<Dashboard> {
  List<dynamic> types;
  List<dynamic> locations;

  var _counter;
  var _value;

  Future _scannerBarcode() async {
    _counter = await FlutterBarcodeScanner.scanBarcode(
        '#004496', "İptal", true, ScanMode.QR);
    setState(() {
      if (_counter == "-1") {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(title: Text("Lütfen Bir QR Kod Okutun")));
      } else {
        _value = _counter;
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => PostMultiMove(QrData: _value)));
      }
      //print('SP: $myMap');
      print(_value);
    });
  }

  _showDialog(title, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text("Tamam"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Uygulamadan çıkış yapmak istiyor musunuz?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Hayır"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(child: Text("Evet"), onPressed: () => exit(0))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SafeArea(
            child: Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).copyWith().size.height / 2,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        margin: EdgeInsets.only(top: 60),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/cinigaz-logo.png'))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Center(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Container(
                              child: SizedBox(
                                width: 160,
                                height: 160,
                                child: RaisedButton(
                                  color: Color.fromRGBO(248, 108, 107, 1),
                                  highlightColor:
                                      Color.fromRGBO(239, 90, 78, 1),
                                  padding: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 10,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/images/time.png',
                                          width: 50,
//                                color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Hareketlerim",
                                          style: TextStyle(
                                              letterSpacing: .5,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )
                                      ]),
                                  onPressed: () async {
                                    //_changePage.pageNum = 10;
                                    pageNumber = _changePage.pageNum;
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new MyMoves()));
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Container(
                              child: SizedBox(
                                width: 160,
                                height: 160,
                                child: RaisedButton(
                                  color: Color.fromRGBO(255, 193, 7, 1),
                                  highlightColor:
                                      Color.fromRGBO(255, 168, 25, 1),
                                  padding: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 10,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/images/sayac.png',
                                          width: 70,
                                        ),
                                        Text(
                                          "Sayaç Ara",
                                          style: TextStyle(
                                              letterSpacing: .5,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )
                                      ]),
                                  onPressed: () async {
                                    var result = await Connectivity()
                                        .checkConnectivity();
                                    if (result == ConnectivityResult.none) {
                                      _showDialog('İnternet Yok!',
                                          'İnternet Bağlantısı Gerekli...');
                                    } else if (result ==
                                            ConnectivityResult.wifi ||
                                        result == ConnectivityResult.mobile) {
                                      pageNumber = _changePage.pageNum;
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  new SayacItemPage()));
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Container(
                              child: SizedBox(
                                width: 160,
                                height: 160,
                                child: RaisedButton(
                                  color: Color.fromRGBO(99, 194, 222, 1),
                                  highlightColor:
                                      Color.fromRGBO(2, 155, 180, 1),
                                  padding: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 10,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/images/serial.png',
                                          width: 70,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Seri Numara\nTara",
                                          style: TextStyle(
                                              letterSpacing: .5,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )
                                      ]),
                                  onPressed: () async {
                                    _changePage.pageNum = 5;
                                    pageNumber = _changePage.pageNum;
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new CreateSingleMove()));
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Container(
                              child: SizedBox(
                                width: 160,
                                height: 160,
                                child: RaisedButton(
                                  color: Color.fromRGBO(32, 168, 216, 1),
                                  highlightColor:
                                      Color.fromRGBO(2, 109, 180, 1),
                                  padding: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 10,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/images/qr_code.png',
                                          width: 60,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Karekod Tara",
                                          style: TextStyle(
                                              letterSpacing: .5,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )
                                      ]),
                                  onPressed: () async {
                                    dbSave();
                                    _scannerBarcode();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
