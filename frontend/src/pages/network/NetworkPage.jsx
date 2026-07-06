import { useState } from 'react';
import {
  Box, Typography, Paper, Chip, TextField, Tab, Tabs, Fade,
} from '@mui/material';
import { alpha } from '@mui/material/styles';
import { DataGrid } from '@mui/x-data-grid';
import WifiIcon from '@mui/icons-material/Wifi';
import WifiOffIcon from '@mui/icons-material/WifiOff';
import HelpOutlineIcon from '@mui/icons-material/HelpOutline';
import RouterIcon from '@mui/icons-material/Router';
import { useQuery } from '@tanstack/react-query';
import { networkService } from '../../services/networkService';
import { NETWORK_STATUS_LABELS, NETWORK_STATUS_COLORS, CONNECTION_TYPE_LABELS } from '../../constants/labels';

const STATUS_ICONS = {
  ONLINE: <WifiIcon fontSize="small" />,
  OFFLINE: <WifiOffIcon fontSize="small" />,
  UNKNOWN: <HelpOutlineIcon fontSize="small" />,
};

const STATUS_DOT_COLOR = { ONLINE: '#2E7D32', OFFLINE: '#C62828', UNKNOWN: '#78909C' };

function PulsingDot({ status }) {
  const color = STATUS_DOT_COLOR[status] || STATUS_DOT_COLOR.UNKNOWN;
  const isLive = status === 'ONLINE' || status === 'OFFLINE';
  return (
    <Box
      sx={{
        width: 9, height: 9, borderRadius: '50%', bgcolor: color, flexShrink: 0,
        animation: isLive ? 'noc-pulse 1.8s infinite' : 'none',
        '@keyframes noc-pulse': {
          '0%': { boxShadow: `0 0 0 0 ${alpha(color, 0.6)}` },
          '70%': { boxShadow: `0 0 0 7px ${alpha(color, 0)}` },
          '100%': { boxShadow: `0 0 0 0 ${alpha(color, 0)}` },
        },
      }}
    />
  );
}

function NocSummaryCard({ label, value, color, status }) {
  return (
    <Paper
      sx={{
        p: 2, minWidth: 140, flex: 1, borderRadius: 2,
        borderLeft: '4px solid', borderLeftColor: color,
        display: 'flex', alignItems: 'center', gap: 1.5,
      }}
    >
      {status && <PulsingDot status={status} />}
      <Box>
        <Typography variant="h5" fontWeight={700} sx={{ color }}>{value ?? '—'}</Typography>
        <Typography variant="caption" color="text.secondary">{label}</Typography>
      </Box>
    </Paper>
  );
}

export default function NetworkPage() {
  const [tab, setTab] = useState(0);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(0);

  const { data: devices, isLoading } = useQuery({
    queryKey: ['networkDevices', search, page],
    queryFn: () => networkService.getDevices({ search: search || undefined, page, size: 15 }),
  });

  const { data: stats } = useQuery({
    queryKey: ['networkStats'],
    queryFn: networkService.getStats,
  });

  const { data: topology } = useQuery({
    queryKey: ['topology'],
    queryFn: networkService.getTopology,
    enabled: tab === 1,
  });

  const columns = [
    { field: 'hostname', headerName: 'Hostname', flex: 1 },
    { field: 'ipAddress', headerName: 'Dirección IP', width: 150 },
    { field: 'macAddress', headerName: 'MAC', width: 160 },
    {
      field: 'networkStatus',
      headerName: 'Estado',
      width: 150,
      renderCell: ({ value }) => (
        <Box display="flex" alignItems="center" gap={1}>
          <PulsingDot status={value} />
          <Chip
            icon={STATUS_ICONS[value]}
            label={NETWORK_STATUS_LABELS[value] || value}
            color={NETWORK_STATUS_COLORS[value]}
            size="small"
            variant="outlined"
          />
        </Box>
      ),
    },
    {
      field: 'asset',
      headerName: 'Activo',
      width: 200,
      valueGetter: ({ row }) => row.asset?.name || 'Sin asignar',
    },
    { field: 'vlanId', headerName: 'VLAN', width: 80 },
    { field: 'firmwareVersion', headerName: 'Firmware', width: 120 },
    {
      field: 'lastSeen',
      headerName: 'Último Contacto',
      width: 160,
      valueFormatter: ({ value }) =>
        value ? new Date(value).toLocaleString('es-CO') : 'N/A',
    },
  ];

  return (
    <Box>
      <Box display="flex" alignItems="center" gap={1} mb={2}>
        <RouterIcon color="primary" />
        <Typography variant="h5" fontWeight={700}>
          Redes & Comunicaciones — Centro de Control
        </Typography>
      </Box>

      {/* Tarjetas de resumen estilo NOC */}
      <Box display="flex" gap={2} mb={3} flexWrap="wrap">
        <NocSummaryCard label="Total Dispositivos" value={stats?.total} color="#1565C0" />
        <NocSummaryCard label={NETWORK_STATUS_LABELS.ONLINE} value={stats?.online} color={STATUS_DOT_COLOR.ONLINE} status="ONLINE" />
        <NocSummaryCard label={NETWORK_STATUS_LABELS.OFFLINE} value={stats?.offline} color={STATUS_DOT_COLOR.OFFLINE} status="OFFLINE" />
        <NocSummaryCard label={NETWORK_STATUS_LABELS.UNKNOWN} value={stats?.unknown} color={STATUS_DOT_COLOR.UNKNOWN} status="UNKNOWN" />
      </Box>

      <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ mb: 2 }}>
        <Tab label="Dispositivos de Red" />
        <Tab label="Topología" />
      </Tabs>

      <Fade in={tab === 0} timeout={300} unmountOnExit>
        <Box>
          <TextField
            label="Buscar por IP, hostname o MAC"
            size="small"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); }}
            sx={{ mb: 2, minWidth: 300 }}
          />
          <Paper>
            <DataGrid
              rows={devices?.content || []}
              columns={columns}
              rowCount={devices?.totalElements || 0}
              loading={isLoading}
              paginationMode="server"
              paginationModel={{ page, pageSize: 15 }}
              onPaginationModelChange={(m) => setPage(m.page)}
              pageSizeOptions={[15]}
              disableRowSelectionOnClick
              autoHeight
              sx={{ border: 0 }}
            />
          </Paper>
        </Box>
      </Fade>

      <Fade in={tab === 1} timeout={300} unmountOnExit>
        <Paper sx={{ p: 3 }}>
          <Typography variant="subtitle1" fontWeight={600} mb={2}>
            Topología de Red — {topology?.length || 0} enlaces activos
          </Typography>
          {topology?.length === 0 ? (
            <Typography color="text.secondary">No hay enlaces de topología registrados.</Typography>
          ) : (
            topology?.map((link) => (
              <Box key={link.id} sx={{ borderBottom: '1px solid', borderColor: 'divider', py: 1.5 }}>
                <Typography variant="body2">
                  <strong>{link.sourceDevice?.hostname || link.sourceDevice?.ipAddress}</strong>
                  {' ↔ '}
                  <strong>{link.targetDevice?.hostname || link.targetDevice?.ipAddress}</strong>
                  {' — '}
                  <Chip label={CONNECTION_TYPE_LABELS[link.connectionType] || link.connectionType} size="small" />
                  {link.bandwidth && ` | ${link.bandwidth}`}
                </Typography>
              </Box>
            ))
          )}
        </Paper>
      </Fade>
    </Box>
  );
}
