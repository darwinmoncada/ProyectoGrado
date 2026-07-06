import { useState } from 'react';
import {
  Box, Typography, Paper, Button, Dialog, DialogTitle, DialogContent,
  DialogActions, TextField, IconButton, Menu, MenuItem, Grid, Card,
  CardContent, Chip, ListItemIcon, ListItemText, Divider,
} from '@mui/material';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import BusinessIcon from '@mui/icons-material/Business';
import ComputerIcon from '@mui/icons-material/Computer';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSnackbar } from 'notistack';
import { useForm, Controller } from 'react-hook-form';
import api from '../../services/api';

export default function AreasPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [menuAnchor, setMenuAnchor] = useState(null);
  const [menuArea, setMenuArea] = useState(null);
  const { enqueueSnackbar } = useSnackbar();
  const queryClient = useQueryClient();

  const { data: areas, isLoading } = useQuery({
    queryKey: ['areas'],
    queryFn: () => api.get('/areas').then((r) => r.data.data),
  });

  const { data: assetCounts = {} } = useQuery({
    queryKey: ['areaAssetCounts'],
    queryFn: () => api.get('/areas/asset-counts').then((r) => r.data.data),
  });

  const { control, handleSubmit, reset, setValue } = useForm({
    defaultValues: { name: '', description: '', location: '', building: '' }
  });

  const mutation = useMutation({
    mutationFn: (data) => editing
      ? api.put(`/areas/${editing.id}`, data)
      : api.post('/areas', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['areas'] });
      enqueueSnackbar(editing ? 'Área actualizada' : 'Área creada', { variant: 'success' });
      setOpen(false);
      setEditing(null);
      reset();
    },
    onError: (err) =>
      enqueueSnackbar(err?.response?.data?.error || 'Error al guardar', { variant: 'error' }),
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => api.delete(`/areas/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['areas'] });
      enqueueSnackbar('Área desactivada', { variant: 'success' });
      setDeleteTarget(null);
    },
    onError: (err) =>
      enqueueSnackbar(err?.response?.data?.error || 'Error al desactivar el área', { variant: 'error' }),
  });

  const handleEdit = (row) => {
    setEditing(row);
    setValue('name', row.name);
    setValue('description', row.description || '');
    setValue('location', row.location || '');
    setValue('building', row.building || '');
    setOpen(true);
    setMenuAnchor(null);
  };

  const openMenu = (e, area) => {
    setMenuAnchor(e.currentTarget);
    setMenuArea(area);
  };

  const closeMenu = () => {
    setMenuAnchor(null);
    setMenuArea(null);
  };

  const closeDialog = () => {
    setOpen(false);
    setEditing(null);
    reset();
  };

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>Gestión de Áreas</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => setOpen(true)}>
          Nueva Área
        </Button>
      </Box>

      {isLoading ? (
        <Typography color="text.secondary">Cargando áreas...</Typography>
      ) : !areas?.length ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography color="text.secondary">No hay áreas registradas.</Typography>
        </Paper>
      ) : (
        <Grid container spacing={2.5}>
          {areas.map((area) => (
            <Grid item xs={12} sm={6} md={4} lg={3} key={area.id}>
              <Card sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={1}>
                    <Typography variant="subtitle1" fontWeight={700} sx={{ pr: 1 }}>
                      {area.name}
                    </Typography>
                    <IconButton size="small" onClick={(e) => openMenu(e, area)}>
                      <MoreVertIcon fontSize="small" />
                    </IconButton>
                  </Box>

                  {area.description && (
                    <Typography variant="body2" color="text.secondary" mb={1.5}
                      sx={{ display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                      {area.description}
                    </Typography>
                  )}

                  <Box display="flex" flexDirection="column" gap={0.5} mb={1.5}>
                    {area.location && (
                      <Box display="flex" alignItems="center" gap={0.75}>
                        <LocationOnIcon sx={{ fontSize: 16 }} color="action" />
                        <Typography variant="caption" color="text.secondary">{area.location}</Typography>
                      </Box>
                    )}
                    {area.building && (
                      <Box display="flex" alignItems="center" gap={0.75}>
                        <BusinessIcon sx={{ fontSize: 16 }} color="action" />
                        <Typography variant="caption" color="text.secondary">{area.building}</Typography>
                      </Box>
                    )}
                  </Box>

                  <Chip
                    icon={<ComputerIcon sx={{ fontSize: 16 }} />}
                    label={`${assetCounts[area.id] || 0} activo(s)`}
                    size="small"
                    variant="outlined"
                    color={assetCounts[area.id] ? 'primary' : 'default'}
                  />
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {/* Menú de acciones (3 puntos) */}
      <Menu anchorEl={menuAnchor} open={!!menuAnchor} onClose={closeMenu}>
        <MenuItem onClick={() => handleEdit(menuArea)}>
          <ListItemIcon><EditIcon fontSize="small" /></ListItemIcon>
          <ListItemText>Editar</ListItemText>
        </MenuItem>
        <Divider />
        <MenuItem onClick={() => { setDeleteTarget(menuArea); closeMenu(); }} sx={{ color: 'error.main' }}>
          <ListItemIcon><DeleteIcon fontSize="small" color="error" /></ListItemIcon>
          <ListItemText>Eliminar</ListItemText>
        </MenuItem>
      </Menu>

      {/* Formulario crear/editar */}
      <Dialog open={open} onClose={closeDialog} maxWidth="sm" fullWidth>
        <DialogTitle>{editing ? 'Editar Área' : 'Nueva Área'}</DialogTitle>
        <form onSubmit={handleSubmit((d) => mutation.mutate(d))}>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2} pt={1}>
              <Controller name="name" control={control} rules={{ required: true }}
                render={({ field }) => <TextField {...field} label="Nombre *" fullWidth />} />
              <Controller name="description" control={control}
                render={({ field }) => <TextField {...field} label="Descripción" fullWidth multiline rows={2} />} />
              <Controller name="location" control={control}
                render={({ field }) => <TextField {...field} label="Ubicación / Piso" fullWidth />} />
              <Controller name="building" control={control}
                render={({ field }) => <TextField {...field} label="Edificio / Bloque" fullWidth />} />
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={closeDialog}>Cancelar</Button>
            <Button type="submit" variant="contained" disabled={mutation.isPending}>
              {editing ? 'Actualizar' : 'Guardar'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Confirmación de eliminación */}
      <Dialog open={!!deleteTarget} onClose={() => setDeleteTarget(null)} maxWidth="xs" fullWidth>
        <DialogTitle>Desactivar Área</DialogTitle>
        <DialogContent>
          <Typography>
            ¿Seguro que deseas desactivar <strong>{deleteTarget?.name}</strong>?
            {assetCounts[deleteTarget?.id] > 0 && (
              <> Tiene <strong>{assetCounts[deleteTarget.id]}</strong> activo(s) asignado(s); no se verán afectados, solo dejarán de mostrar esta área en la lista de áreas activas.</>
            )}
          </Typography>
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setDeleteTarget(null)}>Cancelar</Button>
          <Button
            variant="contained"
            color="error"
            disabled={deleteMutation.isPending}
            onClick={() => deleteMutation.mutate(deleteTarget.id)}
          >
            Desactivar
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
