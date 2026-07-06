package com.uts.inventario.repository.spec;

import com.uts.inventario.entity.Asset;
import com.uts.inventario.enums.AssetStatus;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public class AssetSpecification {

    public static Specification<Asset> searchAssets(String search, AssetStatus status, Long areaId, Long typeId) {
        return searchAssets(search, status, areaId, typeId, null);
    }

    public static Specification<Asset> searchAssets(String search, AssetStatus status, Long areaId, Long typeId, String brand) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Búsqueda por texto
            if (search != null && !search.isBlank()) {
                String searchPattern = "%" + search.toLowerCase() + "%";
                Predicate searchPredicate = cb.or(
                    cb.like(cb.lower(root.get("name")), searchPattern),
                    cb.like(cb.lower(root.get("serialNumber")), searchPattern),
                    cb.like(cb.lower(root.get("codigo")), searchPattern)
                );
                predicates.add(searchPredicate);
            }

            // Filtro por estado
            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            // Filtro por área
            if (areaId != null) {
                predicates.add(cb.equal(root.get("area").get("id"), areaId));
            }

            // Filtro por tipo de activo
            if (typeId != null) {
                predicates.add(cb.equal(root.get("assetType").get("id"), typeId));
            }

            // Filtro por marca
            if (brand != null && !brand.isBlank()) {
                predicates.add(cb.like(cb.lower(root.get("brand")), "%" + brand.toLowerCase() + "%"));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
