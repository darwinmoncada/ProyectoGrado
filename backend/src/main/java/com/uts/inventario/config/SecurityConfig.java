package com.uts.inventario.config;

import com.uts.inventario.security.JwtAuthenticationFilter;
import com.uts.inventario.security.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final UserDetailsServiceImpl userDetailsService;

    @Value("#{'${app.cors.allowed-origins}'.split(',')}")
    private List<String> allowedOrigins;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                // Permitir preflight CORS OPTIONS antes que otras reglas (crítico para navegadores)
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                // Registro de usuarios: solo ADMIN/SUPERADMIN puede crear cuentas (refuerza el @PreAuthorize del controller)
                .requestMatchers(HttpMethod.POST, "/api/auth/register").hasAnyRole("ADMIN", "SUPERADMIN")
                // Nota: eliminar usuario NO se restringe aquí a nivel de filtro; el @PreAuthorize del
                // controller ya lo protege. Un requestMatcher aquí para DELETE provoca que Spring Security
                // rechace la petición antes de llegar al DispatcherServlet, lo que en este entorno termina
                // en un reenvío de error de Tomcat que rompe con métodos no-GET (500 en vez de 403).
                // Rutas públicas de autenticación (login, etc) - muy prioritario
                .requestMatchers("/api/auth/**").permitAll()
                // Permitir recursos estáticos en ubicaciones comunes (incluye /assets/**)
                .requestMatchers(PathRequest.toStaticResources().atCommonLocations()).permitAll()
                // Recursos estáticos y SPA adicionales
                .requestMatchers(
                    "/",
                    "/index.html",
                    "/favicon.ico",
                    "/vite.svg",
                    "/assets/**",
                    "/static/**"
                ).permitAll()
                // "/admin/**" NO se restringe aquí: son rutas del SPA (React Router), no endpoints del
                // backend; bloquearlas rompía el F5 en /admin/users al no llegar JWT en la navegación.
                // Todas las demás APIs requieren autenticación
                .requestMatchers("/api/**").authenticated()
                // Permite el resto (principio de menor privilegio ya aplicado arriba)
                .anyRequest().permitAll()
            )
            .authenticationProvider(authenticationProvider())
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return web -> web.ignoring()
            .requestMatchers(
                "/assets/**",
                "/vite.svg",
                "/favicon.ico",
                "/index.html",
                "/static/**"
            );
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        // Usar allowedOriginPatterns para soportar orígenes dinámicos en producción (Railway, etc)
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
