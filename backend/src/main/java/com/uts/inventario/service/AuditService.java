package com.uts.inventario.service;

import com.uts.inventario.dto.response.AuditLogResponse;
import com.uts.inventario.dto.response.PageResponse;
import com.uts.inventario.entity.AuditLog;
import com.uts.inventario.entity.User;
import com.uts.inventario.enums.AuditAction;
import com.uts.inventario.enums.RoleName;
import com.uts.inventario.repository.AuditLogRepository;
import com.uts.inventario.repository.spec.AuditLogSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuditService {

    // Orden de mayor a menor privilegio; se guarda el más alto que tenga el usuario.
    private static final List<RoleName> ROLE_PRIORITY = List.of(
            RoleName.ROLE_SUPERADMIN, RoleName.ROLE_ADMIN, RoleName.ROLE_TECNICO, RoleName.ROLE_USUARIO);

    private final AuditLogRepository auditLogRepository;

    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(User user, AuditAction action, String entityType, Long entityId,
                    String entityDescription, String ipAddress) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .user(user)
                    .username(user != null ? user.getUsername() : "system")
                    .fullName(user != null ? user.getFullName() : "Sistema")
                    .roleName(user != null ? resolvePrimaryRole(user) : null)
                    .action(action)
                    .entityType(entityType)
                    .entityId(entityId)
                    .entityDescription(entityDescription)
                    .ipAddress(ipAddress)
                    .success(true)
                    .build();

            auditLogRepository.save(auditLog);
        } catch (Exception e) {
            log.error("Error al registrar auditoría: {}", e.getMessage());
        }
    }

    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logWithChanges(User user, AuditAction action, String entityType, Long entityId,
                               String entityDescription, String oldValues, String newValues,
                               String ipAddress) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .user(user)
                    .username(user != null ? user.getUsername() : "system")
                    .fullName(user != null ? user.getFullName() : "Sistema")
                    .roleName(user != null ? resolvePrimaryRole(user) : null)
                    .action(action)
                    .entityType(entityType)
                    .entityId(entityId)
                    .entityDescription(entityDescription)
                    .oldValues(oldValues)
                    .newValues(newValues)
                    .ipAddress(ipAddress)
                    .success(true)
                    .build();

            auditLogRepository.save(auditLog);
        } catch (Exception e) {
            log.error("Error al registrar auditoría con cambios: {}", e.getMessage());
        }
    }

    public PageResponse<AuditLogResponse> searchLogs(Long userId, AuditAction action, String entityType,
                                                       LocalDateTime from, LocalDateTime to, Pageable pageable) {
        Page<AuditLog> result = auditLogRepository.findAll(
                AuditLogSpecification.searchLogs(userId, action, entityType, from, to), pageable);
        return PageResponse.from(result.map(this::toResponse));
    }

    private String resolvePrimaryRole(User user) {
        return ROLE_PRIORITY.stream()
                .filter(roleName -> user.getRoles().stream().anyMatch(role -> role.getName() == roleName))
                .findFirst()
                .map(Enum::name)
                .orElse(null);
    }

    private AuditLogResponse toResponse(AuditLog auditLog) {
        return AuditLogResponse.builder()
                .id(auditLog.getId())
                .username(auditLog.getUsername())
                .fullName(auditLog.getFullName())
                .roleName(auditLog.getRoleName())
                .action(auditLog.getAction())
                .entityType(auditLog.getEntityType())
                .entityId(auditLog.getEntityId())
                .entityDescription(auditLog.getEntityDescription())
                .oldValues(auditLog.getOldValues())
                .newValues(auditLog.getNewValues())
                .ipAddress(auditLog.getIpAddress())
                .success(auditLog.getSuccess())
                .errorMessage(auditLog.getErrorMessage())
                .timestamp(auditLog.getTimestamp())
                .build();
    }
}
