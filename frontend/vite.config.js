import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    // Vite pone por defecto los archivos estáticos compilados en "dist/assets/", lo que choca
    // con la ruta de la SPA "/assets" (listado de Activos TI): nginx trata esa carpeta como un
    // directorio real y devuelve 403 al navegar directo o recargar (F5) en esa URL.
    assetsDir: 'static',
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
});
