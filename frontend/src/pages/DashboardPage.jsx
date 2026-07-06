import { Grid, Card, CardContent, Typography, Box, Skeleton } from '@mui/material';
import ComputerIcon from '@mui/icons-material/Computer';
import WifiIcon from '@mui/icons-material/Wifi';
import WifiOffIcon from '@mui/icons-material/WifiOff';
import InventoryIcon from '@mui/icons-material/Inventory';
import { useQuery } from '@tanstack/react-query';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend
} from 'recharts';
import { assetService } from '../services/assetService';
import { networkService } from '../services/networkService';
import { inventoryService } from '../services/inventoryService';
import { MOVEMENT_TYPE_LABELS } from '../constants/labels';
import EmptyValue from '../components/common/EmptyValue';
import StatCard from '../components/common/StatCard';

const COLORS = ['#1565C0', '#F57F17'];

export default function DashboardPage() {
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
  const byAreaData = assetStats?.byArea?.map(([area, count]) => ({ name: area, value: count })) || [];

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Dashboard
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Activos"
            value={assetStats?.total ?? '—'}
            icon={<ComputerIcon sx={{ color: '#1565C0', fontSize: 32 }} />}
            color="#1565C0"
            loading={loadingAssets}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Dispositivos En Línea"
            value={networkStats?.online ?? '—'}
            icon={<WifiIcon sx={{ color: '#2E7D32', fontSize: 32 }} />}
            color="#2E7D32"
            loading={loadingNetwork}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Dispositivos Fuera de Línea"
            value={networkStats?.offline ?? '—'}
            icon={<WifiOffIcon sx={{ color: '#C62828', fontSize: 32 }} />}
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
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis
                    dataKey="name"
                    angle={-45}
                    textAnchor="end"
                    interval={0}
                    dx={-10}
                    dy={10}
                    height={70}
                    tick={{ fontSize: 11 }}
                  />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Bar dataKey="value" name="Cantidad" fill="#1565C0" radius={[4, 4, 0, 0]} />
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
                      {COLORS.map((color, i) => <Cell key={i} fill={color} />)}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Últimos movimientos */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" mb={2}>Últimos Movimientos de Inventario</Typography>
              {loadingMovements ? (
                [...Array(3)].map((_, i) => <Skeleton key={i} height={40} sx={{ mb: 1 }} />)
              ) : (
                <Box component="table" sx={{ width: '100%', borderCollapse: 'collapse' }}>
                  <Box component="thead">
                    <Box component="tr" sx={{ borderBottom: '2px solid', borderColor: 'divider' }}>
                      {['Activo', 'Tipo', 'Área Destino', 'Fecha', 'Motivo'].map((h) => (
                        <Box key={h} component="th" sx={{ p: 1, textAlign: 'left', fontSize: 13, fontWeight: 600 }}>
                          {h}
                        </Box>
                      ))}
                    </Box>
                  </Box>
                  <Box component="tbody">
                    {recentMovements?.map((m) => (
                      <Box key={m.id} component="tr" sx={{ borderBottom: '1px solid', borderColor: 'divider', '&:hover': { bgcolor: 'action.hover' } }}>
                        <Box component="td" sx={{ p: 1, fontSize: 13 }}>{m.asset?.name}</Box>
                        <Box component="td" sx={{ p: 1, fontSize: 13 }}>
                          {MOVEMENT_TYPE_LABELS[m.movementType] || m.movementType}
                        </Box>
                        <Box component="td" sx={{ p: 1, fontSize: 13 }}>{m.toArea?.name || <EmptyValue />}</Box>
                        <Box component="td" sx={{ p: 1, fontSize: 13 }}>
                          {new Date(m.movementDate).toLocaleDateString('es-CO')}
                        </Box>
                        <Box component="td" sx={{ p: 1, fontSize: 13 }}>{m.reason || <EmptyValue>Sin especificar</EmptyValue>}</Box>
                      </Box>
                    ))}
                  </Box>
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
