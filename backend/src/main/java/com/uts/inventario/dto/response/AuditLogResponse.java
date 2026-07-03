package com.uts.inventario.dto.response;

import com.uts.inventario.enums.AuditAction;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuditLogResponse {

    private Long id;
    private String username;
    private String fullName;
    private String roleName;
    private AuditAction action;
    private String entityType;
    private Long entityId;
    private String entityDescription;
    private String oldValues;
    private String newValues;
    private String ipAddress;
    private Boolean success;
    private String errorMessage;
    private LocalDateTime timestamp;
}
