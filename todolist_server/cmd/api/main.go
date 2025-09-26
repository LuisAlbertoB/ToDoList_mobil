package main

import (
	"log"
	"net/http"

	"todolist_server/internal/config"
	"todolist_server/internal/database"
	taskHandler "todolist_server/internal/handlers/task"
	userHandler "todolist_server/internal/handlers/user" // alias para claridad
	"todolist_server/internal/routes"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file" // Driver para leer migraciones desde archivos
)

func main() {
	// 1. Cargar configuración
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("No se pudo cargar la configuración: %v", err)
	}

	// 2. Inicializar la base de datos
	db, err := database.Init(cfg.DBUrl)
	if err != nil {
		log.Fatalf("No se pudo inicializar la base de datos: %v", err)
	}
	defer db.Close()

	// 3. Ejecutar migraciones
	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		log.Fatalf("No se pudo crear la instancia del driver de migración: %v", err)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://migrations", // Apunta a tu directorio de migraciones
		"postgres", driver)
	if err != nil {
		log.Fatalf("No se pudo crear la instancia de migración: %v", err)
	}

	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		log.Fatalf("Ocurrió un error al ejecutar las migraciones 'up': %v", err)
	} else if err == nil {
		log.Println("Migraciones aplicadas exitosamente.")
	}

	// 4. Crear instancias de los handlers
	// Inyectamos las dependencias (DB, Config) en los handlers.
	userH := userHandler.New(db, cfg)
	taskH := taskHandler.New(db)

	// 5. Configurar el enrutador
	r := routes.Setup(userH, taskH)

	// 6. Iniciar el servidor
	log.Printf("Servidor escuchando en http://localhost:%s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, r); err != nil {
		log.Fatalf("No se pudo iniciar el servidor: %v", err)
	}
}
