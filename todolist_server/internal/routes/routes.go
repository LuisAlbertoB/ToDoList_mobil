package routes

import (
	"log"
	"net/http"

	taskHandler "todolist_server/internal/handlers/task"
	userHandler "todolist_server/internal/handlers/user"
	"todolist_server/internal/middleware"

	"github.com/gorilla/mux"
)

// Setup inicializa y configura todas las rutas de la API.
func Setup(userH *userHandler.Handler, taskH *taskHandler.Handler) *mux.Router {
	r := mux.NewRouter()
	r.Use(loggingMiddleware)

	// --- Rutas Públicas (Autenticación) ---
	// Corresponde a "Sign Up" y "Sign In" del schema
	r.HandleFunc("/users/signup", userH.Create).Methods(http.MethodPost)
	r.HandleFunc("/users/login", userH.Login).Methods(http.MethodPost)

	// --- Sub-enrutador para rutas protegidas por JWT ---
	api := r.PathPrefix("").Subrouter()
	api.Use(middleware.Authenticate(userH.Cfg.JWTSecret))

	// --- Rutas Protegidas de Usuario ---
	api.HandleFunc("/users/me", userH.Read).Methods(http.MethodGet)
	api.HandleFunc("/users/me", userH.Update).Methods(http.MethodPut)
	api.HandleFunc("/users/me", userH.Delete).Methods(http.MethodDelete)

	// --- Rutas Protegidas de Tareas (CRUD) ---
	// Corresponde a "Dashboard (Gestión de Tareas)" del schema
	api.HandleFunc("/tasks", taskH.Create).Methods(http.MethodPost)               // create_task
	api.HandleFunc("/tasks", taskH.GetAllByUser).Methods(http.MethodGet)          // Leer todas las tareas
	api.HandleFunc("/tasks/{id:[0-9]+}", taskH.Update).Methods(http.MethodPut)    // update_task
	api.HandleFunc("/tasks/{id:[0-9]+}", taskH.Delete).Methods(http.MethodDelete) // delete_task

	return r
}

// loggingMiddleware es un simple logger para cada petición recibida.
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Petición recibida: %s %s", r.Method, r.RequestURI)
		next.ServeHTTP(w, r)
	})
}
