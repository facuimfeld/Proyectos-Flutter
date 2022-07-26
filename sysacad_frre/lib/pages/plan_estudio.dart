import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(PlanEstudio());

class PlanEstudio extends StatefulWidget {
  @override
  State<PlanEstudio> createState() => _PlanEstudioState();
}

class _PlanEstudioState extends State<PlanEstudio> {
  Services serv = Services();
  String carrera = '';
  var _key = new GlobalKey<ScaffoldState>();
  getCarrera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    carrera = prefs.getString("carrera").toString();
  }

  @override
  void initState() {
    super.initState();
    getCarrera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Plan de Estudio'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: serv.getPlanEstudio(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        leading: Chip(
                            backgroundColor: snapshot.data!.docs[index]
                                        ['año'] ==
                                    1
                                ? Color(0xff2CA5F6)
                                : snapshot.data!.docs[index]['año'] == 2
                                    ? Color(0xff2681D4)
                                    : snapshot.data!.docs[index]['año'] == 3
                                        ? Color(0xff19569C)
                                        : snapshot.data!.docs[index]['año'] == 4
                                            ? Color(0xff2667D4)
                                            : Color(0xff3C599B),
                            label: Text(
                                snapshot.data!.docs[index]['año'].toString() +
                                    '°' +
                                    'año',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        title: Text(snapshot.data!.docs[index]['materia'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)));
                  });
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class Intermedio extends StatefulWidget {
  String carrera = '';
  Intermedio({required this.carrera});

  @override
  State<Intermedio> createState() => _IntermedioState();
}

class _IntermedioState extends State<Intermedio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Plan Intermedio'),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back))),
      body: widget.carrera == "Ing. Sist. Inf."
          ? Image.network(
              'https://www.frre.utn.edu.ar/isi/clean/files/get/item/3730',
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : Container(),
    );
  }
}
