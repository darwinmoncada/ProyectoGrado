package com.uts.inventario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controlador fallback para el frontend React/Vite (SPA).
 * Redirige las rutas públicas del frontend hacia index.html.
 */
@Controller
public class FallbackController {

    /**
     * Maneja la raíz y las rutas de la SPA que no son /api ni recursos estáticos.
     */
    @GetMapping({
            "/",
            "/{path:^(?!api|swagger-ui|v3|actuator|static|assets|error).*$}",
            "/**/{path:^(?!api|swagger-ui|v3|actuator|static|assets|error).*$}"
    })
    public String root() {
        return "forward:/index.html";
    }
}
