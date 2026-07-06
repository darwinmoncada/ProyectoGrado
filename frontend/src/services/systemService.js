import api from './api';

export const systemService = {
  getNetworkInfo: () => api.get('/system/network-info').then((r) => r.data.data),
};
