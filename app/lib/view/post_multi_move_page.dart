import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:hesap.co_app/classes/db_save.dart';
import 'package:hesap.co_app/classes/load_class.dart';
import 'package:hesap.co_app/classes/localdb/database_crud.dart';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/classes/qr_data_class.dart';
import 'package:hesap.co_app/utils/dbHelper.dart';
import 'package:hesap.co_app/services/create_multi_move_service.dart';
import 'package:hesap.co_app/services/location_service.dart';
import 'package:hesap.co_app/services/transtype_service.dart';

class PostMultiMove extends StatefulWidget {
  var QrData;
  PostMultiMove({this.QrData});
  @override
  _PostMultiMoveState createState() => _PostMultiMoveState();
}

final TransTypeService transTypeService = TransTypeService();
final LocationService locationService = LocationService();
final CreateMultiMoveService createMultiMoveService = CreateMultiMoveService();

class _PostMultiMoveState extends State<PostMultiMove> {
  List<Model> types;
  List<Model> locations;
  dynamic selectedType;
  dynamic selectedLocation;
  int selectyp;
  int selecloc;
  bool loadingIcon = false;
  DateTime now = DateTime.now();
  DatabaseHelper _databaseHelper = DatabaseHelper();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final GlobalKey<State> _LoaderDialog = new GlobalKey<State>();

  void _addNote(ScanModel qrScanModel) async {
    await _databaseHelper.insert(qrScanModel);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveLocalData();
  }

  saveLocalData() async {
    DatabaseDao _databaseDao = DatabaseDao();

    locations = await _databaseDao.getAllSortedByName();
    types = await _databaseDao.getAllSortedByName3();
    setState(() {});

    if (locations.length <= 0 && types.length <= 0) {
      locations = [];
      types = [];
      _showDialog('Veriler Yok!', 'Profilden Çekmeyi Deneyin...');
    } else {
      print("DATA VAR");
    }

    print("currentLocation");
    locations.forEach((element) {
      print(element.id);
      print(element.name);
    });

    print("currentType");
    types.forEach((element) {
      print(element.id);
      print(element.name);
    });
  }

  Future<void> _validate(var ScanData) async {
    if (formkey.currentState.validate()) {
      try {
        String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(now);
        print(selecloc.toString() + "////" + selectyp.toString());
        print("-*-*-*-*- $ScanData");
        var result = await Connectivity().checkConnectivity();
        if (result == ConnectivityResult.none) {
          _addNote(ScanModel(selecloc, selectyp, ScanData, "M", formattedDate,
              "Gönderim Başarısız", false));
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text(
                      "İnternet Bağlantısı Yok !\nİşlem Hareketlerim Sayfasına Kaydedildi.",
                      style: TextStyle(color: Colors.red))));
        } else if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          var response = await createMultiMoveService.multiMoveApiRequest(
              selecloc, selectyp, ScanData);
          print(response.hashCode);
          var meta = jsonDecode(response)['meta']["isSuccess"];
          String errorMessage = jsonDecode(response)['meta']["errorMessage"];

          if (meta) {
            //_addNote(QRScanModel(selecloc, selectyp, ScanData, formattedDate, errorMessage, meta));
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text("Hareket Başarılı ✓",
                        style: TextStyle(color: Colors.green))));
            setState(() {});
          } else if (meta != true) {
            _addNote(ScanModel(selecloc, selectyp, ScanData, "M", formattedDate,
                errorMessage, meta));
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text(
                        "Hareket Oluşturulamadı!\nHareketlerim Sayfasından Kontrol Edin.")));
            setState(() {});
          } else {
            _addNote(ScanModel(selecloc, selectyp, ScanData, "M", formattedDate,
                "Eksik Bilgi İçeren Hareket", false));
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text(
                        "Beklenmedik Hata !\nHareketlerim Sayfasından\nTekrar Deneyin.",
                        style: TextStyle(color: Colors.red))));
            setState(() {});
          }
        } else {
          _addNote(ScanModel(selecloc, selectyp, ScanData, "M", formattedDate,
              "Gönderim Başarısız", false));
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text(
                      "İnternet Bağlantısı Yok !\nİşlem Hareketlerim Sayfasına Kaydedildi.",
                      style: TextStyle(color: Colors.red))));
        }
      } catch (e) {
        print("eeeeee");
        print(e);
        print("eeeeee");
        String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(now);
        _addNote(ScanModel(selecloc, selectyp, ScanData, "M", formattedDate,
            "Eksik Bilgi İçeren Hareket", false));
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(
                    "Beklenmedik Hata !\nHareketlerim Sayfasından\nTekrar Deneyin.",
                    style: TextStyle(color: Colors.red))));

        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: SafeArea(child: FutureBuilder(
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (types != null && locations != null) {
                print('gelen data: $types $locations');
                return Form(
                  key: formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Card(
                        child: Container(
                          width: MediaQuery.of(context).copyWith().size.width,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Stok Hareketi Oluştur",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            child: DropdownButton<dynamic>(
                              hint: Text('Hareket Tipi Şeç'),
                              value: selectedType,
                              onChanged: (dynamic Value) {
                                setState(() {
                                  selectedType = Value;
                                  int intOrStringValue(dynamic o) =>
                                      (o is String ? int.tryParse(o) : o) ?? 0;
                                  selectyp = intOrStringValue(selectedType);
                                });
                              },
                              items: types?.map((Model value) {
                                    return new DropdownMenuItem<dynamic>(
                                      value: value.id,
                                      child: new Text(value.name),
                                    );
                                  })?.toList() ??
                                  [],
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            child: DropdownButton<dynamic>(
                              hint: Text('Hedef Depo Şeç'),
                              value: selectedLocation,
                              onChanged: (dynamic Value) {
                                setState(() {
                                  selectedLocation = Value;
                                  int intOrStringValue(dynamic o) =>
                                      (o is String ? int.tryParse(o) : o) ?? 0;
                                  selecloc = intOrStringValue(selectedLocation);
                                });
                              },
                              items: locations?.map((Model value) {
                                    return new DropdownMenuItem<dynamic>(
                                      value: value.id,
                                      child: new Text(value.name),
                                    );
                                  })?.toList() ??
                                  [],
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            if (selecloc == null || selectyp == null) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                      title: Text("Eksik Seçim Yaptınız!")));
                            } else {
                              setState(() {
                                LoaderDialog.showLoadingDialog(
                                    context, _LoaderDialog);
                                _validate(widget.QrData);
                              });
                            }
                          },
                          child: Text('Stok Hareketi Ekle',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Text(widget.QrData.toString(),
                            style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                dbSave();
                return Center(
                    child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 82.0,
                ));
              }
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("Veriler yükleniyor...")
                ],
              ));
            },
          )),
        ),
      ),
    );
  }
}
