import {
  Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText,
  Toolbar, Divider, Typography, Box, Collapse, Tooltip
} from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import ComputerIcon from '@mui/icons-material/Computer';
import InventoryIcon from '@mui/icons-material/Inventory';
import RouterIcon from '@mui/icons-material/Router';
import PeopleIcon from '@mui/icons-material/People';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import HistoryIcon from '@mui/icons-material/History';
import ExpandLess from '@mui/icons-material/ExpandLess';
import ExpandMore from '@mui/icons-material/ExpandMore';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import { useNavigate, useLocation } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import NetworkInfoBanner from './NetworkInfoBanner';

const navItems = [
  { text: 'Dashboard', icon: <DashboardIcon />, path: '/dashboard' },
  { text: 'Activos TI', icon: <ComputerIcon />, path: '/assets' },
  { text: 'Inventario', icon: <InventoryIcon />, path: '/inventory' },
  { text: 'Redes', icon: <RouterIcon />, path: '/network' },
];

const adminItems = [
  { text: 'Usuarios', icon: <PeopleIcon />, path: '/admin/users' },
  { text: 'Áreas', icon: <LocationOnIcon />, path: '/admin/areas' },
  { text: 'Auditoría', icon: <HistoryIcon />, path: '/admin/audit' },
];

export default function Sidebar({ drawerWidth, collapsedWidth = 64, collapsed = false, mobileOpen, onClose }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { hasRole } = useAuth();
  const [adminOpen, setAdminOpen] = useState(false);

  // Cierra limpiamente el submenú "Administración" al colapsar el sidebar.
  useEffect(() => {
    if (collapsed) setAdminOpen(false);
  }, [collapsed]);

  const isActive = (path) => location.pathname === path || location.pathname.startsWith(path + '/');

  const handleNav = (path) => {
    navigate(path);
    onClose();
  };

  const renderContent = (isCollapsed) => (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <Toolbar sx={{ justifyContent: isCollapsed ? 'center' : 'flex-start', px: isCollapsed ? 1 : 2 }}>
        {!isCollapsed && (
          <Box sx={{ display: 'flex', flexDirection: 'column' }}>
            <Typography variant="subtitle1" fontWeight={700} color="primary">
              Inventario TI
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Unidades Tecnológicas de Santander
            </Typography>
          </Box>
        )}
      </Toolbar>
      <Divider />
      <List sx={{ flexGrow: 1, py: 1 }}>
        {navItems.map((item) => (
          <ListItem key={item.path} disablePadding>
            <Tooltip title={isCollapsed ? item.text : ''} placement="right">
              <ListItemButton
                selected={isActive(item.path)}
                onClick={() => handleNav(item.path)}
                sx={{
                  mx: 1, borderRadius: 2,
                  justifyContent: isCollapsed ? 'center' : 'flex-start',
                  '&.Mui-selected': { bgcolor: 'primary.light', color: 'white',
                    '& .MuiListItemIcon-root': { color: 'white' } },
                }}
              >
                <ListItemIcon sx={{ minWidth: isCollapsed ? 0 : 40, justifyContent: 'center' }}>
                  {item.icon}
                </ListItemIcon>
                {!isCollapsed && <ListItemText primary={item.text} />}
              </ListItemButton>
            </Tooltip>
          </ListItem>
        ))}

        {hasRole(['ROLE_ADMIN', 'ROLE_SUPERADMIN']) && (
          <>
            <Divider sx={{ my: 1 }} />
            <ListItem disablePadding>
              <Tooltip title={isCollapsed ? 'Administración' : ''} placement="right">
                <ListItemButton
                  onClick={() => !isCollapsed && setAdminOpen((prev) => !prev)}
                  sx={{ mx: 1, borderRadius: 2, justifyContent: isCollapsed ? 'center' : 'flex-start' }}
                >
                  <ListItemIcon sx={{ minWidth: isCollapsed ? 0 : 40, justifyContent: 'center' }}>
                    <AdminPanelSettingsIcon />
                  </ListItemIcon>
                  {!isCollapsed && <ListItemText primary="Administración" />}
                  {!isCollapsed && (adminOpen ? <ExpandLess /> : <ExpandMore />)}
                </ListItemButton>
              </Tooltip>
            </ListItem>
            {!isCollapsed && (
              <Collapse in={adminOpen} timeout="auto" unmountOnExit>
                <List disablePadding>
                  {adminItems.map((item) => (
                    <ListItem key={item.path} disablePadding>
                      <ListItemButton
                        selected={isActive(item.path)}
                        onClick={() => handleNav(item.path)}
                        sx={{
                          pl: 4, mx: 1, borderRadius: 2,
                          '&.Mui-selected': { bgcolor: 'primary.light', color: 'white',
                            '& .MuiListItemIcon-root': { color: 'white' } },
                        }}
                      >
                        <ListItemIcon sx={{ minWidth: 36 }}>{item.icon}</ListItemIcon>
                        <ListItemText primary={item.text} />
                      </ListItemButton>
                    </ListItem>
                  ))}
                </List>
              </Collapse>
            )}
          </>
        )}
      </List>

      {!isCollapsed && (
        <Box sx={{ p: 2, borderTop: '1px solid', borderColor: 'divider' }}>
          <NetworkInfoBanner />
          <Typography variant="caption" color="text.secondary">
            v1.0.0 © 2026 UTS
          </Typography>
        </Box>
      )}
    </Box>
  );

  const permanentWidth = collapsed ? collapsedWidth : drawerWidth;

  return (
    <Box component="nav" sx={{ width: { md: permanentWidth }, flexShrink: { md: 0 }, transition: 'width 0.2s' }}>
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={onClose}
        ModalProps={{ keepMounted: true }}
        sx={{ display: { xs: 'block', md: 'none' }, '& .MuiDrawer-paper': { width: drawerWidth } }}
      >
        {renderContent(false)}
      </Drawer>
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', md: 'block' },
          '& .MuiDrawer-paper': {
            width: permanentWidth, boxSizing: 'border-box', overflowX: 'hidden', transition: 'width 0.2s',
          },
        }}
        open
      >
        {renderContent(collapsed)}
      </Drawer>
    </Box>
  );
}
