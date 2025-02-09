package web

import (
	"log/slog"
	"net/http"
)

func Router() http.Handler {
	r := http.NewServeMux()
	r.Handle("GET /static/", http.StripPrefix("/static/", http.FileServer(http.Dir("priv/static"))))
	r.HandleFunc("GET /{$}", handleIndex)
	return logger(r)
}

func logger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ww := rwWrapper{w, 200}
		next.ServeHTTP(&ww, r)
		slog.Info(r.Method, slog.Int("status", ww.statusCode), slog.String("url", r.URL.String()))
	})
}

type rwWrapper struct {
	http.ResponseWriter
	statusCode int
}

func (w *rwWrapper) WriteHeader(statusCode int) {
	w.statusCode = statusCode
	w.ResponseWriter.WriteHeader(statusCode)
}
