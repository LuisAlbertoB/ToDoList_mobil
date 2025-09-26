package middleware

import (
	"context"
	"net/http"
	"todolist_server/internal/auth"
	"todolist_server/internal/web"
)

// UserIDKey es la clave usada para almacenar el ID de usuario en el contexto de la petición.
type UserIDKey string

const TheUserIDKey UserIDKey = "userID"

// Authenticate es un middleware que verifica el token JWT.
func Authenticate(jwtSecret string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Extraer el token de la cabecera.
			userID, err := auth.GetUserIDFromToken(r, jwtSecret)
			if err != nil {
				web.RespondWithError(w, http.StatusUnauthorized, "Acceso no autorizado: "+err.Error())
				return
			}

			// El token es válido. Almacenamos el userID en el contexto de la petición
			// para que los siguientes handlers puedan usarlo.
			ctx := context.WithValue(r.Context(), TheUserIDKey, userID)

			// Llamamos al siguiente handler en la cadena con el nuevo contexto.
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
