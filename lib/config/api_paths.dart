class ApiPaths {
  const ApiPaths._();

  static const String login = '/sesion';

  static const String clientes = '/clientes';

  static String cliente(String documento) => '/clientes/$documento';

  static const String especialidades = '/especialidades';

  static String especialidad(int id) => '/especialidades/$id';

  static const String servicios = '/servicios';

  static String servicio(int id) => '/servicios/$id';

  static const String profesionales = '/profesionales';

  static String profesional(int id) => '/profesionales/$id';

  static String profesionalesPorServicio(int servicioId) => '/profesionales/$servicioId/especialiades';

  static const String reservas = '/reservas';

  static String reserva(int id) => '/reservas/$id';

  static const String agenda = '/agenda';

  static const String horariosLaborales = '/horarios-laboral';

  static String horarioLaboral(int id) => '/horarios-laboral/$id';

  static String horariosDeProfesional(int profesionalId) => '/horarios-laboral/profesional/$profesionalId';

  static const String liquidaciones = '/liquidaciones-comisiones';

  static const String comisiones = '/comisiones';

  static String serviciosDeComision(int comisionId) => '/comisiones/$comisionId/servicios';
}
