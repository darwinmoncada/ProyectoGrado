package com.uts.inventario.controller;

import com.uts.inventario.dto.request.ResetPasswordRequest;
import com.uts.inventario.dto.request.UpdateUserRequest;
import com.uts.inventario.dto.response.ApiResponse;
import com.uts.inventario.dto.response.UserResponse;
import com.uts.inventario.entity.Area;
import com.uts.inventario.entity.AssetType;
import com.uts.inventario.exception.ResourceNotFoundException;
import com.uts.inventario.repository.AreaRepository;
import com.uts.inventario.repository.AssetTypeRepository;
import com.uts.inventario.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Catálogos", description = "Endpoints de catálogos: usuarios, áreas y tipos de activos")
public class UserController {

    private final UserService userService;
    private final AreaRepository areaRepository;
    private final AssetTypeRepository assetTypeRepository;

    // ---- Usuarios ----

    @GetMapping("/users")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN', 'TECNICO')")
    @Operation(summary = "Listar usuarios")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getUsers(
            @RequestParam(defaultValue = "false") boolean includeInactive) {
        return ResponseEntity.ok(ApiResponse.success(userService.getAllUsers(includeInactive)));
    }

    @GetMapping("/users/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN', 'TECNICO')")
    @Operation(summary = "Obtener usuario por ID")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUser(id)));
    }

    @PutMapping("/users/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    @Operation(summary = "Actualizar usuario (solo ADMIN, no aplica a administradores)")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
            @PathVariable Long id, @Valid @RequestBody UpdateUserRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Usuario actualizado", userService.updateUser(id, request)));
    }

    @PatchMapping("/users/{id}/password")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    @Operation(summary = "Restablecer contraseña de un usuario (solo ADMIN, no aplica a administradores)")
    public ResponseEntity<ApiResponse<String>> resetPassword(
            @PathVariable Long id, @Valid @RequestBody ResetPasswordRequest request) {
        userService.resetPassword(id, request);
        return ResponseEntity.ok(ApiResponse.success("Contraseña restablecida", null));
    }

    @PatchMapping("/users/{id}/toggle-active")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    @Operation(summary = "Activar/desactivar usuario")
    public ResponseEntity<ApiResponse<UserResponse>> toggleUser(@PathVariable Long id) {
        UserResponse response = userService.toggleActive(id);
        String state = response.getIsActive() ? "activado" : "desactivado";
        return ResponseEntity.ok(ApiResponse.success("Usuario " + state, response));
    }

    @DeleteMapping("/users/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    @Operation(summary = "Eliminar usuario (solo SUPERADMIN)")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success("Usuario eliminado", null));
    }

    // ---- Áreas ----

    @GetMapping("/areas")
    @Operation(summary = "Listar áreas activas")
    public ResponseEntity<ApiResponse<List<Area>>> getAreas() {
        return ResponseEntity.ok(ApiResponse.success(areaRepository.findByIsActiveTrueOrderByName()));
    }

    @GetMapping("/areas/{id}")
    @Operation(summary = "Obtener área por ID")
    public ResponseEntity<ApiResponse<Area>> getArea(@PathVariable Long id) {
        Area area = areaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Área no encontrada: " + id));
        return ResponseEntity.ok(ApiResponse.success(area));
    }

    @PostMapping("/areas")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    @Operation(summary = "Crear nueva área")
    public ResponseEntity<ApiResponse<Area>> createArea(@RequestBody Area area) {
        area.setIsActive(true);
        return ResponseEntity.ok(ApiResponse.success("Área creada", areaRepository.save(area)));
    }

    @PutMapping("/areas/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    @Operation(summary = "Actualizar área")
    public ResponseEntity<ApiResponse<Area>> updateArea(@PathVariable Long id, @RequestBody Area request) {
        Area area = areaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Área no encontrada: " + id));
        area.setName(request.getName());
        area.setDescription(request.getDescription());
        area.setLocation(request.getLocation());
        area.setFloor(request.getFloor());
        area.setBuilding(request.getBuilding());
        return ResponseEntity.ok(ApiResponse.success("Área actualizada", areaRepository.save(area)));
    }

    // ---- Tipos de activos ----

    @GetMapping("/asset-types")
    @Operation(summary = "Listar tipos de activos")
    public ResponseEntity<ApiResponse<List<AssetType>>> getAssetTypes() {
        return ResponseEntity.ok(ApiResponse.success(assetTypeRepository.findByOrderByName()));
    }

    @GetMapping("/asset-types/category/{category}")
    @Operation(summary = "Listar tipos de activos por categoría")
    public ResponseEntity<ApiResponse<List<AssetType>>> getAssetTypesByCategory(
            @PathVariable String category) {
        return ResponseEntity.ok(ApiResponse.success(
                assetTypeRepository.findByCategoryOrderByName(category.toUpperCase())));
    }

    @PostMapping("/asset-types")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    @Operation(summary = "Crear tipo de activo")
    public ResponseEntity<ApiResponse<AssetType>> createAssetType(@RequestBody AssetType assetType) {
        return ResponseEntity.ok(ApiResponse.success("Tipo creado", assetTypeRepository.save(assetType)));
    }
}
