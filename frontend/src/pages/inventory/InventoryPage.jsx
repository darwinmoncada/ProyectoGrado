import { useState, useRef } from 'react';
import {
  Box, Typography, Paper, Button, Dialog, DialogTitle,
  DialogContent, DialogActions, TextField, FormControl,
  InputLabel, Select, MenuItem, Chip, CircularProgress,
  Alert, Divider, Grid, InputAdornment,
} from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import { DatePicker } from '@mui/x-date-pickers';
import AddIcon from '@mui/icons-material/Add';
import SearchIcon from '@mui/icons-material/Search';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import SwapHorizIcon from '@mui/icons-material/SwapHoriz';
import LoginIcon from '@mui/icons-material/Login';
import LogoutIcon from '@mui/icons-material/Logout';
import HandshakeIcon from '@mui/icons-material/Handshake';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSnackbar } from 'notistack';
import { useForm, Controller } from 'react-hook-form';
import { inventoryService } from '../../services/inventoryService';
import { assetService } from '../../services/assetService';
import { useAuth } from '../../context/AuthContext';
import { MOVEMENT_TYPE_LABELS, MOVEMENT_TYPE_COLORS, ASSET_STATUS_LABELS } from '../../constants/labels';
import StatCard from '../../components/common/StatCard';
import dayjs from 'dayjs';

const MOVEMENT_TYPES = Object.entries(MOVEMENT_TYPE_LABELS).map(([value, label]) => ({ value, label }));

