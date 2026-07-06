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
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSnackbar } from 'notistack';
import { assetService } from '../../services/assetService';
import { useAuth } from '../../context/AuthContext';
import { ASSET_STATUS_LABELS, ASSET_STATUS_COLORS } from '../../constants/labels';
import EmptyValue from '../../components/common/EmptyValue';
import PdfExportMenu from '../../components/common/PdfExportMenu';
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

  const runPdfExport = async (exportPromise, filename, successMsg) => {
    setExportingPdf(true);
    try {
      const blob = await exportPromise;
      downloadBlob(blob, filename);
      enqueueSnackbar(successMsg, { variant: 'success' });
    } catch (err) {
      enqueueSnackbar(await extractBlobErrorMessage(err, 'Error al generar el PDF'), { variant: 'error' });
    } finally {
      setExportingPdf(false);
    }
  };

  const handleExportConsolidated = () => {
    if (!rowSelectionModel.length) {
      enqueueSnackbar('Selecciona al menos un activo para exportar', { variant: 'info' });
      return;
    }
    const ids = rowSelectionModel.map(Number);
    runPdfExport(
      assetService.exportListPdf(ids),
      `reporte-activos-${ids.length}.pdf`,
      `PDF generado con ${ids.length} activo(s) seleccionado(s)`
    );
  };

  const handleExportBatchSheets = () => {
    if (!rowSelectionModel.length) {
      enqueueSnackbar('Selecciona al menos un activo para exportar', { variant: 'info' });
      return;
    }
    const ids = rowSelectionModel.map(Number);
    runPdfExport(
      assetService.exportBatchSheetsPdf(ids),
      `hojas-de-vida-${ids.length}.pdf`,
      `Se generaron ${ids.length} hoja(s) de vida en un solo PDF`
    );
  };

  const handleExportCollectiveMovements = () => {
    if (!rowSelectionModel.length) {
      enqueueSnackbar('Selecciona al menos un activo para exportar', { variant: 'info' });
      return;
    }
    const ids = rowSelectionModel.map(Number);
    runPdfExport(
      assetService.exportCollectiveMovementsPdf(ids),
      `historial-colectivo-${ids.length}.pdf`,
      `Historial de movimientos generado para ${ids.length} activo(s)`
    );
  };

  const handleExportRowConsolidated = (row) => {
    runPdfExport(
      assetService.exportListPdf([row.id]),
      `reporte-activo-${row.codigo || row.id}.pdf`,
      'Reporte consolidado generado'
    );
  };

  const handleExportRowDetail = (row) => {
    runPdfExport(
      assetService.exportDetailPdf(row.id),
      `ficha-activo-${row.codigo || row.id}.pdf`,
      'Ficha técnica generada'
    );
  };

  const handleExportRowMovements = (row) => {
    runPdfExport(
      assetService.exportMovementsPdf(row.id),
      `historial-movimientos-${row.codigo || row.id}.pdf`,
      'Historial de traslados generado'
    );
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
      width: 170,
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
          <PdfExportMenu
            variant="icon"
            label="Exportar PDF"
            options={[
              { label: 'Reporte Consolidado', description: 'Ficha resumida de este activo', onClick: () => handleExportRowConsolidated(row) },
              { label: 'Ficha Técnica', description: 'Hoja de vida del activo', onClick: () => handleExportRowDetail(row) },
              { label: 'Historial de Traslados', description: 'Movimientos y custodios', onClick: () => handleExportRowMovements(row) },
            ]}
          />
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
          <PdfExportMenu
            label={exportingPdf ? 'Generando PDF...' : 'Exportar PDF'}
            disabled={rowSelectionModel.length === 0 || exportingPdf}
            options={[
              {
                label: 'Reporte Consolidado',
                description: 'Tabla resumida de los activos seleccionados',
                onClick: handleExportConsolidated,
              },
              {
                label: 'Hojas de Vida en Lote',
                description: 'Una ficha técnica por cada activo seleccionado',
                onClick: handleExportBatchSheets,
              },
              {
                label: 'Historial Colectivo de Movimientos',
                description: 'Cronología de traslados de todos los seleccionados',
                onClick: handleExportCollectiveMovements,
              },
            ]}
          />
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
