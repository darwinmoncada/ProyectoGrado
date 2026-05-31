package com.uts.inventario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controlador fallback para el frontend React/Vite (SPA).
 * Redirige la raíz hacia index.html.
 * Otros errores 404 son manejados por CustomErrorController.
 */
@Controller
public class FallbackController {

    /**
     * Maneja la raíz y redirige a index.html
     */
    @GetMapping("/")
    public String root() {
        return "forward:/index.html";
    }
}
