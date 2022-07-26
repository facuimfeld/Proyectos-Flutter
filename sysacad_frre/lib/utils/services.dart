import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:MiUTNFRRe/models/comisioncursado.dart';
import 'package:MiUTNFRRe/models/final.dart';
import 'package:MiUTNFRRe/models/inasistencias.dart';
import 'package:MiUTNFRRe/models/materia.dart';
import 'package:MiUTNFRRe/models/materia_cursado.dart';
import 'package:MiUTNFRRe/models/mesa_examen.dart';

import 'package:MiUTNFRRe/utils/save_session.dart';

class Services {
  String? cookie = '';
  String nameAlumno = '';
  String token = '';
  String carrerita = '';
  List<Element> turno1 = [];
  List<Element> turno2 = [];
  String horario = '';
  List<Element> turno3 = [];
  SaveSession save = SaveSession();
  bool connectionOut = false;

  //Inscribirse a cursado
  Future<void> inscripcionCursado() async {
    Map<String, String> data = {
      'csrfmiddlewaretoken': token,
      'espH': '-',
      'planH': '-',
      'materiaH': '-',
      'comision': '-',
      'esp': '-',
      'plan': '-',
      'materia': '-',
      'nombre': '-',
    };
    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Guardar_Inscripcion/';

    var res = await http.post(Uri.parse(url),
        body: data,
        headers: {"Content-Type": "application/x-www-form-urlencoded"});

    if (res.statusCode == 200) {
      var _inp = parse(res.body);

      var s = _inp.getElementsByTagName('input');
      for (int i = 0; i <= s.length - 1; i++) {
        if (s[i].attributes["name"] == "csrfmiddlewaretoken".toString()) {
          token = s[i].attributes["value"].toString();
        }
      }
    }
  }

