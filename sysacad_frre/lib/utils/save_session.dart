import 'package:shared_preferences/shared_preferences.dart';

class SaveSession {
  Future<void> saveUsuario(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('usuario', user);
  }

  Future<void> savePassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
  }

  Future<String> getUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user').toString();
    return user;
  }

  Future<void> deleteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    prefs.remove('password');
  }

  Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String password = prefs.getString('password').toString();
    return password;
  }

  Future<void> saveCookie(String cookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cookie', cookie);
  }

  Future<String> mostrarCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString('cookie');
    return cookie.toString();
  }

  Future<void> deleteCarrera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('carrera')) {
      prefs.remove('carrera');
    }
  }

  Future<void> borrarCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('cookie')) {
      prefs.remove('cookie');
    }
  }

  Future<String> getCarrera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String carrera = prefs.getString('carrera').toString();
    print(carrera);
    return carrera;
  }

  Future<void> printCarrera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String carrera = prefs.getString('carrera').toString();
    print(carrera);
  }
}
