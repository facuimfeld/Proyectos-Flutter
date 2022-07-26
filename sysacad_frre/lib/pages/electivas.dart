import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(Electivas());

// ignore: must_be_immutable
class Electivas extends StatelessWidget {
  Services serv = Services();
  bool isLAR = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Electivas',
              style: TextStyle(fontFamily: 'Gotham-Font')),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: serv.getElectivas(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading: Chip(
                              backgroundColor: snapshot.data![index]['año'] == 3
                                  ? Colors.blue
                                  : snapshot.data![index]['año'] == 4
                                      ? Colors.blue.withOpacity(0.25)
                                      : Colors.blue.withOpacity(0.5),
                              label: Text(
                                  snapshot.data![index]['año'].toString() +
                                      '°' +
                                      'año',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gotham-Font')),
                            ),
                            subtitle: Text(
                                'Horas:' +
                                    ' ' +
                                    snapshot.data![index]['horas'].toString(),
                                style: TextStyle(fontFamily: 'Gotham-Font')),
                            title: Text(snapshot.data![index]['materia'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Gotham-Font')));
                      });
                }
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}
