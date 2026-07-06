import { useMemo } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { createTheme, ThemeProvider, CssBaseline } from '@mui/material';
import { esES } from '@mui/material/locale';
import { useThemeMode } from './context/ThemeModeContext';
import ProtectedRoute from './components/ProtectedRoute';
import MainLayout from './components/layout/MainLayout';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import AssetListPage from './pages/assets/AssetListPage';
import AssetFormPage from './pages/assets/AssetFormPage';
import AssetDetailPage from './pages/assets/AssetDetailPage';
import NetworkPage from './pages/network/NetworkPage';
import InventoryPage from './pages/inventory/InventoryPage';
import UsersPage from './pages/admin/UsersPage';
import AuditPage from './pages/admin/AuditPage';
import AreasPage from './pages/admin/AreasPage';

const getTheme = (mode) => createTheme(
  {
    palette: {
      mode,
      primary: { main: mode === 'dark' ? '#5B9BD5' : '#1565C0' },
      secondary: { main: mode === 'dark' ? '#4FC3F7' : '#0288D1' },
      success: { main: mode === 'dark' ? '#66BB6A' : '#2E7D32' },
      background: mode === 'dark'
        ? { default: '#121212', paper: '#1E1E1E' }
        : { default: '#F5F7FA', paper: '#FFFFFF' },
    },
    typography: {
      fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    },
    components: {
      MuiButton: {
        styleOverrides: {
          root: { textTransform: 'none', borderRadius: 8 },
        },
      },
      MuiCard: {
        styleOverrides: {
          root: {
            borderRadius: 12,
            boxShadow: mode === 'dark' ? '0 2px 8px rgba(0,0,0,0.4)' : '0 2px 8px rgba(0,0,0,0.08)',
          },
        },
      },
    },
  },
  esES
);

export default function App() {
  const { mode } = useThemeMode();
  const theme = useMemo(() => getTheme(mode), [mode]);

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <MainLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="assets" element={<AssetListPage />} />
          <Route path="assets/new" element={<AssetFormPage />} />
          <Route path="assets/:id" element={<AssetDetailPage />} />
          <Route path="assets/:id/edit" element={<AssetFormPage />} />
          <Route path="network" element={<NetworkPage />} />
          <Route path="inventory" element={<InventoryPage />} />
          <Route
            path="admin/users"
            element={
              <ProtectedRoute roles={['ROLE_ADMIN', 'ROLE_SUPERADMIN']}>
                <UsersPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="admin/areas"
            element={
              <ProtectedRoute roles={['ROLE_ADMIN', 'ROLE_SUPERADMIN']}>
                <AreasPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="admin/audit"
            element={
              <ProtectedRoute roles={['ROLE_ADMIN', 'ROLE_SUPERADMIN']}>
                <AuditPage />
              </ProtectedRoute>
            }
          />
        </Route>
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </ThemeProvider>
  );
}
