# Refactor progress: `lib/screens`

Regla: mejorar la estructura sin cambiar la apariencia ni el comportamiento (el diseño viene de Figma).
Modo: **normal** (se confirma antes de modificar cada archivo).

## Inventario

Columnas: líneas · clases/enums de modelo · listas mock · métodos `Widget _x()` que construyen UI.

### Prioridad alta (> 400 líneas o mezcla de UI con datos/lógica)

- [x] `nueva_reserva_servicio_screen.dart`: 810 → 230 líneas
- [x] `reagendar_sesion_screen.dart`: 788 → 157 líneas
- [x] `agenda_screen.dart`: 780 → 288 líneas
- [x] `nueva_reserva_fecha_screen.dart`: 726 → 214 líneas
- [x] `mis_servicios_screen.dart`: 671 → 212 líneas
- [x] `inicio_admin_screen.dart`: 658 → 172 líneas
- [x] `catalogo_fotografos_screen.dart`: 646 → 270 líneas
- [x] `catalogo_clientes_screen.dart`: 622 → 224 líneas
- [x] `horario_semanal_screen.dart`: 620 → 145 líneas
- [x] `nueva_reserva_confirmacion_screen.dart`: 559 → 168 líneas
- [x] `confirmaciones_sheets.dart`: 558 → 5 (re-exporta `cancelacion_sheet.dart` 275 y `atendido_sheet.dart` 267)
- [x] `gestion_inasistencias_screen.dart`: 533 → 284 líneas
- [x] `sesion_detalle_screen.dart`: 509 → 125 líneas
- [x] `configurar_jornada_screen.dart`: 508 → 207 líneas
- [x] `catalogo_especialidades_screen.dart`: 506 → 126 líneas
- [x] `nueva_reserva_cliente_screen.dart`: 486 → 147 líneas
- [x] `catalogo_servicios_screen.dart`: 476 → 112 líneas
- [x] `crear_servicio_screen.dart`: 472 → 237 líneas
- [x] `cierres_periodo_screen.dart`: 470 → 72 líneas
- [x] `busqueda_global_screen.dart`: 470 → 145 líneas
- [x] `nuevo_cierre_screen.dart`: 468 → 136 líneas
- [x] `liquidacion_comisiones_screen.dart`: 463 → 89 líneas
- [x] `login_screen.dart`: 428 → 187 líneas
- [x] `actualizar_condiciones_screen.dart`: 427 → 180 líneas

### Prioridad media (250–400 líneas)

- [x] `registrar_inasistencia_screen.dart`: 394 → 183 líneas
- [x] `registrar_profesional_screen.dart`: 390 → 186 líneas
- [x] `recuperacion_acceso_screen.dart`: 372 → 127 líneas
- [x] `ficha_nuevo_cliente_screen.dart`: 350 → 270 líneas
- [x] `splash_screen.dart`: 307 → 76 líneas
- [x] `registrar_cliente_sheet.dart`: 286 → 183 líneas
- [x] `nueva_especialidad_sheet.dart`: 273 → 129 líneas

### Sin cambios

Ninguno: todos los archivos superan las 250 líneas.

## Repeticiones entre archivos (candidatas a widgets compartidos)

| Patrón | Archivos | Destino propuesto |
|---|---|---|
| Matriz `_grayscale` | catalogo_fotografos, nueva_reserva_servicio | `lib/theme/app_theme.dart` |
| Campo de búsqueda | busqueda_global, catalogo_clientes, catalogo_fotografos, catalogo_servicios, mis_servicios | `HexSearchField` en `lib/widgets/` |
| Chips de filtro horizontales | 13 pantallas | `HexFilterChips` en `lib/widgets/` |
| Colores `Color(0x…)` hardcodeados | busqueda_global (10), actualizar_condiciones (10), catalogo_clientes (7)… | tokens en `AppColors` |
| Modelos privados (`_Fotografo`, `_Cliente`, `_Servicio`…) y mocks | ~14 pantallas | `lib/models/` y `lib/data/mock_data.dart` |

## Widgets compartidos creados

Fase compartida, hecha antes de los archivos. Verificada con los 32 goldens: idénticos.

