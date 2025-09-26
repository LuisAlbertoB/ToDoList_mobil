package task

import (
	"net/http"
	"todolist_server/internal/middleware"
	"todolist_server/internal/models"
	"todolist_server/internal/web"
)

// GetAllByUser fetches all tasks for the authenticated user.
func (h *Handler) GetAllByUser(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.TheUserIDKey).(int)
	if !ok {
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo obtener el ID de usuario del contexto")
		return
	}

	rows, err := h.DB.QueryContext(r.Context(), "SELECT id, user_id, title, content, is_completed, created_at, updated_at FROM tasks WHERE user_id = $1 ORDER BY created_at DESC", userID)
	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al obtener las tareas")
		return
	}
	defer rows.Close()

	var tasks []models.Task
	for rows.Next() {
		var t models.Task
		if err := rows.Scan(&t.ID, &t.UserID, &t.Title, &t.Content, &t.IsCompleted, &t.CreatedAt, &t.UpdatedAt); err != nil {
			web.RespondWithError(w, http.StatusInternalServerError, "Error al procesar las tareas")
			return
		}
		tasks = append(tasks, t)
	}
	if err := rows.Err(); err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al iterar sobre las tareas")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, tasks)
}
