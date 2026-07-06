import { useState } from 'react';
import {
  Box, Typography, IconButton, Tooltip, Link,
  Dialog, DialogTitle, DialogContent, DialogContentText,
} from '@mui/material';
import InfoOutlinedIcon from '@mui/icons-material/InfoOutlined';
import { useQuery } from '@tanstack/react-query';
import { systemService } from '../../services/systemService';

export default function NetworkInfoBanner() {
  const [helpOpen, setHelpOpen] = useState(false);

  const { data } = useQuery({
    queryKey: ['networkInfo'],
    queryFn: systemService.getNetworkInfo,
    staleTime: 5 * 60 * 1000,
    retry: false,
  });

  const localUrl = data?.localIp ? `http://${data.localIp}` : null;

  return (
    <Box sx={{ mb: 1.5 }}>
      <Box display="flex" alignItems="center" gap={0.5}>
        <Typography variant="caption" color="text.secondary" fontWeight={600}>
          Acceso en red local
        </Typography>
        <Tooltip title="¿Cómo acceder desde fuera de la red?">
          <IconButton size="small" onClick={() => setHelpOpen(true)} sx={{ p: 0.25 }}>
            <InfoOutlinedIcon sx={{ fontSize: 14 }} />
          </IconButton>
        </Tooltip>
      </Box>
      {localUrl ? (
        <Link href={localUrl} target="_blank" rel="noopener" variant="caption" sx={{ wordBreak: 'break-all' }}>
          {localUrl}
        </Link>
      ) : (
        <Typography variant="caption" color="text.disabled">Detectando IP...</Typography>
      )}

      <Dialog open={helpOpen} onClose={() => setHelpOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Acceso desde fuera de la red local</DialogTitle>
        <DialogContent>
          <DialogContentText component="div">
            <Typography variant="body2" sx={{ mb: 2 }}>
              <strong>Dentro de la universidad:</strong> cualquier equipo conectado a la misma red
              (cableada o Wi-Fi institucional) puede acceder ingresando a{' '}
              {localUrl ? <strong>{localUrl}</strong> : 'la dirección mostrada arriba'}.
            </Typography>
            <Typography variant="body2" sx={{ mb: 1 }}>
              <strong>Desde fuera de la universidad</strong> (por ejemplo, para una sustentación remota),
              hay dos opciones:
            </Typography>
            <Typography variant="body2" component="div">
              1. <strong>IP pública + reenvío de puertos:</strong> solicita al área de TI que redirija el
              puerto 80 de la IP pública de la institución hacia esta máquina, y comparte esa IP pública.
            </Typography>
            <Typography variant="body2" component="div" sx={{ mt: 1 }}>
              2. <strong>Ngrok (más simple, sin configurar el router):</strong> instala Ngrok
              (ngrok.com/download), ejecuta <code>ngrok http 80</code> en esta máquina y comparte la URL
              pública temporal que te entregue (ej. https://xxxx.ngrok-free.app).
            </Typography>
          </DialogContentText>
        </DialogContent>
      </Dialog>
    </Box>
  );
}
