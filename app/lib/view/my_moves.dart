import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/classes/load_class.dart';
import 'package:hesap.co_app/classes/qr_data_class.dart';
import 'package:hesap.co_app/services/create_multi_move_service.dart';
import 'package:hesap.co_app/services/create_single_move_service.dart';
import 'package:hesap.co_app/utils/dbHelper.dart';
import 'package:intl/intl.dart';

class MyMoves extends StatefulWidget {
  @override
  _MyMovesState createState() => _MyMovesState();
}

final CreateMultiMoveService createMultiMoveService = CreateMultiMoveService();
final CreateSingleMoveService createSingleMoveService =
    CreateSingleMoveService();

class _MyMovesState extends State<MyMoves> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  final GlobalKey<State> _LoaderDialog = new GlobalKey<State>();
  List<ScanModel> allDatas = new List<ScanModel>();
  bool aktiflik = false;
  DateTime now = DateTime.now();
  var _formKey = GlobalKey<FormState>();
  int clickedNoteID;

  void getDatas() async {
    var movesFuture = _databaseHelper.getAllData();
    await movesFuture.then((moves) {
      setState(() {
        this.allDatas = moves.reversed.toList();
        print(allDatas.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDatas();
  }

  Future<void> _validateS(
      int id, var ScanData, int selecloc, int selectyp, String mood) async {
    try {
      var result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text("İnternet Bağlantısı Gerekli !",
                    style: TextStyle(color: Colors.red))));
      } else if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(now);

        var responsesingle = await createSingleMoveService.singleMoveApiRequest(
            selecloc, selectyp, ScanData);
        var metasingle = jsonDecode(responsesingle)['meta']["isSuccess"];
        String errorMessageSingle =
            jsonDecode(responsesingle)['meta']["errorMessage"];

        if (metasingle) {
          _deleteMove(ScanModel.withId(id, selecloc, selectyp, ScanData, "S",
              formattedDate, errorMessageSingle, metasingle));
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text("Hareket Başarılı ✓",
                      style: TextStyle(color: Colors.green))));
        }
      } else {
        //_uptadeMove(ScanModel.withId(id, selecloc, selectyp, ScanData, formattedDate, "Eksik Bilgi İçeren Hareket", false));
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text("Hareket Başarısız !",
                    style: TextStyle(color: Colors.red))));
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text("Beklenmedik Bir Hata Oluştu Tekrar Deneyin !")));
    }
  }

  Future<void> _validateM(
      int id, var ScanData, int selecloc, int selectyp, String mood) async {
    try {
      var result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text("İnternet Bağlantısı Gerekli !",
                    style: TextStyle(color: Colors.red))));
      } else if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(now);

        var responsemulti = await createMultiMoveService.multiMoveApiRequest(
            selecloc, selectyp, ScanData);
        var metamulti = jsonDecode(responsemulti)['meta']["isSuccess"];
        String errorMessageMulti =
            jsonDecode(responsemulti)['meta']["errorMessage"];

        if (metamulti) {
          _deleteMove(ScanModel.withId(id, selecloc, selectyp, ScanData, "M",
              formattedDate, errorMessageMulti, metamulti));
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text("Hareket Başarılı ✓",
                      style: TextStyle(color: Colors.green))));
        } else {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text("İşlem Başarısız !",
                      style: TextStyle(color: Colors.red))));
        }
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text("Beklenmedik Bir Hata Oluştu Tekrar Deneyin !")));
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(203, 39, 32, 1),
          title: new Text("Son Hareketlerim"),
        ),
        body: Container(
            key: _formKey,
            child: Column(children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      itemCount: allDatas.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                                onTap: () {
                                  setState(() {
                                    _addMove();
                                    // Tekrar Listeliyor.
                                  });
                                },
                                title: Text(allDatas[index].qrModel.toString()),
                                subtitle:
                                    Text(allDatas[index].createTime.toString()),
                                trailing: GestureDetector(
                                  onLongPress: () {
                                    return AlertDialog(
                                      title: Text("Hareketi Sil"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Tamam"),
                                          onPressed: () {
                                            _deleteMove(allDatas[index]);
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  },
                                  onTap: () {
                                    var id = allDatas[index].id;
                                    var selecloc =
                                        allDatas[index].destinationLocationId;
                                    var selectyp =
                                        allDatas[index].transactionTypeId;
                                    var ScanData = allDatas[index].qrModel;
                                    String Mood = allDatas[index].multiorSingle;
                                    print("id");
                                    print(id.toString());
                                    print(selecloc.toString());
                                    print(selectyp.toString());
                                    print(ScanData.toString());

                                    if (allDatas[index].multiorSingle == "S") {
                                      setState(() {});
                                      _validateS(id, ScanData, selecloc,
                                          selectyp, Mood);
                                      LoaderDialog.showLoadingDialog(
                                          context, _LoaderDialog);
                                      _addMove();
                                    } else if (allDatas[index].multiorSingle ==
                                        "M") {
                                      setState(() {});
                                      print("Multi");
                                      _validateM(id, ScanData, selecloc,
                                          selectyp, Mood);
                                      LoaderDialog.showLoadingDialog(
                                          context, _LoaderDialog);
                                      _addMove();
                                    }
                                    //_deleteMove(allDatas[index].id, index);
                                  },
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.red,
                                  ),
                                )));
                      }))
            ])));
  }

  Widget buildForm(TextEditingController txtController, String str) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
            autofocus: false,
            controller: txtController,
            decoration:
                InputDecoration(labelText: str, border: OutlineInputBorder())));
  }

  Widget buildButton(String str, Color buttonColor, Function eventFunc) {
    return RaisedButton(
      child: Text(str),
      color: buttonColor,
      onPressed: () {
        eventFunc();
      },
    );
  }

/*  void updateObject() {
    if (clickedNoteID != null) {
      if (_formKey.currentState.validate()) {
        _uptadeNote(QRScanModel.withId(
            clickedNoteID, _controllerTitle.text, _controllerDesc.text));
      }
    } else {
      alert();
    }
  }*/
  void _uptadeMove(ScanModel qrScanModel) async {
    await _databaseHelper.update(qrScanModel);
    setState(() {
      getDatas();
    });
  }

  void _addMove() async {
    setState(() {
      getDatas();
    });
  }

  void _deleteMove(ScanModel deletedDataId) async {
    await _databaseHelper.delete(deletedDataId);
    setState(() {
      getDatas();
    });
  }
}