export default function InventoryPage() {
  const [open, setOpen]       = useState(false);
  const [page, setPage]       = useState(0);
  const [codigoInput, setCodigoInput] = useState('');
  const [assetFound, setAssetFound]   = useState(null);
  const [assetError, setAssetError]   = useState('');
  const [searching, setSearching]     = useState(false);
  const debounceRef = useRef(null);

  const [filters, setFilters] = useState({ search: '', type: '', from: null, to: null });

  const { enqueueSnackbar } = useSnackbar();
  const queryClient = useQueryClient();
  const { hasRole } = useAuth();

  const { data, isLoading } = useQuery({
    queryKey: ['movements', page, filters],
    queryFn: () => inventoryService.getMovements({
      page,
      size: 15,
      search: filters.search || undefined,
      type: filters.type || undefined,
      from: filters.from ? filters.from.startOf('day').toISOString() : undefined,
      to: filters.to ? filters.to.endOf('day').toISOString() : undefined,
    }),
  });

  const { data: stats } = useQuery({
    queryKey: ['movementStats'],
    queryFn: inventoryService.getStats,
  });

  const { control, handleSubmit, reset, setValue, formState: { errors } } = useForm({
    defaultValues: { movementType: '', movementDate: '', notes: '', toAreaId: '', assetTypeId: '' },
  });

  const { data: areas = [] } = useQuery({
    queryKey: ['areas'],
    queryFn: assetService.getAreas,
    enabled: open,
  });

  const { data: assetTypes = [] } = useQuery({
    queryKey: ['assetTypes'],
    queryFn: assetService.getTypes,
    enabled: open,
  });

  const handleCodigoChange = (value) => {
    setCodigoInput(value);
    setAssetFound(null);
    setAssetError('');
    if (debounceRef.current) clearTimeout(debounceRef.current);
    if (!value.trim()) return;
    debounceRef.current = setTimeout(() => buscarActivo(value.trim()), 500);
  };

  const buscarActivo = async (codigo) => {
    setSearching(true);
    try {
      const asset = await assetService.getByCode(codigo);
      setAssetFound(asset);
      setAssetError('');
      setValue('assetTypeId', asset.assetTypeId || '');
      setValue('toAreaId',    asset.areaId      || '');
    } catch {
      setAssetFound(null);
      setAssetError('Activo no válido');
    } finally {
      setSearching(false);
    }
  };

  const handleClose = () => {
    setOpen(false);
    setCodigoInput('');
    setAssetFound(null);
    setAssetError('');
    reset();
  };

  const mutation = useMutation({
    mutationFn: (data) =>
      inventoryService.register({
        assetId:      assetFound.id,
        movementType: data.movementType,
        movementDate: data.movementDate  || null,
        toAreaId:     data.toAreaId      || null,
        assetTypeId:  data.assetTypeId   || null,
        notes:        data.notes         || null,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['movements'] });
      queryClient.invalidateQueries({ queryKey: ['movementStats'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      enqueueSnackbar('Movimiento registrado exitosamente', { variant: 'success' });
      handleClose();
    },
    onError: (err) =>
      enqueueSnackbar(err?.response?.data?.error || 'Error al registrar', { variant: 'error' }),
  });

  const onSubmit = (data) => {
    if (!assetFound) {
      enqueueSnackbar('Debe ingresar un código de activo válido', { variant: 'warning' });
      return;
    }
    mutation.mutate(data);
  };

  const columns = [
    { field: 'id', headerName: '#', width: 60 },
    {
      field: 'asset', headerName: 'Activo', flex: 1,
      valueGetter: ({ row }) => row.asset?.name || 'Sin asignar',
    },
    {
      field: 'codigo', headerName: 'Código', width: 120,
      valueGetter: ({ row }) => row.asset?.codigo || 'Sin asignar',
    },
    {
      field: 'movementType', headerName: 'Tipo de Movimiento', width: 200,
      renderCell: ({ value }) => (
        <Chip label={MOVEMENT_TYPE_LABELS[value] || value} color={MOVEMENT_TYPE_COLORS[value]} size="small" />
      ),
    },
    {
      field: 'movementDate', headerName: 'Fecha', width: 170,
      valueFormatter: ({ value }) =>
        value ? dayjs(value).format('DD/MM/YYYY HH:mm') : 'N/A',
    },
    {
      field: 'notes', headerName: 'Observación', flex: 1,
      valueGetter: ({ row }) => row.notes || 'Sin observaciones',
    },
    {
      field: 'createdBy', headerName: 'Registrado por', width: 160,
      valueGetter: ({ row }) => row.createdBy?.fullName || 'Sin asignar',
    },
  ];

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>Control de Inventario</Typography>
        {hasRole(['ROLE_ADMIN', 'ROLE_SUPERADMIN', 'ROLE_TECNICO']) && (
          <Button variant="contained" startIcon={<AddIcon />} onClick={() => setOpen(true)}>
            Registrar Movimiento
          </Button>
        )}
      </Box>

      <Grid container spacing={2} mb={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Movimientos"
            value={stats?.totalMovements ?? '—'}
            icon={<SwapHorizIcon sx={{ color: '#1565C0', fontSize: 32 }} />}
            color="#1565C0"
            loading={!stats}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Entradas este mes"
            value={stats?.entriesThisMonth ?? '—'}
            icon={<LoginIcon sx={{ color: '#2E7D32', fontSize: 32 }} />}
            color="#2E7D32"
            loading={!stats}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Salidas / Bajas (este mes)"
            value={stats?.exitsThisMonth ?? '—'}
            icon={<LogoutIcon sx={{ color: '#C62828', fontSize: 32 }} />}
            color="#C62828"
            loading={!stats}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Equipos en Préstamo"
            value={stats?.assetsOnLoan ?? '—'}
            icon={<HandshakeIcon sx={{ color: '#F57C00', fontSize: 32 }} />}
            color="#F57C00"
            loading={!stats}
          />
        </Grid>
      </Grid>

      <Paper sx={{ p: 2, mb: 2 }}>
        <Box display="flex" gap={2} flexWrap="wrap" alignItems="center">
          <TextField
            label="Buscar"
            size="small"
            value={filters.search}
            onChange={(e) => { setFilters({ ...filters, search: e.target.value }); setPage(0); }}
            placeholder="Activo, código u observación..."
            sx={{ minWidth: 220 }}
            InputProps={{
              startAdornment: <InputAdornment position="start"><SearchIcon fontSize="small" /></InputAdornment>,
            }}
          />
          <FormControl size="small" sx={{ minWidth: 180 }}>
            <InputLabel>Tipo de Movimiento</InputLabel>
            <Select
              value={filters.type}
              label="Tipo de Movimiento"
              onChange={(e) => { setFilters({ ...filters, type: e.target.value }); setPage(0); }}
            >
              <MenuItem value="">Todos</MenuItem>
              {MOVEMENT_TYPES.map((t) => (
                <MenuItem key={t.value} value={t.value}>{t.label}</MenuItem>
              ))}
            </Select>
          </FormControl>
          <DatePicker
            label="Desde"
            value={filters.from}
            onChange={(value) => { setFilters({ ...filters, from: value }); setPage(0); }}
            slotProps={{ textField: { size: 'small', sx: { minWidth: 160 } } }}
          />
          <DatePicker
            label="Hasta"
            value={filters.to}
            onChange={(value) => { setFilters({ ...filters, to: value }); setPage(0); }}
            slotProps={{ textField: { size: 'small', sx: { minWidth: 160 } } }}
          />
          {(filters.search || filters.type || filters.from || filters.to) && (
            <Button size="small" onClick={() => { setFilters({ search: '', type: '', from: null, to: null }); setPage(0); }}>
              Limpiar filtros
            </Button>
          )}
        </Box>
      </Paper>

      <Paper>
        <DataGrid
          rows={data?.content || []}
          columns={columns}
          rowCount={data?.totalElements || 0}
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

      {/* DIALOG DE REGISTRO */}
      <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
        <DialogTitle>Registrar Movimiento de Inventario</DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2.5} pt={1}>

              {/* BÚSQUEDA POR CÓDIGO */}
              <Typography variant="subtitle2" color="text.secondary">
                Buscar activo por código
              </Typography>
              <TextField
                label="Código del activo"
                value={codigoInput}
                onChange={(e) => handleCodigoChange(e.target.value)}
                fullWidth
                autoFocus
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      {searching
                        ? <CircularProgress size={20} />
                        : assetFound
                          ? <CheckCircleIcon color="success" />
                          : <SearchIcon color="disabled" />}
                    </InputAdornment>
                  ),
                }}
              />

              {assetError && (
                <Alert severity="error" sx={{ py: 0.5 }}>{assetError}</Alert>
              )}

              {/* DATOS DEL ACTIVO (readonly) */}
              {assetFound && (
                <>
                  <Divider />
                  <Typography variant="subtitle2" color="text.secondary">
                    Información del activo
                  </Typography>
                  <Grid container spacing={2}>
                    {/* Nombre — solo lectura */}
                    <Grid item xs={12} sm={6}>
                      <TextField
                        label="Nombre"
                        value={assetFound.name}
                        fullWidth
                        InputProps={{ readOnly: true }}
                        variant="filled"
                        size="small"
                      />
                    </Grid>

                    {/* Tipo de activo — editable, igual que en crear activo */}
                    <Grid item xs={12} sm={6}>
                      <Controller
                        name="assetTypeId"
                        control={control}
                        render={({ field }) => (
                          <FormControl fullWidth size="small">
                            <InputLabel>Tipo de activo</InputLabel>
                            <Select {...field} label="Tipo de activo">
                              {assetTypes.map((t) => (
                                <MenuItem key={t.id} value={t.id}>{t.name}</MenuItem>
                              ))}
                            </Select>
                          </FormControl>
                        )}
                      />
                    </Grid>

                    {/* Estado actual — solo lectura */}
                    <Grid item xs={12} sm={6}>
                      <TextField
                        label="Estado actual"
                        value={ASSET_STATUS_LABELS[assetFound.status] || assetFound.status}
                        fullWidth
                        InputProps={{ readOnly: true }}
                        variant="filled"
                        size="small"
                      />
                    </Grid>

                    {/* Área — editable, igual que en crear activo */}
                    <Grid item xs={12} sm={6}>
                      <Controller
                        name="toAreaId"
                        control={control}
                        render={({ field }) => (
                          <FormControl fullWidth size="small">
                            <InputLabel>Área</InputLabel>
                            <Select {...field} label="Área">
                              <MenuItem value="">Sin asignar</MenuItem>
                              {areas.map((a) => (
                                <MenuItem key={a.id} value={a.id}>{a.name}</MenuItem>
                              ))}
                            </Select>
                          </FormControl>
                        )}
                      />
                    </Grid>
                  </Grid>
                  <Divider />

                  {/* CAMPOS DEL MOVIMIENTO */}
                  <Typography variant="subtitle2" color="text.secondary">
                    Datos del movimiento
                  </Typography>
                  <Controller
                    name="movementType"
                    control={control}
                    rules={{ required: 'Seleccione el tipo de movimiento' }}
                    render={({ field }) => (
                      <FormControl fullWidth error={!!errors.movementType}>
                        <InputLabel>Tipo de movimiento *</InputLabel>
                        <Select {...field} label="Tipo de movimiento *">
                          {MOVEMENT_TYPES.map((t) => (
                            <MenuItem key={t.value} value={t.value}>{t.label}</MenuItem>
                          ))}
                        </Select>
                        {errors.movementType && (
                          <Typography variant="caption" color="error" sx={{ mt: 0.5, ml: 1.5 }}>
                            {errors.movementType.message}
                          </Typography>
                        )}
                      </FormControl>
                    )}
                  />
                  <Controller
                    name="movementDate"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label="Fecha y hora"
                        type="datetime-local"
                        fullWidth
                        InputLabelProps={{ shrink: true }}
                        helperText="Dejar vacío para usar la fecha actual"
                      />
                    )}
                  />
                  <Controller
                    name="notes"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label="Observación"
                        fullWidth
                        multiline
                        rows={3}
                        placeholder="Descripción del movimiento..."
                      />
                    )}
                  />
                </>
              )}
            </Box>
          </DialogContent>

          <DialogActions sx={{ p: 2 }}>
            <Button onClick={handleClose} disabled={mutation.isPending}>Cancelar</Button>
            <Button
              type="submit"
              variant="contained"
              disabled={mutation.isPending || !assetFound}
            >
              {mutation.isPending ? <CircularProgress size={20} /> : 'Registrar'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  );
}
