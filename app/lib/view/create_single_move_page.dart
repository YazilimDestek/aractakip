import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/classes/db_save.dart';
import 'package:hesap.co_app/classes/load_class.dart';
import 'package:hesap.co_app/view/post_single_move_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(MaterialApp(home: CreateSingleMove()));

class CreateSingleMove extends StatefulWidget {
  const CreateSingleMove({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateSingleMoveState();
}

class _CreateSingleMoveState extends State<CreateSingleMove> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final GlobalKey<State> _LoaderDialog = new GlobalKey<State>();
  List serials = [];
  List yeni = [];

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  Future<List<String>> yedekAl(List serialsGercek) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> serials1 = serialsGercek.map((i) => i.toString()).toList();
    prefs.setStringList('serials1', serials1);
    print('SP: $serials1');
    yeni = serials;
    return serials1;
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 200.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(scanArea)),
          Expanded(
            flex: 7,
            child: Container(
              // fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  //shrinkWrap: true,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (serials.length == 0) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          title: Text(
                                              "En Az Bir Barkod Taratın!")));
                                } else {
                                  LoaderDialog.showLoadingDialog(
                                      context, _LoaderDialog);
                                  await controller?.resumeCamera();
                                  yedekAl(serials);
                                  await dbSave();
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              PostSingleMove()));
                                }
                              },
                              child: Text('Hareket Oluştur',
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () async {
                                await controller?.resumeCamera();
                                setState(() {});
                                serials.clear();
                              },
                              child: Text('Listeyi Temizle',
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () async {
                                await controller?.resumeCamera();
                                setState(() {});
                                yedekAl(serials);
                              },
                              child: Text('Devam Et',
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (result != null)
                              for (int i = 0; i < serials.length; i++)
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        (i + 1).toString() +
                                            ')' +
                                            yeni[i].toString(),
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                    //SizedBox(width: 10,),
                                    RaisedButton(
                                      shape: CircleBorder(),
                                      color: Colors.red,
                                      //highlightColor: Colors.redAccent,
                                      onPressed: () async {
                                        setState(() {
                                          serials.removeAt(i);
                                        });
                                        yedekAl(serials);
                                      },
                                      child:
                                          //Icon(Icons.remove),
                                          Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                )
                            else
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'Bir Barkod Taratın',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(double scanArea) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    /*var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;*/
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blueAccent,
          borderRadius: 3,
          borderLength: 10,
          borderWidth: 5,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() async {
        result = scanData;
        setState(() {
          if (!serials.contains(result.code)) {
            serials.add(result.code.toString());
          } else {
            showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(title: Text("Taratılmış barkod!")));
          }
        });
        controller?.pauseCamera();
        yedekAl(serials);
        print('####. $result');
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
