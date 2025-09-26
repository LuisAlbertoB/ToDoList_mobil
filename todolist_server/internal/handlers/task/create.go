package task

import (
	"encoding/json"
	"net/http"
	"todolist_server/internal/middleware"
	"todolist_server/internal/models"
	"todolist_server/internal/web"
)

// Create handles the creation of a new task for the authenticated user.
func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.TheUserIDKey).(int)
	if !ok {
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo obtener el ID de usuario del contexto")
		return
	}

	var task models.Task
	if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
		web.RespondWithError(w, http.StatusBadRequest, "Petición inválida: el cuerpo del JSON no es correcto")
		return
	}

	// Aseguramos que la tarea se asigne al usuario del token, no a otro.
	task.UserID = userID

	err := h.DB.QueryRowContext(r.Context(),
		"INSERT INTO tasks (user_id, title, content) VALUES ($1, $2, $3) RETURNING id, created_at, updated_at, is_completed",
		task.UserID, task.Title, task.Content,
	).Scan(&task.ID, &task.CreatedAt, &task.UpdatedAt, &task.IsCompleted)

	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al crear la tarea en la base de datos")
		return
	}

	web.RespondWithJSON(w, http.StatusCreated, task)
}
