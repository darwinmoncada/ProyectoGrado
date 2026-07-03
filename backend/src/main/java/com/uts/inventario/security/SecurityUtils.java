package com.uts.inventario.security;

import com.uts.inventario.entity.User;
import com.uts.inventario.enums.RoleName;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return null;
        }
        return user;
    }

    public static Long getCurrentUserId() {
        User user = getCurrentUser();
        return user == null ? null : user.getId();
    }

    public static boolean isSuperAdmin() {
        User user = getCurrentUser();
        return user != null && isSuperAdmin(user);
    }

    public static boolean isSuperAdmin(User user) {
        return user.getRoles().stream().anyMatch(role -> role.getName() == RoleName.ROLE_SUPERADMIN);
    }
}
