package com.uts.inventario.controller;

import com.uts.inventario.dto.response.ApiResponse;
import com.uts.inventario.dto.response.NetworkInfoResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;

@RestController
@RequestMapping("/api/system")
@Slf4j
@Tag(name = "Sistema", description = "Información de red del servidor")
@SecurityRequirement(name = "bearerAuth")
public class SystemController {

    // Nombres de interfaz que corresponden a redes virtuales/Docker, no a la red física real.
    private static final List<String> IGNORED_INTERFACE_KEYWORDS =
            List.of("docker", "veth", "br-", "virbr", "vmnet", "vboxnet");

    @GetMapping("/network-info")
    @Operation(summary = "IP privada del servidor en la red local, para acceso desde otros equipos")
    public ResponseEntity<ApiResponse<NetworkInfoResponse>> getNetworkInfo() {
        String ip = resolveIp();
        return ResponseEntity.ok(ApiResponse.success(new NetworkInfoResponse(ip)));
    }

    private String resolveIp() {
        // El backend corre dentro de un contenedor Docker: sus propias interfaces de red
        // muestran la IP interna del bridge de Docker, no la IP real del equipo host en la
        // red de la universidad. Por eso iniciar_servidor.bat detecta esa IP en el host
        // (con ipconfig/PowerShell) y la pasa como variable de entorno antes de levantar
        // los contenedores; aquí simplemente se reutiliza.
        String hostLanIp = System.getenv("HOST_LAN_IP");
        if (hostLanIp != null && !hostLanIp.isBlank() && !"127.0.0.1".equals(hostLanIp)) {
            return hostLanIp;
        }

        // Respaldo: si el backend corre directamente en el host (sin Docker), sí se puede
        // detectar la IP real recorriendo las interfaces de red del propio proceso.
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            for (NetworkInterface iface : Collections.list(interfaces)) {
                if (!isEligible(iface)) continue;

                for (InetAddress address : Collections.list(iface.getInetAddresses())) {
                    if (address instanceof Inet4Address && !address.isLoopbackAddress()) {
                        return address.getHostAddress();
                    }
                }
            }
        } catch (SocketException e) {
            log.warn("No se pudo enumerar las interfaces de red: {}", e.getMessage());
        }

        return "127.0.0.1";
    }

    private boolean isEligible(NetworkInterface iface) throws SocketException {
        if (iface.isLoopback() || !iface.isUp() || iface.isVirtual()) {
            return false;
        }
        String name = iface.getName().toLowerCase();
        String displayName = iface.getDisplayName() != null ? iface.getDisplayName().toLowerCase() : "";
        return IGNORED_INTERFACE_KEYWORDS.stream()
                .noneMatch(keyword -> name.contains(keyword) || displayName.contains(keyword));
    }
}
