package web

import (
	"encoding/json"
	"log"
	"net/http"
)

// RespondWithJSON escribe una respuesta JSON.
func RespondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	data, err := json.Marshal(payload)
	if err != nil {
		log.Printf("Error al serializar la respuesta JSON: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	w.Write(data)
}

// RespondWithError escribe una respuesta de error en formato JSON.
func RespondWithError(w http.ResponseWriter, code int, message string) {
	// Si el código es 5xx, es un error del servidor y deberíamos registrarlo.
	if code >= 500 {
		log.Printf("Respondiendo con error 5xx: %s", message)
	}
	RespondWithJSON(w, code, map[string]string{"error": message})
}
