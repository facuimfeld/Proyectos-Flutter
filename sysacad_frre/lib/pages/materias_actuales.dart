import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:MiUTNFRRe/models/inasistencias.dart';
import 'package:MiUTNFRRe/models/materia.dart';
import 'package:MiUTNFRRe/pages/faltas.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(MateriasActuales());

class MateriasActuales extends StatefulWidget {
  @override
  State<MateriasActuales> createState() => _MateriasActualesState();
}

class _MateriasActualesState extends State<MateriasActuales> {
  Services serv = Services();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: FutureBuilder<List<Materia>>(
            future: serv.getMateriasActuales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          borderOnForeground: true,
                          child: ExpansionTile(
                            textColor: Colors.white,
                            subtitle: Text(snapshot.data![index].horarios),
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary:
                                              Color(0xff3c599b) // background
                                          ),
                                      onPressed: () {
                                        if (snapshot
                                                .data![index].notas.length ==
                                            1) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "No hay notas cargadas para" +
                                                      ' ' +
                                                      snapshot
                                                          .data![index].nombre,
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.grey,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        } else {
                                          _parciales(
                                              snapshot.data![index].notas);
                                        }
                                      },
                                      child: const Text('Notas',
                                          style: TextStyle(
                                              fontFamily: 'Gotham-Font'))),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Color(0xff3c599b) // background
                                        ),
                                    child: const Text('Inasistencias',
                                        style: TextStyle(
                                            fontFamily: 'Gotham-Font')),
                                    onPressed: () async {
                                      Map<String, dynamic> data =
                                          await serv.getInasistencias(snapshot
                                              .data![index].inasistencias);
                                      if (int.parse(data['inasistencias']) ==
                                          0) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "No tiene inasistencias en esta materia",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.grey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Faltas(data: data)));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                            title: Text(snapshot.data![index].nombre,
                                style: const TextStyle(
                                    fontFamily: 'Gotham-Font',
                                    fontWeight: FontWeight.bold)),
                            trailing: snapshot.data![index].condicion.length > 1
                                ? Chip(
                                    label: Text(snapshot.data![index].condicion,
                                        style: const TextStyle(
                                            fontFamily: 'Gotham-Font',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    backgroundColor: snapshot
                                            .data![index].condicion
                                            .contains('Ap.')
                                        ? Color(0xff008f39)
                                        : snapshot.data![index].condicion ==
                                                'Regular'
                                            ? Color(0xffe5be01)
                                            : Color(0xffa52019),
                                  )
                                : const CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                  ),
                          ),
                        );
                      });
                }
                return Center(
                    child: Text('Usted no cursa materias actualmente',
                        style: TextStyle(
                            fontFamily: 'Gotham-Font',
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0)));
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }

  List<String> getParciales(String nota) {
    List<String> notas = [];

    notas = nota.split(new RegExp(r"[,]"));

    return notas;
  }

  void _parciales(String notas) {
    getParciales(notas);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.75,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Icon(
              Icons.remove,
              color: Colors.grey[600],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: getParciales(notas).length,
                itemBuilder: (_, index) {
                  int _index = getParciales(notas)[index].indexOf(':');

                  String firstDigit = getParciales(notas)[index][_index + 2];

                  String secondDigit = getParciales(notas)[index][_index + 3];

                  String _nota = firstDigit + secondDigit;

                  int nota = int.parse(_nota.trim());

                  return Card(
                    child: Padding(
                      child: nota >= 6
                          ? Chip(
                              label: Text(getParciales(notas)[index],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              backgroundColor: Color(0xff008f39),
                            )
                          : Chip(
                              label: Text(getParciales(notas)[index],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              backgroundColor: Color(0xffa52019),
                            ),
                      padding: const EdgeInsets.all(8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
