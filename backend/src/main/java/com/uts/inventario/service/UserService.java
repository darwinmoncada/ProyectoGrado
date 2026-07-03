package com.uts.inventario.service;

import com.uts.inventario.dto.request.ResetPasswordRequest;
import com.uts.inventario.dto.request.UpdateUserRequest;
import com.uts.inventario.dto.response.UserResponse;
import com.uts.inventario.entity.Role;
import com.uts.inventario.entity.User;
import com.uts.inventario.enums.RoleName;
import com.uts.inventario.exception.BusinessException;
import com.uts.inventario.exception.ResourceNotFoundException;
import com.uts.inventario.repository.RoleRepository;
import com.uts.inventario.repository.UserRepository;
import com.uts.inventario.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    public List<UserResponse> getAllUsers(boolean includeInactive) {
        List<User> users = includeInactive
                ? userRepository.findAllByOrderByFullName()
                : userRepository.findAllActive();
        return users.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public UserResponse getUser(Long id) {
        return toResponse(findUserOrThrow(id));
    }

    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        User user = findUserOrThrow(id);
        boolean requesterIsSuperAdmin = SecurityUtils.isSuperAdmin();

        if (SecurityUtils.isSuperAdmin(user) && !requesterIsSuperAdmin) {
            throw new BusinessException("No está permitido modificar a un Super Administrador");
        }

        if (!user.getUsername().equals(request.getUsername())
                && userRepository.existsByUsername(request.getUsername())) {
            throw new BusinessException("El nombre de usuario ya está en uso: " + request.getUsername());
        }
        if (!user.getEmail().equals(request.getEmail())
                && userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("El correo electrónico ya está registrado: " + request.getEmail());
        }

        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setFullName(request.getFullName());
        user.setPhone(request.getPhone());
        user.setDocumentNumber(request.getDocumentNumber());

        if (request.getRoles() != null && !request.getRoles().isEmpty()) {
            user.setRoles(resolveRoles(request.getRoles(), requesterIsSuperAdmin));
        }

        return toResponse(userRepository.save(user));
    }

    @Transactional
    public void resetPassword(Long id, ResetPasswordRequest request) {
        User user = findUserOrThrow(id);

        if (SecurityUtils.isSuperAdmin(user) && !SecurityUtils.isSuperAdmin()) {
            throw new BusinessException("No está permitido restablecer la contraseña de un Super Administrador");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Transactional
    public UserResponse toggleActive(Long id) {
        User user = findUserOrThrow(id);

        if (id.equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("No puedes desactivar tu propia cuenta");
        }
        if (SecurityUtils.isSuperAdmin(user) && !SecurityUtils.isSuperAdmin()) {
            throw new BusinessException("No está permitido cambiar el estado de un Super Administrador");
        }

        user.setIsActive(!user.getIsActive());
        return toResponse(userRepository.save(user));
    }

    @Transactional
    public void deleteUser(Long id) {
        User user = findUserOrThrow(id);

        if (id.equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("No puedes eliminar tu propia cuenta");
        }

        try {
            userRepository.delete(user);
            userRepository.flush();
        } catch (DataIntegrityViolationException ex) {
            throw new BusinessException(
                    "No se puede eliminar: el usuario tiene registros asociados en el sistema " +
                    "(activos, movimientos o auditoría). Desactívalo en su lugar.");
        }
    }

    private Set<Role> resolveRoles(Set<RoleName> roleNames, boolean allowElevatedRoles) {
        boolean requestsElevatedRole = roleNames.contains(RoleName.ROLE_ADMIN) || roleNames.contains(RoleName.ROLE_SUPERADMIN);
        if (requestsElevatedRole && !allowElevatedRoles) {
            throw new BusinessException("No tienes permisos para asignar este rol");
        }

        Set<Role> roles = new HashSet<>();
        for (RoleName roleName : roleNames) {
            Role role = roleRepository.findByName(roleName)
                    .orElseThrow(() -> new BusinessException("Rol no encontrado: " + roleName));
            roles.add(role);
        }
        return roles;
    }

    private User findUserOrThrow(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado: " + id));
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .documentNumber(user.getDocumentNumber())
                .isActive(user.getIsActive())
                .roles(user.getRoles().stream().map(role -> role.getName().name()).collect(Collectors.toList()))
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
