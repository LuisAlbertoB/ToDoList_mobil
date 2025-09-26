package user

import (
	"encoding/json"
	"net/http"
	"todolist_server/internal/middleware"
	"todolist_server/internal/web"
)

// UpdateRequest define la estructura para la petición de actualización de usuario.
type UpdateRequest struct {
	Email string `json:"email"`
}

// Update actualiza la información del usuario actualmente autenticado.
func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.TheUserIDKey).(int)
	if !ok {
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo obtener el ID de usuario del contexto")
		return
	}

	var req UpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		web.RespondWithError(w, http.StatusBadRequest, "Petición inválida")
		return
	}

	// Aquí podrías añadir validación para el formato del email.

	_, err := h.DB.Exec("UPDATE users SET email = $1, updated_at = NOW() WHERE id = $2", req.Email, userID)
	if err != nil {
		// Podría ser un error de conflicto si el nuevo email ya existe.
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo actualizar el usuario. El email podría estar en uso.")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, map[string]string{
		"message": "Usuario actualizado exitosamente",
	})
}
