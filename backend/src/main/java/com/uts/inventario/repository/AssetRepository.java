package com.uts.inventario.repository;

import com.uts.inventario.entity.Asset;
import com.uts.inventario.enums.AssetStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssetRepository extends JpaRepository<Asset, Long>, JpaSpecificationExecutor<Asset> {

    Optional<Asset> findBySerialNumber(String serialNumber);

    // El activo se conserva; solo se desvincula al usuario eliminado.
    @Modifying(clearAutomatically = true)
    @Query("UPDATE Asset a SET a.assignedUser = null WHERE a.assignedUser.id = :userId")
    void detachAssignedUser(@Param("userId") Long userId);

    @Modifying(clearAutomatically = true)
    @Query("UPDATE Asset a SET a.createdBy = null WHERE a.createdBy.id = :userId")
    void detachCreatedBy(@Param("userId") Long userId);

    Optional<Asset> findByCodigo(String codigo);

    Page<Asset> findByStatus(AssetStatus status, Pageable pageable);

    Page<Asset> findByAreaId(Long areaId, Pageable pageable);

    Page<Asset> findByAssignedUserId(Long userId, Pageable pageable);



    long countByStatus(AssetStatus status);

    @Query("SELECT a.assetType.name as type, COUNT(a) as count FROM Asset a GROUP BY a.assetType.name")
    List<Object[]> countByAssetType();

    @Query("SELECT a.area.name as area, COUNT(a) as count FROM Asset a WHERE a.area IS NOT NULL GROUP BY a.area.name")
    List<Object[]> countByArea();

    @Query("SELECT a.area.id as areaId, COUNT(a) as count FROM Asset a WHERE a.area IS NOT NULL GROUP BY a.area.id")
    List<Object[]> countByAreaId();

    List<Asset> findByAreaIdAndStatus(Long areaId, AssetStatus status);
}
