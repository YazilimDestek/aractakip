import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:hesap.co_app/services/location_service.dart';
import 'package:hesap.co_app/services/transtype_service.dart';
import 'package:hesap.co_app/view/home_page.dart';
import 'package:hesap.co_app/services/login_service.dart';
import 'package:hesap.co_app/view/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

final LoginService loginService = LoginService();
final TransTypeService transTypeService = TransTypeService();
final LocationService locationService = LocationService();

final bool hasFloatingPlaceholder = true;
bool _showPassword = true;
bool pressButton = false;

class _LoginPageState extends State<LoginPage> {
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    print("login token aldındı.. $token");
  }

  List<dynamic> types;
  List<dynamic> locations;

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Uygulamadan çıkmak istiyor musunuz?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Hayır"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(child: Text("Evet"), onPressed: () => exit(0))
              ],
            ));
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

  _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      _showDialog('İnternet Yok!', 'İnternet Bağlantısı Gerekli...');
      setState(() {
        loadingIcon = false;
      });
    } else if (result == ConnectivityResult.mobile) {
    } else if (result == ConnectivityResult.wifi) {}
  }

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool loadingIcon = false;
  Future<void> validate() async {
    if (formkey.currentState.validate()) {
      var responseStatus = await loginService.loginApiRequest(
          _usernameController.text, _passwordController.text, true);
      if (responseStatus == 200) {
        //_addDesTrans(DesTransModel(types,locations));
        _usernameController.text = "";
        _passwordController.text = "";
        Navigator.push(context,
                new MaterialPageRoute(builder: (context) => new Home()))
            .then((value) =>
                (_usernameController.text == "") &&
                (_passwordController.text == ""));
      } else if (responseStatus == 401) {
        print("2. if");
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text("Yetkisiz giriş. Hesabınız bulunamamıştır.")));
        setState(() {
          loadingIcon = false;
        });
      } else if (responseStatus == "catch") {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(title: Text("Sunucu Cevap Vermiyor")));
        setState(() {
          loadingIcon = false;
        });
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(
                    "Beklenmedik bir hata oluştu daha sonra tekrar giriş yapmayı deneyiniz.")));
        setState(() {
          loadingIcon = false;
        });
      }
    } else
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: Text("Lütfen bilgilerinizi kontrol ediniz!")));
    setState(() {
      loadingIcon = false;
    });
  }

  String validatePassword(value) {
    if (value.isEmpty && pressButton == true) {
      loadingIcon = false;
      return "Lütfen şifrenizi giriniz!";
    } else {
      return null;
    }
  }

  String validateUsername(value) {
    if (value.isEmpty && pressButton == true) {
      loadingIcon = false;
      return "E-posta alanı boş bırakılamaz!";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(2, 109, 180, 1),
          title: new Text("Üye Girişi"),
        ),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).copyWith().size.height / 3,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        //margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/cinigaz-logo.png'))),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(49, 39, 79, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            )
                          ]),
                      child: Form(
                        autovalidate: true,
                        key: formkey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  left: 20, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[200]))),
                              child: TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                      labelText: "E-Posta",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey)),
                                  validator: validateUsername),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 20, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[200]))),
                              child: TextFormField(
                                obscureText: _showPassword,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                    labelText: "Şifre",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                      child: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    )),
                                validator: validatePassword,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    RaisedButton(
                        color: Colors.blue,
                        highlightColor: Color.fromRGBO(2, 109, 180, 1),
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 15, bottom: 15),
                        elevation: 10,
                        child: Text(
                          "Üye Girişi",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          setState(() {
                            _checkInternetConnectivity();
                          });
                          setState(() {
                            return pressButton = true;
                          });
                          setState(() {
                            loadingIcon = true;
                          });
                          validate();
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                        color: Colors.blue,
                        highlightColor: Color.fromRGBO(2, 109, 180, 1),
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 15, bottom: 15),
                        elevation: 10,
                        child: Text(
                          "Kaydol",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          setState(() {});
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new RegisterPage()));
                        })
                  ],
                ),
              ),
              if (loadingIcon == true)
                Container(
                  height: 50,
                  child: _loadingScreen(),
                ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _loadingScreen() {
    return Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: <Widget>[
            SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )),
          ],
        ));
  }
}
