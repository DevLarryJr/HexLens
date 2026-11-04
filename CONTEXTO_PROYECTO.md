# Contexto del proyecto: HexLens Studio (app móvil Flutter)

> Documento para darle contexto a un asistente de IA. Estado al 28/10/2026.

## 1. Qué es

**HexLens Studio** es una app móvil para la gestión de un **estudio de fotografía** en Colombia (español, es_CO, precios en COP).
Es un proyecto académico (SENA/CECAR). El diseño viene de Figma ("HexLens"): estética editorial, fondo crema, negro
y acento bermellón/rojo.

Tiene dos roles:
- **Administrador / Gestor**: agenda, reservas, clientes, fotógrafos (staff), servicios, especialidades, horarios,
  inasistencias, comisiones y cierres de caja.
- **Fotógrafo**: pantalla "Mis Servicios" con sus sesiones y comisiones.

## 2. Tecnología

- **Flutter 3.47 / Dart 3.13**, en Windows. Paquete: `proyecto_movil`.
- Dependencias: `google_fonts` (Noto Sans y JetBrains Mono), `flutter_svg`, `flutter_localizations`,
  `shared_preferences`.
- Sin gestor de estado externo: `StatefulWidget` + `setState`, y `ValueNotifier` para avisar cambios de datos.
- **No hay git** en la carpeta del proyecto.
- Comandos:
  - `flutter analyze` → debe quedar en "No issues found!".
  - `flutter test` → 118 tests, todos pasan.
  - `flutter run` (mejor en emulador Android o celular; en Chrome el depurador a veces muestra un error inofensivo
    `removeChild` al hacer hot restart).

## 3. Estructura (`lib/`, ~21.700 líneas, 122 archivos)

```
lib/
  main.dart              arranque: carga clientes guardados, MaterialApp (locale es_CO, tema)
  navegacion.dart        Rutas (push, login, sesionDetalle, liquidacion), LoginPage, FotografoHome
  core/reloj.dart        Reloj: fecha/hora actual (ahora(), hoy, dia(n,h,m)); en tests se fija
  theme/app_theme.dart   AppColors, AppText (tamaño mínimo 12 px), AppRadius (xs 2, sm 4, md 8, lg 12), AppShadows
  utils/formato.dart     fechas en español, formatCop, milesConPunto, sinTildes, coincideBusqueda, etc.
  utils/formateadores.dart  formato al escribir: formatoDocumento (1.098.765.432), formatoTelefono (300 123 4567)
  models/                Cliente, Sesion, Servicio, Especialidad, Fotografo, Inasistencia, Jornada, Cierre, ...
  data/                  datos de ejemplo (mock_*.dart) — aquí se conectará la API
  screens/               34 pantallas y hojas modales
  widgets/               widgets compartidos + carpetas por módulo (agenda, reserva, cierres, staff, ...)
test/                    36 archivos de pruebas
assets/icons/, assets/images/   SVG exportados de Figma y fotos
REFACTOR_PROGRESS.md     bitácora detallada de todos los cambios hechos
```

### Pantallas principales
- **Login**, recuperación de acceso, splash.
- **HomeShell** (admin, `screens/home_shell.dart`): barra inferior Inicio · Agenda · Clientes · Más (menú con
  Búsqueda, Especialidades, Servicios, Fotógrafos, Horarios, Inasistencias, Cierres, Cerrar sesión).
- **Agenda**: vistas Día / Semanas / Mensual, flechas de semana o mes, selector de fecha, "Volver a hoy",
  filtros por estado y fotógrafo.
- **Nueva reserva** en 4 pasos: Cliente → Servicio → Fecha y hora (tira de días + calendario) → Confirmación.
- **Detalle de sesión**, **Reagendar** (calendario mensual, franjas según la agenda; mueve la sesión de verdad),
  hojas de **Cancelar** y **Atendido**.
