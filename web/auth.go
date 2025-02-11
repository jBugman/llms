package web

import (
	"context"
	"crypto/rand"
	"fmt"
	"log/slog"
	"net/http"
	"time"
)

const authCookieName = "llms_session"

func auth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var sessionID string

		cookie, err := r.Cookie(authCookieName)
		if err != nil {
			// http.Error(w, "Unauthorized", http.StatusUnauthorized)
			buf := make([]byte, 10)
			_, err := rand.Read(buf)
			if err != nil {
				slog.Error("failed to generate session id", slog.Any("error", err))
				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
				return
			}
			sessionID = fmt.Sprintf("%x", buf)
			cookie = &http.Cookie{
				Name:     authCookieName,
				Value:    sessionID,
				Path:     "/",
				Secure:   false, // true
				SameSite: http.SameSiteStrictMode,
				Expires:  time.Now().Add(24 * time.Hour),
			}
			http.SetCookie(w, cookie)
		}
		sessionID = cookie.Value

		ctx := context.WithValue(r.Context(), sessionIDKey{}, sessionID)

		next.ServeHTTP(w, r.WithContext(ctx))
	}
}

type sessionIDKey struct{}

func getSessionID(r *http.Request) string {
	v := r.Context().Value(sessionIDKey{})
	if v != nil {
		return v.(string)
	}
	return ""
}
