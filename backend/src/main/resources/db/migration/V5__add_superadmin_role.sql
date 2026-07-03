-- ================================================================
-- V5: Rol ROLE_SUPERADMIN y migración del administrador original
-- ================================================================

INSERT INTO roles (name, description) VALUES
    ('ROLE_SUPERADMIN', 'Super administrador con control total del sistema')
ON CONFLICT (name) DO NOTHING;

-- El usuario 'admin' original pasa de ROLE_ADMIN a ROLE_SUPERADMIN
DELETE FROM user_roles
WHERE user_id = (SELECT id FROM users WHERE username = 'admin')
  AND role_id = (SELECT id FROM roles WHERE name = 'ROLE_ADMIN');

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'admin' AND r.name = 'ROLE_SUPERADMIN'
ON CONFLICT DO NOTHING;
