package task

import (
	"encoding/json"
	"net/http"
	"strconv"
	"todolist_server/internal/middleware"
	"todolist_server/internal/models"
	"todolist_server/internal/web"

	"github.com/gorilla/mux"
)

// Update handles the modification of an existing task.
func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.TheUserIDKey).(int)
	if !ok {
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo obtener el ID de usuario del contexto")
		return
	}

	vars := mux.Vars(r)
	taskID, err := strconv.Atoi(vars["id"])
	if err != nil {
		web.RespondWithError(w, http.StatusBadRequest, "ID de tarea inválido")
		return
	}

	var task models.Task
	if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
		web.RespondWithError(w, http.StatusBadRequest, "Petición inválida: el cuerpo del JSON no es correcto")
		return
	}

	result, err := h.DB.ExecContext(r.Context(),
		"UPDATE tasks SET title = $1, content = $2, is_completed = $3, updated_at = NOW() WHERE id = $4 AND user_id = $5",
		task.Title, task.Content, task.IsCompleted, taskID, userID,
	)
	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al actualizar la tarea")
		return
	}

	if rows, _ := result.RowsAffected(); rows == 0 {
		web.RespondWithError(w, http.StatusNotFound, "Tarea no encontrada o no tienes permiso para modificarla")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, map[string]string{"message": "Tarea actualizada exitosamente"})
}
