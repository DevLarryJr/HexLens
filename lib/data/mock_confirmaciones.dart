/// Motivos para cancelar una cita: (motivo, detalle).
const motivosCancelacion = [
  ('Solicitud directa del cliente (aviso previo > 24h)', 'Cumple ventana de reprogramación estándar sin cobro punitivo.'),
  ('Inasistencia del cliente / No-Show', 'Superó los 20 min de tolerancia de estudio.'),
  ('Fuerza mayor técnica / Mantenimiento de set o equipo', 'Falla de generador, luces estroboscópicas o ciclorama.'),
  ('Incapacidad médica del fotógrafo', 'Sin relevo disponible en el bloque horario.'),
  ('Otro motivo operativo', 'Registrar detalle en la bitácora de la orden.'),
];

/// Checklist técnico para cerrar una sesión atendida: (punto, detalle).
/// Los [checklistObligatorios] primeros son obligatorios.
const checklistEntrega = [
  ('Toma de capturas fotográficas finalizada', 'Mínimo técnico acordado: 35 disparos RAW validados'),
  ('Selección de 5 tomas maestras', 'Revisadas y aprobadas junto al cliente en monitor de set'),
  ('Backup de memoria transferido', 'Ingesta completa al almacenamiento local (#NAS-SET-02)'),
  ('Entrega inmediata de muestras digitales', 'Opcional: envío de 2 previsualizaciones al cliente'),
];

const checklistObligatorios = 3;
