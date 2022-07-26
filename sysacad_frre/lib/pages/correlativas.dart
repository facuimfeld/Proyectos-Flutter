import 'dart:async';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:MiUTNFRRe/models/final.dart';

import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(Correlativas());

class Correlativas extends StatefulWidget {
  @override
  State<Correlativas> createState() => _CorrelativasState();
}

class _CorrelativasState extends State<Correlativas>
    with TickerProviderStateMixin {
  late Future<List<Final>> myFuture1;
  late Future<List<Final>> myFuture2;
  late TabController tabController;
  Services serv = Services();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    myFuture1 = serv.getCorrelativasRendir();
    myFuture2 = serv.getCorrelativasCursar();
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
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Tab(
                child: Text('Cursado',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget examenes() {
    return FutureBuilder<List<Final>>(
        future: myFuture1,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return buildExamen(snapshot, index);
                });
          }
          return loading();
        });
  }

  Widget loading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(height: 10),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget buildExamen(AsyncSnapshot<List<Final>> snapshot, int index) {
    return ListTile(
        leading: snapshot.data![index].condicion == 'Puede Inscribirse'
            ? const CircleAvatar(
                backgroundColor: Color(0xff008f39),
                child: FaIcon(Icons.check, color: Colors.white),
              )
            : const CircleAvatar(
                backgroundColor: Color(0xffa52019),
                child: FaIcon(Icons.close, color: Colors.white),
              ),
        title: Text(snapshot.data![index].materia,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(snapshot.data![index].condicion));
  }

  Widget cursado() {
    return FutureBuilder<List<Final>>(
        future: myFuture2,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: snapshot.data![index].condicion == 'Puede Cursar'
                          ? const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: FaIcon(Icons.check, color: Colors.white),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: FaIcon(Icons.close, color: Colors.white),
                            ),
                      title: Text(snapshot.data![index].materia,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(snapshot.data![index].condicion));
                });
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(height: 10),
                CircularProgressIndicator(),
              ],
            ),
          );
        });
  }
}
