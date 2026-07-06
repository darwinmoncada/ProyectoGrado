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
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSnackbar } from 'notistack';
import { assetService } from '../../services/assetService';
import { useAuth } from '../../context/AuthContext';
import { ASSET_STATUS_LABELS, ASSET_STATUS_COLORS } from '../../constants/labels';
import EmptyValue from '../../components/common/EmptyValue';
import { downloadBlob, extractBlobErrorMessage } from '../../utils/fileDownload';

export default function AssetListPage() {
  const navigate = useNavigate();
  const { hasRole } = useAuth();
  const { enqueueSnackbar } = useSnackbar();
  const queryClient = useQueryClient();

  const [filters, setFilters] = useState({ search: '', status: '', page: 0, size: 10 });
  const [rowSelectionModel, setRowSelectionModel] = useState([]);
  const [exportingPdf, setExportingPdf] = useState(false);

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
    if (!rowSelectionModel.length) {
      enqueueSnackbar('Selecciona al menos un activo para exportar', { variant: 'info' });
      return;
    }
    setExportingPdf(true);
    try {
      const blob = await assetService.exportListPdf(rowSelectionModel.map(Number));
      downloadBlob(blob, `reporte-activos-${rowSelectionModel.length}.pdf`);
      enqueueSnackbar(`PDF generado con ${rowSelectionModel.length} activo(s) y su historial consolidado`, { variant: 'success' });
    } catch (err) {
      enqueueSnackbar(await extractBlobErrorMessage(err, 'Error al generar el PDF'), { variant: 'error' });
    } finally {
      setExportingPdf(false);
    }
  };

  const columns = [
    { field: 'codigo', headerName: 'Código', width: 110 },
    { field: 'name', headerName: 'Nombre', flex: 1, minWidth: 150 },
    {
      field: 'brand', headerName: 'Marca', width: 100,
      renderCell: ({ value }) => value || <EmptyValue />,
    },
    {
      field: 'model', headerName: 'Modelo', width: 120,
      renderCell: ({ value }) => value || <EmptyValue />,
    },
    { field: 'assetTypeName', headerName: 'Tipo', width: 150 },
    { field: 'areaName', headerName: 'Área', width: 150 },
    {
      field: 'status',
      headerName: 'Estado',
      width: 150,
      renderCell: ({ value }) => (
        <Chip label={ASSET_STATUS_LABELS[value] || value} color={ASSET_STATUS_COLORS[value]} size="small" />
      ),
    },
    {
      field: 'hasNetworkDevice',
      headerName: 'IP',
      width: 130,
      renderCell: ({ row }) => row.hasNetworkDevice ? (
        <Chip label={row.ipAddress || 'Configurado'} size="small" color="info" />
      ) : <EmptyValue />,
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
            disabled={rowSelectionModel.length === 0 || exportingPdf}
          >
            {exportingPdf ? 'Generando PDF...' : 'Exportar PDF'}
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
              {Object.entries(ASSET_STATUS_LABELS).map(([value, label]) => (
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
