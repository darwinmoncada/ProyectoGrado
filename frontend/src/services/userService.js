import api from './api';

export const userService = {
  getAll: () => api.get('/users', { params: { includeInactive: true } }).then((r) => r.data.data),
  getById: (id) => api.get(`/users/${id}`).then((r) => r.data.data),
  create: (data) => api.post('/auth/register', data).then((r) => r.data.data),
  update: (id, data) => api.put(`/users/${id}`, data).then((r) => r.data.data),
  resetPassword: (id, newPassword) =>
    api.patch(`/users/${id}/password`, { newPassword }).then((r) => r.data),
  toggleActive: (id) => api.patch(`/users/${id}/toggle-active`).then((r) => r.data.data),
  delete: (id) => api.delete(`/users/${id}`).then((r) => r.data),
};
