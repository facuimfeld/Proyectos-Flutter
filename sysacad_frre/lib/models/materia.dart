class Materia {
  String nombre;
  String calificacion;
  String fecha;
  String condicion;
  String horarios;
  String inasistencias;
  String notas;
  Materia(
      {required this.nombre,
      this.calificacion = '',
      this.inasistencias = '',
      this.condicion = '',
      this.fecha = '',
      this.horarios = '',
      this.notas = ''});
}
