import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:MiUTNFRRe/pages/electivas.dart';
import 'package:MiUTNFRRe/pages/estadisticas_cursado.dart';
import 'package:MiUTNFRRe/pages/estado_academico.dart';
import 'package:MiUTNFRRe/pages/correlativas.dart';

import 'package:MiUTNFRRe/pages/inscripciones.dart';

import 'package:MiUTNFRRe/pages/login.dart';
import 'package:MiUTNFRRe/pages/materias_actuales.dart';
import 'package:MiUTNFRRe/pages/plan_estudio.dart';
import 'package:MiUTNFRRe/utils/save_session.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(Home());

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Services serv = Services();
  String carrera = '';

  SaveSession save = SaveSession();
  int currentIndex = 0;
  bool obscure = false;
  late Future<String> getNombre;
  @override
  void initState() {
    getNombre = loadData();

    //serv.getNombreAutenticado();

    super.initState();

    serv.getCarrera();
  }

  final _tabs = [
    EstadoAcademico(),
    Correlativas(),
    Inscripciones(),
    MateriasActuales(),
  ];
  Future<String> loadData() async {
    return await serv.getNombreAutenticado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.6),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                save.deleteCarrera();
                save.borrarCookie();
                save.deleteData();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              icon: FaIcon(FontAwesomeIcons.powerOff, size: 18.0)),
          actions: [
            PopupMenuButton(
                iconSize: 18.0,
                padding: EdgeInsets.zero,
                initialValue: 3,
                itemBuilder: (context) {
                  return List.generate(3, (index) {
                    return PopupMenuItem(
                        enabled: true,
                        mouseCursor: MouseCursor.defer,
                        child: (index == 0)
                            ? GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EstadisticasCursado())),
                                child: const Text('Estadisticas de cursado'))
                            : (index == 1)
                                ? GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Electivas())),
                                    child: const Text('Electivas'))
                                : GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PlanEstudio())),
                                    child: const Text('Plan de Estudio')));
                  });
                }),
          ],
          title: Column(
            children: [
              FutureBuilder<String>(
                  future: getNombre,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(snapshot.data!.substring(11),
                          style: TextStyle(fontFamily: 'Gotham-Font'));
                    }
                    return Container();
                  }),
            ],
          ),
        ),
        body: SafeArea(child: _tabs[currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Color(0xff1c1c1c),
            selectedItemColor: Color(0xff3c599b),
            unselectedItemColor: Colors.white,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  label: 'Finales',
                  icon: Icon(Icons.school),
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  label: 'Correlativas',
                  icon: FaIcon(Icons.list_alt_outlined),
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  label: 'Inscripciones',
                  icon: FaIcon(FontAwesomeIcons.pencilAlt),
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  label: 'Cursado',
                  icon: FaIcon(FontAwesomeIcons.paperclip),
                  backgroundColor: Colors.blue),
            ]));
  }
}
