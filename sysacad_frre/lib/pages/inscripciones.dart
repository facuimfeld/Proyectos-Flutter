import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:MiUTNFRRe/models/comisioncursado.dart';
import 'package:MiUTNFRRe/models/final.dart';
import 'package:MiUTNFRRe/models/materia_cursado.dart';
import 'package:MiUTNFRRe/models/mesa_examen.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(Inscripciones());

class Inscripciones extends StatefulWidget {
  @override
  State<Inscripciones> createState() => _InscripcionesState();
}

class _InscripcionesState extends State<Inscripciones>
    with TickerProviderStateMixin {
  late TabController tabController;
  Services serv = Services();
  int currentIndex = 0;
  var _key = new GlobalKey<ScaffoldState>();
  bool inscripto = false;

  @override
  void initState() {
    super.initState();

    tabController = TabController(initialIndex: 0, length: 2, vsync: this)
      ..addListener(() {
        setState(() {
          switch (tabController.index) {
            case 0:
              currentIndex = 0;
              break;
            case 1:
              currentIndex = 1;

              break;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: currentIndex,
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            indicatorColor: Color(0xff3c599b),
            tabs: [
              Tab(
                child: Text('Exámenes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gotham-Font')),
              ),
              Tab(
                child: Text('Cursado',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gotham-Font')),
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          examenes(),
          cursado(),
        ]),
      ),
    );
  }

  Widget tabs() {
    return Builder(
        builder: (context) => Container(
            color: Colors.black,
            height: 48,
            child: Column(children: <Widget>[
              Align(
                child: TabBar(
                  labelColor: Colors.white,
                  labelStyle:
                      const TextStyle(color: Colors.black, fontSize: 20.0),
                  indicatorSize: TabBarIndicatorSize.tab,
                  isScrollable: true,
                  controller: tabController,
                  tabs: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: const Tab(
                        child: Text(
                          'Cursado',
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: 'Gotham-Font'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: const Tab(
                        child: Text('Examenes',
                            style: TextStyle(
                                fontSize: 20.0, fontFamily: 'Gotham-Font')),
                      ),
                    ),
                  ],
                ),
                alignment: Alignment.bottomLeft,
              )
            ])));
  }

  Widget examenes() {
    return FutureBuilder<dynamic>(
        future: serv.inscripcionExamenes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data is String) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(snapshot.data!.toString()),
                  ),
                ],
              );
            }
            if (snapshot.data is List) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data!.length != 0) {
                      return ListTile(
                        title: Text(snapshot.data![index].materia,
                            style: TextStyle(
                                fontFamily: 'Gotham-Font',
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        trailing: snapshot.data![index].inscripto == true
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                                child: Text('Inscripto',
                                    style: TextStyle(
                                        fontFamily: 'Gotham-Font',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xff3c599b),
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  String url =
                                      'https://sysacadweb.frre.utn.edu.ar/' +
                                          snapshot.data![index].linkInscripcion
                                              .toString();

                                  _modalBottomSheetMenu(
                                      url, snapshot.data![index].materia);
                                },
                                child: Text('Inscribirme',
                                    style: TextStyle(
                                        fontFamily: 'Gotham-Font',
                                        fontWeight: FontWeight.bold))),
                      );
                    }
                    return Center(
                        child: Text('Usted no tiene materias por rendir',
                            style: TextStyle(
                                fontFamily: 'Gotham-Font',
                                fontWeight: FontWeight.bold,
                                color: Colors.white)));
                  });
            }
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  void _modalBottomSheetInscripcion(MateriaCursado materia) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: FutureBuilder<dynamic>(
                future:
                    serv.efectivizarInscripcionCursado(materia.linkInscripcion),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data! is List) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                                child: Text('Cursado de ${materia.materia}',
                                    style: TextStyle(
                                        fontFamily: 'Gotham-Font',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0)),
                              ),
                            ),
                            SizedBox(height: 5),
                            SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                child: DataTable(
                                    columnSpacing: 10,
                                    dataRowHeight: 100.0,
                                    columns: [
                                      DataColumn(
                                          label: Text('Comision-Curso',
                                              style: TextStyle(
                                                  fontFamily: 'Gotham-Font'))),
                                      DataColumn(
                                          label: Text('Edificio',
                                              style: TextStyle(
                                                  fontFamily: 'Gotham-Font'))),
                                      DataColumn(
                                          label: Text('Horario',
                                              style: TextStyle(
                                                  fontFamily: 'Gotham-Font'))),
                                      DataColumn(
                                          label: Text('Inscripcion',
                                              style: TextStyle(
                                                  fontFamily: 'Gotham-Font'))),
                                    ],
                                    rows: buildDataRowInscripcionCursado(
                                        snapshot.data!, materia)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Inscripcion a cursado de ${materia.materia}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontFamily: 'Gotham-Font',
                                      color: Colors.white,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(snapshot.data!.toString(),
                                style: TextStyle(fontFamily: 'Gotham-Font')),
                          )),
                        ],
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ));
        });
  }

  void _modalBottomSheetMenu(String url, String nombreMateria) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            height: 250.0,
            color: Colors.black,
            child: FutureBuilder<dynamic>(
                future: serv.inscribirExamen(url),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data! is List) {
                      return DataTable(
                        columns: [
                          DataColumn(
                              label: Text('Fecha',
                                  style: TextStyle(fontFamily: 'Gotham-Font'))),
                          DataColumn(
                              label: Text('Turno',
                                  style: TextStyle(fontFamily: 'Gotham-Font'))),
                          DataColumn(label: Text('')),
                        ],
                        rows: buildDataRow(snapshot.data!, nombreMateria),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined,
                                  color: Color(0xffa52019), size: 22.0),
                              SizedBox(width: 10),
                              Text('Ooops, parece que no te podés anotar',
                                  style: TextStyle(
                                      fontFamily: 'Gotham-Font',
                                      color: Colors.white,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(snapshot.data!.toString(),
                                style: TextStyle(fontFamily: 'Gotham-Font')),
                          )),
                        ],
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          );
        });
  }

  List<DataRow> buildDataRow(List<MesaExamen> examen, String nombreMateria) {
    List<DataRow> rows = [];
    for (int i = 0; i <= examen.length - 1; i++) {
      DataRow row = DataRow(cells: [
        DataCell(Text(examen[i].fecha,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Gotham-Font'))),
        DataCell(Text(examen[i].turno,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Gotham-Font'))),
        DataCell(ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Color(0xff3c599b),
                textStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();

              await serv
                  .efectivizarInscripcion(examen[i].id, nombreMateria)
                  .then(
                    // ignore: deprecated_member_use
                    (value) => _key.currentState!.showSnackBar(SnackBar(
                        backgroundColor: Colors.black,
                        content: Row(
                          children: [
                            CircularProgressIndicator(color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Inscribiendose a la mesa',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gotham-Font')),
                          ],
                        ))),
                  )
                  .whenComplete(
                    // ignore: deprecated_member_use
                    () => _key.currentState!.showSnackBar(SnackBar(
                        backgroundColor: Colors.black,
                        content: Row(
                          children: [
                            Icon(Icons.check, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Inscripcion hecha',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gotham-Font')),
                          ],
                        ))),
                  );
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  Inscripciones();
                });
              });
            },
            child: Text('Inscribirme',
                style: TextStyle(fontFamily: 'Gotham-Font')))),
      ]);

      rows.add(row);
    }

    return rows;
  }

  List<DataRow> buildDataRowInscripcionCursado(
      List<ComisionCursado> comCursado, MateriaCursado materia) {
    List<DataRow> rows = [];

    for (int i = 0; i <= comCursado.length - 1; i++) {
      DataRow row = DataRow(cells: [
        DataCell(Text(comCursado[i].comision,
            style: TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(comCursado[i].edificio,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0))),
        DataCell(Text(comCursado[i].horario,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0))),
        DataCell(ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Color(0xff3c599b),
                textStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: () async {
              int m = 0;

              m = i + 1;

              Navigator.of(context, rootNavigator: true).pop();
              dynamic error = await serv.makeInscripcion(
                  materia.linkInscripcion, m.toString());

              await serv
                  .makeInscripcion(materia.linkInscripcion, m.toString())
                  .then(
                    // ignore: deprecated_member_use
                    (value) => _key.currentState!.showSnackBar(SnackBar(
                        backgroundColor: Colors.black,
                        content: Row(
                          children: [
                            CircularProgressIndicator(color: Color(0xff3c599b)),
                            SizedBox(width: 10),
                            Text('Inscribiendose al cursado...',
                                style: TextStyle(
                                    fontFamily: 'Gotham-Font',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ))),
                  )
                  .whenComplete(
                    // ignore: deprecated_member_use
                    () => _key.currentState!.showSnackBar(SnackBar(
                        backgroundColor: Colors.black,
                        content: error.length > 0
                            ? Row(
                                children: [
                                  Icon(Icons.cancel_outlined,
                                      color: Color(0xffa52019), size: 30.0),
                                  SizedBox(width: 10),
                                  Flexible(
                                    child: Text(error.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Gotham-Font',
                                            fontSize: 14.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(Icons.check, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text('Inscripcion a cursado hecha',
                                      style: TextStyle(
                                          fontFamily: 'Gotham-Font',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ))),
                  );

              ;
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  Inscripciones();
                });
              });
            },
            child: Text('Inscribirme',
                style: TextStyle(fontFamily: 'Gotham-Font')))),
      ]);

      rows.add(row);
    }

    return rows;
  }

  List<DataRow> buildDataRowCursado(List<MateriaCursado> materia) {
    List<DataRow> rows = [];
    for (int i = 0; i <= materia.length - 1; i++) {
      DataRow row = DataRow(cells: [
        DataCell(Text(materia[i].anio,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Gotham-Font'))),
        DataCell(Text(materia[i].materia,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Gotham-Font'))),
        DataCell(
          materia[i].comision == 'Inscribirse'
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xff3c599b),
                      textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gotham-Font')),
                  onPressed: () {
                    _modalBottomSheetInscripcion(materia[i]);
                  },
                  child: Text('Inscribirme',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gotham-Font')))
              : Container(
                  margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(materia[i].comision.substring(0, 33),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gotham-Font')),
                ),
        ),
      ]);

      rows.add(row);
    }

    return rows;
  }

  Widget cursado() {
    return FutureBuilder<dynamic>(
        future: serv.inscribirMateria(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data is String) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(snapshot.data!.toString(),
                        style: TextStyle(fontFamily: 'Gotham-Font')),
                  ),
                ],
              );
            }
            if (snapshot.data is List) {
              return SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: DataTable(
                  columnSpacing: 40,
                  dataRowHeight: 100,
                  horizontalMargin: 4.0,
                  columns: [
                    DataColumn(
                        label: Text('Año',
                            style: TextStyle(fontFamily: 'Gotham-Font'))),
                    DataColumn(
                        label: Text('Materia',
                            style: TextStyle(fontFamily: 'Gotham-Font'))),
                    DataColumn(
                        label: Text('Inscripcion',
                            style: TextStyle(fontFamily: 'Gotham-Font'))),
                  ],
                  rows: buildDataRowCursado(snapshot.data!),
                ),
              ));
            }
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
