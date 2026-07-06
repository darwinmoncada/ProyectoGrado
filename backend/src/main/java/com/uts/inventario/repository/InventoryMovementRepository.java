package com.uts.inventario.repository;

import com.uts.inventario.entity.InventoryMovement;
import com.uts.inventario.enums.MovementType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InventoryMovementRepository extends JpaRepository<InventoryMovement, Long>, JpaSpecificationExecutor<InventoryMovement> {

    Page<InventoryMovement> findByAssetId(Long assetId, Pageable pageable);

    // Se conserva el movimiento (activo, fechas, área); solo se desvincula al usuario eliminado.
    @Modifying(clearAutomatically = true)
    @Query("UPDATE InventoryMovement m SET m.fromUser = null WHERE m.fromUser.id = :userId")
    void detachFromUser(@Param("userId") Long userId);

    @Modifying(clearAutomatically = true)
    @Query("UPDATE InventoryMovement m SET m.toUser = null WHERE m.toUser.id = :userId")
    void detachToUser(@Param("userId") Long userId);

    @Modifying(clearAutomatically = true)
    @Query("UPDATE InventoryMovement m SET m.createdBy = null WHERE m.createdBy.id = :userId")
    void detachCreatedBy(@Param("userId") Long userId);

    @Query("""
        SELECT m FROM InventoryMovement m
        LEFT JOIN FETCH m.fromArea
        LEFT JOIN FETCH m.toArea
        LEFT JOIN FETCH m.fromUser
        LEFT JOIN FETCH m.toUser
        LEFT JOIN FETCH m.createdBy
        WHERE m.asset.id = :assetId
        ORDER BY m.movementDate DESC
        """)
    List<InventoryMovement> findByAssetIdOrderByMovementDateDesc(@Param("assetId") Long assetId);

    @Query("SELECT m FROM InventoryMovement m ORDER BY m.movementDate DESC")
    List<InventoryMovement> findRecentMovements(Pageable pageable);

    long countByMovementType(MovementType movementType);

    long countByMovementTypeAndMovementDateBetween(MovementType movementType, java.time.LocalDateTime from, java.time.LocalDateTime to);

    // Activos cuyo movimiento más reciente es un préstamo (LOAN) sin devolución posterior:
    // se consideran "en préstamo" en este momento.
    @Query("""
        SELECT COUNT(DISTINCT m.asset.id) FROM InventoryMovement m
        WHERE m.movementType = com.uts.inventario.enums.MovementType.LOAN
        AND m.movementDate = (
            SELECT MAX(m2.movementDate) FROM InventoryMovement m2 WHERE m2.asset.id = m.asset.id
        )
        """)
    long countAssetsCurrentlyOnLoan();
}
