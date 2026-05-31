package com.uts.inventario.controller;

import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Controlador de errores personalizado para Spring Boot.
 * Captura todos los errores 404 y los redirige a index.html
 * para que React Router pueda manejar las rutas de la SPA.
 */
@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError() {
        // Redirige todos los errores 404 a index.html
        // De esta forma React Router puede manejar las rutas de la SPA
        return "forward:/index.html";
    }

    public String getErrorPath() {
        return "/error";
    }
}
