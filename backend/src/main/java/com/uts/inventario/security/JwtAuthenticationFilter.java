package com.uts.inventario.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");

        // Seguridad defensiva: si no hay header válido, continuar la cadena de filtros
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Protección ante headers mal formados
        if (authHeader.length() <= 7) {
            filterChain.doFilter(request, response);
            return;
        }

        final String jwt = authHeader.substring(7);

        try {
            if (jwtTokenProvider == null) {
                log.warn("JwtTokenProvider is not available");
            } else if (userDetailsService == null) {
                log.warn("UserDetailsService is not available");
            } else {
                final String username = jwtTokenProvider.extractUsername(jwt);

                if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    UserDetails userDetails = null;
                    try {
                        userDetails = userDetailsService.loadUserByUsername(username);
                    } catch (Exception e) {
                        log.warn("Failed to load user by username {}: {}", username, e.getMessage());
                    }

                    if (userDetails != null) {
                        try {
                            if (jwtTokenProvider.isTokenValid(jwt, userDetails)) {
                                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                                        userDetails, null, userDetails.getAuthorities()
                                );
                                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                                SecurityContextHolder.getContext().setAuthentication(authToken);
                            }
                        } catch (Exception e) {
                            log.warn("Token validation failed for user {}: {}", username, e.getMessage());
                        }
                    }
                }
            }
        } catch (Throwable ex) {
            log.warn("Unexpected error in JWT authentication filter", ex);
        }

        filterChain.doFilter(request, response);
    }
}
