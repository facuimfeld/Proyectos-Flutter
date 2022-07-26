import 'package:MiUTNFRRe/models/final.dart';

class MateriaCursado {
  String materia = '';
  String anio = '';
  String comision = '';
  String horario = '';
  String linkInscripcion = '';
  String linkBorradoInscripcion = '';
  MateriaCursado(
      {required this.materia,
      this.anio = '',
      this.horario = '',
      this.comision = '',
      this.linkInscripcion = '',
      this.linkBorradoInscripcion = ''});
}
