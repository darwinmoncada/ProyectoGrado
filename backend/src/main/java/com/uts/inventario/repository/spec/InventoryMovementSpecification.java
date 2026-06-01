package com.uts.inventario.repository.spec;

import com.uts.inventario.entity.InventoryMovement;
import com.uts.inventario.enums.MovementType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class InventoryMovementSpecification {

    public static Specification<InventoryMovement> searchMovements(Long assetId, MovementType movementType, LocalDateTime from, LocalDateTime to) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Filtro por activo
            if (assetId != null) {
                predicates.add(cb.equal(root.get("asset").get("id"), assetId));
            }

            // Filtro por tipo de movimiento
            if (movementType != null) {
                predicates.add(cb.equal(root.get("movementType"), movementType));
            }

            // Filtro por fecha desde
            if (from != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("movementDate"), from));
            }

            // Filtro por fecha hasta
            if (to != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("movementDate"), to));
            }

            // Ordenar por fecha descendente
            query.orderBy(cb.desc(root.get("movementDate")));

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
