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
        return searchMovements(assetId, movementType, from, to, null);
    }

    public static Specification<InventoryMovement> searchMovements(Long assetId, MovementType movementType,
                                                                     LocalDateTime from, LocalDateTime to, String search) {
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

            // Búsqueda por palabra clave: nombre o código del activo, o notas del movimiento
            if (search != null && !search.isBlank()) {
                String pattern = "%" + search.toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("asset").get("name")), pattern),
                        cb.like(cb.lower(root.get("asset").get("codigo")), pattern),
                        cb.like(cb.lower(root.get("notes")), pattern)
                ));
            }

            // Ordenar por fecha descendente
            query.orderBy(cb.desc(root.get("movementDate")));

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
