import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/classes/db_save.dart';
import 'package:hesap.co_app/classes/load_class.dart';
import 'package:hesap.co_app/classes/localdb/database_crud.dart';
import 'package:hesap.co_app/classes/qr_data_class.dart';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:hesap.co_app/services/create_single_move_service.dart';
import 'package:hesap.co_app/services/location_service.dart';
import 'package:hesap.co_app/services/transtype_service.dart';
import 'package:hesap.co_app/utils/dbHelper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostSingleMove extends StatefulWidget {
  @override
  _PostSingleMoveState createState() => _PostSingleMoveState();
}

final TransTypeService transTypeService = TransTypeService();
final LocationService locationService = LocationService();
final CreateSingleMoveService createSingleMoveService =
    CreateSingleMoveService();

class _PostSingleMoveState extends State<PostSingleMove> {
  List<Model> types;
  List<Model> locations;

  dynamic selectedType;
  dynamic selectedLocation;
  DateTime now = DateTime.now();

  DatabaseHelper _databaseHelper = DatabaseHelper();
  int selectyp;
  int selecloc;

  bool loadingIcon = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final GlobalKey<State> _LoaderDialog = new GlobalKey<State>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveLocalData();
  }

  saveLocalData() async {
    DatabaseDao _databaseDao = DatabaseDao();

    locations = await _databaseDao.getAllSortedByName();
    types = await _databaseDao.getAllSortedByName2();
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

  void _addNote(ScanModel qrScanModel) async {
    await _databaseHelper.insert(qrScanModel);
  }

  Future<void> _validate() async {
    if (formkey.currentState.validate()) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      List<String> serialNumbers = sharedPreferences.getStringList('serials1');

      var serialNum = jsonEncode(serialNumbers);

      print(" ++++++++++++++++++++ $serialNumbers yeni" +
          selecloc.toString() +
          "////" +
          selectyp.toString());
      print("-*-*-*-*-"); // bunu yazıyo

      try {
        String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(now);
        var result = await Connectivity().checkConnectivity();
        if (result == ConnectivityResult.none) {
          _addNote(ScanModel(selecloc, selectyp, serialNum, "S", formattedDate,
              "Gönderim Başarısız", false));
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text(
                      "İnternet Bağlantısı Yok !\nİşlem Hareketlerim Sayfasına Kaydedildi.",
                      style: TextStyle(color: Colors.red))));

          setState(() {});
        } else if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          var serialNum = jsonEncode(serialNumbers);
          var response = await createSingleMoveService.singleMoveApiRequest(
              selecloc, selectyp, serialNum);
          var meta = jsonDecode(response)['meta']["isSuccess"];

          String errorMessage = jsonDecode(response)['meta']["errorMessage"];
          print(response.toString() +
              " resstatus++++++++++++++++++++++++++++++++++++"); // bunu yazmıyo, singleMoveApiRequestten çıkamıyo ki bunu yazsın

          if (meta) {
            //_addNote(QRScanModel(selecloc, selectyp, serialNum, formattedDate, errorMessage, meta));
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text("Hareket Başarılı ✓",
                        style: TextStyle(color: Colors.green))));
            setState(() {});
          } else if (meta != true) {
            _addNote(ScanModel(selecloc, selectyp, serialNum, "S",
                formattedDate, errorMessage, meta));
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text(
                        "Hareket Oluşturulamadı !\nHareketlerim Sayfasından\nTekrar Deneyin.",
                        style: TextStyle(color: Colors.red))));
            setState(() {});
          } else {
            _addNote(ScanModel(selecloc, selectyp, serialNum, "S",
                formattedDate, "Eksik Bilgi İçeren Hareket", false));
            serialNumbers.clear();
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
      } catch (e) {
        print("eeeeee");
        print(e);
        print("eeeeee");
        String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(now);
        _addNote(ScanModel(selecloc, selectyp, serialNum, "S", formattedDate,
            "Eksik Bilgi İçeren Hareket", false));
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(
                    "Beklenmedik Hata !\nHareketlerim Sayfasından\nTekrar Deneyin.",
                    style: TextStyle(color: Colors.red))));
        setState(() {
          loadingIcon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //onWillPop: _onBackPressed,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: SafeArea(
            child: FutureBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (types != null && locations != null) {
                  //types ;
                  //locations ;
                  print('gelen data: $types $locations');
                  String dropdownValue = 'Hedef Depo Seçin';
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
                                onChanged: (Value) {
                                  setState(() {
                                    selectedType = Value;
                                    selectyp = selectedType.hashCode;
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
                                onChanged: (Value) {
                                  setState(() {
                                    selectedLocation = Value;
                                    selecloc = selectedLocation;
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
                                        title: Text("Esik Seçim Yaptınız!")));
                              } else {
                                setState(() {
                                  LoaderDialog.showLoadingDialog(
                                      context, _LoaderDialog);
                                  _validate();
                                });
                              }
                            },
                            child: Text('Stok Hareketi Ekle',
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
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
            ),
          ),
        ),
      ),
    );
  }
}
