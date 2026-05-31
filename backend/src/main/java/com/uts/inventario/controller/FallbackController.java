package com.uts.inventario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controlador que actúa como fallback para el frontend React/Vite (SPA).
 * Redirige todas las rutas que no corresponden a API ni recursos estáticos
 * hacia index.html para que React Router pueda manejarlas.
 */
@Controller
public class FallbackController {

    /**
     * Captura todas las rutas y devuelve index.html
     * Spring Security ya permitió que llegue aquí (no es /api/*)
     * Los archivos estáticos se sirven desde WebConfig
     */
    @GetMapping({
        "/",
        "/{path:^(?!api|swagger-ui|v3|actuator|static|assets|error).+}",
        "/{path:^(?!api|swagger-ui|v3|actuator|static|assets|error).+}/{subPath:.*}"
    })
    public String forward() {
        return "forward:/index.html";
    }
}
