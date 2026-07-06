import { Card, CardContent, Typography, Box, Skeleton, useTheme } from '@mui/material';

export default function StatCard({ title, value, icon, color, loading }) {
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';

  return (
    <Card
      sx={{
        boxShadow: isDark ? 'none' : undefined,
        border: isDark ? '1px solid' : 'none',
        borderColor: isDark ? 'divider' : 'transparent',
      }}
    >
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Box>
            <Typography variant="body2" color="text.secondary">{title}</Typography>
            {loading ? (
              <Skeleton width={60} height={40} />
            ) : (
              <Typography variant="h4" fontWeight={700} color={color}>{value}</Typography>
            )}
          </Box>
          <Box sx={{
            p: 1.75, borderRadius: '50%', display: 'flex',
            bgcolor: isDark ? `${color}30` : `${color}18`,
            color,
          }}>
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
}
