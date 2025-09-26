package auth

import (
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// GenerateJWT crea un nuevo token JWT para un usuario.
func GenerateJWT(userID int, secret string) (string, error) {
	// El token expira en 24 horas.
	expirationTime := time.Now().Add(24 * time.Hour)

	// Creamos los claims (la información que contendrá el token).
	claims := &jwt.RegisteredClaims{
		Subject:   strconv.Itoa(userID),
		ExpiresAt: jwt.NewNumericDate(expirationTime),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
	}

	// Creamos el token con el algoritmo de firma HS256 y los claims.
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Firmamos el token con nuestro secreto.
	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// GetUserIDFromToken extrae el ID de usuario de un token JWT en la cabecera de la petición.
func GetUserIDFromToken(r *http.Request, secret string) (int, error) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return 0, errors.New("cabecera de autorización vacía")
	}

	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
		return 0, errors.New("formato de cabecera de autorización inválido")
	}

	tokenString := parts[1]

	claims := &jwt.RegisteredClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return 0, errors.New("token inválido o expirado")
	}

	userID, err := strconv.Atoi(claims.Subject)
	if err != nil {
		return 0, errors.New("ID de usuario en el token es inválido")
	}

	return userID, err
}
