package com.uts.inventario.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Controlador de errores personalizado para Spring Boot.
 * Captura todos los errores (especialmente 404) y los redirige a index.html
 * para que React Router pueda manejar las rutas de la SPA.
 */
@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        
        // Redirige TODOS los errores (404, 403, 500, etc.) a index.html
        // De esta forma React Router puede manejar las rutas de la SPA
        return "forward:/index.html";
    }

    @Override
    public String getErrorPath() {
        return "/error";
    }

}
