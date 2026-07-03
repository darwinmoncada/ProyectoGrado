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
