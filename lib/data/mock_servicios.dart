import 'package:flutter/foundation.dart';

import '../api/api.dart';
import '../api/servicios_api.dart';
import '../models/especialidad.dart';
import '../models/servicio.dart';
import 'mock_especialidades.dart';

/// Servicios de ejemplo (sin sesión en la API): una sola tarifa por servicio en toda la app.
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

/// Servicios del estudio: los de la API si hay sesión, si no los de ejemplo.
final List<Servicio> serviciosEstudio = [..._ejemplo];

/// Cambia cada vez que se crea, edita o elimina un servicio.
final revisionServicios = ValueNotifier(0);

/// Servicio de ejemplo por código. Lanza si no existe (los códigos de abajo son fijos).
Servicio _deEjemplo(String codigo) => _ejemplo.firstWhere((s) => s.codigo == codigo);

/// Servicio por defecto de las pantallas de la reserva cuando no hay ninguno elegido.
final servicioEjemplo = _deEjemplo('#SRV-001');

/// Servicios del catálogo administrativo: todos los de la API, o 6 de ejemplo (Figma "Catálogo de Servicios").
List<Servicio> get serviciosCatalogo => Api.conectada
    ? serviciosEstudio
    : [for (final c in ['#SRV-001', '#SRV-002', '#SRV-003', '#SRV-004', '#SRV-005', '#SRV-006']) _deEjemplo(c)];

/// Servicios que se ofrecen en el paso 2 de "Nueva reserva": todos los de la API, o 6 de ejemplo.
List<Servicio> get serviciosReserva => Api.conectada
    ? serviciosEstudio
    : [for (final c in ['#SRV-001', '#SRV-002', '#SRV-007', '#SRV-008', '#SRV-009', '#SRV-010']) _deEjemplo(c)];

/// Servicios de una especialidad (por su id de la API o, en los de ejemplo, por su nombre).
List<Servicio> serviciosDe(Especialidad e) => [
      for (final s in serviciosEstudio)
        if (e.id != null ? s.especialidadId == e.id : s.categoria == e.nombre) s,
    ];

/// Con sesión en la API, reemplaza la lista por la de `GET /api/servicios`. Lanza [ApiError] si falla.
Future<void> sincronizarServicios() async {
  if (!Api.conectada) return;
  final deLaApi = await obtenerServiciosApi();
  serviciosEstudio
    ..clear()
    ..addAll([for (final s in deLaApi) servicioDesdeApi(s, nombreEspecialidad: nombreEspecialidad)]);
  revisionServicios.value++;
}

/// Crea un servicio (en la API si hay sesión) y lo agrega a la lista.
Future<Servicio> crearServicio({
  required String nombre,
  required int precio,
  required String descripcion,
  required int duracionMin,
  required Especialidad especialidad,
}) async {
  final Servicio nuevo;
  if (Api.conectada) {
    final json = await crearServicioApi(servicioParaApi(
      nombre: nombre,
      precio: precio,
      descripcion: descripcion,
      duracionMin: duracionMin,
      especialidadId: especialidad.id ?? 0,
    ));
    nuevo = servicioDesdeApi(json, nombreEspecialidad: nombreEspecialidad);
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

/// Cambia precio, duración y descripción de [s] (en la API si hay sesión). El nombre y la especialidad no
/// se cambian, para no alterar el histórico de sesiones y comisiones.
Future<Servicio> actualizarServicio(Servicio s, {required int precio, required int duracionMin, required String descripcion}) async {
  if (Api.conectada && s.id != null) {
    await actualizarServicioApi(
      s.id!,
      servicioParaApi(
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

/// Elimina el servicio (en la API si hay sesión). Si la API lo rechaza, lanza [ApiError] y no se quita.
Future<void> eliminarServicio(Servicio s) async {
  if (Api.conectada && s.id != null) await eliminarServicioApi(s.id!);
  serviciosEstudio.remove(s);
  revisionServicios.value++;
}