  Future<double> getPromedio() async {
    int nro_examenes = 0;

    double promedio = 0.0;
    double notas = 0;
    List<Materia> finales = await getEstadoAcademico();
    if (finales.isNotEmpty) {
      for (int i = 0; i <= finales.length - 1; i++) {
        int fecha = int.parse(finales[i].fecha.substring(6, 10));

        if (getCalificacion(finales[i].calificacion) >= 4 && fecha < 2017) {
          nro_examenes++;
          notas =
              notas + ponderarNota(getCalificacion(finales[i].calificacion));
        }
        /*
      if (getCalificacion(finales[i].calificacion) < 6 && fecha >= 2017) {
        if (getCalificacion(finales[i].calificacion) != 0 &&
            getCalificacion(finales[i].calificacion) != -1) {
          nro_examenes++;
          notas = notas + getCalificacion(finales[i].calificacion);
        }
      }*/
        if (getCalificacion(finales[i].calificacion) >= 6 && fecha >= 2017) {
          nro_examenes++;
          notas = notas + getCalificacion(finales[i].calificacion);
        }
      }
    } else {
      String cookie = await save.mostrarCookie();
      String url = 'https://sysacadweb.frre.utn.edu.ar/Alumnos/estado/';
      var resp = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Cookie": cookie.toString(),
        "Accept": "text/html"
      });
      if (resp.statusCode == 200) {
        var res = parse(resp.body);

        var _resp = res.getElementsByTagName("td").toList();
        for (int i = 0; i <= _resp.length - 1; i++) {
          if (_resp[i].text.contains('Aprobada')) {
            nro_examenes++;
            //print(_resp[i].text.substring(12, 14));
            //print('///');
            int nota_materia = int.parse(_resp[i].text.substring(13, 15));
            notas = notas + ponderarNota(nota_materia);
          }
          //
        }
        //log(resp.body);
      }
    }

    promedio = notas / nro_examenes;
    return promedio;
  }

  double ponderarNota(int notaFinal) {
    double _notaFinal = (2 / 3) * (notaFinal + 5);
    return _notaFinal;
  }

  int getCalificacion(String calif) {
    int nota = 0;
    switch (calif) {
      case 'uno':
        nota = 1;
        break;
      case 'dos':
        nota = 2;
        break;
      case 'tres':
        nota = 3;
        break;
      case 'cuatro':
        nota = 4;
        break;
      case 'cinco':
        nota = 5;
        break;
      case 'seis':
        nota = 6;
        break;
      case 'siete':
        nota = 7;
        break;
      case 'ocho':
        nota = 8;
        break;
      case 'nueve':
        nota = 9;
        break;
      case 'diez':
        nota = 10;
        break;
      case 'Insc.':
        nota = -1;
        break;
    }
    return nota;
  }

  List<String> getParciales(String nota) {
    List<String> notas = [];
    int i = 0;
    while (i <= nota.length) {
      int j = i;
      String _nota = '';
      while (nota[j] != ',') {
        _nota = _nota + nota[j];
      }

      notas.add(_nota);
      i++;
    }
    return notas;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPlanEstudio() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String carrera = prefs.getString('carrera').toString();

    if (carrera == "Ing. Sist. Inf.") {
      var collec = await FirebaseFirestore.instance
          .collection('planestudioISI')
          .orderBy('año')
          .get();
      yield collec;
    }
    if (carrera == 'Ing. Química') {
      var collec = await FirebaseFirestore.instance
          .collection('planestudioIQ')
          .orderBy('año')
          .get();
      yield collec;
    }
    if (carrera == 'Ing. Electromec') {
      var collec = await FirebaseFirestore.instance
          .collection('planestudioIEM')
          .orderBy('año')
          .get();
      yield collec;
    }
  }

  Future<bool> authenticate(String legajo, String password) async {
    bool auth = false;
    var form = <String, String>{
      //'csrfmiddlewaretoken': 'ERhp2jjdLrM2KI9wtcJTIVnZrWPSznqg',
      'radio': 'A',
      'username': legajo,
      'password': password,
    };
    String url = 'https://sysacadweb.frre.utn.edu.ar/';

    var res = await http.post(Uri.parse(url),
        body: form,
        headers: {"Content-Type": "application/x-www-form-urlencoded"});

    if (res.statusCode == 302) {
      cookie = res.headers['set-cookie'];

      save.saveCookie(cookie.toString());
      auth = true;
    } else {
      auth = false;
    }
    return auth;
  }

  Future<String> getNombreAutenticado() async {
    String cookie = await save.mostrarCookie();

    String name = '';
    String url = 'https://sysacadweb.frre.utn.edu.ar/Alumnos/menu/';
    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });

    if (resp.statusCode == 200) {
      var body = parse(resp.body);

      name = body.getElementsByClassName("wel")[1].text;
      name = name.trim();
      // print(name);
    }
    return name;
  }

  Future<List<Materia>> getEstadoAcademico() async {
    List<Materia> finales = [];
    String cookie = await save.mostrarCookie();
    String url = 'https://sysacadweb.frre.utn.edu.ar/Alumnos/Examenes/';
    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      var body = parse(resp.body);

      int i = 0;
      int c = 1;

      while (i <= body.getElementsByTagName('td').length - 1) {
        List<Element> list = body.getElementsByTagName('td').sublist(i, i + 3);
        if (c.isOdd) {
          Materia materia = new Materia(nombre: '', notas: '');
          for (int k = 0; k <= list.length - 1; k++) {
            if (k == 0) {
              materia.fecha = list[k].text;
            }
            if (k == 1) {
              materia.nombre = list[k].text;
            }
            if (k == 2) {
              materia.calificacion = list[k].text;
            }
          }
          finales.add(materia);
        }
        c++;

        i = i + 3;
      }
    }

    return finales;
  }

  //get electivas
  Stream<List<Map<String, dynamic>>> getElectivas() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> materias = [];

    carrerita = prefs.getString('carrera').toString();

    if (carrerita == 'Ing. Química') {
      var collection = FirebaseFirestore.instance.collection('electivasIQ');
      var snap = await collection.get();
      for (var sn in snap.docs) {
        Map<String, dynamic> materia = {};
        materia['año'] = sn['año'];
        materia['horas'] = sn['horas'];

        materia['materia'] = sn['materia'];
        materias.add(materia);
      }
    } else {
      if (carrerita == 'Ing. Sist. Inf.') {
        var collection = FirebaseFirestore.instance.collection('electivasISI');
        var snap = await collection.get();
        for (var sn in snap.docs) {
          Map<String, dynamic> materia = {};
          materia['año'] = sn['año'];
          materia['horas'] = sn['horas'];

          materia['materia'] = sn['materia'];
          materias.add(materia);
        }
      } else {
        if (carrerita == 'Ing. Electromec') {
          var collection =
              FirebaseFirestore.instance.collection('electivasIEM');
          var snap = await collection.get();
          for (var sn in snap.docs) {
            Map<String, dynamic> materia = {};
            materia['año'] = sn['año'];
            materia['horas'] = sn['horas'];

            materia['materia'] = sn['materia'];
            materias.add(materia);
          }
        } else {
          var collection =
              FirebaseFirestore.instance.collection('electivasLAR');
          var snap = await collection.get();
          for (var sn in snap.docs) {
            Map<String, dynamic> materia = {};
            materia['año'] = sn['año'];
            // materia['horas'] = sn['horas'];

            materia['materia'] = sn['materia'];
            materias.add(materia);
          }
        }
      }
    }

    materias.sort((a, b) => (a['año']).compareTo(b['año']));
    yield materias;
  }

  Future<void> getCarrera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = 'https://sysacadweb.frre.utn.edu.ar/Alumnos/Examenes/';
    String cookie = await save.mostrarCookie();
    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      var body = parse(resp.body);

      var carrera = body.getElementsByTagName('td');
      int i = 3;
      if (i <= carrera.length) {
        prefs.setString('carrera', carrera[i].text);
      } else {
        List<Final> finales = await inscripcionExamenes();
        List<String> _materias = [];
        for (int i = 0; i <= finales.length - 1; i++) {
          _materias.add(finales[i].materia);
        }
        bool founded = false;
        var collection =
            FirebaseFirestore.instance.collection('planestudioISI');
        var collection2 =
            FirebaseFirestore.instance.collection('planestudioIQ');
        var collection3 =
            FirebaseFirestore.instance.collection('planestudioIEM');

        var snap = await collection.get();
        for (var sn in snap.docs) {
          String materia = sn['materia'];
          if (_materias.contains(materia)) {
            prefs.setString('carrera', 'Ing. Sist. Inf.');
            founded = true;
          } else {
            print('1');
          }
        }
        if (founded == false) {
          var snap = await collection2.get();
          for (var sn in snap.docs) {
            String materia = sn['materia'];
            if (_materias.contains(materia)) {
              prefs.setString('carrera', 'Ing. Química');
              founded = true;
            } else {
              print('2');
            }
          }
        }
        if (founded == false) {
          var snap = await collection3.get();
          for (var sn in snap.docs) {
            String materia = sn['materia'];
            if (_materias.contains(materia)) {
              prefs.setString('carrera', 'Ing. Electromec');
              founded = true;
            } else {
              print('3');
            }
          }
        }
        carrerita = prefs.getString('carrera').toString();
        // print(carrera);
      }
    }
  }

  Future<dynamic> inscripcionExamenes() async {
    List<Final> _materias = [];
    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Inscripcion_Examen/';
    String cookie = await save.mostrarCookie();
    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    String msg = '';
    if (resp.statusCode == 200) {
      var res = parse(resp.body);
      var strong = res.getElementsByTagName('strong').toList();
      //log(resp.body);
      if (strong.isNotEmpty) {
        msg = strong[0].text;
        return msg;
      }

      var hrefs = res
          .getElementsByTagName('a')
          .where((element) => element.attributes.containsKey('href'))
          .map((e) => e.attributes['href'])
          .toList();
      hrefs.removeWhere(
          (element) => !element!.contains('Inscripcion_Examen/Fechas'));

      var materias = res
          .getElementsByTagName('td')
          .where((element) => element.text.length > 4)
          .toList();
      materias.removeWhere((element) => element == 'Inscribirse');

      for (int i = 0; i <= materias.length - 1; i++) {
        if (materias[i].text.trim() != 'Inscribirse' &&
            materias[i].text.trim() != "Borrar Insc.") {
          Final _final = Final(
              materia: materias[i].text.trim(),
              linkInscripcion: '',
              inscripto: false);
          if (materias[i + 1].text.trim().toString() == "Borrar Insc.") {
            _final.inscripto = true;
          } else {
            _final.inscripto = false;
          }
          _materias.add(_final);
        } else {
          //print(materias[i].text.trim());
        }
      }

      for (int i = 0; i <= hrefs.length - 1; i++) {
        _materias[i].linkInscripcion = hrefs[i].toString();
      }
    }

    return _materias;
  }
