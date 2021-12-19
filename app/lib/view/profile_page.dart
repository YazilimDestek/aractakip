import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/classes/load_class.dart';
import 'package:hesap.co_app/classes/localdb/database_crud.dart';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:hesap.co_app/services/location_service.dart';
import 'package:hesap.co_app/services/transtype_qr_service.dart';
import 'package:hesap.co_app/services/transtype_service.dart';
import 'package:hesap.co_app/utils/dbHelper.dart';
import 'package:hesap.co_app/view/login_page.dart';
import 'package:hesap.co_app/services/profile_service.dart';
import 'package:hesap.co_app/view/home_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

final ProfileService profileService = ProfileService();
final TransTypeService transTypeService = TransTypeService();
final LocationService locationService = LocationService();
DateFormat format2 = DateFormat("dd.MM.yyyy");
final GlobalKey<State> _LoaderDialog = new GlobalKey<State>();

class _ProfileState extends State<Profile> {
  removeData() async {
    DatabaseDao _databaseDao = DatabaseDao();
    await _databaseDao.deleteAll();
    DatabaseHelper _databaseHelper = DatabaseHelper();
    await _databaseHelper.deleteAll();
    print("silindi.");
  }

  saveLocalData() async {
    DatabaseDao _databaseDao = DatabaseDao();
    TransTypeService _transTypeService = TransTypeService();
    LocationService _locationService = LocationService();
    TransTypeQrService _transTypeQrService = TransTypeQrService();

    await _databaseDao.deleteAll();

    try {
      List<Model> _transfer = await _transTypeService.getTransTypeInfo();
      await _databaseDao.insertTranstype(_transfer);
      List<Model> _transferqr = await _transTypeQrService.getTransTypeQrInfo();
      await _databaseDao.insertTranstypeQr(_transferqr);
      List<Model> _model = await _locationService.getLocationInfo();
      await _databaseDao.insertLocation(_model);

      if (_model.length > 0 && _transfer.length > 0 && _transferqr.length > 0) {
        print("DATA VAR");
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text("Veriler Başarıyla Çekildi.",
                    style: TextStyle(color: Colors.green))));
        setState(() {});
      } else {
        print("DATA YOK");
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(
                    "Veriler Çekilemedi.\nİnternet Bağlantınızı Kontrol Edin.",
                    style: TextStyle(color: Colors.red))));
        setState(() {});
      }
    } catch (e) {
      print("DATA YOK");
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text("Beklenmedik Bir Hata Oluştu.",
                  style: TextStyle(color: Colors.red))));
      setState(() {});
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

  Future<bool> _onBackPressed() {
    return Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new Home()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          child: SafeArea(
            child: Column(
              children: [
                FutureBuilder(
                  future: profileService.getProfileInfo(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          Card(
                            child: Container(
                              width:
                                  MediaQuery.of(context).copyWith().size.width,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Kullanıcı Bilgileri",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Container(
                              color: Colors.white38,
                              height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height /
                                  2,
                              width:
                                  MediaQuery.of(context).copyWith().size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "Kullanıcı Adı : " +
                                            snapshot.data["entity"]["username"]
                                                .toString(),
                                        style: TextStyle(fontSize: 20)),
                                    Text(
                                        "E-mail : " +
                                            snapshot.data["entity"]["email"]
                                                .toString(),
                                        style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      if (snapshot.error.hashCode == 111 ||
                          snapshot.error.hashCode == 403 ||
                          snapshot.error.hashCode == 401) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hesap Zaman Aşımına Uğradı\nTekrar Giriş Yapın.",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              FlatButton(
                                  color: Colors.redAccent,
                                  highlightColor: Colors.red,
                                  child: Text(
                                    "Tamam",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences sharedPreferences =
                                        await SharedPreferences.getInstance();
                                    sharedPreferences.remove('token').then(
                                        (value) => Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    new LoginPage())));
                                    removeData();
                                  })
                            ],
                          ),
                        );
                        // var instanceRequest = SharedPreferences.getInstance();
                        // instanceRequest.then((value) => value.remove('token').then(
                        //     (value) => Navigator.push(
                        //         context,
                        //         new MaterialPageRoute(
                        //             builder: (context) => new LoginPage()))));
                        // removeData();
                      } else {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 82.0,
                            ),
                            Text("Bağlantınızı Kontrol Edin...")
                          ],
                        ));
                      }
                    }
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.redAccent,
                      highlightColor: Colors.red,
                      padding: EdgeInsets.only(
                          left: 25, right: 25, top: 15, bottom: 15),
                      elevation: 5,
                      child: Text(
                        "Çıkış Yap",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () async {
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();

                        return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text(
                                      "Hesabınızdan çıkış yapmak istiyor musunuz?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Hayır"),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    FlatButton(
                                        child: Text("Evet"),
                                        onPressed: () {
                                          sharedPreferences
                                              .remove('token')
                                              .then((value) => Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) =>
                                                          new LoginPage())));
                                          removeData();
                                        })
                                  ],
                                ));
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      color: Colors.redAccent,
                      highlightColor: Colors.red,
                      padding: EdgeInsets.only(
                          left: 25, right: 25, top: 15, bottom: 15),
                      elevation: 5,
                      child: Text(
                        "Veri Çek",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () async {
                        setState(() {});
                        saveLocalData();
                        LoaderDialog.showLoadingDialog(context, _LoaderDialog);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
