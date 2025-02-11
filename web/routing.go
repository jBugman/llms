package web

import (
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"runtime/debug"
	"slices"
	"strings"
)

func Router() http.Handler {
	r := http.NewServeMux()

	r.Handle("GET /static/", http.StripPrefix("/static/", http.FileServer(http.Dir("web/static"))))

	r.HandleFunc("GET /{$}", handleIndex)

	return recovery(logger(r))
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

func recovery(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				stack := debug.Stack()
				line := getStackTraceLine(stack)

				slog.Error("panic in http handler",
					slog.Any("error", err),
					slog.String("line", line),
				)

				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
			}
		}()

		next.ServeHTTP(w, r)
	})
}

func getStackTraceLine(stack []byte) string {
	lines := strings.Split(string(stack), "\n")
	i := slices.IndexFunc(lines, func(line string) bool {
		return strings.Contains(line, "runtime/panic.go")
	})
	if i == -1 {
		return strings.Split(strings.TrimSpace(lines[0]), " ")[0]
	}
	absPath := strings.Split(strings.TrimSpace(lines[i+2]), " ")[0]
	cwd, _ := os.Getwd()
	relPath, _ := filepath.Rel(cwd, absPath)
	return relPath
}
