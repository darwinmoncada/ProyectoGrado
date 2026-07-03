import {
  AppBar, Toolbar, IconButton, Typography, Box,
  Avatar, Menu, MenuItem, Divider, Chip
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import LogoutIcon from '@mui/icons-material/Logout';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import logoUts from '../../img/Logo-UTS-1.png'; 
import logoRedesImg from '../../img/Logo-REDES-1.png'; // Asegúrate de tener esta ruta correcta

export default function Header({ drawerWidth, onMenuClick }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = useState(null);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getRoleColor = (roles) => {
    if (roles?.includes('ROLE_SUPERADMIN')) return 'secondary';
    if (roles?.includes('ROLE_ADMIN')) return 'error';
    if (roles?.includes('ROLE_TECNICO')) return 'warning';
    return 'default';
  };

  const getRoleLabel = (roles) => {
    if (roles?.includes('ROLE_SUPERADMIN')) return 'SuperAdministrador';
    if (roles?.includes('ROLE_ADMIN')) return 'Administrador';
    if (roles?.includes('ROLE_TECNICO')) return 'Técnico';
    return 'Usuario';
  };

  return (
    <AppBar
      position="fixed"
      sx={{ zIndex: (theme) => theme.zIndex.drawer + 1, width: '100%' }}
      elevation={1}
    >
      <Toolbar sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        
        {/* ================= PARTE IZQUIERDA ================= */}
        <Box sx={{ flex: 1, display: 'flex', justifyContent: 'flex-start' }}>
          <IconButton color="inherit" edge="start" onClick={onMenuClick}>
            <MenuIcon />
          </IconButton>
        </Box>

        {/* ================= PARTE CENTRAL ================= */}
        <Box 
          sx={{ 
            flex: 2, 
            display: 'flex', 
            flexDirection: 'row', 
            alignItems: 'center', 
            justifyContent: 'space-between', // Distribuye: izquierda, centro y derecha
            gap: 2,
            maxHeight: '64px'
          }}
        >
          {/* Imagen pegada a la izquierda del centro */}
          <Box
            component="img"
            src={logoRedesImg}
            alt="Logo REDES"
            sx={{
              width: 60,
              height: 'auto',
              objectFit: 'contain'
            }}
          />

          {/* Título bien centrado */}
          <Typography variant="h6" noWrap fontWeight={700} sx={{ textAlign: 'center', flexGrow: 1 }}>
            Sistema de Inventario TI
          </Typography>

          {/* Imagen pegada a la derecha del centro */}
          <Box
            component="img"
            src={logoUts}
            alt="Logo UTS"
            sx={{
              height: 35,
              width: 'auto',
              objectFit: 'contain'
            }}
          />
        </Box>

        {/* ================= PARTE DERECHA ================= */}
        <Box sx={{ flex: 1, display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: 1 }}>
          {user && (
            <>
              {/* Rol del usuario */}
              <Chip
                label={getRoleLabel(user.roles)}
                color={getRoleColor(user.roles)}
                size="small"
                sx={{ display: { xs: 'none', sm: 'flex' } }}
              />
              {/* Menú del usuario */}
              <IconButton color="inherit" onClick={(e) => setAnchorEl(e.currentTarget)}>
                <Avatar sx={{ width: 32, height: 32, bgcolor: 'secondary.main', fontSize: 14 }}>
                  {user.fullName?.charAt(0).toUpperCase()}
                </Avatar>
              </IconButton>
            </>
          )}
        </Box>

        {/* Menú Desplegable */}
        <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={() => setAnchorEl(null)}>
          <Box sx={{ px: 2, py: 1 }}>
            <Typography variant="subtitle2">{user?.fullName}</Typography>
            <Typography variant="caption" color="text.secondary">{user?.email}</Typography>
          </Box>
          <Divider />
          <MenuItem onClick={handleLogout}>
            <LogoutIcon fontSize="small" sx={{ mr: 1 }} />
            Cerrar sesión
          </MenuItem>
        </Menu>

      </Toolbar>
    </AppBar>
  );
}