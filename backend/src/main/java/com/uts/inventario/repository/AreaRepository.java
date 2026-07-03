package com.uts.inventario.repository;

import com.uts.inventario.entity.Area;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AreaRepository extends JpaRepository<Area, Long> {

    List<Area> findByIsActiveTrueOrderByName();

    boolean existsByName(String name);

    // El área se conserva; solo se desvincula al usuario eliminado como responsable.
    @Modifying(clearAutomatically = true)
    @Query("UPDATE Area a SET a.responsible = null WHERE a.responsible.id = :userId")
    void detachResponsible(@Param("userId") Long userId);
}
