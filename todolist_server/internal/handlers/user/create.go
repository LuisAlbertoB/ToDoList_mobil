package user

import (
	"encoding/json"
	"net/http"

	"todolist_server/internal/models"
	"todolist_server/internal/web"

	"golang.org/x/crypto/bcrypt"
)

// Create (SignUp) handles the creation of a new user.
func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	var creds models.Credentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		web.RespondWithError(w, http.StatusBadRequest, "Petición inválida")
		return
	}

	// Hashear la contraseña
	hashedPasswordBytes, err := bcrypt.GenerateFromPassword([]byte(creds.Password), bcrypt.DefaultCost)
	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error interno del servidor al procesar la contraseña")
		return
	}
	hashedPassword := string(hashedPasswordBytes)

	var userID int
	err = h.DB.QueryRowContext(r.Context(),
		"INSERT INTO users (email, password) VALUES ($1, $2) RETURNING id",
		creds.Email, hashedPassword,
	).Scan(&userID)

	if err != nil {
		// This is a common error, so we give a specific message.
		web.RespondWithError(w, http.StatusConflict, "El email ya está en uso")
		return
	}

	web.RespondWithJSON(w, http.StatusCreated, map[string]interface{}{
		"message": "Usuario creado exitosamente",
		"userId":  userID,
	})
}
