-- Ajuste seguro de estados de activos sin borrar registros
-- Primero muestra cuántos registros se van a modificar.
-- Luego aplica el cambio solo para los estados indicados.

SELECT 'Registros a modificar' AS mensaje, count(*) AS cantidad
FROM public.assets
WHERE status IN ('Baja', 'RETIRED', 'Pendiente de baja', 'LOST');

UPDATE public.assets
SET status = CASE
    WHEN status = 'Baja' THEN 'RETIRED'
    WHEN status = 'RETIRED' THEN 'RETIRED'
    WHEN status = 'Pendiente de baja' THEN 'LOST'
    WHEN status = 'LOST' THEN 'LOST'
    ELSE status
END
WHERE status IN ('Baja', 'RETIRED', 'Pendiente de baja', 'LOST');