- **Clientes**: directorio, ficha "Nuevo Cliente" y hoja "Registrar Cliente".
- **Staff**: catálogo de fotógrafos, registrar profesional, condiciones/comisión, horario semanal,
  configurar jornada (navega semanas), inasistencias (gestión y registro).
- **Servicios** y **Especialidades**: catálogos y formularios de creación.
- **Finanzas**: cierres de período, nuevo cierre, liquidación de comisiones.
- **Rol fotógrafo**: Mis Servicios.

## 4. Convenciones del código (respetarlas)

- **Todo en español**: nombres de clases, variables, comentarios (`///` con doc en español) y textos de la UI.
- **DRY**: antes de crear un widget, usar los compartidos:
  - `widgets/hex_widgets.dart`: `HexHeader` (vuelve atrás por defecto), `HexCard`, `HexButton`, `Tag`,
    `IconoTexto`, `SvgIcon`, `Dot`, `HeaderScaffold`, `mostrarHoja(...)`, mixin `RedibujarAlCambiar`.
  - `widgets/hex_form.dart`: `FieldLabel`, `HexTextField` (con `formatos:`), `MensajeCampo`, `ParAcciones` +
    `BarraAcciones` (botones de pie), `EncabezadoSeccion`, `TarjetaCampo`, `InfoBox`, `showHexToast`,
    `confirmarSalida(...)` y mixin `ProtegeCambios` (formularios).
  - `widgets/hex_search_field.dart`: `HexSearchField` y mixin `ConBusqueda` (controlador `busqueda`).
  - `widgets/calendario_mensual.dart`: `CalendarioMensual`, `FlechaCalendario`, `FechaElegida`.
- **Una sola salida por pantalla**:
  - Pantallas de consulta: solo la ← del header. Abrirlas con `Rutas.push(context, pantalla, desde: 'Agenda')` para
    que el header diga a dónde vuelve ("AGENDA ›"). Nada de "Volver a ..." repetido en el contenido.
  - Formularios: `HexHeader(cerrar: true)` (✕), sin botón "Cancelar/Descartar" abajo; el `State` usa `ProtegeCambios`
    (`firmaFormulario` + `protegerSalida(...)`; al guardar, `salirSinPreguntar()`).
  - Nueva reserva: ✕ = salir de toda la reserva (pregunta); "Volver" / atrás del sistema = paso anterior.
  - Hojas modales: sin ✕; se cierran con el botón secundario de `ParAcciones` o deslizando hacia abajo.
- Colores, textos y radios **siempre** desde `AppColors`, `AppText` y `AppRadius` (nada de números sueltos).
- Fechas: usar `Reloj.hoy` / `Reloj.ahora()`, nunca `DateTime.now()` directo (así los tests son deterministas).
- Búsquedas: `coincideBusqueda(consulta, [campos])`, que ignora tildes y mayúsculas.
- Cada cambio se verifica con `flutter analyze` + `flutter test` y se anota en `REFACTOR_PROGRESS.md`.
- Tests: el reloj está fijo en **jueves 15/10/2026 09:45** (`test/flutter_test_config.dart`) y
  `SharedPreferences` usa un almacenamiento simulado vacío.

## 5. Datos: hoy son de ejemplo (mock)

- Viven en `lib/data/mock_*.dart` y están **anclados a la fecha real** (`Reloj`).
- `mock_agenda.dart` genera sesiones de ejemplo ±120 días alrededor de hoy (siempre iguales por fecha; pasadas
  realizadas, futuras programadas). No agenda a un fotógrafo en sus días de ausencia.
- `reagendarSesion()` mueve una sesión; `revisionAgenda` (ValueNotifier) avisa a las pantallas abiertas.
- **Clientes**: `registrarCliente(...)` crea el cliente y lo **guarda en el celular** con `shared_preferences`
  (temporal); `cargarClientesRegistrados()` se llama en `main`. `revisionClientes` avisa los cambios.
