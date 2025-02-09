package mock

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"
	"time"
)

type Request struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
}

type Response struct {
	Response string `json:"response"`
}

// spellchecker:disable-next-line
const simpleResponse = `Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.`

const markdownResponse = `# Demo

**Hello from LLM!** this is [markdown](https://markdownguide.org)`

func handleGenerate(w http.ResponseWriter, r *http.Request) {
	var request Request
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	switch strings.ToLower(request.Prompt) {
	case "slow":
		time.Sleep(2 * time.Second)
		respond(w, simpleResponse)
	case "markdown", "md":
		time.Sleep(100 * time.Millisecond)
		respond(w, markdownResponse)
	default:
		respond(w, simpleResponse)
	}
}

func ListenAndServe() {
	http.HandleFunc("/api/generate", handleGenerate)

	slog.Info("starting mock server", slog.Int("port", 11434))
	if err := http.ListenAndServe(":11434", nil); err != nil {
		slog.Error("failed to start server", slog.Any("error", err))
	}
}

func respond(w http.ResponseWriter, message string) {
	response := Response{Response: message}
	jsonResponse, _ := json.Marshal(response)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}
