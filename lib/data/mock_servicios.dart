import 'package:flutter/foundation.dart';

import '../models/especialidad.dart';
import '../models/servicio.dart';
import '../models/servicio/servicio_request.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/servicios_api.dart';
import 'mock_especialidades.dart';

const _ejemplo = [
  Servicio(
    codigo: '#SRV-001',
    nombre: 'Retrato profesional',
    categoria: 'Retratos',
    duracionMin: 45,
    descripcion: '3 fotos con retoque digital HD y cambio de fondo en ciclorama.',
    ficha:
        '3 fotos con retoque digital HD y ciclorama blanco. Nota: Nombre y especialidad bloqueados; precio y duración editables.',
    precio: 120000,
    popular: true,
  ),
  Servicio(
    codigo: '#SRV-002',
    nombre: 'Sesión de graduación individual',
    categoria: 'Retratos',
    duracionMin: 60,
    descripcion:
        '5 fotografías retocadas de toga, birrete y traje formal con tomas familiares incluidas.',
    ficha: '5 fotografías retocadas de toga, birrete y tomas familiares en estudio cerrado de luz suave.',
    precio: 150000,
  ),
  Servicio(
    codigo: '#SRV-003',
    nombre: 'Sesión familiar',
    categoria: 'Familiar',
    duracionMin: 60,
    descripcion: 'Hasta 5 integrantes + mascotas en Set Principal con esquema lumínico editorial cálido.',
    precio: 180000,
  ),
  Servicio(
    codigo: '#SRV-004',
    nombre: 'Sesión de maternidad',
    categoria: 'Familiar',
    duracionMin: 90,
    descripcion: 'Incluye vestuario y 8 fotos finales editadas con etalonaje cromático de alta definición.',
    precio: 220000,
  ),
  Servicio(
    codigo: '#SRV-005',
    nombre: 'Fotografía de producto básica',
    categoria: 'Productos',
    duracionMin: 90,
    descripcion: 'Mesa de luz y bodegón comercial. Limpieza digital de imperfecciones y formato e-commerce listo.',
    precio: 250000,
  ),
  Servicio(
    codigo: '#SRV-006',
    nombre: 'Sesión editorial',
    categoria: 'Editorial',
    duracionMin: 120,
    descripcion: 'Dirección de arte e iluminación especializada. Concepto vanguardista para catálogos y portafolios.',
    precio: 350000,
  ),
  Servicio(
    codigo: '#SRV-007',
    nombre: 'Retrato corporativo ejecutivo',
    categoria: 'Retratos',
    duracionMin: 60,
    descripcion: 'Sesión orientada a LinkedIn y memorias anuales. Incluye iluminación de contraste suave.',
    precio: 160000,
  ),
  Servicio(
    codigo: '#SRV-008',
    nombre: 'Sesión familiar en estudio',
    categoria: 'Familiar',
    duracionMin: 90,
    descripcion: '10 fotografías retocadas con hasta 6 integrantes y dos cambios de fondo.',
    precio: 220000,
  ),
  Servicio(
    codigo: '#SRV-009',
    nombre: 'Fotografía de producto e-commerce',
    categoria: 'Productos',
    duracionMin: 120,
    descripcion: '15 tomas sobre fondo blanco con recorte listo para tienda en línea.',
    precio: 280000,
  ),
  Servicio(
    codigo: '#SRV-010',
    nombre: 'Editorial de moda',
    categoria: 'Editorial',
    duracionMin: 180,
    descripcion: 'Producción con dirección de arte, 3 looks y 12 imágenes para publicación.',
    precio: 450000,
  ),
];

final List<Servicio> serviciosEstudio = [..._ejemplo];

final revisionServicios = ValueNotifier(0);

Servicio _deEjemplo(String codigo) => _ejemplo.firstWhere((s) => s.codigo == codigo);

final servicioEjemplo = _deEjemplo('#SRV-001');

List<Servicio> get serviciosCatalogo => SesionActual.conectada
    ? serviciosEstudio
    : [for (final c in ['#SRV-001', '#SRV-002', '#SRV-003', '#SRV-004', '#SRV-005', '#SRV-006']) _deEjemplo(c)];

List<Servicio> get serviciosReserva => SesionActual.conectada
    ? serviciosEstudio
    : [for (final c in ['#SRV-001', '#SRV-002', '#SRV-007', '#SRV-008', '#SRV-009', '#SRV-010']) _deEjemplo(c)];

List<Servicio> serviciosDe(Especialidad e) => [
      for (final s in serviciosEstudio)
        if (e.id != null ? s.especialidadId == e.id : s.categoria == e.nombre) s,
    ];

Future<void> sincronizarServicios() async {
  if (!SesionActual.conectada) return;
  final deLaApi = await ServiciosApi().listar(nombreEspecialidad: nombreEspecialidad);
  serviciosEstudio
    ..clear()
    ..addAll(deLaApi);
  revisionServicios.value++;
}

Future<Servicio> crearServicio({
  required String nombre,
  required int precio,
  required String descripcion,
  required int duracionMin,
  required Especialidad especialidad,
}) async {
  final Servicio nuevo;
  if (SesionActual.conectada) {
    final request = ServicioRequest(
      nombre: nombre,
      precio: precio,
      descripcion: descripcion,
      duracionMin: duracionMin,
      especialidadId: especialidad.id ?? 0,
    );
    nuevo = await ServiciosApi().crear(request, nombreEspecialidad: nombreEspecialidad);
  } else {
    nuevo = Servicio(
      codigo: '#SRV-${(serviciosEstudio.length + 1).toString().padLeft(3, '0')}',
      nombre: nombre.trim(),
      categoria: especialidad.nombre,
      duracionMin: duracionMin,
      descripcion: descripcion.trim(),
      precio: precio,
    );
  }
  serviciosEstudio.add(nuevo);
  revisionServicios.value++;
  return nuevo;
}

Future<Servicio> actualizarServicio(Servicio s, {required int precio, required int duracionMin, required String descripcion}) async {
  if (SesionActual.conectada && s.id != null) {
    await ServiciosApi().actualizar(
      s.id!,
      ServicioRequest(
        nombre: s.nombre,
        precio: precio,
        descripcion: descripcion,
        duracionMin: duracionMin,
        especialidadId: s.especialidadId ?? 0,
      ),
    );
  }
  final editado = Servicio(
    id: s.id,
    codigo: s.codigo,
    nombre: s.nombre,
    categoria: s.categoria,
    especialidadId: s.especialidadId,
    duracionMin: duracionMin,
    descripcion: descripcion.trim(),
    precio: precio,
    popular: s.popular,
    activo: s.activo,
  );
  final i = serviciosEstudio.indexOf(s);
  if (i >= 0) serviciosEstudio[i] = editado;
  revisionServicios.value++;
  return editado;
}

Future<void> eliminarServicio(Servicio s) async {
  if (SesionActual.conectada && s.id != null) await ServiciosApi().eliminar(s.id!);
  serviciosEstudio.remove(s);
  revisionServicios.value++;
}
