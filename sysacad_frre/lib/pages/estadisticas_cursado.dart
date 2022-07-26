import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:MiUTNFRRe/utils/save_session.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(EstadisticasCursado());

class EstadisticasCursado extends StatefulWidget {
  @override
  State<EstadisticasCursado> createState() => _EstadisticasCursadoState();
}

class _EstadisticasCursadoState extends State<EstadisticasCursado> {
  Services serv = Services();
  SaveSession save = SaveSession();
  String carrera = '';
  @override
  void initState() {
    super.initState();
    getCarrera();
  }

  Future<void> getCarrera() async {
    carrera = await save.getCarrera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Estadisticas de Cursado',
              style: TextStyle(fontFamily: 'Gotham-Font')),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Center(
              child: FutureBuilder<num>(
                  future: serv.getMateriasAprobadasIngenieria(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 20.0,
                        percent: snapshot.data! / 42,
                        curve: Curves.linear,
                        animation: true,
                        center: carrera == 'Ing. Sist. Inf.'
                            ? Text(
                                ((snapshot.data! / 42) * 100)
                                        .toStringAsFixed(0) +
                                    '%',
                                style: TextStyle(
                                    fontFamily: 'Gotham-Font',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40.0))
                            : carrera == 'Ing. Química'
                                ? Text(
                                    ((snapshot.data! / 42) * 100)
                                            .toStringAsFixed(0) +
                                        '%',
                                    style: TextStyle(
                                        fontFamily: 'Gotham-Font',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40.0))
                                : Text(
                                    ((snapshot.data! / 46) * 100)
                                            .toStringAsFixed(0) +
                                        '%',
                                    style: TextStyle(
                                        fontFamily: 'Gotham-Font',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40.0)),
                        progressColor: Color(0xff008f39),
                      );
                    }
                    return CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 20.0,
                      percent: 0,
                      curve: Curves.linear,
                      animation: true,
                      center:
                          const CircularProgressIndicator(color: Colors.grey),
                      progressColor: Colors.green,
                    );
                  }),
            ),
            SizedBox(height: 15),
            Container(
              child: Text('PROGRESO',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Gotham-Font',
                      fontSize: 20.0)),
            ),
            SizedBox(height: 10),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              indent: 20.0,
              endIndent: 20.0,
            ),
            SizedBox(height: 10),
            ListTile(
                trailing: FutureBuilder<double>(
                    future: serv.getPromedio(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(snapshot.data!.toStringAsFixed(2),
                            style: TextStyle(
                                color: Colors.grey, fontFamily: 'Gotham-Font'));
                      }
                      return const SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ),
                      );
                    }),
                title: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text('PROMEDIO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Gotham-Font')),
                )),
            ListTile(
                trailing: FutureBuilder<num>(
                    future: serv.getMateriasAprobadasIngenieria(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        switch (carrera) {
                          case 'Ing. Sist. Inf.':
                            return Text(
                                snapshot.data!.toStringAsFixed(0) + '/42',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Gotham-Font'));
                          case 'Ing. Química':
                            return Text(
                                snapshot.data!.toStringAsFixed(0) + '/42',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Gotham-Font'));
                          case 'Ing. Electromec':
                            return Text(
                                snapshot.data!.toStringAsFixed(0) + '/48',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Gotham-Font'));
                        }
                      }
                      return const SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ),
                      );
                    }),
                title: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text('MATERIAS APROBADAS',
                      style: TextStyle(
                          fontFamily: 'Gotham-Font',
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                )),
            ListTile(
                trailing: FutureBuilder<num>(
                    future: serv.getHorasElectivas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data! >= 23 &&
                                carrera == 'Ing. Sist. Inf.' ||
                            snapshot.data! >= 44 && carrera == 'Ing. Química') {
                          return Text('Horas completadas',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gotham-Font'));
                        } else {
                          return carrera == 'Ing. Sist. Inf.'
                              ? Text(snapshot.data!.toStringAsFixed(0) + '/22',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Gotham-Font',
                                      fontWeight: FontWeight.bold))
                              : Text(snapshot.data!.toStringAsFixed(0) + '/44',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Gotham-Font',
                                      fontWeight: FontWeight.bold));
                        }
                      }
                      return const SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ),
                      );
                    }),
                title: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text('HORAS ELECTIVAS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Gotham-Font')),
                )),
          ],
        ));
  }
}
