import { useState } from 'react';
import {
  Box, Typography, Paper, Chip, IconButton, Tooltip, Button,
  Dialog, DialogTitle, DialogContent, DialogActions, TextField,
  FormControl, InputLabel, Select, MenuItem
} from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import LockResetIcon from '@mui/icons-material/LockReset';
import BlockIcon from '@mui/icons-material/Block';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSnackbar } from 'notistack';
import { useForm, Controller } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { userService } from '../../services/userService';
import { useAuth } from '../../context/AuthContext';

const ALL_ROLE_OPTIONS = [
  { value: 'ROLE_SUPERADMIN', label: 'SuperAdministrador' },
  { value: 'ROLE_ADMIN', label: 'Administrador' },
  { value: 'ROLE_TECNICO', label: 'Técnico' },
  { value: 'ROLE_USUARIO', label: 'Usuario Estándar' },
];

const ROLE_CHIP_COLOR = {
  ROLE_SUPERADMIN: 'secondary',
  ROLE_ADMIN: 'error',
  ROLE_TECNICO: 'warning',
  ROLE_USUARIO: 'default',
};

const USERNAME_REGEX = /^[a-zA-Z0-9._-]+$/;
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/;

function buildBaseFields(allowedRoleValues) {
  return {
    fullName: yup.string().trim().required('El nombre completo es obligatorio').max(100, 'Máximo 100 caracteres'),
    username: yup.string().trim().required('El usuario es obligatorio')
      .min(4, 'Mínimo 4 caracteres').max(50, 'Máximo 50 caracteres')
      .matches(USERNAME_REGEX, 'Solo letras, números, puntos, guiones y guiones bajos'),
    email: yup.string().trim().required('El correo es obligatorio').email('Correo electrónico inválido'),
    phone: yup.string().max(20, 'Máximo 20 caracteres').nullable(),
    documentNumber: yup.string().max(20, 'Máximo 20 caracteres').nullable(),
    role: yup.string().required('El rol es obligatorio').oneOf(allowedRoleValues, 'Rol inválido'),
  };
}

function buildCreateSchema(allowedRoleValues) {
  return yup.object({
    ...buildBaseFields(allowedRoleValues),
    password: yup.string().required('La contraseña es obligatoria')
      .min(8, 'Mínimo 8 caracteres')
      .matches(PASSWORD_REGEX, 'Debe incluir mayúsculas, minúsculas, números y un carácter especial'),
    confirmPassword: yup.string().required('Confirma la contraseña')
      .oneOf([yup.ref('password')], 'Las contraseñas no coinciden'),
  });
}

function buildEditSchema(allowedRoleValues) {
  return yup.object(buildBaseFields(allowedRoleValues));
}

const resetPasswordSchema = yup.object({
  newPassword: yup.string().required('La contraseña es obligatoria')
    .min(8, 'Mínimo 8 caracteres')
    .matches(PASSWORD_REGEX, 'Debe incluir mayúsculas, minúsculas, números y un carácter especial'),
  confirmPassword: yup.string().required('Confirma la contraseña')
    .oneOf([yup.ref('newPassword')], 'Las contraseñas no coinciden'),
});

const emptyFormValues = {
  fullName: '', username: '', email: '', phone: '', documentNumber: '',
  role: 'ROLE_USUARIO', password: '', confirmPassword: '',
};

