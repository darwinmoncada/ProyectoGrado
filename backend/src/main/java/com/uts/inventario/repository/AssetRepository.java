package com.uts.inventario.repository;

import com.uts.inventario.entity.Asset;
import com.uts.inventario.enums.AssetStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssetRepository extends JpaRepository<Asset, Long>, JpaSpecificationExecutor<Asset> {

    Optional<Asset> findBySerialNumber(String serialNumber);

    Optional<Asset> findByCodigo(String codigo);

    Page<Asset> findByStatus(AssetStatus status, Pageable pageable);

    Page<Asset> findByAreaId(Long areaId, Pageable pageable);

    Page<Asset> findByAssignedUserId(Long userId, Pageable pageable);



    long countByStatus(AssetStatus status);

    @Query("SELECT a.assetType.name as type, COUNT(a) as count FROM Asset a GROUP BY a.assetType.name")
    List<Object[]> countByAssetType();

    @Query("SELECT a.area.name as area, COUNT(a) as count FROM Asset a WHERE a.area IS NOT NULL GROUP BY a.area.name")
    List<Object[]> countByArea();

    List<Asset> findByAreaIdAndStatus(Long areaId, AssetStatus status);
}
