import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';

export default function StatCard({ title, value, icon, color, loading }) {
  return (
    <Card>
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
          <Box sx={{ p: 1.5, borderRadius: 2, bgcolor: `${color}20` }}>
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
}
