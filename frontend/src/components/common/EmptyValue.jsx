import { Box } from '@mui/material';

export default function EmptyValue({ children = 'Sin asignar' }) {
  return (
    <Box component="span" sx={{ color: 'text.disabled', fontStyle: 'italic' }}>
      {children}
    </Box>
  );
}
