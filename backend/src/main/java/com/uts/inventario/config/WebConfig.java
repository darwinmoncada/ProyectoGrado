package com.uts.inventario.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Mapea las peticiones de la raíz y recursos estáticos para que busquen dentro de la carpeta /static
        // Esta carpeta es generada por el Dockerfile al compilar el frontend
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/");
    }
}
