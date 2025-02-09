package main

import (
	"log/slog"
	"net/http"
	"os"

	mock "llms/mock_server"
	"llms/web"
)

func main() {
	router := web.Router()

	go mock.ListenAndServe()

	slog.Info("starting web server", slog.Int("port", 8000))
	if err := http.ListenAndServe(":8000", router); err != nil {
		slog.Error("failed to start server", slog.Any("error", err))
		os.Exit(1)
	}
}
