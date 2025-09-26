package database

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq" // Driver de PostgreSQL
)

// Init inicializa y devuelve una conexión a la base de datos.
func Init(dbURL string) (*sql.DB, error) {
	if dbURL == "" {
		return nil, fmt.Errorf("la URL de la base de datos (DB_URL) no puede estar vacía")
	}

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		return nil, fmt.Errorf("error al abrir la conexión a la base de datos: %w", err)
	}

	if err = db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("error al conectar con la base de datos: %w", err)
	}

	fmt.Println("Conexión a la base de datos establecida exitosamente.")
	return db, nil
}
