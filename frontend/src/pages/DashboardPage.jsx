import { Grid, Card, CardContent, Typography, Box, Skeleton, useTheme } from '@mui/material';
import {
  Timeline, TimelineItem, TimelineSeparator, TimelineDot,
  TimelineConnector, TimelineContent, TimelineOppositeContent,
} from '@mui/lab';
import ComputerIcon from '@mui/icons-material/Computer';
import WifiIcon from '@mui/icons-material/Wifi';
import WifiOffIcon from '@mui/icons-material/WifiOff';
import { useQuery } from '@tanstack/react-query';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend
} from 'recharts';
import { assetService } from '../services/assetService';
import { networkService } from '../services/networkService';
import { inventoryService } from '../services/inventoryService';
import { MOVEMENT_TYPE_LABELS, MOVEMENT_TYPE_COLORS } from '../constants/labels';
import EmptyValue from '../components/common/EmptyValue';
import StatCard from '../components/common/StatCard';

const PIE_COLORS = ['#1565C0', '#F57F17'];
const TIMELINE_DOT_COLOR = {
  success: '#2E7D32', error: '#C62828', info: '#0288D1',
  warning: '#F57C00', default: 'grey',
};

function ChartTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <Box sx={{
      bgcolor: 'background.paper', border: '1px solid', borderColor: 'divider',
      borderRadius: 1.5, px: 1.5, py: 1, boxShadow: 4,
    }}>
      {label && <Typography variant="caption" fontWeight={700} display="block">{label}</Typography>}
      {payload.map((p, i) => (
        <Typography key={i} variant="body2" sx={{ color: p.color || p.payload?.fill }}>
          {p.name}: <strong>{p.value}</strong>
        </Typography>
      ))}
    </Box>
  );
}

export default function DashboardPage() {
  const theme = useTheme();

  const { data: assetStats, isLoading: loadingAssets } = useQuery({
    queryKey: ['assetStats'],
    queryFn: assetService.getStats,
  });

  const { data: networkStats, isLoading: loadingNetwork } = useQuery({
    queryKey: ['networkStats'],
    queryFn: networkService.getStats,
  });

  const { data: recentMovements, isLoading: loadingMovements } = useQuery({
    queryKey: ['recentMovements'],
    queryFn: () => inventoryService.getRecent(5),
  });

  const byTypeData = assetStats?.byType?.map(([type, count]) => ({ name: type, value: count })) || [];
  const axisTick = { fill: theme.palette.text.secondary, fontSize: 11 };
  const legendStyle = { color: theme.palette.text.primary, fontSize: 13 };

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Dashboard
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Total Activos"
            value={assetStats?.total ?? '—'}
            icon={<ComputerIcon sx={{ fontSize: 40 }} />}
            color="#1565C0"
            loading={loadingAssets}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Dispositivos En Línea"
            value={networkStats?.online ?? '—'}
            icon={<WifiIcon sx={{ fontSize: 40 }} />}
            color="#2E7D32"
            loading={loadingNetwork}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Dispositivos Fuera de Línea"
            value={networkStats?.offline ?? '—'}
            icon={<WifiOffIcon sx={{ fontSize: 40 }} />}
            color="#C62828"
            loading={loadingNetwork}
          />
        </Grid>

        {/* Gráfico por tipo */}
        <Grid item xs={12} md={7}>
          <Card>
            <CardContent>
              <Typography variant="h6" mb={2}>Activos por Tipo</Typography>
              <ResponsiveContainer width="100%" height={280}>
                <BarChart data={byTypeData} margin={{ top: 5, right: 20, bottom: 70, left: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} />
                  <XAxis
                    dataKey="name"
                    angle={-45}
                    textAnchor="end"
                    interval={0}
                    dx={-10}
                    dy={10}
                    height={70}
                    tick={axisTick}
                  />
                  <YAxis allowDecimals={false} tick={axisTick} />
                  <Tooltip content={<ChartTooltip />} cursor={{ fill: theme.palette.action.hover }} />
                  <Bar dataKey="value" name="Cantidad" fill={theme.palette.primary.main} radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* Gráfico por estado (pie) */}
        <Grid item xs={12} md={5}>
          <Card>
            <CardContent>
              <Typography variant="h6" mb={2}>Estado de Activos</Typography>
              {!loadingAssets && assetStats && (
                <ResponsiveContainer width="100%" height={280}>
                  <PieChart>
                    <Pie
                      data={[
                        { name: 'Activos', value: assetStats.active },
                        { name: 'Pendiente de baja', value: assetStats.lost },
                      ]}
                      cx="50%"
                      cy="50%"
                      outerRadius={90}
                      dataKey="value"
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                      labelLine={false}
                    >
                      {PIE_COLORS.map((color, i) => <Cell key={i} fill={color} />)}
                    </Pie>
                    <Tooltip content={<ChartTooltip />} />
                    <Legend wrapperStyle={legendStyle} />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Últimos movimientos: línea de tiempo */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" mb={1}>Últimos Movimientos de Inventario</Typography>
              {loadingMovements ? (
                [...Array(3)].map((_, i) => <Skeleton key={i} height={40} sx={{ mb: 1 }} />)
              ) : !recentMovements?.length ? (
                <Typography color="text.secondary" sx={{ py: 2 }}>Sin movimientos registrados.</Typography>
              ) : (
                <Timeline sx={{ px: 0, m: 0, [`& .MuiTimelineItem-root:before`]: { flex: 0, p: 0 } }}>
                  {recentMovements.map((m, i) => {
                    const dotColor = TIMELINE_DOT_COLOR[MOVEMENT_TYPE_COLORS[m.movementType]] || 'grey';
                    return (
                      <TimelineItem key={m.id}>
                        <TimelineOppositeContent sx={{ flex: 0.25, py: 1.5 }} color="text.secondary" variant="body2">
                          {new Date(m.movementDate).toLocaleDateString('es-CO')}
                        </TimelineOppositeContent>
                        <TimelineSeparator>
                          <TimelineDot sx={{ bgcolor: dotColor }} />
                          {i < recentMovements.length - 1 && <TimelineConnector />}
                        </TimelineSeparator>
                        <TimelineContent sx={{ py: 1.5 }}>
                          <Typography variant="body2" fontWeight={600}>
                            {m.asset?.name || <EmptyValue />}
                            <Typography component="span" variant="body2" color="text.secondary" ml={1}>
                              {MOVEMENT_TYPE_LABELS[m.movementType] || m.movementType}
                            </Typography>
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {m.toArea?.name ? `→ ${m.toArea.name}` : 'Sin área destino'}
                            {m.reason ? ` · ${m.reason}` : ''}
                          </Typography>
                        </TimelineContent>
                      </TimelineItem>
                    );
                  })}
                </Timeline>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
