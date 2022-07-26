import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() => runApp(Faltas(
      data: {},
    ));

class Faltas extends StatefulWidget {
  Map<String, dynamic> data = {};
  Faltas({required this.data});
  @override
  State<Faltas> createState() => _FaltasState();
}

class _FaltasState extends State<Faltas> {
  int index = 0;
  final List<Map<String, String>> list = [];
  @override
  void initState() {
    super.initState();
    buildList();
    index = widget.data['materia'].indexOf(':');
  }

  void buildList() {
    for (int i = 0; i <= widget.data['detalle_inasistencias'].length - 1; i++) {
      list.add(widget.data['detalle_inasistencias'][i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('INASISTENCIAS',
              style: TextStyle(fontSize: 20.0, fontFamily: 'Gotham-Font')),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 40, 0, 0),
                child: Text(
                    'Materia:' + widget.data['materia'].substring(index + 1),
                    style:
                        TextStyle(fontSize: 17.0, fontFamily: 'Gotham-Font')),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text('PORCENTAJE:' + ' ' + widget.data['porcentaje'],
                      style: TextStyle(
                          fontSize: 14.0, fontFamily: 'Gotham-Font'))),
              SizedBox(height: 15),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
                indent: 10.0,
                endIndent: 20.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: MediaQuery.of(context).size.width * 0.5,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Fecha',
                          style: TextStyle(fontFamily: 'Gotham-Font')),
                    ),
                    DataColumn(
                      label: Text('Justificado',
                          style: TextStyle(fontFamily: 'Gotham-Font')),
                    ),
                  ],
                  rows:
                      list // Loops through dataColumnText, each iteration assigning the value to element
                          .map(
                            ((element) => DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(element["fecha"].toString(),
                                        style: TextStyle(
                                            fontFamily: 'Gotham-Font'))),
                                    DataCell(Text(
                                        element["justificado"].toString(),
                                        style: TextStyle(
                                            fontFamily: 'Gotham-Font'))),
                                  ],
                                )),
                          )
                          .toList(),
                ),
              ),
            ]));
  }
}
