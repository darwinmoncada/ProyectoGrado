package com.uts.inventario.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controlador fallback para el frontend React/Vite (SPA).
 * Redirige las rutas públicas del frontend hacia index.html.
 */
@Controller
public class FallbackController {

    @GetMapping({
            "/",
            "/{path:[^.]*}",
            "/**/{path:[^.]*}"
    })
    public String root(HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri.startsWith("/api") || uri.startsWith("/swagger-ui") || uri.startsWith("/v3")
                || uri.startsWith("/actuator") || uri.startsWith("/static") || uri.startsWith("/error")) {
            return "forward:/error.html";
        }
        return "forward:/index.html";
    }
}
