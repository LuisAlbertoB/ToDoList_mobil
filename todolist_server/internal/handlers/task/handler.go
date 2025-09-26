package task

import (
	"database/sql"
)

// Handler holds dependencies for task handlers.
type Handler struct {
	DB *sql.DB
}

// New creates a new task handler with its dependencies.
func New(db *sql.DB) *Handler {
	return &Handler{DB: db}
}
