// Mapeos centralizados de enums del backend a texto/color en español.
// Única fuente de verdad para evitar traducciones incompletas o inconsistentes entre vistas.

export const ASSET_STATUS_LABELS = {
  ACTIVE: 'Activo',
  MAINTENANCE: 'En Mantenimiento',
  RETIRED: 'Dado de Baja',
  LOST: 'Pendiente de Baja',
};

export const ASSET_STATUS_COLORS = {
  ACTIVE: 'success',
  MAINTENANCE: 'warning',
  RETIRED: 'default',
  LOST: 'error',
};

// Chip "outlined" con fondo semitransparente según semántica — se ve bien en claro y oscuro
// porque el color se mezcla por alpha en vez de depender de un hex sólido fijo.
export const ASSET_STATUS_OUTLINED_STYLE = {
  ACTIVE: { color: '#2E7D32', borderColor: 'rgba(46,125,50,0.5)', bgcolor: 'rgba(46,125,50,0.12)' },
  MAINTENANCE: { color: '#F57C00', borderColor: 'rgba(245,124,0,0.5)', bgcolor: 'rgba(245,124,0,0.12)' },
  RETIRED: { color: 'text.secondary', borderColor: 'divider', bgcolor: 'action.hover' },
  LOST: { color: '#C62828', borderColor: 'rgba(198,40,40,0.5)', bgcolor: 'rgba(198,40,40,0.12)' },
};

export const MOVEMENT_TYPE_LABELS = {
  ENTRY: 'Entrada',
  EXIT: 'Salida',
  TRANSFER: 'Traslado',
  LOAN: 'Préstamo',
  RETURN: 'Devolución',
  MAINTENANCE_IN: 'Entrada a Mantenimiento',
  MAINTENANCE_OUT: 'Salida de Mantenimiento',
};

export const MOVEMENT_TYPE_COLORS = {
  ENTRY: 'success',
  EXIT: 'error',
  TRANSFER: 'info',
  LOAN: 'warning',
  RETURN: 'default',
  MAINTENANCE_IN: 'warning',
  MAINTENANCE_OUT: 'success',
};

export const NETWORK_STATUS_LABELS = {
  ONLINE: 'En línea',
  OFFLINE: 'Fuera de línea',
  UNKNOWN: 'Desconocido',
};

export const NETWORK_STATUS_COLORS = {
  ONLINE: 'success',
  OFFLINE: 'error',
  UNKNOWN: 'default',
};

export const AUDIT_ACTION_LABELS = {
  CREATE: 'Creación',
  UPDATE: 'Actualización',
  DELETE: 'Eliminación',
  VIEW: 'Consulta',
  LOGIN: 'Inicio de Sesión',
  LOGOUT: 'Cierre de Sesión',
  EXPORT: 'Exportación',
  IMPORT: 'Importación',
};

export const AUDIT_ACTION_COLORS = {
  CREATE: 'success',
  UPDATE: 'warning',
  DELETE: 'error',
  LOGIN: 'info',
  LOGOUT: 'default',
  VIEW: 'default',
  EXPORT: 'info',
  IMPORT: 'info',
};

// Color sólido de franja lateral por acción (barra de color en la vista de Auditoría).
export const AUDIT_ACTION_STRIPE_COLOR = {
  CREATE: '#2E7D32',
  UPDATE: '#F57C00',
  DELETE: '#C62828',
  LOGIN: '#0288D1',
  LOGOUT: '#78909C',
  VIEW: '#78909C',
  EXPORT: '#0288D1',
  IMPORT: '#0288D1',
};

export const CONNECTION_TYPE_LABELS = {
  ETHERNET: 'Ethernet',
  WIFI: 'Wi-Fi',
  FIBER: 'Fibra Óptica',
  SERIAL: 'Serial',
  COAXIAL: 'Coaxial',
};

export const ENTITY_TYPE_LABELS = {
  Asset: 'Activo',
  User: 'Usuario',
  NetworkDevice: 'Dispositivo de Red',
  InventoryMovement: 'Movimiento de Inventario',
  Area: 'Área',
};

export const ROLE_LABELS = {
  ROLE_SUPERADMIN: 'SuperAdministrador',
  ROLE_ADMIN: 'Administrador',
  ROLE_TECNICO: 'Técnico',
  ROLE_USUARIO: 'Usuario Estándar',
};

// Fondo semitransparente (rgba) en vez de hex sólido: se ve bien tanto en modo claro
// como oscuro, porque el color de fondo se mezcla por alpha sobre el fondo real del tema,
// mientras el texto conserva un tono saturado con buen contraste en ambos casos.
export const ROLE_CHIP_STYLE = {
  ROLE_SUPERADMIN: { bgcolor: 'rgba(79,70,229,0.16)', color: '#4F46E5', fontWeight: 700, border: '1px solid rgba(79,70,229,0.4)' },
  ROLE_ADMIN: { bgcolor: 'rgba(13,148,136,0.16)', color: '#0D9488', fontWeight: 600, border: '1px solid rgba(13,148,136,0.4)' },
  ROLE_TECNICO: { bgcolor: 'rgba(26,115,232,0.16)', color: '#1A73E8', fontWeight: 600, border: '1px solid rgba(26,115,232,0.4)' },
  ROLE_USUARIO: { bgcolor: 'rgba(107,114,128,0.16)', color: '#6B7280', fontWeight: 600, border: '1px solid rgba(107,114,128,0.4)' },
};
