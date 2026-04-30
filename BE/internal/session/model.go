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

type OptionOutput struct {
	Name     string `json:"name"`
	ColorHex string `json:"colorHex"`
}

type ResultOutput struct {
	Name     string `json:"name"`
	ColorHex string `json:"colorHex"`
	Rank     int    `json:"rank"`
}

type SessionOutput struct {
	ID           uuid.UUID      `json:"id"`
	SpunAt       time.Time      `json:"spunAt"`
	IsRanked     bool           `json:"isRanked"`
	WheelOptions []OptionOutput `json:"wheelOptions"`
	Results      []ResultOutput `json:"results"`
}