export default function UsersPage() {
  const { enqueueSnackbar } = useSnackbar();
  const queryClient = useQueryClient();
  const { user: currentUser, hasRole } = useAuth();

  const currentUserId = currentUser?.userId;
  const isSuperAdmin = hasRole(['ROLE_SUPERADMIN']);
  const roleOptions = isSuperAdmin
    ? ALL_ROLE_OPTIONS
    : ALL_ROLE_OPTIONS.filter((opt) => opt.value !== 'ROLE_SUPERADMIN' && opt.value !== 'ROLE_ADMIN');
  const allowedRoleValues = roleOptions.map((opt) => opt.value);

  const [formOpen, setFormOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [resetTarget, setResetTarget] = useState(null);

  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: userService.getAll,
  });

  const { control, handleSubmit, reset, formState: { errors } } = useForm({
    resolver: yupResolver(editingUser ? buildEditSchema(allowedRoleValues) : buildCreateSchema(allowedRoleValues)),
    defaultValues: emptyFormValues,
  });

  const resetPasswordForm = useForm({
    resolver: yupResolver(resetPasswordSchema),
    defaultValues: { newPassword: '', confirmPassword: '' },
  });

  const closeForm = () => {
    setFormOpen(false);
    setEditingUser(null);
    reset(emptyFormValues);
  };

  const closeResetDialog = () => {
    setResetTarget(null);
    resetPasswordForm.reset({ newPassword: '', confirmPassword: '' });
  };

  const saveMutation = useMutation({
    mutationFn: (data) => {
      const payload = {
        fullName: data.fullName,
        username: data.username,
        email: data.email,
        phone: data.phone || null,
        documentNumber: data.documentNumber || null,
        roles: [data.role],
      };
      return editingUser
        ? userService.update(editingUser.id, payload)
        : userService.create({ ...payload, password: data.password });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      enqueueSnackbar(editingUser ? 'Usuario actualizado' : 'Usuario creado', { variant: 'success' });
      closeForm();
    },
    onError: (err) =>
      enqueueSnackbar(err?.response?.data?.error || 'Error al guardar el usuario', { variant: 'error' }),
  });

  const resetPasswordMutation = useMutation({
    mutationFn: ({ id, newPassword }) => userService.resetPassword(id, newPassword),
    onSuccess: () => {
      enqueueSnackbar('Contraseña restablecida correctamente', { variant: 'success' });
      closeResetDialog();
    },
    onError: (err) =>
      enqueueSnackbar(err?.response?.data?.error || 'Error al restablecer la contraseña', { variant: 'error' }),
  });

  const toggleMutation = useMutation({
    mutationFn: (id) => userService.toggleActive(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      enqueueSnackbar('Estado del usuario actualizado', { variant: 'success' });
    },
    onError: (err) =>
      enqueueSnackbar(err?.response?.data?.error || 'Error al actualizar el estado', { variant: 'error' }),
  });

  const handleCreate = () => {
    setEditingUser(null);
    reset(emptyFormValues);
    setFormOpen(true);
  };

  const handleEdit = (row) => {
    setEditingUser(row);
    reset({
      fullName: row.fullName,
      username: row.username,
      email: row.email,
      phone: row.phone || '',
      documentNumber: row.documentNumber || '',
      role: row.roles?.[0] || 'ROLE_USUARIO',
      password: '',
      confirmPassword: '',
    });
    setFormOpen(true);
  };

  // Jerarquía de protección: nadie salvo un ROLE_SUPERADMIN puede tocar cuentas ROLE_SUPERADMIN,
  // y ningún usuario puede desactivarse a sí mismo.
  function getRowRestriction(row) {
    if (row.roles?.includes('ROLE_SUPERADMIN') && !isSuperAdmin) return 'super-admin';
    if (row.id === currentUserId) return 'self';
    return null;
  }

  const columns = [
    { field: 'id', headerName: 'ID', width: 60 },
    { field: 'fullName', headerName: 'Nombre Completo', flex: 1 },
    { field: 'username', headerName: 'Usuario', width: 140 },
    { field: 'email', headerName: 'Correo', flex: 1 },
    { field: 'phone', headerName: 'Teléfono', width: 130 },
    {
      field: 'roles', headerName: 'Rol', width: 160,
      renderCell: ({ row }) => (
        <Box display="flex" gap={0.5} flexWrap="wrap">
          {row.roles?.map((r) => (
            <Chip key={r} label={r?.replace('ROLE_', '')} size="small"
              color={ROLE_CHIP_COLOR[r] || 'default'} />
          ))}
        </Box>
      )
    },
    {
      field: 'isActive', headerName: 'Estado', width: 100,
      renderCell: ({ value }) => (
        <Chip label={value ? 'Activo' : 'Inactivo'} color={value ? 'success' : 'default'} size="small" />
      )
    },
    {
      field: 'actions', headerName: 'Acciones', width: 150, sortable: false,
      renderCell: ({ row }) => {
        const restriction = getRowRestriction(row);
        const editToggleDisabled = restriction !== null;
        const resetDisabled = restriction === 'super-admin';

        const editTooltip = restriction === 'super-admin'
          ? 'No se puede editar a un SuperAdministrador'
          : restriction === 'self'
            ? 'No puedes editar tu propio usuario desde aquí'
            : 'Editar';
        const resetTooltip = restriction === 'super-admin'
          ? 'No se puede restablecer la contraseña de un SuperAdministrador'
          : 'Restablecer Contraseña';
        const toggleTooltip = restriction === 'super-admin'
          ? 'No se puede cambiar el estado de un SuperAdministrador'
          : restriction === 'self'
            ? 'No puedes desactivar tu propia cuenta'
            : (row.isActive ? 'Desactivar' : 'Activar');

        return (
          <Box display="flex" gap={0.5}>
            <Tooltip title={editTooltip}>
              <span>
                <IconButton size="small" disabled={editToggleDisabled} onClick={() => handleEdit(row)}>
                  <EditIcon fontSize="small" />
                </IconButton>
              </span>
            </Tooltip>
            <Tooltip title={resetTooltip}>
              <span>
                <IconButton size="small" disabled={resetDisabled} onClick={() => setResetTarget(row)}>
                  <LockResetIcon fontSize="small" />
                </IconButton>
              </span>
            </Tooltip>
            <Tooltip title={toggleTooltip}>
              <span>
                <IconButton size="small" disabled={editToggleDisabled} onClick={() => toggleMutation.mutate(row.id)}>
                  {row.isActive ? <BlockIcon fontSize="small" color="error" /> : <CheckCircleIcon fontSize="small" color="success" />}
                </IconButton>
              </span>
            </Tooltip>
          </Box>
        );
      }
    }
  ];

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>Gestión de Usuarios</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={handleCreate}>
          Crear Usuario
        </Button>
      </Box>
      <Paper>
        <DataGrid
          rows={users || []}
          columns={columns}
          loading={isLoading}
          disableRowSelectionOnClick
          autoHeight
          sx={{ border: 0 }}
        />
      </Paper>

      <Dialog open={formOpen} onClose={closeForm} maxWidth="sm" fullWidth>
        <DialogTitle>{editingUser ? 'Editar Usuario' : 'Crear Usuario'}</DialogTitle>
        <form onSubmit={handleSubmit((d) => saveMutation.mutate(d))}>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2} pt={1}>
              <Controller name="fullName" control={control}
                render={({ field }) => (
                  <TextField {...field} label="Nombre Completo *" fullWidth
                    error={!!errors.fullName} helperText={errors.fullName?.message} />
                )} />
              <Controller name="username" control={control}
                render={({ field }) => (
                  <TextField {...field} label="Usuario *" fullWidth
                    error={!!errors.username} helperText={errors.username?.message} />
                )} />
              <Controller name="email" control={control}
                render={({ field }) => (
                  <TextField {...field} label="Correo *" fullWidth
                    error={!!errors.email} helperText={errors.email?.message} />
                )} />
              <Controller name="phone" control={control}
                render={({ field }) => (
                  <TextField {...field} label="Teléfono" fullWidth
                    error={!!errors.phone} helperText={errors.phone?.message} />
                )} />
              <Controller name="documentNumber" control={control}
                render={({ field }) => (
                  <TextField {...field} label="Número de Documento" fullWidth
                    error={!!errors.documentNumber} helperText={errors.documentNumber?.message} />
                )} />
              <Controller name="role" control={control}
                render={({ field }) => (
                  <FormControl fullWidth error={!!errors.role}>
                    <InputLabel>Rol *</InputLabel>
                    <Select {...field} label="Rol *">
                      {roleOptions.map((opt) => (
                        <MenuItem key={opt.value} value={opt.value}>{opt.label}</MenuItem>
                      ))}
                    </Select>
                  </FormControl>
                )} />
              {!editingUser && (
                <>
                  <Controller name="password" control={control}
                    render={({ field }) => (
                      <TextField {...field} type="password" label="Contraseña *" fullWidth
                        error={!!errors.password} helperText={errors.password?.message} />
                    )} />
                  <Controller name="confirmPassword" control={control}
                    render={({ field }) => (
                      <TextField {...field} type="password" label="Confirmar Contraseña *" fullWidth
                        error={!!errors.confirmPassword} helperText={errors.confirmPassword?.message} />
                    )} />
                </>
              )}
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={closeForm}>Cancelar</Button>
            <Button type="submit" variant="contained" disabled={saveMutation.isPending}>
              {editingUser ? 'Actualizar' : 'Guardar'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      <Dialog open={!!resetTarget} onClose={closeResetDialog} maxWidth="xs" fullWidth>
        <DialogTitle>Restablecer Contraseña{resetTarget ? ` — ${resetTarget.username}` : ''}</DialogTitle>
        <form onSubmit={resetPasswordForm.handleSubmit((d) =>
          resetPasswordMutation.mutate({ id: resetTarget.id, newPassword: d.newPassword }))}>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2} pt={1}>
              <Controller name="newPassword" control={resetPasswordForm.control}
                render={({ field }) => (
                  <TextField {...field} type="password" label="Nueva Contraseña *" fullWidth
                    error={!!resetPasswordForm.formState.errors.newPassword}
                    helperText={resetPasswordForm.formState.errors.newPassword?.message} />
                )} />
              <Controller name="confirmPassword" control={resetPasswordForm.control}
                render={({ field }) => (
                  <TextField {...field} type="password" label="Confirmar Contraseña *" fullWidth
                    error={!!resetPasswordForm.formState.errors.confirmPassword}
                    helperText={resetPasswordForm.formState.errors.confirmPassword?.message} />
                )} />
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={closeResetDialog}>Cancelar</Button>
            <Button type="submit" variant="contained" disabled={resetPasswordMutation.isPending}>
              Restablecer
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  );
}