| Elemento | Ubicación | Uso |
|---|---|---|
| `AppShadows.hairline` | `lib/theme/app_theme.dart` | Reemplazó 19 `BoxShadow(0x0D000000, 0/1/2)` en 13 archivos |
| `AppColors.graphite`, `surfaceDim`, `success`, `successDark` | `lib/theme/app_theme.dart` | Reemplazaron 13 colores escritos a mano |
| `AppFilters.grayscale` | `lib/theme/app_theme.dart` | Reemplazó la matriz `_grayscale` duplicada (fotógrafos, reserva-servicio) |
| `HexSearchField` | `lib/widgets/hex_search_field.dart` | Para catálogos de clientes, fotógrafos y servicios (se aplica en cada ciclo) |
| `HexChip` + `HexChipBar` | `lib/widgets/hex_chips.dart` | Chips de filtro. Usado en: nueva_reserva_servicio |
| `AppColors.error` | `lib/theme/app_theme.dart` | Rojo de error `#BA1A1A` |
| `Servicio` | `lib/models/servicio.dart` | Modelo de servicio (precio `int` en COP). Reutilizar en catálogo de servicios y mis servicios |
| `formatCop()` | `lib/utils/formato.dart` | `120000` → `$120.000`. Reutilizar en liquidación, cierres, crear servicio |
| `SelectCheck` | `lib/widgets/reserva/servicio_card.dart` | Círculo de selección negro/gris |
| `BlurBottomBar` | `lib/widgets/hex_widgets.dart` | Barra inferior desenfocada. Usado en: reagendar, `ResumenFooter`, nueva_reserva_cliente (blur 12) |
| `AppShadows.bottomBar` | `lib/theme/app_theme.dart` | Sombra `(0,-4,16)` de las barras inferiores |
| `AppColors.disabled`, `neutralDot` | `lib/theme/app_theme.dart` | Texto deshabilitado 40 % y punto neutro |
| `nombreDia`, `nombreMes`, `mesCorto`, `fechaLarga` | `lib/utils/formato.dart` | Fechas en español. Reutilizar en agenda, fecha de reserva, horario, cierres |
| `FranjaHoraria` | `lib/models/franja_horaria.dart` | Franja con motivo de bloqueo. Candidato para nueva_reserva_fecha |
| `SeccionHeader` | `lib/widgets/reagendar/seccion_header.dart` | Encabezado "01 // TÍTULO" + dato a la derecha |
| `Sesion`, `SesionEstado` | `lib/models/sesion.dart` | Sesión con `DateTime`, duración y precio numéricos. Reutilizar en inicio_admin, sesion_detalle, mis_servicios |
| `letraDia`, `mismoDia`, `semanaIso`, `horasDesdeMinutos`, `horaCorta` | `lib/utils/formato.dart` | Utilidades de fecha/hora |
| `EstadoBadge`, `SesionCard` | `lib/widgets/agenda/sesion_card.dart` | Candidatos para inicio_admin (próximas reservas) |
| `HexChip` | `lib/widgets/hex_chips.dart` | Usado también en los filtros de la agenda |
| `AppColors.accentTint`, `accentFaint`, `surfaceHighFaded`, `onDarkFaint` | `lib/theme/app_theme.dart` | Variantes translúcidas; reemplazaron 8 colores en 5 archivos |
| `BloqueHorario`, `BloqueTipo` | `lib/models/bloque_horario.dart` | Bloque de jornada; los libres toman la duración del servicio. Candidato para unificar con `FranjaHoraria` (reagendar) |
| `hoyDemo` | `lib/data/mock_disponibilidad.dart` | "Hoy" simulado (15-oct-2026). Reutilizar donde haya "HOY" |
| `horaAmPm`, `rangoAmPm`, `diaCorto` | `lib/utils/formato.dart` | Horas de 12 h y día abreviado |
| `ReservaProgreso` | `lib/widgets/reserva/reserva_progreso.dart` | Barra "Paso N de 4" + tarjeta del servicio. Revisar si sirve en la confirmación |
| `AppColors.glassHeader`, `glassBar`, `glassSolid` | `lib/theme/app_theme.dart` | Fondos crema translúcidos 85/90/95 %; reemplazaron 15 colores |
| `BlurTopBar` | `lib/widgets/hex_widgets.dart` | Header propio con blur. Usado en: mis_servicios, busqueda_global (alto 72, padding izq. 8) |
| `BlurBottomBar.shadow` | `lib/widgets/hex_widgets.dart` | Sombra configurable; usado por `StaffBottomNav` |
| `Sesion.codigo`, `Sesion.equipo` | `lib/models/sesion.dart` | Mis Servicios reutiliza el modelo `Sesion` de la agenda |
| `Sesion.servicio` / `nombreServicio` | `lib/models/sesion.dart` | Nombre corto del servicio vs. `descripcion` (detalle) |
| `AppColors.surfaceFaded` | `lib/theme/app_theme.dart` | Blanco 80 % (inicio, especialidades) |
| `ModuloLink`, `HardwareStatusCard`, `KpiResumen` | `lib/widgets/inicio/` | Tarjetas del inicio administrativo |
| `Fotografo`, `EstadoFotografo` | `lib/models/fotografo.dart` | Staff con score y comisión numéricos. Reutilizar en liquidación, horario, inasistencias, reserva |
| `fotografos` | `lib/data/mock_fotografos.dart` | Los 4 fotógrafos del estudio |
| `EstadoFotografoBadge` | `lib/widgets/fotografos/fotografo_card.dart` | Etiqueta En turno / Disponible / Almuerzo / Inactivo |
| `HexSearchField` | `lib/widgets/hex_search_field.dart` | Usado en: catálogo de fotógrafos, catálogo de clientes |
| `Cliente`, `EstadoCliente` | `lib/models/cliente.dart` | Cliente con iniciales calculadas. Reutilizar en nueva_reserva_cliente, ficha, búsqueda |
| `clientes` | `lib/data/mock_clientes.dart` | Directorio de clientes |
| `AppColors.onAccentBright`, `accentWash` | `lib/theme/app_theme.dart` | Blanco cálido sobre rojo y rojo al 10 % |
| `AppColors.neutralContainer`, `onNeutralContainer` | `lib/theme/app_theme.dart` | Etiqueta azulada de jornada especial |
| `Jornada` + `semanaLaura()` | `lib/models/jornada.dart`, `lib/data/mock_horario.dart` | Jornada con minutos reales. Reutilizar en configurar_jornada, inasistencias |
| `StaffTabs` | `lib/widgets/staff/staff_tabs.dart` | Movido desde horario_semanal (se re-exporta ahí); parámetro `inasistencias` para el globo |
| `JornadaDiaCard`, `StaffPerfilCard`, `HorarioMetricas`, `SemanaNavegador` | `lib/widgets/staff/` | Tarjetas del horario semanal |
| `AppColors.outlineFaint`, `scrim` | `lib/theme/app_theme.dart` | Líneas suaves 30 % y velo negro 80 % (splash, crear servicio, confirmación) |
| `MedioPago` + `mediosPago` | `lib/models/medio_pago.dart`, `lib/data/mock_pagos.dart` | Transferencia / Efectivo |
| `Cliente.ciudad` | `lib/models/cliente.dart` | Ciudad de expedición del documento |
| `AppColors.barrier`, `barrierStrong`, `accentBorder`; `AppShadows.sheetActions` | `lib/theme/app_theme.dart` | Velos y bordes de hojas modales (también especialidad y registrar cliente) |
| `ConfirmacionSheetFrame`, `SheetAcciones`, `OrdenHeader` | `lib/widgets/sheets/confirmacion_sheet_frame.dart` | Marco de hojas de confirmación |
| `sesionEnGestion`, `clientePorNombre`, `fotografoPorNombre` | `lib/data/` | Sesión del detalle (Valentina, #ORD-9821) y búsquedas por nombre |
| `Inasistencia` + `inasistencias` | `lib/models/inasistencia.dart`, `lib/data/mock_inasistencias.dart` | Con vigencia por fecha. Reutilizar en registrar_inasistencia y en la disponibilidad de la reserva |
| `InasistenciaCard` | `lib/widgets/staff/inasistencia_card.dart` | Capacitación / cita médica / licencia |
| `fechaCorta` | `lib/utils/formato.dart` | "04 Oct 2026" |
| `iniciales()` | `lib/utils/formato.dart` | "Laura Méndez" → "LM" (lo usa también `Cliente.iniciales`) |
| `AppColors.scrimSoft` | `lib/theme/app_theme.dart` | Negro 70 % (etiquetas sobre fotos) |
| `DetalleBreadcrumb`, `DetalleHeroCard`, `MoodboardRow`, `AgendaDetalleCard`, `ServicioLiquidacionCard` | `lib/widgets/detalle/detalle_cards.dart` | Tarjetas del detalle de sesión |
| `FichaJornadaCard`, `DiaProgramaSelector`, `HoraStepperBox`, `ValidacionRow`, `TurnoCard`, `AlmuerzoCard`, `AplicarTodosCard` | `lib/widgets/jornada/jornada_cards.dart` | Configuración de jornada. `HoraStepperBox` y `ValidacionRow` sirven para registrar_inasistencia |
| `Especialidad` + `especialidades`, `titularDe()` | `lib/models/especialidad.dart`, `lib/data/mock_especialidades.dart` | El titular sale del fotógrafo con esa especialidad. Reutilizar en nueva_especialidad_sheet, crear_servicio |
| `SincronizacionBanner`, `EspecialidadesTitulo`, `ConteoChip`, `EspecialidadCard`, `EspecialidadInactivaCard` | `lib/widgets/especialidades/especialidad_cards.dart` | `ConteoChip` (chip con contador) sirve para otros filtros con conteo |
| `HexSearchField.radius`, `iconMinWidth` | `lib/widgets/hex_search_field.dart` | Radio y ancho del ícono configurables (por defecto 4 y 44) |
| `AppColors.onDarkSoft` | `lib/theme/app_theme.dart` | `surfaceHighest` al 30 % (contador sobre chip negro) |
| `ReservaClienteIntro`, `ResultadosHeader`, `ClienteResultadoCard`, `ParametrosRapidosCard` | `lib/widgets/reserva/cliente_seleccion.dart` | Paso 1 de la reserva |
| `Cliente.coincide()`, `sinTildes()`, `soloDigitos()` | `lib/models/cliente.dart`, `lib/utils/formato.dart` | Búsqueda por nombre sin tildes, cédula o teléfono. Candidato para catalogo_clientes y busqueda_global |
| `HexSearchField.hint` opcional | `lib/widgets/hex_search_field.dart` | Sin pista no se crea `hintText` |
| `serviciosEstudio` (10), `serviciosCatalogo`, `serviciosReserva`, `servicioPorCodigo()` | `lib/data/mock_servicios.dart` | Una sola lista de servicios con código y tarifa únicos; cada pantalla toma sus 6 por código |
| `Servicio.codigo`, `ficha`, `activo` | `lib/models/servicio.dart` | Código #SRV, ficha técnica del catálogo y estado |
| `ServiciosCabecera`, `CategoriaChip`, `EstadoSegmentos`, `ServicioCatalogoCard`, `IntegridadNota` | `lib/widgets/servicios/servicio_catalogo_cards.dart` | Catálogo de servicios. `EstadoSegmentos` sirve para otros Todos/Activos/Inactivos |
| `CatalogoFranja`, `EtiquetaCampo`, `AyudaCampo`, `RepartoTarifa`, `DuracionHeader`, `DuracionSelector`, `PresetCard`, `DisponibleCard`, `FichaEquipamiento` | `lib/widgets/servicios/crear_servicio_widgets.dart` | Formulario de servicio. `EtiquetaCampo` y `AyudaCampo` sirven en otros formularios |
| `nombreCorto()` | `lib/utils/formato.dart` | "Laura Méndez" → "Laura M." |
| `Cierre`, `EstadoCierre` + `cierres` | `lib/models/cierre.dart`, `lib/data/mock_cierres.dart` | Cierre quincenal con importes `int` (Estudio = Total − Staff). Reutilizar en nuevo_cierre y liquidación |
| `FinanceTag`, `NuevoCierreBoton`, `PeriodoFiltros`, `ResumenConsolidadoCard`, `HistorialHeader`, `CierreCard`, `ReglaConsolidacion` | `lib/widgets/cierres/cierre_cards.dart` | `FinanceTag` se movió aquí y se re-exporta desde cierres_periodo |
| `BusquedaHeader`, `BusquedaNav`, `BusquedaFiltroChip`, `QueryEstadoBar`, `ResultadoBusquedaCard`, `SinResultados` | `lib/widgets/busqueda/busqueda_widgets.dart` | Búsqueda global (la ilustración vacía es un `CustomPainter` privado) |
| `Liquidacion`, `SesionLiquidada` + `liquidacionesOct1`, `liquidacionesEntre()`, `codigoCierre()` | `lib/models/liquidacion.dart`, `lib/data/mock_cierres.dart` | Comisión = base × tasa del fotógrafo. El cierre #CIE-2026-10A se calcula con ella. Reutilizar en liquidación |
| `PasoAuditoriaHeader`, `RangoLiquidacionCard`, `EscaneoSesiones`, `DesgloseFinancieroCard`, `FotografosInvolucradosHeader`, `FotografoComisionCard` | `lib/widgets/cierres/nuevo_cierre_widgets.dart` | Nuevo cierre contable |
| `AppColors.charcoal` | `lib/theme/app_theme.dart` | Gris `#333333` sobre paneles negros |
| `LiquidacionSelector`, `LiquidacionResumenCard`, `SesionesAsignadasHeader`, `SesionLiquidadaCard`, `FormulaLiquidacion` | `lib/widgets/cierres/liquidacion_widgets.dart` | Liquidación de comisiones (reciben el modelo `Liquidacion`) |
| `LoginTopIndicator`, `LoginEncabezado`, `RolSelector`, `LoginEtiqueta`, `LoginCampo`, `RecordarSesionRow`, `EstadoEstudioCard`, `LoginFooter` | `lib/widgets/login/login_widgets.dart` | Inicio de sesión. `LoginCampo` tiene estado de error (borde rojo); candidato para recuperación de acceso |
| `CondicionesBottomBar`, `ValidacionEstadoBar`, `ErrorGuardarBanner`, `CondicionCard`, `EtiquetaRequerida`, `CampoErrorBox`, `DocumentoVerificadoCard`, `CanalPagoCard`, `AuditoriaCard` | `lib/widgets/condiciones/condiciones_widgets.dart` | Formulario de condiciones; `EtiquetaRequerida` y `CampoErrorBox` sirven en otros formularios |
| `AppColors.errorTag`, `errorWash`, `successContainer` | `lib/theme/app_theme.dart` | `#FFB4AB`, `#FFE9E5`, `#E6F4E7` (este último también en registrar_inasistencia) |
| `PersonalAsignadoCard`, `PeriodoDesconexionCard`, `AuditoriaAgendaCard` | `lib/widgets/staff/registro_inasistencia_widgets.dart` | Registro de ausencia; la auditoría se pone roja con conflictos |
| `RegistroStaffEncabezado`, `SeccionFicha`, `FichaPill`, `ComisionSimuladorCard`, `EstadoOperativoSelector`, `NotaCumplimiento` | `lib/widgets/staff/registro_profesional_widgets.dart` | Alta de profesional |
| `AppColors.accentOverlay` | `lib/theme/app_theme.dart` | `accentBright` al 13 % (halo del deslizador) |
| `RecuperacionTopBar`, `RecuperacionEncabezado`, `SolicitarOtpCard`, `OtpCasillas`, `ValidarOtpCard`, `CaducidadNota` | `lib/widgets/login/recuperacion_widgets.dart` | Recuperación de acceso por OTP |
| `EsquinaTriangulo` | `lib/widgets/hex_widgets.dart` | Triángulo de esquina; unificó los painters de recuperación y liquidación |
| `AltaTitularBanner`, `FichaCard`, `FichaEtiqueta`, `FichaError`, `TipoDocumentoSelector`, `HabeasDataNota` | `lib/widgets/clientes/ficha_cliente_widgets.dart` | Ficha de cliente; candidatos para registrar_cliente_sheet |
| `SplashVisor`, `SplashTelemetria`, `SplashMarca`, `SplashCarga`, `SplashPie` | `lib/widgets/splash/splash_widgets.dart` | Pantalla de carga |
| `AppColors.surfaceHighGhost`, `surfaceHighestFaded` | `lib/theme/app_theme.dart` | `#66EBE8E1` y `#99E5E2DB` del splash |
| `RegistroClienteCabecera`, `RegistroEtiqueta`, `RequeridoMarca`, `HabeasDataBreve`, `RegistroClienteAcciones` | `lib/widgets/clientes/registro_cliente_widgets.dart` | Hoja de alta rápida de cliente |
| `SheetHandle` | `lib/widgets/hex_widgets.dart` | Asa de hojas modales (también nueva_especialidad, ancho 48) |
| `clientePorDocumento()`, `esCorreo()`, `AppColors.whatsapp` | `lib/data/mock_clientes.dart`, `lib/utils/formato.dart`, `lib/theme/app_theme.dart` | Duplicados por dígitos y validación de correo, compartidos por la ficha y la hoja |
| `NuevaEspecialidadCabecera`, `EstadoEspecialidadCard`, `InactivarEspecialidadNota`, `NuevaEspecialidadAcciones`, `ProtocoloEditorialPie` | `lib/widgets/especialidades/nueva_especialidad_widgets.dart` | Hoja de nueva especialidad |

**Herramienta de verificación:** `scratchpad/extraer_original.ps1` recupera del log de la sesión el código original
de un archivo ya modificado (no hay git), para comparar estados que la imagen inicial no muestra.

## Verificación visual

`test/refactor/golden_test.dart` (TEMPORAL) guarda una imagen de referencia de las 27 pantallas y 4 hojas
tomada **antes** del refactor y compara píxel a píxel después de cada cambio. Se borra al terminar.
Nota: las fotos salen negras en el test (no se decodifican imágenes); el layout sí se compara.

**Estado final:** los 31 archivos pasaron la comparación (refactor puro idéntico). La carpeta `test/refactor/` se
borró al terminar; quedan 69 tests permanentes en `test/` y `flutter analyze` sin avisos.

## Registro por archivo

### 1. `nueva_reserva_servicio_screen.dart`: 810 → 230 líneas

**Archivos creados**
- `lib/models/servicio.dart` (24), `lib/data/mock_servicios.dart` (50), `lib/utils/formato.dart` (10)
- `lib/widgets/reserva/reserva_stepper.dart` (139): `ReservaStepper` movido tal cual
- `lib/widgets/reserva/servicio_card.dart` (160): `ServicioCard`, `SelectCheck`
- `lib/widgets/reserva/fotografo_opcion_cards.dart` (273): `AutoAsignarCard`, `FotografoRecomendadoCard`, `FotografoNoDisponibleCard`
- `lib/widgets/reserva/resumen_footer.dart` (124): `ResumenFooter`
- `test/nueva_reserva_servicio_test.dart`: tests permanentes de `formatCop` y del filtro

**Refactor puro:** golden idéntico píxel a píxel.

**Bugs corregidos (paso aparte)**
1. El filtro de categorías no filtraba (solo cambiaba el título). Ahora filtra por `Servicio.categoria`; se añadieron servicios de Familiar, Productos y Editorial al mock.
2. La selección era por índice; ahora es por objeto `Servicio`, así sobrevive al cambio de filtro.
3. El pie obtenía la duración con `meta.split('• ')`; ahora usa `Servicio.duracion`.
4. Contador "4 categorías" fijo → calculado. Precio `String` → `int` + `formatCop`.
5. Textos fijos a "Retrato profesional" / "categoría Retratos" en las tarjetas de fotógrafo → usan el servicio elegido.
6. **Encontrado al probar los datos nuevos:** el pie desbordaba 2.7 px con precios de 6 cifras y 120+ min. Se corrigió con `Flexible` + `FittedBox(scaleDown)`. Golden actualizado: diferencia solo de suavizado sub-píxel (comparado a ojo, idéntico).

**Pendiente (fuera de este archivo):** los fotógrafos (Laura, Nicolás) siguen fijos; se conectarán al modelo de fotógrafo al procesar `catalogo_fotografos_screen.dart`.

### 2. `reagendar_sesion_screen.dart`: 788 → 157 líneas

**Archivos creados**
- `lib/models/franja_horaria.dart` (11), `lib/models/opcion_staff.dart` (13), `lib/data/mock_reagendar.dart` (37)
- `lib/widgets/reagendar/`: `contexto_bloqueado.dart` (224), `calendario_mes.dart` (164), `franja_grid.dart` (147),
  `staff_selector.dart` (146), `politica_card.dart` (59), `seccion_header.dart` (26)
- `BlurBottomBar` en `hex_widgets.dart`; también aplicado a `ResumenFooter` de la reserva
- Tests permanentes: `test/reagendar_sesion_test.dart`, `test/formato_test.dart` (se movió aquí el test de `formatCop`)

**Refactor puro:** golden idéntico píxel a píxel (reagendar y reserva-servicio).

**Bugs corregidos (paso aparte, golden sigue idéntico)**
1. Nombres de día escritos a mano en un mapa → `fechaLarga(DateTime)`; las semanas visibles se calculan desde el lunes del día original.
2. "Sin conflicto en franja de 11:30 AM" fijo → usa la franja elegida.
3. "Original: 18 Oct" y "Octubre 2024" fijos → salen de `diaOriginalReagendar` / `mesReagendar`.
4. El toast decía "Oct" fijo → `mesCorto`.
5. Colores sueltos → `AppColors.disabled`, `AppColors.neutralDot`, `AppShadows.bottomBar`.

**Pendiente:** las flechas ‹ › del mes no hacen nada (sería una funcionalidad nueva: navegar meses).
El título del header está en inglés ("Reschedule Session"), así viene del Figma; no se cambió.

### 3. `agenda_screen.dart`: 780 → 288 líneas

**Archivos creados**
- `lib/models/sesion.dart` (45), `lib/data/mock_agenda.dart` (115)
- `lib/widgets/agenda/`: `sesion_card.dart` (290: `SesionCard`, `SesionCanceladaCard`, `EstadoBadge`), `semana_strip.dart` (155),
  `cierre_resumen_card.dart` (79), `vista_tabs.dart` (58), `nueva_reserva_fab.dart` (38)
- Test permanente: `test/agenda_test.dart` (3 tests)

**Refactor puro:** golden idéntico píxel a píxel. Los chips de filtro pasaron a `HexChip`.

**Bugs corregidos (paso aparte)**
1. Los filtros de estado no filtraban → filtran; contadores calculados desde las sesiones del día.
2. Filtro de staff → real, **sin selección inicial** (decisión del usuario); tocar el mismo fotógrafo lo quita.
   Único cambio visual: el chip "Laura M." arranca gris (golden actualizado; se verificó que es la única diferencia).
3. Tocar otro día no cambiaba nada → cambian título, lista y totales. Mock: +2 sesiones el 14 y +2 el 17,
   así los puntos de la tira salen de los datos (coinciden con el diseño). Aviso cuando no hay sesiones.
4. El día elegido siempre mostraba 3 puntos → muestra sus sesiones (máx. 3).
5. Totales escritos a mano ($700.000, 4.25 h, 15 OCT, Semana 42, "Octubre 2026") → calculados. Precio `String` → `int`.

**Pendiente:** flechas ‹ › de semana y pestañas "Semanas"/"Mensual" (funcionalidad nueva). El día con alerta roja
(sábado 17) sale de `diasConAlertaAgenda` en el mock porque el diseño no dice qué significa.

### 4. `nueva_reserva_fecha_screen.dart`: 726 → 214 líneas

**Archivos creados**
- `lib/models/bloque_horario.dart` (19), `lib/data/mock_disponibilidad.dart` (45)
- `lib/widgets/reserva/`: `bloque_tile.dart` (204), `reserva_progreso.dart` (143), `dia_card.dart` (108),
  `turno_info_cards.dart` (89: `JornadaInfoCard`, `SetAsignadoCard`), `sesion_configurada_card.dart` (86)
- Test permanente: `test/nueva_reserva_fecha_test.dart` (3 tests)
- Nuevo parámetro opcional `servicio` en `NuevaReservaFechaScreen` (no rompe `main.dart`)

**Refactor puro:** golden idéntico píxel a píxel.

**Bugs corregidos (paso aparte)**
1. Todos los días mostraban las mismas franjas (incluida "Sesión Daniel Castro") → bloques por día.
2. Al cambiar de día la franja quedaba por índice → se elige la primera libre del nuevo día.
3. "HOY", "Pasado", "Octubre 2026", "S42", "Oct" → calculados desde la fecha.
4. **Precio, duración y nombre del servicio se leen del modelo `Servicio`** (pedido del usuario), ya no están escritos en la pantalla.

**Cambios visibles aprobados por el usuario** (golden actualizado; se verificó que son las únicas diferencias)
- A. "4 Libres" → "5 Libres" (cuenta real).
- B. "14:15 - 15:00 PM" → "02:15 - 03:00 PM"; "13:00 - 14:00" → "01:00 - 02:00 PM".
- C. Tarifa "$180.000" → "$120.000" (precio real del Retrato profesional).

**Pendiente:** el servicio elegido en el paso 2 no viaja al paso 3 (el flujo usa `VoidCallback`); hoy se usa el
primero del catálogo. Se resolverá con el manejo de estado del flujo de reserva. Flechas ‹ › sin función.

### 5. `mis_servicios_screen.dart`: 671 → 212 líneas

**Archivos creados**
- `lib/data/mock_mis_servicios.dart` (42): reutiliza el modelo `Sesion` (+ `codigo`, `equipo`); el `Widget icono`
  que vivía en los datos ahora lo elige la tarjeta según el tipo de servicio
- `lib/widgets/mis_servicios/`: `servicio_staff_card.dart` (260), `staff_resumen_cards.dart` (227: `ModoStaffBanner`,
  `SaludoStaffCard`, `ContadorServiciosCard`, `ProximaSesionCard`), `staff_bottom_nav.dart` (57)
- `BlurTopBar` en `hex_widgets.dart`; tokens `glass*`
- Test permanente: `test/mis_servicios_test.dart` (2 tests)

**Refactor puro:** golden idéntico píxel a píxel. Ya en este paso, tarifa y comisión pasan a calcularse
(`precio × 30 %` con `formatCop`) y el filtro "Este mes" compara fechas reales; dan los mismos valores.

**Bugs corregidos (paso aparte)**
1. Contador "4" y chip "Todos (4)" con 3 servicios → calculados (aprobado por el usuario: muestra 3).
2. "Próxima sesión" repetía los datos a mano → sale de la primera sesión programada de hoy; se oculta si no hay.
   Efecto visible no consultado: "Set A" → "Set Estudio A" (el lugar de la sesión). Fácil de revertir.
3. Sin aviso cuando la búsqueda no encuentra nada → "Ningún servicio coincide con la búsqueda."

**Sin cambiar (datos del Figma):** "Hola, Sara" con "• Retratos", aunque en el catálogo Sara Torres es de Productos.

### 6. `inicio_admin_screen.dart`: 658 → 172 líneas

**Archivos creados**
- `lib/widgets/inicio/`: `reserva_hoy_card.dart` (275: `ReservaDestacadaCard`, `ReservaHoyCard`), `modulo_link.dart` (104:
  `ModuloLink`, `HardwareStatusCard`), `kpi_resumen.dart` (100), `nueva_reserva_banner.dart` (85, incluye el toast),
  `saludo_admin.dart` (58)
- Test permanente: `test/inicio_admin_test.dart`

**Refactor puro:** golden idéntico píxel a píxel.

**Bugs corregidos (paso aparte)**
1. Las 4 reservas eran una copia a mano de las sesiones de la agenda → salen de `sesionesAgenda` (hoy, sin canceladas,
   programadas por hora y realizadas al final). Si cambia la agenda, cambia el inicio.
2. KPIs "4 / 3 / 1", "4 turnos" y la fecha → calculados (mismos valores).
3. Nuevo campo `Sesion.servicio` para el nombre corto ("Sesión familiar"); la agenda sigue mostrando el detalle.

**Cambio visible aprobado:** "11:30 - 12:30 PM" → "11:30 AM - 12:30 PM" (golden actualizado; única diferencia).

**Pendiente:** el botón "Iniciar" de la reserva destacada no hace nada (funcionalidad nueva).

### 7. `catalogo_fotografos_screen.dart`: 646 → 270 líneas

**Archivos creados**
- `lib/models/fotografo.dart` (36), `lib/data/mock_fotografos.dart` (44)
- `lib/widgets/fotografos/fotografo_card.dart` (362: `FotografoCard`, `EstadoFotografoBadge`, acciones rápidas)
- Test permanente: `test/catalogo_fotografos_test.dart` (2 tests)

**Refactor puro:** golden idéntico. Buscador → `HexSearchField`; chips → `HexChip`/`HexChipBar`; score y comisión numéricos.

**Bugs corregidos (paso aparte, golden sigue idéntico)**
1. Al reactivar, las acciones seguían siendo "Comisiones / Reactivar" → siguen el estado actual (Horarios / Ver Ficha).
2. "3 fotógrafos activos en turno hoy" fijo → calculado; tras reactivar dice 4.
3. Los reactivados se guardaban por nombre → por documento (identificador único).
4. Los chips de especialidad estaban duplicados en una lista aparte → salen de los datos.

**Sin cambiar (Figma):** el header dice "Catalogo Fotografos" sin tildes.
**Pendiente:** la reactivación vive solo en esta pantalla (se pierde al salir); necesita el manejo de estado global.

### 8. `catalogo_clientes_screen.dart`: 622 → 224 líneas

**Archivos creados**
- `lib/models/cliente.dart` (44), `lib/data/mock_clientes.dart` (42)
- `lib/widgets/clientes/cliente_card.dart` (352: tarjeta, recuadro de estado, contacto y acciones)
- Test permanente: `test/catalogo_clientes_test.dart` (2 tests)

**Refactor puro:** golden idéntico. Buscador → `HexSearchField`; chips → `HexChip`.

**Bugs corregidos (paso aparte)**
1. Los textos de estado estaban atados al enum (todo cliente "frecuente" mostraba los datos de Valentina) → viven en cada cliente.
2. "Todos (4)" fijo e iniciales escritas a mano ("AM", "DC") → calculados.
3. Colores sueltos → `AppColors.onAccentBright`, `accentWash` (también en horario, reserva-cliente y fotógrafos).

**Cambio visible aprobado:** el detalle de Andrés sale de su próxima sesión en la agenda:
"15 Oct, 14:00 Studio B" → "15 Oct, 11:30 Set Principal" (golden actualizado; única diferencia).

**Pendiente:** los correos están guardados ya recortados (`andres.m@ex...`); el usuario decidió no cambiarlos por ahora.
Teléfono/correo, "Monitor Set" e "Historial" no hacen nada (funcionalidad nueva).

### 9. `horario_semanal_screen.dart`: 620 → 145 líneas

**Archivos creados**
- `lib/models/jornada.dart` (38), `lib/data/mock_horario.dart` (13)
- `lib/widgets/staff/`: `jornada_dia_card.dart` (316), `horario_cards.dart` (184), `staff_tabs.dart` (112)
- Test permanente: `test/horario_semanal_test.dart` (2 tests)

**Refactor puro:** golden idéntico (también el de inasistencias, que usa `StaffTabs` vía el re-export).

**Bugs corregidos (paso aparte)**
1. Las flechas solo cambiaban la etiqueta → mueven los días de verdad (semana, mes y número ISO calculados).
2. Métricas "40h / 5 Días / 60 min" fijas → calculadas, **sin contar la media jornada** (decisión del usuario; mismos valores).
3. "Hoy en estudio: 3 sesiones", "(8h efectivas)", la pausa "13:00 - 14:00" y el toast "semana 43" → calculados.
4. Colores sueltos → `AppColors.neutralContainer`, `onNeutralContainer`.

**Cambio visible aprobado:** la semana inicial es la de hoy (12–18 oct, HOY = jueves 15), consistente con agenda y
reserva. Antes mostraba 19–25 como "Sem 42" (era la 43). Golden actualizado; solo cambian los números de los días.

**Pendiente:** "CAMBIAR" fotógrafo no hace nada; el lápiz de cada día no le dice a la pantalla de jornada qué día editar;
el globo "1" de Inasistencias se conectará al procesar `gestion_inasistencias_screen.dart`.

### 10. `nueva_reserva_confirmacion_screen.dart`: 559 → 168 líneas

**Archivos creados**
- `lib/widgets/reserva/confirmacion_cards.dart` (487: `ConfirmacionCabecera`, `ResumenReservaCard`, `PagoOpcionTile`)
- `lib/models/medio_pago.dart`, `lib/data/mock_pagos.dart`
- Test permanente: `test/nueva_reserva_confirmacion_test.dart` (2 tests)
- Parámetros opcionales nuevos: `cliente`, `servicio`, `fotografo`, `inicio`, `lugar`, `codigo` (no rompen `main.dart`)

**Refactor puro:** golden idéntico.

**Bugs corregidos (paso aparte):** todo el resumen estaba escrito a mano → sale de `Cliente`, `Servicio` y `Fotografo`
(precio con `formatCop`, duración, comisión, iniciales, documento + ciudad, fecha y horario calculados).

**Cambios visibles aprobados** (goldens actualizados; únicas diferencias)
- Confirmación: "Retrato Profesional" → "Retrato profesional" (nombre del catálogo).
- Catálogo de clientes: los correos se guardan completos (`valentina.ruiz@example.com`); en la tarjeta se cortan con "…".

**Pendiente:** el medio de pago elegido no se informa al confirmar (`onConfirmar` es `VoidCallback`); la etiqueta
"Fotógrafa" es fija (el modelo no tiene género). Ambos con el manejo de estado del flujo de reserva.

### 11. `confirmaciones_sheets.dart`: 558 → 5 + 275 + 267 líneas

**⚠️ Hallazgo en la verificación:** las imágenes de referencia de las 4 hojas modales solo capturaban el botón "go"
(un único `pump` dejaba la hoja en el cuadro 0 de su animación). Se corrigió el test (dos `pump`) y, como no hay git,
se generaron las referencias de estas dos hojas desde una copia literal del código original (archivo temporal ya
borrado). Las hojas de especialidad y registrar cliente aún no se habían tocado: sus referencias ya son válidas.

**Archivos creados**
- `lib/screens/cancelacion_sheet.dart`, `lib/screens/atendido_sheet.dart`; `confirmaciones_sheets.dart` las re-exporta
- `lib/widgets/sheets/confirmacion_sheet_frame.dart` (158), `lib/data/mock_confirmaciones.dart` (19)
- Test permanente: `test/confirmaciones_sheets_test.dart` (3 tests)

**Bugs corregidos**
1. Datos contradictorios con el resto de la app → salen de la sesión en gestión (`Sesion`, `Cliente`, `Fotografo`).
2. El motivo de cancelación "obligatorio" se perdía → nueva `showCancelarCitaSheet` devuelve el motivo;
   `showConfirmarCancelacionSheet` sigue devolviendo bool (sesion_detalle no cambia).
3. Colores sueltos → tokens.

**Cambios visibles aprobados** (verificado contra el original: solo cambian estos textos)
C.C. 1.018.490.231 → 1.025.340.890 · "Jueves 24 Octubre 2024 • 11:30 AM" → "Jueves 15 Octubre 2026 • 10:00 AM" ·
"Cabina 02 (Luz Continua)" → "Ciclorama Blanco" · "Comisión: 45% ($54.000)" → "30% ($36.000)" · "Retrato profesional".

**Pendiente:** 6 Material Icons (puntos, check, ↶ ←) siguen ahí; cambiarlos altera levemente el tamaño. sesion_detalle
podría mostrar el motivo en el toast al procesar ese archivo.

### 12. `gestion_inasistencias_screen.dart`: 533 → 284 líneas

**Archivos creados**
- `lib/models/inasistencia.dart` (45), `lib/data/mock_inasistencias.dart` (38)
- `lib/widgets/staff/inasistencia_card.dart` (303): una tarjeta con 3 variantes (antes 3 métodos con todo escrito a mano)
- Test permanente: `test/gestion_inasistencias_test.dart` (2 tests)

**Refactor puro:** golden idéntico y, además, las tres variantes verificadas contra el código original con los
filtros "Todas" e "Historial" (copia temporal extraída del log, ya borrada).

**Bugs corregidos**
1. Filtros que clasificaban a mano → por fecha real (`vigenteEn(hoy)`); conteos calculados.
2. "Liberar Fechas" no actualizaba los conteos → libera por id y todo se recalcula.
3. "0 citas afectadas" y "Retratos" fijos → desde la agenda y la especialidad del fotógrafo (mismos valores).

**Cambio visible aprobado:** "Vigentes" pasa de 1 a 2 (la licencia de Nicolás, 01–31 oct, está en curso) y su tarjeta
aparece al entrar. Golden actualizado.

**Pendiente (el usuario decidió no cambiarlo ahora):** el encabezado dice "Sara Méndez" con la C.C. de Laura Méndez;
el globo "1" de la pestaña sigue fijo. "Alternar" y "Cambiar" no hacen nada.

### 13. `sesion_detalle_screen.dart`: 509 → 125 líneas

**Archivos creados**
- `lib/widgets/detalle/detalle_cards.dart` (503: 5 tarjetas)
- Test permanente: `test/sesion_detalle_test.dart` (3 tests); parámetro opcional nuevo `sesion`

**Refactor puro:** golden idéntico.

**Bugs corregidos**
1. Todo escrito a mano → sale de `Sesion`, `Cliente`, `Fotografo` y `MedioPago` (fecha, horario, duración, tarifa,
   comisión, liquidación, iniciales, especialidad, medio de pago).
2. Dos códigos para la misma sesión → **#RSV-2026-042** en todas partes (decisión del usuario; también en las hojas y el toast).
3. El toast de cancelación ahora incluye el motivo elegido (`showCancelarCitaSheet`).
4. **Encontrado al conectar datos:** la fila del set desbordaba 23 px con locaciones largas → `Flexible`; el texto baja a 2 líneas.

**Cambios visibles aprobados:** C.C. 1.020.345.890 → 1.025.340.890, teléfono +57 310 → +57 312, "Estudio A" →
"Ciclorama Blanco" (en 2 líneas), "Retrato profesional", y #ORD-9821 → #RSV-2026-042 en las hojas. Goldens actualizados.

**Pendiente:** el nombre del cliente ya salía cortado ("Valentina …") en el original: a 28 px no cabe junto a la
etiqueta "Programada". "Llamar"/"Enviar" no hacen nada. "Creada 10 Oct 2026" y "3 fotografías procesadas…" siguen fijos
(el modelo no tiene esos campos).

### 14. `configurar_jornada_screen.dart`: 508 → 207 líneas

**Archivos creados**
- `lib/widgets/jornada/jornada_cards.dart` (553: ficha, selector de días, caja de hora, validación, turno, almuerzo, aplicar L–V)
- Test permanente: `test/configurar_jornada_test.dart` (3 tests)

**Refactor puro:** golden idéntico.

**Bugs corregidos**
1. Horas en 24 h con sufijo ("17:00 PM", "13:00 PM") → 12 h con `horaAmPm` ("05:00 PM", "01:00 PM").
2. Todos los días compartían el mismo horario → cada día carga su jornada de `semanaLaura` (sábado 09–14 sin
   almuerzo; el domingo libre propone 08–17) y recuerda lo editado. El día inicial sale de `hoyDemo` (jueves).
3. El día corto del jueves decía "Jueves" en vez de "Jue" (se veía al elegir otro día) → nombres desde `nombreDia`.
4. "0 conflictos con las 4 reservas…" fijo → calculado con las reservas programadas de Laura en la semana y su choque
   con el turno o el almuerzo (con "aplicar L–V", contra el horario editado).
5. La ficha de Laura usaba `foto_sara_mendez.jpg` → la foto del modelo (`foto_laura_staff.jpg`).
6. Pausa de almuerzo por defecto desde `almuerzoInicioMin` y `Jornada.pausaAlmuerzoMin` (mismos valores).

**Cambios visibles aprobados:** 05:00 PM, 01:00 PM, 02:00 PM; "0 conflictos con 1 reserva programada de esta semana";
la foto de Laura. Goldens actualizados (el de inasistencias cambió solo por la caché de imágenes entre tests: esa
pantalla sigue usando `foto_sara_mendez.jpg`).

**Pendiente:** guardar no persiste (la pantalla se cierra). "Fotógrafa Principal • ID #HL-084" sigue fijo. Quedan 3
íconos Material (flechas y error).

### 15. `catalogo_especialidades_screen.dart`: 506 → 126 líneas

**Archivos creados**
- `lib/models/especialidad.dart`, `lib/data/mock_especialidades.dart`
- `lib/widgets/especialidades/especialidad_cards.dart` (418 líneas: 5 widgets)
- Test permanente: `test/catalogo_especialidades_test.dart` (3 tests)

**Refactor puro:** golden idéntico (los chips siguen centrados como en el original). Chips con `HexChip`, búsqueda con
`HexSearchField`, color `0x4DE5E2DB` → `AppColors.onDarkSoft`. Titular e iniciales salen de `fotografos`.

**Bugs corregidos**
1. Al desactivar una especialidad, la tarjeta decía "0 servicios asignados" y "Sin fotógrafo…" → muestra sus servicios
   reales y "Titular en pausa: <nombre>" (Eventos y Corporativo sigue igual).
2. La búsqueda por titular ignoraba las especialidades inactivas.

**Cambios visibles:** ninguno en la pantalla inicial (solo al desactivar). Golden sin cambios.

**Pendiente:** "Editar" no hace nada; el aviso "Especialidad 'Retratos' actualizada" es fijo. Los nombres de servicio de
cada especialidad no coinciden aún con el catálogo de servicios (se revisará en `catalogo_servicios`).

### 16. `nueva_reserva_cliente_screen.dart`: 486 → 147 líneas

**Archivos creados**
- `lib/widgets/reserva/cliente_seleccion.dart` (324 líneas: intro con pasos, encabezado de resultados, tarjeta de cliente, parámetros rápidos)
- Test permanente: `test/nueva_reserva_cliente_test.dart` (3 tests)

**Refactor puro:** golden idéntico. Panel inferior con `BlurBottomBar(blur: 12)`, buscador con `HexSearchField`.

**Bugs corregidos**
1. El buscador no filtraba y el contador "3" era fijo → filtra por nombre (sin tildes), cédula o teléfono con
   `Cliente.coincide`; contador real y mensaje cuando no hay coincidencias.
2. Clientes copiados a mano → salen de `clientes`; la selección se guarda por nombre (no por índice de la lista filtrada).
3. "Recurrente (3 sesiones)" sale de `Cliente.sesiones`.

**Cambios visibles aprobados:** el campo arranca vacío con la pista "Nombre, cédula o teléfono"; 4 resultados (aparece
Daniel Castro); Camila con su foto; cédulas en una línea; Valentina usa `foto_valentina.jpg` (la del modelo). El correo y
el último lookbook solo se muestran en clientes frecuentes, como en Figma. Golden actualizado.

**Pendiente:** el cliente elegido no se pasa al paso siguiente (`onContinuar` sigue siendo `VoidCallback`). "Último
lookbook: Editorial Neon Y2K · 18 ENE 2025" sigue fijo (no está en el modelo). El título del header es "Detalle De Sesión"
en todo el flujo, como en Figma.

### 17. `catalogo_servicios_screen.dart`: 476 → 112 líneas

**Archivos creados**
- `lib/widgets/servicios/servicio_catalogo_cards.dart` (336 líneas: 5 widgets)
- Test permanente: `test/catalogo_servicios_test.dart` (3 tests, uno comprueba que la agenda cobra la tarifa del catálogo)

**Refactor puro:** golden idéntico (también los de la reserva, que ahora leen la lista unificada). Búsqueda con
`HexSearchField`, chips con `HexChip` + `HexChipBar`.

**Bugs corregidos**
1. Dos catálogos de servicios sin relación (este y el del paso 2 de la reserva) → `serviciosEstudio` con 10 servicios,
   código #SRV y precio único; cada pantalla muestra sus 6 de Figma (decisión del usuario).
2. Precio y duración como texto (`'$120.000'`, `'45 MIN'`) → `int` del modelo con `formatCop`.
3. "6 SERVICIOS ACTIVOS", "Activos (6)" e "Inactivos (0)" fijos → calculados con `Servicio.activo`; el filtro
   "Activos" ahora filtra de verdad.
4. "Editar Tarifa" usaba un SnackBar propio → `showHexToast` como el resto de la app.

**Cambios visibles:** ninguno en la pantalla inicial. Goldens sin cambios.

**Pendiente:** "Editar Tarifa" y "Nuevo" no editan nada. La reserva aún no ofrece los 4 servicios que solo están aquí
(y al revés). Los nombres de servicio de `especialidades` siguen siendo etiquetas cortas.

### 18. `crear_servicio_screen.dart`: 472 → 237 líneas

**Archivos creados**
- `lib/widgets/servicios/crear_servicio_widgets.dart` (357 líneas: 9 widgets)
- Test permanente: `test/crear_servicio_test.dart` (2 tests)

**Refactor puro:** golden idéntico. `_cop` duplicado → `formatCop`; `surfaceHigh` al 60 % → `AppColors.surfaceHighFaded`.

**Bugs corregidos**
1. Especialidades y fotógrafos escritos a mano ("Retratos (Moda & Editorial)", "Laura M., Carlos M." — Carlos no existe)
   → especialidades activas de `especialidades` y fotógrafos de `fotografos` con `nombreCorto`.
2. Reparto 70/30 fijo → usa la comisión del titular de la especialidad (Mateo 35 %, Nicolás 40 %).

**Cambios visibles aprobados:** el desplegable dice "Retratos" y los habilitados "Laura M."; todo lo de abajo sube una
línea. Golden actualizado.

**Pendiente (el usuario decidió no cambiarlo ahora):** no avisa de nombres duplicados; al pasar de 50 caracteres el
cursor salta. Guardar no añade el servicio al catálogo. Duraciones solo de 30 a 90 min (el catálogo tiene de 120 y
180). Quedan 3 íconos Material (error, info, rayo).

### 19. `cierres_periodo_screen.dart`: 470 → 72 líneas

**Archivos creados**
- `lib/models/cierre.dart`, `lib/data/mock_cierres.dart`
- `lib/widgets/cierres/cierre_cards.dart` (522 líneas: 7 widgets públicos; una sola `CierreCard` para auditado y liquidado)
- Test permanente: `test/cierres_periodo_test.dart` (2 tests)

**Refactor puro:** golden idéntico. `FinanceTag` se re-exporta para liquidación y nuevo cierre.

**Bugs corregidos**
1. El resumen ($1.840.000 / $614.000 / $1.226.000) no cuadraba con los cierres → suma de los cierres visibles.
2. El filtro "Agosto" mostraba octubre y septiembre → filtra por mes; sin resultados muestra "Sin cierres en este periodo."
3. "2 registros" fijo → cuenta real (con singular "1 registro").
4. **Encontrado al conectar datos:** importes de 7 dígitos se partían en 2 líneas en las tarjetas pequeñas → `FittedBox`.

**Cambios visibles aprobados:** resumen $3.050.000 / $1.006.000 / $2.044.000. Golden actualizado.

**Pendiente:** "Correspondiente Estudio" ya se cortaba a mitad de palabra en el original; en la fila de importes las
cifras quedan pegadas ("$1.200.000$396.000"). El año "2026" es fijo. Los importes de los cierres son de ejemplo (no salen
de la agenda).

### 20. `busqueda_global_screen.dart`: 470 → 145 líneas

**Archivos creados**
- `lib/widgets/busqueda/busqueda_widgets.dart` (405 líneas: 6 widgets + ilustración)
- Test permanente: `test/busqueda_global_test.dart` (3 tests)

**Refactor puro:** golden idéntico. Cabecera con `BlurTopBar`, chips con `HexChip` + `HexChipBar`, `_norm` duplicado →
`sinTildes`, `0xFFC4C7C7` → `AppColors.outlineVariant` (los dos grises propios de la ilustración quedan como constantes del painter).

**Bugs corregidos**
1. Índice de 14 entradas copiado a mano → se arma desde `clientes`, `serviciosEstudio` (activos) y `fotografos`.
2. Buscar la cédula sin puntos ("1025340890") o con "C.C." no encontraba nada, aunque la pantalla sugiere buscar por
   C.C. → si la consulta es solo un número se compara por dígitos.

**Cambios visibles:** ninguno en la pantalla inicial. Al buscar "retrato" salen 3 servicios (incluye #SRV-007).

**Pendiente:** tocar un resultado no abre nada; los 4 botones de la barra inferior solo vuelven atrás ("Equipos" y
"Ajustes" no existen). Quedan 4 íconos Material (3 de resultados + info).

### 21. `nuevo_cierre_screen.dart`: 468 → 136 líneas

**Archivos creados**
- `lib/models/liquidacion.dart`; `lib/data/mock_cierres.dart` amplía con `liquidacionesOct1`, `liquidacionesEntre`, `codigoCierre`
- `lib/widgets/cierres/nuevo_cierre_widgets.dart` (449 líneas: 6 widgets)
- Test permanente: `test/nuevo_cierre_test.dart` (3 tests); se actualizó `cierres_periodo_test` con las cifras nuevas

**Refactor puro:** golden idéntico. `0xFF333333` → `AppColors.charcoal`.

**Bugs corregidos**
1. Sara Torres: $320.000 al 30 % mostraba $114.000 → todo se calcula desde las sesiones liquidadas (Sara $96.000).
   El cierre #CIE-2026-10A usa los mismos datos: comisiones $378.000 y estudio $822.000 (decisión del usuario).
2. Las cifras no dependían del rango → se filtran las sesiones por fecha; "Q4 // 2026" se calcula del mes.
3. El toast decía "#CIE-2026-10B" para el rango 1–15 oct → el código se calcula del rango y, si ya existe, avisa
   "#CIE-2026-10A ya existe; se regeneró la vista previa" sin duplicarlo.
4. Plurales ("1 servicio", "1 fotógrafo asignado").

**Cambios visibles aprobados:** comisiones -$378.000, estudio $822.000, Sara $96.000. En Cierres de Periodo: staff
$378.000 / estudio $822.000 y resumen $988.000 / $2.062.000. Goldens actualizados.

**Pendiente:** "Canceladas 0" y "En Curso 2" siguen fijos (no hay modelo de sesiones canceladas por rango). La
liquidación incluye sesiones del 15 oct que en la agenda aún figuran como programadas (Valentina, Andrés, Camila).

### 22. `liquidacion_comisiones_screen.dart`: 463 → 89 líneas

**Archivos creados**
- `lib/widgets/cierres/liquidacion_widgets.dart` (374 líneas: 5 widgets)
- Test permanente: `test/liquidacion_comisiones_test.dart`

**Refactor puro:** golden idéntico. Los datos propios (`_Liquidacion`, `_Sesion`) se reemplazan por `liquidacionesEntre`
del cierre #CIE-2026-10A (mismos valores); código y periodo salen del `Cierre`; C.C., foto, especialidad y tasa de
`Fotografo`; `_cop` → `formatCop`.

**Bugs corregidos**
1. La fórmula decía siempre "% contractual (30%)" → muestra la tasa del fotógrafo elegido o "según cada contrato".
2. "Todos (3)" fijo → se cuenta.

**Cambios visibles:** ninguno en la pantalla inicial.

**Pendiente:** la etiqueta "RET-OPT" y el sello "PRO" son iguales para todos. "Exportar comprobante" solo muestra un
toast. La pantalla siempre muestra el último cierre (no recibe cuál).

### 23. `login_screen.dart`: 428 → 187 líneas

**Archivos creados**
- `lib/widgets/login/login_widgets.dart` (328 líneas: 8 widgets)
- Test permanente: `test/login_test.dart`; `widget_test` ahora escribe una contraseña antes de entrar

**Refactor puro:** golden idéntico.

**Bugs corregidos**
1. La contraseña "production2025!" venía escrita en el código y rellena → el campo arranca vacío.
2. "Iniciar sesión" entraba con los campos vacíos → marca en rojo el campo vacío y muestra "Ingresa tu usuario y
   contraseña" (no hay backend: cualquier valor no vacío entra).
3. "3 Sesiones Activas" fijo → sesiones programadas de hoy en la agenda (mismo valor), con singular.

**Cambio visible aprobado:** la contraseña aparece vacía. Golden actualizado.

**Pendiente:** "Mantener sesión activa" no guarda nada; "Set A: Campaña Primavera 10:00 - 18:00" sigue fijo. El usuario
"admin@hexlens.com" se mantiene al cambiar a Fotógrafo.

### 24. `actualizar_condiciones_screen.dart`: 427 → 180 líneas

**Archivos creados**
- `lib/widgets/condiciones/condiciones_widgets.dart` (361 líneas: 9 widgets)
- Test permanente: `test/actualizar_condiciones_test.dart` (2 tests); parámetro opcional nuevo `fotografo`

**Refactor puro:** golden idéntico. 5 colores escritos a mano → `errorContainer` (existente), `errorTag`, `errorWash`,
`successContainer`.

**Bugs corregidos** (opciones recomendadas; el usuario pidió seguir sin elegir otras)
1. Especialidades escritas a mano ("Retrato Editorial & Moda") → especialidades activas del modelo.
2. Nuevo `fotografo` opcional: rellena nombre, C.C., comisión y especialidad. Sin él se mantiene el estado de error del Figma.

**Cambio visible:** el desplegable dice "Retratos". Golden actualizado.

**Pendiente:** el catálogo de fotógrafos abre "Editar ficha" sin decir qué fotógrafo (`onEditarFicha` es `VoidCallback`),
así que aún no se usa `fotografo`. El tope del 65 % sigue siendo solo un aviso. El header dice "Catalogo Servicios" (como en Figma).
Quedan 4 íconos Material.

### 25. `registrar_inasistencia_screen.dart`: 394 → 183 líneas

**Archivos creados**
- `lib/widgets/staff/registro_inasistencia_widgets.dart` (319 líneas: 3 widgets)
- Test permanente: `test/registrar_inasistencia_test.dart` (2 tests, uno elige el 15 oct en el calendario)

**Refactor puro:** golden idéntico. `#E6F4E7` → `AppColors.successContainer`.

**Bugs corregidos**
1. "28-29 Oct 2026", "0 citas" y "Sin conflictos detectados" no cambiaban con las fechas → rango formateado y reservas
   programadas de Laura en ese periodo. Con choques, la etiqueta se pone roja ("1 conflicto detectado") y el consejo cambia.

**Cambios visibles:** ninguno al abrir.

**Pendiente (decisión del usuario):** la ficha sigue diciendo "Ingris Méndez" con la C.C. de Laura (igual que "Sara Méndez"
en Inasistencias; corregir ambas juntas). "Cambiar operador" no es un selector real; confirmar no añade la ausencia a
`inasistencias`; el contador "/ 200" no limita el texto; los motivos no coinciden con `TipoInasistencia`.

### 26. `registrar_profesional_screen.dart`: 390 → 186 líneas

**Archivos creados**
- `lib/widgets/staff/registro_profesional_widgets.dart` (280 líneas: 6 widgets)
- Test permanente: `test/registrar_profesional_test.dart`

**Refactor puro:** golden idéntico. `_cop` → `formatCop`; `0x22DB351A` → `AppColors.accentOverlay`.

**Bugs corregidos**
1. Especialidades escritas a mano → especialidades activas del modelo.
2. La simulación usaba siempre una sesión de $120.000 → usa el servicio base de la especialidad elegida (Retratos
   $120.000, Familiar $180.000, Productos $250.000, Editorial $350.000).

**Cambio visible aprobado:** el desplegable dice "Retratos". Golden actualizado.

**Pendiente:** registrar no añade el profesional a `fotografos`; el toast dice "registrada" siempre; no se valida que
la C.C. no exista ya. La edad se calcula con la fecha real (no con `hoyDemo`). El header dice "Catalogo Servicios" (como en Figma).

### 27. `recuperacion_acceso_screen.dart`: 372 → 127 líneas

**Archivos creados**
- `lib/widgets/login/recuperacion_widgets.dart` (347 líneas: 6 widgets); `EsquinaTriangulo` en `hex_widgets.dart`
- Test permanente: `test/recuperacion_acceso_test.dart` (2 tests)

**Refactor puro:** goldens idénticos (también liquidación, que ahora usa `EsquinaTriangulo`).

**Bugs corregidos**
1. El borde de la casilla OTP activa no se actualizaba al enfocar/desenfocar → se escucha el `FocusNode`.
2. Cualquier texto de 4 letras contaba como válido → correo con @ y dominio, C.C. numérica o ID "HL-084".

**Cambios visibles:** ninguno al abrir.

**Pendiente:** "Actualizar Código OTP" reinicia la cuenta aunque aún no se pueda reenviar; cualquier código de 6 dígitos
se acepta (no hay backend). Quedan 2 íconos Material (emergency, verified).

### 28. `ficha_nuevo_cliente_screen.dart`: 350 → 270 líneas

**Archivos creados**
- `lib/widgets/clientes/ficha_cliente_widgets.dart` (172 líneas: 6 widgets)
- Test permanente: `test/ficha_nuevo_cliente_test.dart` (2 tests)

**Refactor puro:** golden idéntico.

**Bugs corregidos**
1. Fecha de nacimiento en formato de EE. UU. (mm/dd/yyyy) → dd/mm/aaaa; ya no deja elegir fechas futuras (máximo `hoyDemo`).
2. Se podía registrar una C.C. existente → aviso "Ya existe un cliente con ese documento (Valentina Ruiz)" bajo el
   campo y no guarda (compara solo dígitos).

**Cambio visible aprobado:** la pista dice "dd/mm/aaaa". Golden actualizado.

**Pendiente:** confirmar no añade el cliente a `clientes`; el header dice "New Session Modal" (Figma, en inglés).

### 29. `splash_screen.dart`: 307 → 76 líneas

**Archivos creados**
- `lib/widgets/splash/splash_widgets.dart` (259 líneas: 5 widgets)
- Test permanente: `test/splash_test.dart` (2 tests)

**Refactor puro:** golden idéntico. 2 colores → `surfaceHighGhost`, `surfaceHighestFaded`.

**Bug corregido:** el `Timer` de 300 ms tras la carga no se cancelaba si la pantalla se cerraba antes → se guarda y se
cancela en `dispose` (el test fallaría con "A Timer is still pending" sin el arreglo).

**Cambios visibles:** ninguno.

### 30. `registrar_cliente_sheet.dart`: 286 → 183 líneas

**Archivos creados**
- `lib/widgets/clientes/registro_cliente_widgets.dart` (174 líneas: 5 widgets); `SheetHandle` en `hex_widgets.dart`
- Test permanente: `test/registrar_cliente_sheet_test.dart` (2 tests)

**Refactor puro:** golden de la hoja idéntico. `#22A55B` → `AppColors.whatsapp`; `surfaceHigh` al 60 % → `surfaceHighFaded`.

**Bugs corregidos**
1. Dejaba guardar una C.C. existente → aviso bajo el campo y botón deshabilitado (`clientePorDocumento`, compartido con la ficha).
2. El correo no se validaba → si se escribe, debe ser válido (`esCorreo`, también usado ahora por la ficha).
3. SnackBar propio → `showHexToast` (se muestra antes de cerrar la hoja y sigue visible).

**Cambios visibles:** ninguno al abrir.

**Pendiente:** guardar no añade el cliente a `clientes`; la fecha de nacimiento es texto libre (sin calendario ni
validación); quedan 3 íconos Material (punto, punto verde, SMS).

### 31. `nueva_especialidad_sheet.dart`: 273 → 129 líneas

**Archivos creados**
- `lib/widgets/especialidades/nueva_especialidad_widgets.dart` (209 líneas: 5 widgets); usa `SheetHandle(width: 48)`
- Test permanente: `test/nueva_especialidad_sheet_test.dart`

**Refactor puro:** golden de la hoja idéntico.

**Bug corregido:** se podía crear una especialidad existente ("retratos") → aviso "Ya existe la especialidad Retratos." y
guardar deshabilitado (sin distinguir mayúsculas ni tildes).

**Cambios visibles:** ninguno al abrir.

**Pendiente:** el estado Activa/Inactiva no llega a quien abre la hoja (`showNuevaEspecialidadSheet` devuelve solo el
nombre; cambiarlo rompería la firma pública). La especialidad creada no se añade a `especialidades`.

## Ajuste posterior: fechas de Reagendar (2024 → 2026)

Pedido del usuario: revisar fechas que no van con la actual. Solo se aprobó corregir Reagendar.

- `mock_reagendar.dart`: el mes, el día original y los días bloqueados salen de `sesionEnGestion` (15 oct 2026) y
  `hoyDemo`: se bloquean los días ya pasados y los domingos. El día propuesto es el mismo día de la semana siguiente (jue 22).
- `reagendar_sesion_screen.dart`: la ficha bloqueada usa la sesión en gestión (#RSV-2026-042, C.C. 1.025.340.890,
  +57 312 987 6543, "Retrato profesional", Ciclorama Blanco). Esto resuelve el pendiente de "la otra Valentina".
- **Encontrado al conectar datos:** "Ciclorama Blanco" desbordaba 8,6 px en la fila duración/cabina → `Wrap`.
- `reagendar_sesion_test` actualizado (también comprueba que un día pasado no se puede elegir).

**Sin cambiar (decisión del usuario):** "© 2024" (splash), "HEXLENS CORE // 2024 REV 2.4" (búsqueda), "REV. 2024.9"
(registrar profesional), versiones "V24…" y el último lookbook "18 ENE 2025".

## Funcionalidad real · Fase 1: fecha y hora reales

Pedido del usuario: que "hoy" sea la fecha real del teléfono y que la hora afecte lo que se muestra.

- **`lib/core/reloj.dart` (`Reloj`)**: única fuente de fecha/hora (`ahora()`, `hoy`, `dia(n, h, m)`). Reemplaza a
  `hoyDemo` (15 oct 2026 fijo) en 11 archivos. En pruebas, `test/flutter_test_config.dart` lo fija en jue 15 oct 2026 09:45.
- **Datos anclados a hoy**: agenda (ayer / hoy / pasado mañana, saltando domingos), mis servicios, inasistencias
  (+13 días, −11 días, mes en curso), cierres (la última quincena terminada y la anterior), disponibilidad (ayer a
  pasado mañana), reagendar, jornada, nuevo cierre y registrar inasistencia. Los códigos llevan el año real.
- **Según la hora**:
  - Las sesiones de hoy salen *realizadas* si ya terminaron; la primera que no ha terminado es la destacada; la sesión
    en gestión es la en curso o la próxima.
  - Detalle: estado real (Programada / En curso / Realizada / Cancelada); sin acciones si ya no es programada; "Creada" relativa.
  - Reserva: bloques de hoy ya pasados → nuevo tipo `BloqueTipo.pasado` ("PASADO"); día sin cupos → "Sin Cupos";
    abre en el primer día con cupo.
  - Fotógrafos: `estadoEnTiempoReal` (en turno si está en sesión, almuerzo 13–14, fuera de turno de noche/domingo,
    inactivo con inasistencia que cubre hoy) → nuevo estado `EstadoFotografo.fueraDeTurno`. `Inasistencia.cubre(dia)`.
  - Saludo "Buenos días / Buenas tardes / Buenas noches" en el inicio y en Mis Servicios (el de staff ahora puede
    bajar de línea: con "Buenas noches" desbordaba 16 px).
- Verificado con capturas reales a jue 8 oct 22:18 y 10:15. Tests: 71 (nuevo `estado_staff_test`).

**Pendiente (fase 2)**: almacén central con guardado local; que las pantallas se refresquen solas cada minuto; que
los bloques libres salgan de la agenda real (hoy son de ejemplo); "Familia Ortiz" y otros clientes de la agenda no
están en el directorio (sin teléfono/correo en el detalle).

## Legibilidad

Pedido del usuario: mejorar la legibilidad. Revisado con capturas a tamaño de celular (393 px, fuentes reales) de
las 27 pantallas y 6 hojas, antes y después; ninguna desborda.

- **Tamaño mínimo 12 px** en `AppText` (había 80 textos de 9–11 px en 35 archivos) e interlineado ≥ 1,15.
- **Contraste**: `outline` #747878 → #616565 (4,2:1 → 5,6:1) y `muted` #7E848C → #62686F; las pistas de búsqueda
  pasan de `outlineVariant` (1,6:1) a `outline`.
- **Títulos de cabecera** correctos y en español, hasta 2 líneas en vez de cortarse ("Nueva Reserva" en todo el flujo,
  "Reagendar Sesión", "Nuevo Servicio", "Condiciones del Staff", "Fotógrafos", "Cierres de Período"…).
- **Jerga técnica a español claro** (decisión del usuario): "SIN RESULTADOS / 0 coincidencias", "HAY CAMPOS POR
  CORREGIR", "FINANZAS · CIERRES Y CAJA", "EN LÍNEA"… Se quitaron las etiquetas puramente decorativas (versiones
  "V2.4", "MOD-04", "⌘K", "ERR_422", "SRV-FORM", "TERMINAL…", pies "HEXLENS CORE…").
- **Cortes y pegados**: nombres largos en 2 líneas ("Valentina Ruiz", cliente de la reserva, cuenta bancaria), pasos
  de la reserva en 2 líneas, horas en una línea ("11:30 AM"), montos separados ("$1.200.000 $378.000"), palabras que
  se partían ("Correspondiente", "Valor correspondiente"), fechas "01/10/2026", "Período" con tilde.
- Tests actualizados a los textos nuevos (71 pasan).

## DRY y código limpio (componentes compartidos)

Pedido del usuario: aplicar DRY en todo el proyecto, por familia de componente, igualando el estilo. Cada paso se
verificó con `flutter analyze`, los 73 tests y capturas a 393 px comparadas con la línea base.

| Familia | Antes | Ahora |
|---|---|---|
| Fechas | 9 formateos a mano (`_fmt`, `padLeft`) | `dosCifras`, `diaMes`, `fechaCorta`, `fechaNumerica` en `utils/formato.dart` |
| Etiqueta de campo | 6 clases | `FieldLabel(texto, required:, error:, trailing:)` |
| Mensaje bajo el campo | 4 clases | `MensajeCampo(texto, tipo: ayuda/error/ok)` |
| Par de botones final | 5 clases | `ParAcciones` + `BarraAcciones` (gris 2/5, principal 3/5, 56 px) |
| Encabezado de sección | 8 clases | `EncabezadoSeccion(titulo, marca:, dato:, extra:, subrayado:, franja:)` + `ModuleHeader` |
| Tarjeta de formulario / caja | `FichaCard`, `CondicionCard`, 2× `_Caja` | `TarjetaCampo` y `InfoBox` |
| Etiquetas a mano | 23 `Container` + `Text` | `Tag` |
| Icono + texto | 75 `Row` a mano | `IconoTexto(icono, texto, estilo:, ajuste:, arriba:, compacto:)` |
| Radios de esquina | números sueltos (2, 2.5, 4, 6, 8, 10, 12) | `AppRadius.xs/sm/md/lg` (2/4/8/12) |

- Cambios visibles a propósito: botones finales con el mismo alto y textos en una línea ("Confirmar Atendido",
  "Guardar Especialidad"), encabezados de sección con un solo estilo ("FOTÓGRAFOS (3)", "RESULTADOS"), separación
  entre tarjetas de formulario de 24 px, radios 6/10/2.5 → 8/12/2.
- Líneas en `lib`: 22.078 → 21.106 (−972, −4,4 %); 123 → 122 archivos. La reducción es menor que la estimada
  porque las conversiones de icono+texto y etiquetas ahorran repetición pero no tantas líneas.
- No se aplicó `dart format`: el proyecto nunca se formateó con él y cambiaría 102 archivos.

## DRY y código limpio en las pantallas

Pedido del usuario: aplicar DRY y código limpio a las pantallas (la API la entrega su profesor; no se tocó la capa
de datos más allá de concentrar consultas). Verificado con `flutter analyze`, 75 tests y capturas idénticas píxel a
píxel antes/después.

| # | Cambio | Dónde |
|---|---|---|
| 1–2 | `coincideBusqueda(consulta, campos)` en `formato.dart`: una sola regla de búsqueda que **ignora tildes** (antes "Jose" no encontraba "José") | 5 catálogos |
| 3 | El catálogo de clientes usa `Cliente.coincide()` en vez de repetir la lógica | `catalogo_clientes_screen` |
| 4 | `HexHeader` vuelve atrás por defecto; se quitó `onBack: back` de 19 cabeceras | 19 pantallas |
| 5 | Mixin `ConBusqueda` (controlador `busqueda` + `dispose`) | 7 pantallas |
| 6 | `mostrarHoja(context, hoja, oscuro:)` para abrir hojas inferiores | 4 hojas |
| 7 | `programadasDeHoy([sesiones])` en `mock_agenda.dart` (punto único para la API) | login, horario, mis servicios |
| 8a | Ficha de cliente: `build` de 244 → 30 líneas; secciones `_identificacion()` / `_contacto()` y un solo `_campo(...)` para los 5 campos de texto | `ficha_nuevo_cliente_screen` |
| 8b | Fecha de reserva: `_dentroDeLimites`, `_estadoDia` (antes 20 líneas de if/else en el `itemBuilder`), el calendario reutiliza `_elegirFecha`; botón a `widgets/reserva/boton_navegacion.dart` | `nueva_reserva_fecha_screen` |
| 8c | `main.dart` 367 → 42 líneas: rutas y login en `navegacion.dart`, el contenedor admin en `screens/home_shell.dart` con el menú "Más" como lista de datos + `_OpcionMenu` | `main.dart` |

- Pantallas + `main.dart`: 6.159 → 5.942 líneas (−217). `build` más largo: 154 líneas (antes 244).
- Tests nuevos: búsqueda sin tildes (`formato_test`) y menú "Más" (`widget_test`).

## Arreglo: registrar cliente no guardaba nada

Reporte del usuario: al llenar el registro de cliente no se creaba ningún cliente. Causa: `_guardar()` (hoja
"Registrar Cliente") y `_confirmar()` (ficha "Nuevo Cliente") solo mostraban el aviso "guardado en BBDD" y cerraban;
el directorio era una lista `const`.

- `mock_clientes.dart`: el directorio es una lista que crece (`clientes`), con `registrarCliente(...)` que normaliza
  documento ("C.C. 1.018.490.231"), teléfono ("+57 …") y nombre, y lo pone primero. Vive en memoria hasta la API
  del profesor (se pierde al cerrar la app). `revisionClientes` avisa del cambio.
- Nuevo estado `EstadoCliente.nuevo` con su tarjeta ("CLIENTE NUEVO · Sin sesiones", Ver Ficha / Agendar Sesión).
- Las dos formas registran de verdad; la hoja devuelve el cliente y en Nueva Reserva queda seleccionado.
- El catálogo y Nueva Reserva se redibujan solos (mixin `RedibujarAlCambiar`); la búsqueda global incluye a los nuevos.
- Tests: el registro queda en el directorio con datos normalizados; el catálogo lo muestra al instante (75 tests).

### Segunda parte: formato al escribir y guardado en el celular

Reporte del usuario (con captura): el cliente sí aparecía en la sesión, pero la cédula y el teléfono no se
separaban al escribir y el cliente se perdía al reiniciar la app.

- `utils/formateadores.dart`: `formatoDocumento` ("1.098.765.432", máx. 10 dígitos) y `formatoTelefono`
  ("300 123 4567", máx. 10 dígitos) mientras se escribe; `HexTextField(formatos: …)`. Aplicados en la hoja
  "Registrar Cliente" y en la ficha "Nuevo Cliente".
- Guardado local temporal con `shared_preferences` (decisión previa del usuario: "localmente… solo va ser temporal"):
  `Cliente.toJson/fromJson`, `cargarClientesRegistrados()` al abrir la app (en `main`) y guardado en cada
  `registrarCliente`. Solo se guardan los clientes registrados; los de ejemplo no se duplican.
- Tests: formato al escribir y "reabrir la app" conserva el cliente (77 tests).

## Fechas funcionales (fuera de la semana actual)

Pedido del usuario (con captura de la Agenda): todo lo que tenga fechas era maqueta; que funcione para cualquier
fecha, no solo la semana actual.

- **Datos**: `mock_agenda.dart` genera sesiones de ejemplo ±120 días (siempre las mismas para cada fecha; pasadas
  realizadas, futuras programadas, alguna cancelada), con tarifas del catálogo y sin agendar a un fotógrafo en sus
  días de ausencia. `reagendarSesion()` mueve una sesión y `revisionAgenda` avisa a las pantallas abiertas.
- **`widgets/calendario_mensual.dart`**: `CalendarioMensual` (mes completo con flechas, días bloqueados, puntos de
  sesiones, día original tachado, hoy resaltado, accesible) + `FlechaCalendario` + `FechaElegida`.
- **Agenda**: flechas de semana (o de mes en Mensual), tocar el mes abre un selector de fecha, "Volver a hoy";
  las pestañas Semanas (sesiones agrupadas por día) y Mensual (calendario + lista del mes) funcionan; títulos,
  filtros y "Cierre operativo" se calculan sobre el período visible.
- **Reagendar**: calendario de mes completo con navegación (mes actual a +6), días bloqueados reales (pasados,
  domingos, ausencias del fotógrafo), franjas según la agenda del día (OCUPADO / PASADO / CIERRE) y
  "Confirmar Reagendamiento" mueve la sesión de verdad. Se borró `reagendar/calendario_mes.dart` (2 semanas fijas).
- **Cierres de Período**: los meses del filtro salen de los cierres existentes (no "Octubre/Septiembre/Agosto" fijos).
- **Configurar Jornada**: navegación de semanas (actual a +8) con el rango de fechas visible.
- **Registrar Cliente**: la fecha de nacimiento se elige con calendario.
- Arreglado: el título de "Cierre Operativo Proyectado" se desbordaba con rótulos largos ("12–18 OCT").
- Tests: 83 (navegación de agenda, vistas Semanas/Mensual, reagendar entre meses, franjas ocupadas, semanas de
  jornada). Se ajustaron los que suponían datos solo en 3 días.

## Conexión con la API de Ehily (fase 1: login y clientes)

Pedido del usuario: tomar la dirección de la API de la colección de Bruno ("Ehily API CECAR - Gestor") y conectarla.

- `lib/api/api.dart`: `urlApi = https://api.ehily.cecar.cloud` (entorno Produccion de Bruno), clase `Api`
  (`iniciarSesion`, `cerrarSesion`, `get/post/put/delete`) con token Bearer, lectura de `{ success, code, message,
  data }`, errores en español (`ApiError`: 401 cierra la sesión, sin internet, 4xx/5xx) y `SesionApi` (rol, empresa
  y vencimiento leídos del JWT). El login lee `accessToken`, como el script de Bruno.
- `lib/api/clientes_api.dart`: conversión cliente app ↔ API (`Documento`, `Nombres`, `Apellidos`, `Celular`,
  `Correo`, `FechaNacimiento` yyyy-MM-dd), tolerante a PascalCase/camelCase.
- Login real: usuario = cédula, clave; el panel lo decide el rol del token (Gestor → admin). Tras entrar se
  carga el directorio desde `GET /api/clientes`. Cerrar sesión borra el token.
- Registrar cliente (hoja y ficha): con sesión hace `POST /api/clientes`; sin sesión, como antes, en el celular.
- `Cliente.id` (id en la API). `fechaDesdeNumerica`. Permiso INTERNET en el AndroidManifest principal.
- Tests con API falsa (`test/api_falsa.dart`, MockClient, credenciales inventadas): 90 tests.
- Pendiente: servicios, especialidades, profesionales, reservas/agenda, comisiones y liquidaciones.

## Conexión con la API: especialidades

Decisión del usuario: "Desactivar" = **Eliminar** con confirmación (la API no guarda estado activa/inactiva).

- `lib/api/especialidades_api.dart`: GET/POST/PUT/DELETE `/api/especialidades` (`{ "Nombre": … }`).
  `campo()` (lectura sin importar mayúsculas) pasó a `api.dart` para compartirse.
- `Especialidad`: nuevo `id`; el ícono se elige por el nombre (`icono` → svg/ancho/alto), uno genérico si no se
  reconoce. Se quitaron `activa`, `icono/iconW/iconH` fijos.
- `mock_especialidades.dart`: lista que cambia + `revisionEspecialidades`; `sincronizarEspecialidades`,
  `crearEspecialidad`, `renombrarEspecialidad`, `eliminarEspecialidad` (API si hay sesión; si no, local).
- Catálogo: carga de la API al abrir (cargando / error con "Reintentar" / vacío), contador real, aviso real tras
  cada acción (antes un aviso fijo de maqueta), **Editar** (renombra con PUT) y **Eliminar** con diálogo de
  confirmación; si la API rechaza el borrado, se muestra su mensaje y no se quita. Se quitaron los filtros
  Activas/Inactivas y la tarjeta de inactiva.
- Hoja "Nueva especialidad": crea de verdad (POST), sin el selector de estado.
- Selectores de especialidad (Nuevo servicio, Registrar profesional, Condiciones): leen la lista actual y no
  fallan si llega vacía (`HexDropdown` muestra "No hay opciones").
- El login carga clientes y especialidades. Tests: 91.

## Conexión con la API: servicios

- `lib/api/servicios_api.dart`: GET/POST/PUT/DELETE `/api/servicios`, cuerpo `{Nombre, Precio, Descripcion,
  Duracion, Especialidad(id)}`. Lee la especialidad como id, nombre u objeto; precio entero o decimal.
- `Servicio`: `id`, `especialidadId`; código "#SRV-007" a partir del id.
- `mock_servicios.dart`: `serviciosEstudio` es una lista que cambia + `revisionServicios`; `serviciosCatalogo` y
  `serviciosReserva` son todos los de la API con sesión (6 de ejemplo sin ella); `sincronizarServicios`,
  `crearServicio`, `actualizarServicio` (precio, duración, descripción), `eliminarServicio`, `serviciosDe(e)`,
  `servicioEjemplo`.
- Especialidades: sus servicios ya no son una lista fija: salen de los servicios reales (`serviciosDe`).
- Catálogo de servicios: carga de la API, categorías desde los servicios reales, "Editar Tarifa" abre la edición
  (antes un aviso de maqueta); se quitó el filtro Activos/Inactivos (la API no tiene estado).
- Nuevo/Editar servicio: sin datos de ejemplo precargados; campo **Descripción** (obligatorio en la API); precio
  con puntos al escribir (`formatoPrecio`); al editar, nombre y especialidad bloqueados y botón "Eliminar
  Servicio" con confirmación; se quitó el interruptor "disponible" (sin respaldo en la API).
- Nueva reserva paso 2: categorías desde los servicios reales; sin servicios muestra un aviso y no deja seguir.
- El login carga clientes → especialidades → servicios. Tests: 93.

## Conexión con la API: profesionales (fotógrafos)

- `lib/api/profesionales_api.dart`: GET/POST/PUT/DELETE `/api/profesionales`; cuerpo de alta
  `{Documento, Nombres, Apellidos, FechaNacimiento, Porcentaje, Estado, Especialidad}`; PUT solo con lo que cambia.
  Compartidos en `api.dart`/`especialidades_api.dart`: `entero()` y `especialidadDeJson()` (antes duplicados en
  servicios); `nombreEspecialidad(id)` pasó a `mock_especialidades.dart`.
- `Fotografo`: `id`, `nombres`, `apellidos`, `especialidadId`; `foto` opcional (sin foto se ven las iniciales:
  `widgets/fotografos/foto_fotografo.dart`), `equipo` opcional ("Sin equipo registrado").
- `mock_fotografos.dart`: `fotografos` es una lista que cambia + `revisionFotografos`; `fotografosEjemplo` y
  `fotografoEjemplo()` para los datos de ejemplo (cierres) que no vienen de la API; `sincronizarFotografos`,
  `registrarFotografo`, `actualizarCondiciones`, `cambiarEstadoFotografo`.
- Catálogo: carga de la API, filtros por especialidad reales; **Reactivar** hace `PUT {Estado: true}` y termina la
  ausencia vigente (antes solo en pantalla); **Ver Ficha** abre las condiciones de ESE fotógrafo (antes abría la
  demo de error con 125 %); rótulo "LICENCIA TEMPORAL" solo si hay ausencia, si no "INACTIVO".
- Registrar profesional: sin datos de ejemplo precargados; fecha de nacimiento obligatoria ("Elegir fecha");
  Activo → Estado true, En licencia/Inactivo → false; POST real.
- Condiciones: "Guardar Cambios" hace el PUT (nombre partido en nombres/apellidos, porcentaje, especialidad).
- El login carga clientes → especialidades → servicios → fotógrafos. Tests: 96.

## Conexión con la API: reservas y agenda

La colección de Bruno no trae respuestas de ejemplo: la lectura de reservas acepta varios formatos (objetos
anidados `cliente/servicio/profesional`, nombres sueltos o solo ids; `fecha` con "T" o espacio; estado en texto).

- `lib/api/reservas_api.dart`: `GET /api/reservas?FechaInicio=&FechaFin=`, `POST /api/reservas`
  `{Fecha, ServicioId, ClienteId}`, `PUT /{id}` `{Fecha, ServicioId}`, `DELETE /{id}` (cancelar),
  `GET /api/agenda?fecha=&servicioId=` (horas libres: lista de horas o de objetos). `sesionDesdeApi`,
  `estadoDesdeApi`, `fechaParaApi`/`fechaDesdeApi`.
- `Sesion`: `id`, `clienteId`, `servicioId`.
- `mock_agenda.dart`: `sincronizarAgenda()` (≈4 meses atrás y 6 adelante; completa cliente/servicio con los ya
  cargados), `crearReserva`, `reagendarSesion` (ahora async, PUT), `cancelarSesion` (DELETE, queda marcada
  como cancelada), `marcarRealizada` (solo local: la API no tiene esa acción).
- Abrir una sesión desde Agenda/Inicio muestra **esa** sesión (antes siempre la "sesión en gestión");
  Reagendar recibe la sesión y toma las horas libres de la API.
- Nueva reserva: los 4 pasos se pasan lo elegido (cliente → servicio → hora → confirmación); el paso 3 consulta
  las horas libres en la API; "Confirmar reserva" hace el POST real y vuelve a la agenda. El fotógrafo lo
  asigna el estudio (la API no lo recibe al crear).
- El login carga al final la agenda. Tests: 102 (incluye el flujo completo con la API falsa).

## Conexión con la API: comisiones y liquidaciones (finanzas)

- `lib/api/comisiones_api.dart`: `GET/POST /api/liquidaciones-comisiones` (`{fechaInicio, fechaFin}`),
  `GET /api/comisiones?cierreId=` y `GET /api/comisiones/{id}/servicios` (si los servicios no vienen incluidos).
  Lectura flexible (no hay respuestas de ejemplo). `codigoCierre` vive aquí (antes duplicado).
  Compartidos en `api.dart`: `primerCampo()` y `nombreDe()` (antes privados y repetidos en reservas).
- `Cierre.id`. `mock_cierres.dart`: `cierres` lista que cambia + `revisionCierres`; `sincronizarCierres`,
  `generarCierre`, `liquidacionesDe(cierre)` (comisiones de la API), `liquidacionesEntre` (vista previa: con la
  API, desde la agenda real —sesiones terminadas y no canceladas— por fotógrafo y su %), `pendientesEntre`,
  `fotografoDe(profesional)`.
- Cierres de Período: carga de la API; "Ver detalle" abre la liquidación de ESE cierre.
- Liquidación de Comisiones: recibe el cierre y carga sus comisiones (cargando / error / vacío); estado
  AUDITADO o LIQUIDADO real; "Exportar comprobante" avisa que aún no está disponible (antes fingía exportar).
- Nuevo Cierre: contadores reales de canceladas y pendientes (antes 0 y 2 fijos); "Confirmar" genera la
  liquidación en la API; no deja repetir un período ya cerrado.
- `FotografoComisionCard` recibe el fotógrafo (foto o iniciales).
- El login carga también los cierres. Tests: 106.

## API: peticiones extra (cliente por documento, profesionales por especialidad)

- `buscarClientePorDocumentoApi` (`GET /api/clientes/{documento}`, 404 = no existe). `guardarCliente` la llama antes del POST: si la cédula ya está en la API lanza `ApiError` "Ya existe un cliente con ese documento (Nombre)".
- `profesionalesPorEspecialidadApi` (`GET /api/profesionales/{especialidadId}/especialiades`; la ruta va escrita igual que en Bruno).
- `mock_fotografos`: `fotografosParaServicio(servicio)` (solo activos, con caché por especialidad que se borra cuando cambia el staff; un 404 usa el staff ya cargado) y `fotografoSugerido(servicio)`.
- Nueva Reserva (Fecha y Confirmación) cargan el fotógrafo así; `home_shell` ya no lo pasa con `titularDe`. Es informativo: la reserva no envía profesional.
- Tests: +2 (108 en total).

## API: horarios por profesional

- `horariosDisponiblesApi(dia, servicioId, {profesionalId})`: agrega `&profesionalId=` (petición "Consultar horarios por profesional").
- Nueva Reserva → Fecha: primero carga el fotógrafo sugerido y luego sus horas libres.
- Reagendar: consulta las horas libres del fotógrafo que ya tiene la sesión (`fotografoPorNombre(...)?.id`; si no está en el staff, sin filtro).
- Tests: +1 (109).

## Navegación: una sola salida por pantalla, y que diga a dónde vuelve

- Problema: Detalle de Sesión tenía la flecha del header + "‹ Volver a Agenda", y Liquidación tenía la flecha +
  "Volver a Cierres de Período". Hacían lo mismo, y el texto mentía: el detalle también se abre desde Inicio,
  Clientes y Mis Servicios; la liquidación, desde Fotógrafos y Mis Servicios.
- `VolverA` (en `hex_widgets.dart`): viaja en `RouteSettings.arguments`. `Rutas.push(..., desde: 'Agenda')`
  lo agrega y `HexHeader` (variante detalle) lo muestra como miga sobre el título ("AGENDA ›"); la flecha
  anuncia "Volver a Agenda" a los lectores de pantalla. Sin `desde`, el header queda como antes.
- `home_shell`: el detalle se abre con `desde:` Inicio / Agenda (según la pestaña actual) o Clientes; la
  liquidación con Cierres o Fotógrafos. `FotografoHome`: Mis Servicios.
- `DetalleBreadcrumb` → `DetalleCodigo` (solo la etiqueta # del código). Se quitó "Volver a Cierres de Período".
  Íconos que quedaron sin uso: `detalle/arrow_back_small.svg`, `liquidacion/volver.svg`.
- Tests: +2 (111).

## Navegación: una sola salida también en formularios, nueva reserva y hojas

Respaldo previo (sin git): `C:\Users\SENA\respaldos_proyectoMovil\2026-11-03_antes_salidas_formularios_y_reserva\`
(`lib/`, `test/` y esta bitácora, tal como estaban antes de este cambio).

- **Formularios** (Nuevo/Editar Servicio, Nuevo Profesional, Nuevo Cierre, Nueva Ausencia, Jornada Laboral,
  Condiciones del Staff, Reagendar Sesión, Ficha de Nuevo Cliente): el header muestra ✕ (`HexHeader(cerrar: true)`)
  y se quitaron "Descartar Cambios", "Cancelar", "Cancelar y Volver", "Descartar y Volver" y "Descartar".
  Antes la ← borraba lo escrito sin avisar; ahora, con cambios, la ✕ y el atrás de Android preguntan
  "¿Descartar los cambios?" (Seguir editando / Descartar).
  - `hex_form.dart`: `confirmarSalida(...)` (diálogo) y mixin `ProtegeCambios`: cada pantalla define
    `firmaFormulario` (sus valores editables en un texto), envuelve su contenido con `protegerSalida(...)` y,
    al guardar o eliminar, sale con `salirSinPreguntar()`. Jornada llama `reiniciarFirma()` al cambiar de
    semana; en Reagendar la franja elegida sola (al abrir o al cargar horarios) no cuenta como cambio.
  - `ParAcciones.secundario` ahora es opcional: sin él, el botón principal ocupa todo el ancho.
- **Nueva reserva**: la ✕ del header sale de toda la reserva. En el paso 1 no pregunta; en los pasos 2 a 4,
  `HomeShell._salirDeReserva` pregunta "¿Salir de la nueva reserva?" y vuelve a la pestaña desde la que se
  empezó. "Volver" (o el atrás del sistema) regresa solo al paso anterior. Se quitaron "Cancelar y volver a
  Agenda" (paso 1) y "Volver a la Agenda Operativa" (paso 4, junto con `onVolverAgenda`, reemplazado por
  `onSalir`). "Volver y corregir datos" ahora dice "Volver a Fecha y hora", en línea con "Volver a Servicio".
- **Hojas modales** (Atendido, Cancelar cita, Nueva especialidad, Registrar cliente): sin la ✕ de arriba. Se
  cierran con su botón secundario (Regresar / Volver / Cancelar / Descartar) o deslizando hacia abajo.
- **Recuperación de acceso**: se quitó "Volver al Inicio de Sesión" del final; queda la flecha de arriba
  (anuncia "Volver al inicio de sesión" a lectores de pantalla).
- Íconos que quedaron sin uso: `crear_servicio/close.svg`, `nuevo_cierre/close.svg`, `reg_inasistencia/close.svg`,
  `jornada/close.svg`, `condiciones/close.svg`, `confirm/agenda.svg`, `confirm/edit.svg`, `confirmar/close.svg`,
  `reg_cliente/close.svg`, `recuperacion/volver.svg`.
- Tests: `test/salidas_test.dart` (+7). 118 en total.
