package user

import (
	"net/http"
	"todolist_server/internal/middleware"
	"todolist_server/internal/web"
)

// Delete elimina la cuenta del usuario actualmente autenticado.
func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.TheUserIDKey).(int)
	if !ok {
		web.RespondWithError(w, http.StatusInternalServerError, "No se pudo obtener el ID de usuario del contexto")
		return
	}

	// La restricción ON DELETE CASCADE en la tabla 'tasks' se encargará de borrar las tareas del usuario.
	result, err := h.DB.Exec("DELETE FROM users WHERE id = $1", userID)
	if err != nil {
		web.RespondWithError(w, http.StatusInternalServerError, "Error al eliminar el usuario de la base de datos")
		return
	}

	// Opcional: verificar si se eliminó alguna fila.
	if rows, _ := result.RowsAffected(); rows == 0 {
		web.RespondWithError(w, http.StatusNotFound, "El usuario a eliminar no fue encontrado")
		return
	}

	web.RespondWithJSON(w, http.StatusOK, map[string]string{"message": "Usuario eliminado exitosamente"})
}
