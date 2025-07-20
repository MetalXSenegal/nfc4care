package com.nfc4care.security;

import com.nfc4care.service.JwtService;
import com.nfc4care.service.TokenService;
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
    
    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;
    private final TokenService tokenService;
    
    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userEmail;
        
        log.debug("🔍 Filtre JWT - URL: {} {}", request.getMethod(), request.getRequestURI());
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.debug("❌ Pas de header Authorization ou format incorrect");
            filterChain.doFilter(request, response);
            return;
        }
        
        jwt = authHeader.substring(7);
        log.debug("🔑 Token JWT reçu: {}...", jwt.substring(0, Math.min(20, jwt.length())));
        
        try {
            // Vérifier d'abord la validité JWT
            userEmail = jwtService.extractUsername(jwt);
            
            if (userEmail == null) {
                log.warn("❌ Impossible d'extraire l'email du token JWT");
                filterChain.doFilter(request, response);
                return;
            }
            
            log.debug("📧 Email extrait du token: {}", userEmail);
            
            if (SecurityContextHolder.getContext().getAuthentication() == null) {
                // Vérifier si le token existe en base de données et est actif
                log.debug("🔍 Vérification du token en base de données...");
                boolean isTokenValidInDB = tokenService.isTokenValid(jwt);
                
                if (!isTokenValidInDB) {
                    log.warn("❌ Token non trouvé en base de données ou révoqué pour l'utilisateur: {}", userEmail);
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("{\"success\":false,\"error\":\"Token invalide ou révoqué\",\"message\":\"Votre session a expiré. Veuillez vous reconnecter.\"}");
                    response.setContentType("application/json");
                    return;
                }
                
                log.debug("✅ Token validé en base de données");
                
                // Vérifier la validité JWT
                if (jwtService.isTokenValid(jwt)) {
                    UserDetails userDetails = this.userDetailsService.loadUserByUsername(userEmail);
                    
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    
                    log.info("✅ Authentification réussie pour l'utilisateur: {}", userEmail);
                } else {
                    log.warn("❌ Token JWT invalide pour l'utilisateur: {}", userEmail);
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("{\"success\":false,\"error\":\"Token JWT invalide\",\"message\":\"Votre session a expiré. Veuillez vous reconnecter.\"}");
                    response.setContentType("application/json");
                    return;
                }
            } else {
                log.debug("✅ Utilisateur déjà authentifié: {}", userEmail);
            }
        } catch (Exception e) {
            log.error("❌ Erreur lors de la validation du token JWT: {}", e.getMessage());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"error\":\"Erreur de validation du token\",\"message\":\"Votre session a expiré. Veuillez vous reconnecter.\"}");
            response.setContentType("application/json");
            return;
        }
        
        filterChain.doFilter(request, response);
    }
} 