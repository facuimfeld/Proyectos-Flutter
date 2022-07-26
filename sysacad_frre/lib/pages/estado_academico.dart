import 'package:animations/animations.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:MiUTNFRRe/models/materia.dart';
import 'package:MiUTNFRRe/pages/login.dart';
import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(EstadoAcademico());

class EstadoAcademico extends StatefulWidget {
  @override
  State<EstadoAcademico> createState() => _EstadoAcademicoState();
}

class _EstadoAcademicoState extends State<EstadoAcademico>
    with SingleTickerProviderStateMixin {
  Services serv = Services();
  late AnimationController controller;
  late Animation<double> animation;

  late Future<List<Materia>> getEstadoAcademico;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    getEstadoAcademico = serv.getEstadoAcademico();
  }

  final options = LiveOptions(
    // Start animation after (default zero)
    delay: Duration(milliseconds: 100),

    // Show each item through (default 250)
    showItemInterval: Duration(milliseconds: 100),

    // Animation duration (default 250)
    showItemDuration: Duration(milliseconds: 100),

    // Animations starts at 0.05 visible
    // item fraction in sight (default 0.025)
    visibleFraction: 0.04,

    // Repeat the animation of the appearance
    // when scrolling in the opposite direction (default false)
    // To get the effect as in a showcase for ListView, set true
    reAnimateOnVisibility: false,
  );
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: FutureBuilder<List<Materia>>(
          future: getEstadoAcademico,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.length != 0) {
                return LiveList(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index,
                      Animation<double> animation) {
                    int anio =
                        int.parse(snapshot.data![index].fecha.substring(6, 10));
                    int calificacion = serv
                        .getCalificacion(snapshot.data![index].calificacion);
                    return FadeTransition(
                      opacity: Tween<double>(
                        begin: 0,
                        end: 1,
                      ).animate(animation),
                      // And slide transition
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        // Paste you Widget
                        child: buildFinal(anio, calificacion, snapshot, index),
                      ),
                    );
                  },
                  //options: options,
                );
              } else {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('No hay examenes cargados',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                            fontFamily: 'Gotham-Font')),
                  ],
                ));
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget buildFinal(int anio, int calificacion,
      AsyncSnapshot<List<Materia>> snapshot, int index) {
    return ListTile(
        trailing: CircleAvatar(
          child: Text(
              calificacion == 0
                  ? 'AU'
                  : calificacion == -1
                      ? 'IN'
                      : calificacion.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Gotham-Font')),
          backgroundColor: calificacion == 0 || calificacion == -1
              ? Colors.grey[500]
              : anio < 2017 && calificacion < 4
                  ? calificacion == 0 || calificacion == -1
                      ? Colors.grey[500]
                      : Color(0xffa52019)
                  : anio < 2017 && calificacion >= 4
                      ? Color(0xff008f39)
                      : anio >= 2017 && calificacion < 6
                          ? calificacion == 0
                              ? Colors.grey[500]
                              : Color(0xffa52019)
                          : anio >= 2017 && calificacion >= 6
                              ? Color(0xff008f39)
                              : Colors.grey[500],
        ),
        title: Text(snapshot.data![index].nombre,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Gotham-Font')),
        subtitle: Text(snapshot.data![index].fecha,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Gotham-Font')));
  }
}
