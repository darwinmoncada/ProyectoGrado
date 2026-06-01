package com.uts.inventario.repository;

import com.uts.inventario.entity.NetworkDevice;
import com.uts.inventario.enums.NetworkStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NetworkDeviceRepository extends JpaRepository<NetworkDevice, Long>, JpaSpecificationExecutor<NetworkDevice> {

    Optional<NetworkDevice> findByAssetId(Long assetId);

    Optional<NetworkDevice> findByIpAddress(String ipAddress);

    Optional<NetworkDevice> findByMacAddress(String macAddress);

    boolean existsByIpAddress(String ipAddress);

    boolean existsByMacAddress(String macAddress);

    List<NetworkDevice> findByNetworkStatus(NetworkStatus status);

    long countByNetworkStatus(NetworkStatus status);
}
