package com.uts.inventario.repository.spec;

import com.uts.inventario.entity.NetworkDevice;
import com.uts.inventario.enums.NetworkStatus;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public class NetworkDeviceSpecification {

    public static Specification<NetworkDevice> searchDevices(String search, NetworkStatus status) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Búsqueda por texto
            if (search != null && !search.isBlank()) {
                String searchPattern = "%" + search.toLowerCase() + "%";
                Predicate searchPredicate = cb.or(
                    cb.like(cb.lower(root.get("ipAddress")), searchPattern),
                    cb.like(cb.lower(root.get("hostname")), searchPattern),
                    cb.like(cb.lower(root.get("macAddress")), searchPattern),
                    cb.like(cb.lower(root.get("asset").get("name")), searchPattern)
                );
                predicates.add(searchPredicate);
            }

            // Filtro por estado
            if (status != null) {
                predicates.add(cb.equal(root.get("networkStatus"), status));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
