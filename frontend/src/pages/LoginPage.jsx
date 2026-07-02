import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box, Paper, TextField, Button, Typography, Alert,
  InputAdornment, IconButton, CircularProgress
} from '@mui/material';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import { useAuth } from '../context/AuthContext';
import logoRedesImg from '../img/Logo-REDES-1.png';
import logoUtsImg from '../img/Logo-UTS-1.png';

export default function LoginPage() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [form, setForm] = useState({ username: '', password: '' });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(form.username, form.password);
      navigate('/dashboard');
    } catch (err) {
      setError(
        err?.response?.data?.error || 'Credenciales inválidas. Verifique sus datos.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #1565C0 0%, #0288D1 100%)',
      }}
    >
      <Paper elevation={8} sx={{ p: 4, width: '100%', maxWidth: 420, borderRadius: 3 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 3 }}>
          <Box 
            sx={{ 
              display: 'flex', 
              flexDirection: 'row', 
              alignItems: 'center', 
              justifyContent: 'center', 
              gap: 2,
              mb: 2 
            }}
          >
            <Box
              component="img"
              src={logoRedesImg}
              alt="Logo REDES"
              sx={{
                width: 80,
                height: 'auto',
                objectFit: 'contain'
              }}
            />
          </Box>
          
          <Typography variant="h5" fontWeight={700} color="primary" textAlign="center">
            Sistema de Inventario TI
          </Typography>
          <Typography variant="body2" color="text.secondary" textAlign="center">
            Unidades Tecnológicas de Santander
          </Typography>
          
        </Box>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        <form onSubmit={handleSubmit}>
          <TextField
            fullWidth
            label="Usuario"
            value={form.username}
            onChange={(e) => setForm({ ...form, username: e.target.value })}
            margin="normal"
            required
            autoFocus
            disabled={loading}
          />
          <TextField
            fullWidth
            label="Contraseña"
            type={showPassword ? 'text' : 'password'}
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
            margin="normal"
            required
            disabled={loading}
            InputProps={{
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton onClick={() => setShowPassword(!showPassword)} edge="end">
                    {showPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                  </IconButton>
                </InputAdornment>
              ),
            }}
          />
          <Button
            type="submit"
            fullWidth
            variant="contained"
            size="large"
            disabled={loading}
            sx={{ mt: 3, mb: 2, py: 1.5 }}
          >
            {loading ? <CircularProgress size={24} color="inherit" /> : 'Iniciar Sesión'}
          </Button>
        </form>

        <Typography variant="caption" color="text.secondary" display="block" textAlign="center">
          © 2026 UTS - Todos los derechos reservados.
        </Typography>
        <Box 
            sx={{ 
              display: 'flex', 
              flexDirection: 'row', 
              alignItems: 'center', 
              justifyContent: 'center', 
              gap: 2,
              mb: 2 
            }}
          >
            <Box
              component="img"
              src={logoUtsImg}
              alt="Logo UTS"
              sx={{
                width: 80, 
                height: 'auto',
                objectFit: 'contain'
              }}
            />
          </Box>
      </Paper>
    </Box>
  );
}