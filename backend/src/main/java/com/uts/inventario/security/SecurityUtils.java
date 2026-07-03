package com.uts.inventario.security;

import com.uts.inventario.entity.User;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {

    /**
     * ID del Administrador Original del sistema (sembrado en la migración/DataInitializer).
     * Es el único usuario con permiso para crear o modificar otros ROLE_ADMIN.
     */
    public static final Long SUPER_ADMIN_ID = 1L;

    private SecurityUtils() {
    }

    public static Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return null;
        }
        return user.getId();
    }

    public static boolean isSuperAdmin() {
        return SUPER_ADMIN_ID.equals(getCurrentUserId());
    }
}
