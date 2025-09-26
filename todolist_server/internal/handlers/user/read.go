package user

import (
	"database/sql"
	"net/http"
	"todolist_server/internal/middleware"
	"todolist_server/internal/models"
	"todolist_server/internal/web"
)

// Read obtiene la información del usuario actualmente autenticado.
func (h *Handler) Read(w http.ResponseWriter, r *http.Request) {
	// Obtenemos el userID que el middleware de autenticación guardó en el contexto.
	userID, ok := r.Context().Value(middleware.TheUserIDKey).(int)
	if !ok {
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo obtener el ID de usuario del contexto")
		return
	}

	var user models.User
	err := h.DB.QueryRow("SELECT id, email, created_at, updated_at FROM users WHERE id = $1", userID).Scan(&user.ID, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			web.RespondWithError(w, http.StatusNotFound, "Usuario no encontrado")
			return
		}
		web.RespondWithError(w, http.StatusInternalServerError, "Error al consultar la base de datos")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, user)
}
