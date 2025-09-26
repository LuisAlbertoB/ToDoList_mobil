package task

import (
	"net/http"
	"strconv"
	"todolist_server/internal/middleware"
	"todolist_server/internal/web"

	"github.com/gorilla/mux"
)

// Delete handles the removal of a task.
func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
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

	result, err := h.DB.ExecContext(r.Context(), "DELETE FROM tasks WHERE id = $1 AND user_id = $2", taskID, userID)
	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al eliminar la tarea")
		return
	}

	if rows, _ := result.RowsAffected(); rows == 0 {
		web.RespondWithError(w, http.StatusNotFound, "Tarea no encontrada o no tienes permiso para eliminarla")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, map[string]string{"message": "Tarea eliminada exitosamente"})
}
