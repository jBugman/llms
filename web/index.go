package web

import (
	"net/http"

	"github.com/google/uuid"
)

func handleIndex(w http.ResponseWriter, r *http.Request) {
	chats := []chatListItem{
		{
			title:     "Gleam Programming Discussion",
			id:        uuid.New(),
			isCurrent: true,
		},
		{
			// spellchecker:disable-next-line
			title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
			id:    uuid.New(),
		},
	}

	messages := []chatMessage{
		{
			text: "Hello, how are you?",

			isUser: true,
		},
		{
			text: "I'm fine, thank you!",
		},
	}

	models := []string{"o3-mini", "deepseek-r1"}

	body := bodyEl(messages, models, chats)

	pageLayout("Local LLM Chat", body).Render(w)
}
