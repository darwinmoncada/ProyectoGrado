-- ================================================================
-- V6: Snapshot de nombre completo y rol del usuario en audit_logs
-- Permite mostrar "Nombre Completo" y "Rol" en la tabla de auditoría
-- sin depender de un JOIN al usuario (que puede haber sido eliminado).
-- ================================================================

ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS full_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS role_name VARCHAR(50);
