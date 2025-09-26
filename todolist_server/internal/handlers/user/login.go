package user

import (
	"database/sql"
	"encoding/json"
	"net/http"

	"todolist_server/internal/auth"
	"todolist_server/internal/models"
	"todolist_server/internal/web"

	"golang.org/x/crypto/bcrypt"
)

// Login (SignIn) handles user authentication and token generation.
func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var creds models.Credentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		web.RespondWithError(w, http.StatusBadRequest, "Petición inválida")
		return
	}

	var user models.User
	err := h.DB.QueryRowContext(r.Context(), "SELECT id, password FROM users WHERE email = $1", creds.Email).Scan(&user.ID, &user.Password)
	if err != nil {
		if err == sql.ErrNoRows {
			web.RespondWithError(w, http.StatusUnauthorized, "Credenciales inválidas")
			return
		}
		web.RespondWithError(w, http.StatusInternalServerError, "Error interno del servidor")
		return
	}

	// Compara la contraseña enviada con el hash almacenado
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(creds.Password)); err != nil {
		web.RespondWithError(w, http.StatusUnauthorized, "Credenciales inválidas")
		return
	}

	// Genera el token JWT
	tokenString, err := auth.GenerateJWT(user.ID, h.Cfg.JWTSecret)
	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al generar el token de autenticación")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, map[string]string{
		"token": tokenString,
	})
}
