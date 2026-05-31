package com.uts.inventario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Controlador que actúa como fallback para el frontend React/Vite.
 * Redirige todas las rutas que no corresponden a API ni recursos estáticos
 * hacia index.html para que React Router pueda manejarlas.
 */
@Controller
public class FallbackController {

    /**
     * Redirige todas las peticiones excepto las que ya están manejadas
     * (como /api/*, /swagger-ui/*, etc.) hacia index.html.
     * Esto permite que React Router funcione correctamente en todas las rutas.
     */
    @RequestMapping(value = "/{path:^(?!api|swagger-ui|v3|actuator|static|assets).*}/**")
    public String forward() {
        return "forward:/index.html";
    }

    @RequestMapping(value = "/{path:^(?!api|swagger-ui|v3|actuator|static|assets).*}")
    public String forwardRoot() {
        return "forward:/index.html";
    }
}
