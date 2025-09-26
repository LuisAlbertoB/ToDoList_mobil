package models

import "time"

// User represents the model of a user in the database.
type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	Password  string    `json:"-"` // Do not expose password in JSON responses
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Credentials holds the data for user login.
type Credentials struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
