package session

import (
	"time"

	"github.com/google/uuid"
)

type OptionInput struct {
	Name     string `json:"name"`
	ColorHex string `json:"colorHex"`
}

type ResultInput struct {
	Name     string `json:"name"`
	ColorHex string `json:"colorHex"`
	Rank     int    `json:"rank"`
}

type CreateInput struct {
	UserID       uuid.UUID
	SpunAt       time.Time
	IsRanked     bool
	WheelOptions []OptionInput
	Results      []ResultInput
}
