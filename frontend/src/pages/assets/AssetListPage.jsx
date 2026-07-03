import { useState } from 'react';
import {
  Box, Button, Chip, Typography, TextField, MenuItem,
  Select, FormControl, InputLabel, IconButton, Tooltip, Paper
} from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PictureAsPdfIcon from '@mui/icons-material/PictureAsPdf';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSnackbar } from 'notistack';
import dayjs from 'dayjs';
import { assetService } from '../../services/assetService';
import { inventoryService } from '../../services/inventoryService';
import { useAuth } from '../../context/AuthContext';

const STATUS_COLORS = {
  ACTIVE: 'success', LOST: 'warning'
};
const STATUS_LABELS = {
  ACTIVE: 'Activo', LOST: 'Pendiente de baja'
};

export default function AssetListPage() {
  const navigate = useNavigate();
  const { hasRole } = useAuth();
  const { enqueueSnackbar } = useSnackbar();
  const queryClient = useQueryClient();

  const [filters, setFilters] = useState({ search: '', status: '', page: 0, size: 10 });
  const [rowSelectionModel, setRowSelectionModel] = useState([]);

  const { data, isLoading } = useQuery({
    queryKey: ['assets', filters],
    queryFn: () => assetService.getAll({
      search: filters.search || undefined,
      status: filters.status || undefined,
      page: filters.page,
      size: filters.size,
    }),
  });

  const deleteMutation = useMutation({
    mutationFn: assetService.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      enqueueSnackbar('Activo eliminado', { variant: 'success' });
    },
    onError: (err) => enqueueSnackbar(err?.response?.data?.error || 'Error al eliminar', { variant: 'error' }),
  });

  const handleExportPdf = async () => {
    const selectedIds = rowSelectionModel.map((id) => String(id));
    const selectedIdsSet = new Set(selectedIds);
    const currentAssets = (data?.content || []).filter((asset) => selectedIdsSet.has(String(asset.id)));

    const missingIds = selectedIds.filter((id) => !currentAssets.some((asset) => String(asset.id) === id));
    const loadedAssets = await Promise.all(
      missingIds.map((id) => assetService.getById(id).catch(() => null))
    );

    const selectedAssets = [...currentAssets, ...loadedAssets.filter(Boolean)];

    if (!selectedAssets.length) {
      enqueueSnackbar('Selecciona al menos un activo para exportar', { variant: 'info' });
      return;
    }

    const doc = new jsPDF();
    doc.setFontSize(16);
    doc.text('Reporte de activos seleccionados', 14, 16);
    doc.setFontSize(10);
    doc.text(`Generado: ${new Date().toLocaleString('es-ES')}`, 14, 24);

    autoTable(doc, {
      startY: 32,
      head: [['Código', 'Nombre', 'Marca', 'Modelo', 'Tipo', 'Área', 'Estado']],
      body: selectedAssets.map((asset) => [
        asset.codigo || '-',
        asset.name || '-',
        asset.brand || '-',
        asset.model || '-',
        asset.assetTypeName || '-',
        asset.areaName || '-',
        STATUS_LABELS[asset.status] || asset.status || '-',
      ]),
      styles: { fontSize: 8 },
      headStyles: { fillColor: [25, 118, 210] },
      alternateRowStyles: { fillColor: [245, 245, 245] },
    });

    const allMovements = await Promise.all(
      selectedAssets.map((asset) =>
        inventoryService.getByAsset(asset.id)
          .then((movements) => ({ asset, movements }))
          .catch(() => ({ asset, movements: [] }))
      )
    );

    const movementRows = allMovements.flatMap(({ asset, movements }) =>
      movements.map((m) => [
        asset.name || '-',
        dayjs(m.movementDate).format('DD/MM/YYYY HH:mm') || '-',
        MOVEMENT_LABELS[m.movementType] || m.movementType || '-',
        m.fromArea?.name || '-',
        m.toArea?.name || '-',
        m.toUser?.fullName || m.fromUser?.fullName || '-',
        m.reason || '-',
        m.notes || '-',
      ])
    );

    doc.addPage();
    doc.setFontSize(14);
    doc.text('Historial consolidado de movimientos', 14, 20);
    doc.setFontSize(10);
    doc.text(`Movimientos totales: ${movementRows.length}`, 14, 26);

    if (!movementRows.length) {
      doc.setFontSize(10);
      doc.text('No se encontraron movimientos para los activos seleccionados.', 14, 36);
    } else {
      autoTable(doc, {
        startY: 36,
        head: [
          ['Activo', 'Fecha', 'Tipo', 'Área Origen', 'Área Destino', 'Usuario', 'Razón', 'Observaciones'],
        ],
        body: movementRows,
        styles: { fontSize: 8 },
        headStyles: { fillColor: [33, 150, 243] },
        alternateRowStyles: { fillColor: [245, 245, 245] },
      });
    }

    doc.save(`activos-seleccionados-${selectedAssets.length}.pdf`);
    enqueueSnackbar(`PDF generado con ${selectedAssets.length} activo(s) y su historial consolidado`, { variant: 'success' });
  };

  const columns = [
    { field: 'codigo', headerName: 'Código', width: 110 },
    { field: 'name', headerName: 'Nombre', flex: 1, minWidth: 150 },
    { field: 'brand', headerName: 'Marca', width: 100 },
    { field: 'model', headerName: 'Modelo', width: 120 },
    { field: 'assetTypeName', headerName: 'Tipo', width: 150 },
    { field: 'areaName', headerName: 'Área', width: 150 },
    {
      field: 'status',
      headerName: 'Estado',
      width: 130,
      renderCell: ({ value }) => (
        <Chip label={STATUS_LABELS[value] || value} color={STATUS_COLORS[value]} size="small" />
      ),
    },
    {
      field: 'hasNetworkDevice',
      headerName: 'IP',
      width: 130,
      renderCell: ({ row }) => row.hasNetworkDevice ? (
        <Chip label={row.ipAddress || 'Configurado'} size="small" color="info" />
      ) : '—',
    },
    {
      field: 'actions',
      headerName: 'Acciones',
      width: 130,
      sortable: false,
      renderCell: ({ row }) => (
        <Box>
          <Tooltip title="Ver detalle">
            <IconButton size="small" onClick={() => navigate(`/assets/${row.id}`)}>
              <VisibilityIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          {hasRole(['ROLE_ADMIN', 'ROLE_SUPERADMIN', 'ROLE_TECNICO']) && (
            <Tooltip title="Editar">
              <IconButton size="small" onClick={() => navigate(`/assets/${row.id}/edit`)}>
                <EditIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          {hasRole(['ROLE_ADMIN', 'ROLE_SUPERADMIN']) && (
            <Tooltip title="Eliminar">
              <IconButton
                size="small"
                color="error"
                onClick={() => {
                  if (window.confirm('¿Eliminar este activo?')) deleteMutation.mutate(row.id);
                }}
              >
                <DeleteIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
        </Box>
      ),
    },
  ];

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>Activos Tecnológicos</Typography>
        <Box display="flex" gap={1}>
          <Button
            variant="outlined"
            color="secondary"
            startIcon={<PictureAsPdfIcon />}
            onClick={handleExportPdf}
            disabled={rowSelectionModel.length === 0}
          >
            Exportar PDF
          </Button>
          {hasRole(['ROLE_ADMIN', 'ROLE_SUPERADMIN', 'ROLE_TECNICO']) && (
            <Button variant="contained" startIcon={<AddIcon />} onClick={() => navigate('/assets/new')}>
              Nuevo Activo
            </Button>
          )}
        </Box>
      </Box>

      <Paper sx={{ p: 2, mb: 2 }}>
        <Box display="flex" gap={2} flexWrap="wrap">
          <TextField
            label="Buscar"
            size="small"
            value={filters.search}
            onChange={(e) => setFilters({ ...filters, search: e.target.value, page: 0 })}
            placeholder="Nombre, serial, código..."
            sx={{ minWidth: 220 }}
          />
          <FormControl size="small" sx={{ minWidth: 160 }}>
            <InputLabel>Estado</InputLabel>
            <Select
              value={filters.status}
              label="Estado"
              onChange={(e) => setFilters({ ...filters, status: e.target.value, page: 0 })}
            >
              <MenuItem value="">Todos</MenuItem>
              <MenuItem value="ACTIVE">Activo</MenuItem>
              <MenuItem value="RETIRED">Baja</MenuItem>
              <MenuItem value="LOST">Pendiente de baja</MenuItem>
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
          paginationModel={{ page: filters.page, pageSize: filters.size }}
          onPaginationModelChange={(model) =>
            setFilters({ ...filters, page: model.page, size: model.pageSize })
          }
          pageSizeOptions={[10, 25, 50]}
          checkboxSelection
          rowSelectionModel={rowSelectionModel}
          onRowSelectionModelChange={(newModel) => setRowSelectionModel(newModel)}
          autoHeight
          sx={{ border: 0 }}
        />
      </Paper>
    </Box>
  );
}