- Lo demás (reservas creadas, reagendamientos, servicios nuevos...) vive solo en memoria y se pierde al cerrar la app.

## 6. La API real (la entrega el profesor)

- Base: `https://api.ehily.cecar.cloud` (API "Ehily", multiempresa; los ejemplos de la colección son de una
  barbería, los datos de este proyecto deben ser de fotografía).
- Colección de **Bruno** en `C:\Users\SENA\Desktop\Ehily API - Gestor` (archivos `.bru`). Ya se probó:
  login OK y `GET /api/clientes` → 200.
- Autenticación: `POST /api/sesion` con `{ "Usuario": "<cédula>", "Clave": "<clave>" }` → devuelve un **JWT**
  (rol "Gestor", claim `empresaId`). Las demás rutas usan `Authorization: Bearer <token>`. Algunas rutas
  públicas usan el header `X-Empresa-Id`.
- Formato de respuesta: `{ "success": bool, "code": "CLIENTS_RETRIEVED", "message": "...", "data": ... }`.

| Recurso | Rutas | Cuerpo |
|---|---|---|
| Sesión | `POST /api/sesion` | `Usuario`, `Clave` |
| Clientes | `GET/POST /api/clientes`, `GET /api/clientes/{documento}`, `PUT/DELETE /api/clientes/{id}` | `Documento`, `Nombres`, `Apellidos`, `FechaNacimiento` (yyyy-MM-dd), `Celular`, `Correo` |
| Especialidades | CRUD `/api/especialidades` | `Nombre` |
| Servicios | CRUD `/api/servicios` | `Nombre`, `Precio`, `Descripcion`, `Duracion` (min), `Especialidad` (id) |
| Profesionales | CRUD `/api/profesionales`, `GET /api/profesionales/{id}/especialiades` | `Documento`, `Nombres`, `Apellidos`, `FechaNacimiento`, `Porcentaje`, `Estado`, `Especialidad` |
| Agenda / horarios | `GET /api/agenda?fecha=&servicioId=&profesionalId=`, `GET /api/agenda/{fecha}` | — |
| Reservas | CRUD `/api/reservas`, filtro `?FechaInicio=&FechaFin=` | `Fecha`, `ServicioId`, `ClienteId` (o datos de cliente nuevo: `Documento`, `Nombres`, `Apellidos`, `Celular`) |
| Comisiones | `GET /api/comisiones?profesionalId=` o `?cierreId=`, `GET /api/comisiones/{id}/servicios` | — |
| Liquidaciones | `GET /api/liquidaciones-comisiones` (`?ultimo=true`), `POST` | `fechaInicio`, `fechaFin` |

No hay rutas para inasistencias ni jornada laboral: esas siguen locales.

### Reglas para conectar la API
- **Nunca** escribir el token ni contraseñas en el código. La app hace login con lo que escribe el usuario, guarda
  el token y lo manda en cada petición; si responde 401, volver al login.
- Reemplazar los datos de ejemplo **dentro de `lib/data/`** (p. ej. `registrarCliente`, `clientes`,
  `sesionesAgenda`) para que las pantallas casi no cambien.
- Orden sugerido: login → clientes → especialidades y servicios → profesionales → reservas y agenda → comisiones
  y liquidaciones.
- Falta conocer el formato exacto de `data` en cada respuesta (campos de cliente, servicio, reserva, login).

## 7. Pendiente / ideas

1. Conectar el resto de la API (sección 6). Ya están conectados el login, los clientes, las especialidades, los servicios, los profesionales, las reservas/agenda y las comisiones/liquidaciones (`lib/api/`, paquete `http`): toda la API de la colección.
2. Guardar en el celular también las reservas y reagendamientos (hoy solo los clientes).
3. Partir los widgets más largos (`InasistenciaCard`, `JornadaDiaCard`, `ServicioStaffCard`, `ResumenReservaCard`).
4. Mantener `flutter analyze` limpio y los 118 tests en verde.
