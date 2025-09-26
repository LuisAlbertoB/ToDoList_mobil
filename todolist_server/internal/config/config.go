package config

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Config holds all configuration for the application
type Config struct {
	DBUrl     string
	JWTSecret string
	Port      string
}

// Load loads configuration from environment variables.
func Load() (*Config, error) {
	// Cargar variables de entorno desde el archivo .env
	err := godotenv.Load()
	if err != nil {
		log.Println("Advertencia: No se pudo cargar el archivo .env. Usando variables de entorno del sistema.")
	}

	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("la variable de entorno DB_URL es requerida")
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		return nil, fmt.Errorf("la variable de entorno JWT_SECRET es requerida")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Puerto por defecto
	}

	return &Config{
		DBUrl:     dbURL,
		JWTSecret: jwtSecret,
		Port:      port,
	}, nil
}
