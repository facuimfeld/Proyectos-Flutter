import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:MiUTNFRRe/pages/home.dart';
import 'package:MiUTNFRRe/utils/save_session.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(const Login());

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isHide = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Services serv = Services();

  bool recording = false;
  SaveSession _save = SaveSession();

  TextEditingController legajo = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
            child: Container(
          margin: EdgeInsets.fromLTRB(0, 75, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Image.asset(
                    'assets/images/logo.png',
                    scale: 1,
                    color: Color(0xff3c599b),
                  ),
                  flex: 1),
              Expanded(
                  flex: 2,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                          child: TextFormField(
                              controller: legajo,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Legajo',
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: TextFormField(
                              controller: password,
                              obscureText: _isHide,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: _isHide == true
                                        ? const Icon(Icons.lock_outline)
                                        : const Icon(Icons.lock_open),
                                    onPressed: () {
                                      setState(() {
                                        _isHide = !_isHide;
                                      });
                                    }),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Contraseña',
                              )),
                        ),
                        const SizedBox(height: 35),
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              showLoaderDialog(context);
                              try {
                                bool res = await serv
                                    .authenticate(legajo.text, password.text)
                                    .timeout(Duration(seconds: 6));

                                if (res == true) {
                                  Navigator.pop(context);
                                  _save.saveUsuario(legajo.text);
                                  _save.savePassword(password.text);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(),
                                    ),
                                  );
                                  //dispose();
                                  legajo.clear();
                                  password.clear();
                                } else {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: "Error de autenticación",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              } on TimeoutException catch (_) {
                                setState(() {
                                  Navigator.pop(context);
                                });
                                Fluttertoast.showToast(
                                    msg: "Error de conexión",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            } else {
                              print('datos invalidos');
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            child: Container(
                              color: Color(0xff3c599b),
                              child: Center(
                                  child: Text('INGRESAR',
                                      style: TextStyle(
                                          fontFamily: 'Gotham-Font',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))),
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        )),
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Ingresando...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