/*
  Future<void> borrarInscripcionExamen(String fechaExamen) async {
    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Inscripcion_Examen/Borrar/';
  }*/

  Future<List<Final>> getCorrelativasCursar() async {
    List<Final> materias_cursar = [];
    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Correlatividad_Cursado/';
    String cookie = await save.mostrarCookie();

    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      var res = parse(resp.body);

      int i = 0;

      while (i <= res.getElementsByTagName('td').length - 1) {
        List<Element> list = res.getElementsByTagName('td').sublist(i, i + 3);

        Final _final = Final(anio: '', condicion: '', materia: '');

        for (int k = 0; k <= list.length - 1; k++) {
          if (list[k].text != '2008') {
            if (list[k].text.length == 1) {
              _final.anio = list[k].text.trim();
            } else {
              if (list[k].text.contains('regularizó') ||
                  list[k].text.contains('Puede') ||
                  list[k].text.contains('aprobó')) {
                _final.condicion = list[k].text.trim();
              } else {
                _final.materia = list[k].text.trim();
              }
            }
          }
        }
        materias_cursar.add(_final);

        i = i + 4;
      }
    }
    return materias_cursar;
  }

  Future<List<Final>> getCorrelativasRendir() async {
    List<Final> finales = [];

    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Correlatividad_Rendir/';
    String cookie = await save.mostrarCookie();

    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });

    if (resp.statusCode == 200) {
      var res = parse(resp.body);

      int i = 0;

      while (i <= res.getElementsByTagName('td').length - 1) {
        List<Element> list = res.getElementsByTagName('td').sublist(i, i + 3);

        Final _final = Final(anio: '', condicion: '', materia: '');

        for (int k = 0; k <= list.length - 1; k++) {
          if (list[k].text != '2008') {
            if (list[k].text.length == 1) {
              _final.anio = list[k].text.trim();
            } else {
              if (list[k].text.contains('regularizó') ||
                  list[k].text.contains('Puede') ||
                  list[k].text.contains('aprobó')) {
                _final.condicion = list[k].text.trim();
              } else {
                _final.materia = list[k].text.trim();
              }
            }
          }
        }
        finales.add(_final);

        i = i + 4;
        // i++;
      }
    }
    {
      print(resp.statusCode);
    }

    return finales;
  }
  //asentar inscripcion

  Future<void> efectivizarInscripcion(String id, String nombreMateria) async {
    String cookie = await save.mostrarCookie();

    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Inscripcion_Examen/Inscripcion/';
    var body = {
      "esp": '-',
      "plan": '-',
      "materia": "-",
      "turno": "-",
      "tribunal": "-",
      "fecha": "-",
      "horario": horario,
      "nombre": "-",
      "csrfmiddlewaretoken": token,
    };
    print(id);
    if (id == "0") {
      body["esp"] = turno1[0].attributes["value"].toString();
      body["plan"] = turno1[1].attributes["value"].toString();
      body["materia"] = turno1[2].attributes["value"].toString();
      body["turno"] = turno1[3].attributes["value"].toString();
      body["tribunal"] = turno1[4].attributes["value"].toString();
      body["fecha"] = turno1[5].attributes["value"].toString();
      body["nombre"] = nombreMateria;
    }
    if (id == "1") {
      body["esp"] = turno2[0].attributes["value"].toString();
      body["plan"] = turno2[1].attributes["value"].toString();
      body["materia"] = turno2[2].attributes["value"].toString();
      body["turno"] = turno2[3].attributes["value"].toString();
      body["tribunal"] = turno2[4].attributes["value"].toString();
      body["fecha"] = turno2[5].attributes["value"].toString();
      body["nombre"] = nombreMateria;
    }
    if (id == "2") {
      body["esp"] = turno3[0].attributes["value"].toString();
      body["plan"] = turno3[1].attributes["value"].toString();
      body["materia"] = turno3[2].attributes["value"].toString();
      body["turno"] = turno3[3].attributes["value"].toString();
      body["tribunal"] = turno3[4].attributes["value"].toString();
      body["fecha"] = turno3[5].attributes["value"].toString();
      body["nombre"] = nombreMateria;
    }

    var resp = await http.post(Uri.parse(url), body: body, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      print('inscripcion hecha');
    } else {
      print(resp.body);
    }
  }
  //Inscribirse a una mesa de examen

  Future<dynamic> inscribirExamen(String url) async {
    String cookie = await save.mostrarCookie();
    var strong;
    String message = '';
    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    List<MesaExamen> mesas = [];
    if (resp.statusCode == 200) {
      //log(resp.body);

      var res = parse(resp.body);

      //obtener el tag que muestra que no esta habilitado las inscripciones
      strong = res.getElementsByTagName('strong').toList();

      var info = res.getElementsByTagName('td');

      var _input = res.getElementsByTagName("input");
      ;
      for (int i = 0; i <= _input.length - 1; i++) {
        if (_input[i].attributes["name"] == "csrfmiddlewaretoken".toString()) {
          token = _input[i].attributes["value"].toString();
        }
      }
      MesaExamen mesa = MesaExamen(
        turno: '',
        fecha: '',
        id: '',
      );

      if (_input.length == 27) {
        //Tres turnos

        turno1 = _input.sublist(0, 6);

        turno2 = _input.sublist(7, 13);
        turno3 = _input.sublist(14, 20);
      } else {
        if (_input.length == 18) {
          //dos turnos
          turno1 = _input.sublist(0, 6);
          turno2 = _input.sublist(7, 13);
        } else {
          //un turno
          if (_input.length == 9) {
            turno1 = _input.sublist(0, 6);
          }
        }
      }

      if (info.toString() != '[]') {
        int j = 0;
        if (j < info.length) {
          if (info[0].text.length == 10) {
            mesa.fecha = info[0].text.trim();
            mesa.turno = info[1].text.trim();
            mesa.id = '0';
            if (mesa.turno == "Tarde") {
              horario = "2";
            }
            if (mesa.turno == "Noche") {
              horario = "3";
            }
            if (mesa.turno == "Mañana") {
              horario = "1";
            }
            mesas.add(mesa);
          }
        }
        j = 3;
        if (j < info.length) {
          if (info[3].text.length == 10) {
            MesaExamen mesa = MesaExamen(
              turno: '',
              fecha: '',
              id: '1',
            );
            mesa.fecha = info[3].text.trim();
            mesa.turno = info[4].text.trim();

            mesas.add(mesa);
          }
        }
        j = 6;
        if (j < info.length) {
          if (info[6].text.length == 10) {
            MesaExamen mesa = MesaExamen(
              turno: '',
              fecha: '',
              id: '2',
            );
            mesa.fecha = info[6].text.trim();
            mesa.turno = info[7].text.trim();

            mesas.add(mesa);
          }
        }
      } else {
        message = strong[0].text;
      }
    }
    if (mesas.isNotEmpty) {
      return mesas;
    }
    return message;
  }

  //calcular cantidad de materias aprobadas del intermedio
  Future<num> getMateriasAprobadasIntermedio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    num mat_aprobadas = 0;
    String carrera = prefs.getString('carrera').toString();
    List<Materia> materias = await getEstadoAcademico();

    List<String> nombres =
        List.generate(materias.length, (index) => materias[index].nombre);

    if (carrera == 'Ing. Sist. Inf.') {
      var collec = await FirebaseFirestore.instance.collection('intermedioISI');
      var _documents = await collec.get();
      for (var sn in _documents.docs) {
        if (nombres.contains(sn['materia'])) {
          mat_aprobadas++;
        }
      }
    }
    if (carrera == 'Ing. Química') {
      var collec = await FirebaseFirestore.instance.collection('intermedioIQ');
      var _documents = await collec.get();
      for (var sn in _documents.docs) {
        if (nombres.contains(sn['materia'])) {
          mat_aprobadas++;
        }
      }
    }
    if (carrera == 'Ing. Electromec') {
      return -1;
    }
    return mat_aprobadas;
  }

  //check si esta inscripto
  Future<bool> isInscripto(String materia) async {
    bool result = false;
    List<Materia> materias = await getEstadoAcademico();
    for (int i = 0; i <= materias.length - 1; i++) {
      if (materias[i].nombre == materia) {
        if (materias[i].calificacion == "Insc.") {
          result = true;
        } else {
          result = false;
        }
      }
    }
    return result;
  }

  Future<num> getMateriasAprobadasIngenieria() async {
    num mat_aprobadas = 0;
    //String carrera = prefs.getString('carrera').toString();

    List<Materia> materias = await getEstadoAcademico();
    if (materias.isNotEmpty) {
      for (int i = 0; i <= materias.length - 1; i++) {
        int calif = getCalificacion(materias[i].calificacion);
        String mes = materias[i].fecha.substring(3, 5);

        String anio = materias[i].fecha.substring(6, 10);

        if (calif >= 6 && int.parse(anio) >= 2017 && int.parse(mes) >= 3 ||
            calif >= 4 && int.parse(anio) < 2017 ||
            calif >= 6 && int.parse(anio) >= 2017) {
          mat_aprobadas++;
        }
      }
    } else {
      String cookie = await save.mostrarCookie();
      String url = 'https://sysacadweb.frre.utn.edu.ar/Alumnos/estado/';
      var resp = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Cookie": cookie.toString(),
        "Accept": "text/html"
      });
      if (resp.statusCode == 200) {
        var res = parse(resp.body);

        var _resp = res.getElementsByTagName("td").toList();
        if (resp.toString() != '[]') {
          for (int i = 0; i <= _resp.length - 1; i++) {
            if (_resp[i].text.contains('Aprobada')) {
              mat_aprobadas++;
            }
            //
          }
        }

        //log(resp.body);
      }
    }

    return mat_aprobadas;
  }

  //Calcular horas de electivas
  Future<num> getHorasElectivas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String carrera = prefs.getString('carrera').toString();
    num horas_electivas = 0;

    List<Materia> materias = await getEstadoAcademico();
    if (carrera == 'Ing. Sist. Inf.') {
      var collection =
          await FirebaseFirestore.instance.collection('electivasISI').get();

      for (int i = 0; i <= materias.length - 1; i++) {
        for (var sn in collection.docs) {
          if (materias[i].nombre == sn['materia']) {
            horas_electivas = horas_electivas + sn['horas'];
          } else {
            //print('ioio3');
          }
        }
      }
    }
    if (carrera == 'Ing. Química') {
      var collection =
          await FirebaseFirestore.instance.collection('electivasIQ').get();

      for (int i = 0; i <= materias.length - 1; i++) {
        for (var sn in collection.docs) {
          if (materias[i].nombre == sn['materia'] &&
              sn["dictado"] == "cuatrimestral") {
            horas_electivas = horas_electivas + sn['horas'];
          } else {
            if (materias[i].nombre == sn["materia"] &&
                sn["dictado"] == "anual") {
              horas_electivas = horas_electivas + sn["horas"] * 2;
            }
          }
        }
      }
    }
    if (carrera == 'Ing. Electromec') {
      var collection =
          await FirebaseFirestore.instance.collection('electivasIEM').get();

      for (int i = 0; i <= materias.length - 1; i++) {
        for (var sn in collection.docs) {
          if (materias[i].nombre == sn['materia']) {
            horas_electivas = horas_electivas + sn['horas'];
          }
        }
      }
    }

    return horas_electivas;
  }

  //Inscribirse a una materia

  Future<dynamic> inscribirMateria() async {
    String url =
        'https://sysacadweb.frre.utn.edu.ar/Alumnos/Inscripcion_Cursado/';
    String cookie = await save.mostrarCookie();
    var strong = [];

    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      String msg = '';
      // log(resp.body);
      var res = parse(resp.body);
      strong = res.getElementsByTagName('strong').toList();

      if (strong.isNotEmpty && strong[0].text[0] != 'S') {
        msg = strong[0].text;
        return msg;
      }

      var hrefs = res
          .getElementsByTagName('a')
          .where((element) => element.attributes.containsKey('href'))
          .map((e) => e.attributes['href'])
          .toList();
      hrefs.removeWhere((element) =>
          !element!.contains("/Alumnos/Eliminar_Materia_Cursado") &&
          !element.contains("/Alumnos/Inscribirse_Materia_Cursado"));

      int i = 0;
      var materias = res.getElementsByTagName("td");
      List<String> _anios = [];
      List<String> mat = [];
      List<String> _comision = [];
      List<MateriaCursado> _materias = [];
      while (i <= materias.length - 1) {
        List<Element> sublist = materias.sublist(i, i + 5);
        for (int j = 0; j <= sublist.length - 1; j++) {
          if (j == 0) {
            _anios.add(sublist[j].text);
          }
          if (j == 1) {
            mat.add(sublist[j].text);
          }
          if (j == 2) {
            _comision.add(sublist[j].text);
          }
        }
        i = i + 5;
      }
      for (int i = 0; i <= mat.length - 1; i++) {
        MateriaCursado mate = MateriaCursado(
            materia: mat[i],
            anio: _anios[i],
            comision: _comision[i],
            linkBorradoInscripcion: '',
            linkInscripcion: '');

        _materias.add(mate);
      }
      if (hrefs.length == _materias.length) {
        for (int i = 0; i <= hrefs.length - 1; i++) {
          if (hrefs[i]!.contains("/Alumnos/Eliminar_Materia_Cursado")) {
            _materias[i].linkBorradoInscripcion = hrefs[i].toString();
          } else {
            _materias[i].linkInscripcion = hrefs[i].toString();
          }
        }
      } else {
        String url =
            'https://sysacadweb.frre.utn.edu.ar/Alumnos/Inscripcion_Cursado/';
        var resp = await http.get(Uri.parse(url), headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": cookie.toString(),
          "Accept": "text/html"
        });
        if (resp.statusCode == 200) {
          var res = parse(resp.body);
          var _inp = res.getElementsByTagName("td");
          _inp.removeWhere((element) =>
              element.text.length == 3 ||
              element.text == '2008' ||
              element.text == '95');
          List<String> _anios = [];
          List<String> mat = [];
          List<String> _comision = [];
          for (int i = 0; i <= _inp.length - 1; i++) {
            if (_inp[i].text.contains('aula')) {
              _inp.remove(i);
              _inp.removeAt(i - 1);
            }
          }
          _inp.removeWhere((element) => element.text == 'Inscribirse');
          _inp.removeWhere(
              (element) => element.text.contains('EDIFICIO CENTRAL'));
          _inp.removeWhere((element) => element.text.contains('ANEXO'));

          var materias = res.getElementsByTagName("td");

          while (i <= materias.length - 1) {
            List<Element> sublist = materias.sublist(i, i + 5);
            for (int j = 0; j <= sublist.length - 1; j++) {
              if (j == 0) {
                _anios.add(sublist[j].text);
              }
              if (j == 1) {
                mat.add(sublist[j].text);
              }
              if (j == 2) {
                _comision.add(sublist[j].text);
              }
            }
            i = i + 5;
          }
          mat.removeWhere((element) => element.length == 1);

          List<String> auxmate = mat.toSet().toList();

          for (int i = 0; i <= auxmate.length - 1; i++) {
            MateriaCursado mate = MateriaCursado(
                materia: auxmate[i],
                anio: _anios[i],
                comision: _comision[i],
                linkBorradoInscripcion: '',
                linkInscripcion: '');

            _materias.add(mate);
          }

          int indiceUrl = 0;
          int indiceMateria = 0;
          while (indiceMateria <= _materias.length - 1) {
            if (_materias[indiceMateria].comision == 'Inscribirse') {
              _materias[indiceMateria].linkInscripcion =
                  hrefs[indiceUrl].toString();
              indiceUrl++;
              indiceMateria++;
            } else {
              indiceMateria++;
            }
          }
        }
      }

      return _materias;
    }
  }

  //Efectivizar inscripcion a cursado
  Future<dynamic> efectivizarInscripcionCursado(String url) async {
    String msg = '';
    print('link' + " " + url);
    var strong;
    String cookie = await save.mostrarCookie();
    String _url = 'https://sysacadweb.frre.utn.edu.ar/$url';
    var resp = await http.get(Uri.parse(_url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    List<ComisionCursado> com = [];
    if (resp.statusCode == 200) {
      //log(resp.body);
      int i = 0;
      var res = parse(resp.body);

      List<dynamic> hr = res.getElementsByTagName("td");
      // hr.removeWhere((element) => element.text.trim().length == 0);
      strong = res.getElementsByTagName('strong').toList();
      var _inp = res.getElementsByTagName('input');

      if (strong.isNotEmpty) {
        msg = strong[0].text;
        return msg;
      }

      while (i <= hr.length - 1) {
        List<dynamic> sublist = hr.sublist(i, i + 3);

        ComisionCursado _com = ComisionCursado();

        for (int j = 0; j <= sublist.length - 1; j++) {
          if (j == 0) {
            _com.comision = sublist[j].text;
          }
          if (j == 1) {
            _com.edificio = sublist[j].text;
          }
          if (j == 2) {
            _com.horario = sublist[j].text;
            com.add(_com);
          }
        }

        i = i + 4;
      }
    } else {
      print("codigo de error " + resp.statusCode.toString());
    }
    return com;
  }

  //Hacer inscripcion
  Future<String> makeInscripcion(String url, String comision) async {
    String cookie = await save.mostrarCookie();
    print(url + " " + comision);
    var resp = await http
        .get(Uri.parse('https://sysacadweb.frre.utn.edu.ar/$url'), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    var msg = '';
    List<ComisionCursado> _comi = [];

    if (resp.statusCode == 200) {
      var res = parse(resp.body);

      var _inp = res.getElementsByTagName("input");
      _inp.removeWhere((element) => element.attributes["value"] == 'Inscribir');

      int i = 0;

      Map<String, String> data = {
        'csrfmiddlewaretoken': '-',
        'espH': '-',
        'planH': '-',
        'materiaH': '-',
        'comision': '-',
        'esp': '-',
        'plan': '-',
        'materia': '-',
        'nombre': '-',
      };

      while (i <= _inp.length - 1) {
        int k = 0;
        ComisionCursado comi = ComisionCursado();
        List<Element> sublist = _inp.sublist(i, i + 8);
        while (k <= sublist.length - 1) {
          switch (k) {
            case 0:
              comi.token = sublist[k].attributes["value"].toString();
              break;
            case 1:
              comi.espH = sublist[k].attributes["value"].toString();
              break;
            case 2:
              comi.planH = sublist[k].attributes["value"].toString();
              break;
            case 3:
              comi.materiaH = sublist[k].attributes["value"].toString();
              break;
            case 4:
              comi.comision = sublist[k].attributes["value"].toString();
              break;
            case 5:
              comi.esp = sublist[k].attributes["value"].toString();
              break;
            case 6:
              comi.plan = sublist[k].attributes["value"].toString();
              break;
            case 7:
              comi.materia = sublist[k].attributes["value"].toString();
              _comi.add(comi);
              break;
          }

          k++;
        }
        i = i + 9;
      }
      int index = int.parse(comision) - 1;
      data["csrfmiddlewaretoken"] = _comi[index].token;
      data["espH"] = _comi[index].espH;
      data["planH"] = _comi[index].planH;
      data["materiaH"] = _comi[index].materiaH;
      data["comision"] = _comi[index].comision;
      data["esp"] = _comi[index].esp;
      data["plan"] = _comi[index].plan;
      data["materia"] = _comi[index].materia;
      data["nombre"] = _comi[index].nombre;

      var _resp = await http.post(
        Uri.parse(
          'https://sysacadweb.frre.utn.edu.ar/Alumnos/Guardar_Inscripcion/',
        ),
        body: data,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": cookie.toString(),
          "Accept": "text/html"
        },
      );

      if (_resp.statusCode == 200) {
        // print('inscripcion hecha');
        //log(_resp.body);
        var res = parse(_resp.body);
        var strong = res.getElementsByTagName("strong").toList();
        if (strong.isNotEmpty) {
          msg = strong[0].text;
        }

        //print(strong.toString());
      } else {
        print(_resp.statusCode);
      }
    }
    return msg;
  }

  //Obtener materias cursando actualmente y sus notas
  Future<List<Materia>> getMateriasActuales() async {
    String url = 'https://sysacadweb.frre.utn.edu.ar/Alumnos/Cursado/';
    String cookie = await save.mostrarCookie();

    List<Materia> materias = [];
    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      // log(resp.body);
      var materias_actuales = parse(resp.body);

      List<Element> strong =
          materias_actuales.getElementsByTagName('td').toList();
      var hrefs = materias_actuales
          .getElementsByTagName('a')
          .where((element) => element.attributes.containsKey('href'))
          .map((e) => e.attributes['href'])
          .toList();
      hrefs.removeWhere(
          (element) => !element!.contains('/Inasistencias/Listar'));

      int i = 0;
      while (i <= strong.length - 1) {
        List<Element> sublist = strong.sublist(i, i + 6);

        Materia materia = Materia(nombre: '', notas: '');
        for (int i = 0; i <= sublist.length - 1; i++) {
          if (i == 1) {
            materia.nombre = sublist[i].text;
          }
          if (i == 3) {
            materia.horarios = sublist[i].text;
          }
          if (i == 4) {
            materia.notas = sublist[i].text;
          }
          if (i == 5) {
            materia.condicion = sublist[i].text;
          }
        }

        materias.add(materia);
        i = i + 8;
      }

      for (int i = 0; i <= materias.length - 1; i++) {
        materias[i].inasistencias = hrefs[i].toString();
      }
    }
    return materias;
  }

  Future<Map<String, dynamic>> getInasistencias(String materia) async {
    Map<String, dynamic> data = {};
    SaveSession save = SaveSession();
    String url = 'https://sysacadweb.frre.utn.edu.ar/$materia';
    String cookie = await save.mostrarCookie();

    var resp = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie.toString(),
      "Accept": "text/html"
    });
    if (resp.statusCode == 200) {
      var _inasistencias = parse(resp.body);
      List<Element> strong =
          _inasistencias.getElementsByTagName('span').toList();

      final List<Map<String, String>> inasistencias = [];
      data['materia'] = strong[10].text;
      data['inasistencias'] = strong[11].text;
      data['porcentaje'] = strong[12].text;
      List<Element> elem = _inasistencias.getElementsByTagName('td').toList();
      int i = 0;
      while (i <= elem.length - 1) {
        Map<String, String> cell = {};
        Inasistencias inasist = Inasistencias();
        if (elem[i].text.contains('/')) {
          inasist.fecha = elem[i].text;
        }
        i++;
        inasist.justificada = elem[i].text;
        cell['fecha'] = inasist.fecha;
        cell['justificado'] = inasist.justificada;
        inasistencias.add(cell);

        i++;
      }
      data['detalle_inasistencias'] = inasistencias;
    }
    return data;
  }
}
