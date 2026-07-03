import { useState } from 'react';
import { Box, Typography, Paper, FormControl, InputLabel, Select, MenuItem, Chip } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import { useQuery } from '@tanstack/react-query';
import api from '../../services/api';
import {
  AUDIT_ACTION_LABELS, AUDIT_ACTION_COLORS, ENTITY_TYPE_LABELS,
  ROLE_LABELS, ROLE_CHIP_STYLE,
} from '../../constants/labels';
import EmptyValue from '../../components/common/EmptyValue';

// Genera una frase legible combinando acción, usuario, entidad y descripción del registro,
// en vez de repetir el username crudo en la columna "Descripción".
function buildAuditDescription(row) {
  const who = `El usuario ${row.username}`;
  const entityLabel = ENTITY_TYPE_LABELS[row.entityType] || row.entityType;
  const target = row.entityDescription ? ` "${row.entityDescription}"` : '';

  switch (row.action) {
    case 'LOGIN':
      return row.success
        ? `${who} inició sesión con éxito en el sistema.`
        : `${who} intentó iniciar sesión sin éxito.`;
    case 'LOGOUT':
      return `${who} cerró sesión en el sistema.`;
    case 'CREATE':
      return `${who} creó un nuevo registro de ${entityLabel}${target}.`;
    case 'UPDATE':
      return `${who} modificó el registro de ${entityLabel}${target}.`;
    case 'DELETE':
      return `${who} eliminó el registro de ${entityLabel}${target}.`;
    case 'VIEW':
      return `${who} consultó el registro de ${entityLabel}${target}.`;
    case 'EXPORT':
      return `${who} exportó datos de ${entityLabel}${target}.`;
    case 'IMPORT':
      return `${who} importó datos de ${entityLabel}${target}.`;
    default:
      return row.entityDescription || `${who} realizó una acción sobre ${entityLabel}.`;
  }
}

export default function AuditPage() {
  const [filters, setFilters] = useState({ action: '', entityType: '', page: 0 });

  const { data, isLoading } = useQuery({
    queryKey: ['audit', filters],
    queryFn: () => api.get('/audit/logs', {
      params: {
        action: filters.action || undefined,
        entityType: filters.entityType || undefined,
        page: filters.page,
        size: 20,
      }
    }).then((r) => r.data.data),
  });

  const columns = [
    { field: 'id', headerName: '#', width: 60 },
    { field: 'username', headerName: 'Usuario', width: 120 },
    {
      field: 'fullName', headerName: 'Nombre Completo', width: 180,
      renderCell: ({ value }) => value || <EmptyValue />,
    },
    {
      field: 'roleName', headerName: 'Rol', width: 160,
      renderCell: ({ value }) => (
        <Chip label={ROLE_LABELS[value] || 'Sistema'} size="small"
          sx={ROLE_CHIP_STYLE[value] || ROLE_CHIP_STYLE.ROLE_USUARIO} />
      ),
    },
    {
      field: 'action', headerName: 'Acción', width: 140,
      renderCell: ({ value }) => <Chip label={AUDIT_ACTION_LABELS[value] || value} color={AUDIT_ACTION_COLORS[value] || 'default'} size="small" />
    },
    {
      field: 'entityType', headerName: 'Entidad', width: 160,
      renderCell: ({ value }) => ENTITY_TYPE_LABELS[value] || value,
    },
    {
      field: 'entityDescription', headerName: 'Descripción', flex: 1, minWidth: 320,
      renderCell: ({ row }) => buildAuditDescription(row),
    },
    { field: 'ipAddress', headerName: 'IP', width: 130 },
    {
      field: 'success', headerName: 'Éxito', width: 80,
      renderCell: ({ value }) => <Chip label={value ? 'Sí' : 'No'} color={value ? 'success' : 'error'} size="small" />
    },
    {
      field: 'timestamp', headerName: 'Fecha/Hora', width: 170,
      valueFormatter: ({ value }) => value ? new Date(value).toLocaleString('es-CO') : 'N/A'
    },
  ];

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>Registros de Auditoría</Typography>
      <Paper sx={{ p: 2, mb: 2 }}>
        <Box display="flex" gap={2} flexWrap="wrap">
          <FormControl size="small" sx={{ minWidth: 150 }}>
            <InputLabel>Acción</InputLabel>
            <Select value={filters.action} label="Acción"
              onChange={(e) => setFilters({ ...filters, action: e.target.value, page: 0 })}>
              <MenuItem value="">Todas</MenuItem>
              {Object.entries(AUDIT_ACTION_LABELS).map(([value, label]) => (
                <MenuItem key={value} value={value}>{label}</MenuItem>
              ))}
            </Select>
          </FormControl>
          <FormControl size="small" sx={{ minWidth: 180 }}>
            <InputLabel>Tipo de Entidad</InputLabel>
            <Select value={filters.entityType} label="Tipo de Entidad"
              onChange={(e) => setFilters({ ...filters, entityType: e.target.value, page: 0 })}>
              <MenuItem value="">Todas</MenuItem>
              {Object.entries(ENTITY_TYPE_LABELS).map(([value, label]) => (
                <MenuItem key={value} value={value}>{label}</MenuItem>
              ))}
            </Select>
          </FormControl>
        </Box>
      </Paper>
      <Paper>
        <DataGrid
          rows={data?.content || []}
          columns={columns}
          rowCount={data?.totalElements || 0}
          loading={isLoading}
          paginationMode="server"
          paginationModel={{ page: filters.page, pageSize: 20 }}
          onPaginationModelChange={(m) => setFilters({ ...filters, page: m.page })}
          pageSizeOptions={[20]}
          disableRowSelectionOnClick
          autoHeight
          sx={{ border: 0 }}
        />
      </Paper>
    </Box>
  );
}
