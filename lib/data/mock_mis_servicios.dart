import '../core/reloj.dart';
import '../models/sesion.dart';
import 'mock_agenda.dart';

const comisionStaffPct = 30;

String _rsv(int n) => '#RSV-${Reloj.hoy.year}-0$n';

final misServicios = [
  Sesion(
    inicio: Reloj.dia(0, 10),
    duracionMin: 45,
    lugar: 'Set Estudio A',
    cliente: 'Valentina Ruiz',
    descripcion: 'Retrato Profesional',
    fotografo: 'Sara Torres',
    precio: 120000,
    estado: estadoSegunReloj(Reloj.dia(0, 10), 45),
    codigo: _rsv(42),
    equipo: 'A7IV / 50mm 1.2',
  ),
  Sesion(
    inicio: Reloj.dia(0, 8, 30),
    duracionMin: 60,
    lugar: 'Set B Ciclorama',
    cliente: 'Daniel Castro',
    descripcion: 'Sesión de graduación individual',
    fotografo: 'Sara Torres',
    precio: 150000,
    estado: estadoSegunReloj(Reloj.dia(0, 8, 30), 60),
    codigo: _rsv(38),
  ),
  Sesion(
    inicio: Reloj.dia(-7, 9),
    duracionMin: 60,
    lugar: 'Locación Exterior Terraza',
    cliente: 'Elena Gómez',
    descripcion: 'Retrato profesional corporativo',
    fotografo: 'Sara Torres',
    precio: 130000,
    estado: SesionEstado.realizada,
    codigo: _rsv(29),
  ),
];
