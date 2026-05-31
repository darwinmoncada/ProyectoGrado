package com.uts.inventario.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    // Dejar que Spring Boot sirva los recursos estáticos por defecto desde classpath:/static/
}
