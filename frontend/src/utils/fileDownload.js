export function downloadBlob(blob, filename) {
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
}

// Axios con responseType: 'blob' entrega el cuerpo de error también como Blob
// (no como JSON parseado), así que hay que leerlo como texto antes de extraer el mensaje.
export async function extractBlobErrorMessage(err, fallback = 'Ocurrió un error inesperado') {
  const data = err?.response?.data;
  if (data instanceof Blob) {
    try {
      const text = await data.text();
      const json = JSON.parse(text);
      return json?.error || json?.message || fallback;
    } catch {
      return fallback;
    }
  }
  return err?.response?.data?.error || fallback;
}
