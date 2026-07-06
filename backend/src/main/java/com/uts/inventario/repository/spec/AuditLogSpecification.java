package com.uts.inventario.repository.spec;

import com.uts.inventario.entity.AuditLog;
import com.uts.inventario.enums.AuditAction;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AuditLogSpecification {

    public static Specification<AuditLog> searchLogs(Long userId, AuditAction action, String entityType, LocalDateTime from, LocalDateTime to) {
        return searchLogs(userId, action, entityType, from, to, null);
    }

    public static Specification<AuditLog> searchLogs(Long userId, AuditAction action, String entityType,
                                                       LocalDateTime from, LocalDateTime to, String username) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Filtro por usuario
            if (userId != null) {
                predicates.add(cb.equal(root.get("user").get("id"), userId));
            }

            // Búsqueda por nombre de usuario (texto libre, snapshot guardado en el propio log)
            if (username != null && !username.isBlank()) {
                predicates.add(cb.like(cb.lower(root.get("username")), "%" + username.toLowerCase() + "%"));
            }

            // Filtro por acción
            if (action != null) {
                predicates.add(cb.equal(root.get("action"), action));
            }

            // Filtro por tipo de entidad
            if (entityType != null && !entityType.isBlank()) {
                predicates.add(cb.equal(root.get("entityType"), entityType));
            }

            // Filtro por fecha desde
            if (from != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("timestamp"), from));
            }

            // Filtro por fecha hasta
            if (to != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("timestamp"), to));
            }

            // Ordenar por fecha descendente
            query.orderBy(cb.desc(root.get("timestamp")));

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
