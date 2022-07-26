class Final {
  String materia;
  String anio;
  String linkInscripcion;
  String condicion;
  bool inscripto;
  String fechaExamen;
  Final(
      {required this.materia,
      this.anio = '',
      this.inscripto = false,
      this.fechaExamen = '',
      this.condicion = '',
      this.linkInscripcion = ''});
}
