package user

import (
	"database/sql"
	"todolist_server/internal/config"
)

// Handler holds dependencies for user handlers.
type Handler struct {
	DB  *sql.DB
	Cfg *config.Config
}

// New crea un nuevo user handler con sus dependencias.
func New(db *sql.DB, cfg *config.Config) *Handler {
	return &Handler{DB: db, Cfg: cfg}
}
