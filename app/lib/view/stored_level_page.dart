import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hesap.co_app/services/stored_level_service.dart';
import 'package:hesap.co_app/view/home_page.dart';

class StoredLevelPage extends StatefulWidget {
  @override
  _StoredLevelPageState createState() => _StoredLevelPageState();
}

final TextEditingController inputSearchText = TextEditingController();
final StoredLevelService storedLevelService = StoredLevelService();

bool searchBarTextCheck = false;
List<dynamic> sayaclist;
List<dynamic> sayaclistyeni = [];

class _StoredLevelPageState extends State<StoredLevelPage> {
  getData() async {
    if (searchBarTextCheck == true) {
      sayaclistyeni.clear();
      sayaclist = await storedLevelService
          .storedLevelFilterApiRequest(inputSearchText.text);
      print(sayaclist.length.toString());
      String girdi = inputSearchText.text;
      print(inputSearchText.text.toString());

      for (int i = 0; i < sayaclist.length; i++) {
        print(sayaclist[i]["serialNumber"]);
        if (sayaclist[i]["serialNumber"].toString() == girdi) {
          //sayaclist.removeAt(i);
          sayaclistyeni.add(sayaclist[i]);
        }
      }
      return sayaclistyeni;
    }
  }

  String _counter, _value = " ";
  Future _scannerBarcode() async {
    _counter = await FlutterBarcodeScanner.scanBarcode(
        '#004496', "İptal", true, ScanMode.QR);
    setState(() {
      _counter == "-1" ? _value = "" : _value = _counter;
      inputSearchText.text = _value;
      return searchBarTextCheck = true;
    });
  }

  Future<bool> _onBackPressed() {
    return Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new Home()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(203, 39, 32, 1),
          title: Text("Sayaç Ara"),
          automaticallyImplyLeading: false,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scannerBarcode,
          tooltip: 'Kodu Tarat',
          child: Icon(Icons.settings_overscan),
        ),
        body: new Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: Column(
            children: <Widget>[
              _searchBar(),
              SizedBox(
                height: 20,
              ),
              if (searchBarTextCheck == true) _createListView(),
              if (searchBarTextCheck == false) _pleaseSearch()
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(49, 39, 79, .3),
              blurRadius: 20,
              offset: Offset(0, -3),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15.0, top: 0, bottom: 0, right: 6.0),
        child: Row(
          children: [
            Flexible(
              flex: 9,
              child: TextField(
                controller: inputSearchText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 13),
                  hintText: "Sayaç Seri Numarası ile arama yapınız...",
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Text("Ara",
                    style: TextStyle(
                        color: Colors.black, fontSize: 12, letterSpacing: .5),
                    textAlign: TextAlign.center),
                color: Colors.orangeAccent,
                onPressed: () {
                  if (inputSearchText.text.isNotEmpty) {
                    setState(() {
                      return searchBarTextCheck = true;
                    });
                  } else {
                    setState(() {
                      return searchBarTextCheck = false;
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _pleaseSearch() {
    return Center(
      child: Text("Lütfen Sayaç Seri Numarası giriniz veya taratınız!"),
    );
  }

  Widget _emptySearch() {
    return Center(
      child: Text("Girilen Seri Numarasına Sahip Sayaç Bulunamadı!"),
    );
  }

  Widget _createListView() {
    return new Flexible(
        child: Container(
      child: SafeArea(
        child: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return _emptySearch();
              } else {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              var currentData = snapshot.data[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Flexible(
                                            flex: 6,
                                            fit: FlexFit.tight,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "Ürün: " +
                                                          "${currentData["name"]}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "Seri No: " +
                                                          "${currentData["serialNumber"]}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "Barcode: " +
                                                          currentData[
                                                              "barcode"],
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "Marka  : " +
                                                          currentData["brand"]
                                                              ["name"],
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                SizedBox(
                                                  height: .5,
                                                  child: Container(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: .5,
                                        child: Container(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Flexible(
                                            flex: 6,
                                            fit: FlexFit.tight,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                if (currentData[
                                                            "storedItemVariant"] !=
                                                        null ||
                                                    currentData[
                                                            "storedItemVariant"] ==
                                                        "")
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: List.generate(
                                                          currentData["storedItemVariant"]
                                                                  [
                                                                  "variantParams"]
                                                              .length,
                                                          (arrIndex) {
                                                        return Text(
                                                            "${currentData["storedItemVariant"]["variantParams"][arrIndex]["variantName"]}" +
                                                                " : " +
                                                                "${currentData["storedItemVariant"]["variantParams"][arrIndex]["variantValue"]}",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold));
                                                      }),
                                                    ),
                                                  ),
                                                if (currentData[
                                                        "storedItemVariant"] ==
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        "Variantsız Ürün",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                SizedBox(
                                                  height: .5,
                                                  child: Container(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                if (currentData["category"]
                                                            ["name"] !=
                                                        null ||
                                                    currentData["category"]
                                                            ["name"] ==
                                                        "")
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        "Kategori : " +
                                                            currentData[
                                                                    "category"]
                                                                ["name"],
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                if (currentData["category"]
                                                        ["name"] ==
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        "Kategorisiz Ürün",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                );
              }
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
    ));
  }
}
