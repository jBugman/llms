package web

import (
	"github.com/google/uuid"

	. "maragu.dev/gomponents"
	hx "maragu.dev/gomponents-htmx"
	. "maragu.dev/gomponents/html"
)

type chatListItem struct {
	title string

	id uuid.UUID

	isCurrent bool
}

type chatMessage struct {
	text string

	isUser bool
}

func bodyEl(
	messages []chatMessage,
	models []string,
	chats []chatListItem,
) Node {
	return Div(Class("drawer drawer-open"),
		Input(ID("drawer-toggle"), Type("checkbox"), Class("drawer-toggle")),
		Div(Class("drawer-content flex flex-col"),
			Div(Class("flex-1 flex justify-center"),
				Div(Class("max-w-5xl w-full flex flex-col h-screen grow gap-4"),
					Div(
						ID("chat_messages"),
						Class("flex-1 overflow-y-auto p-4 space-y-4"),
						Map(messages, chatMessageEl),
						thinking(),
					),
					inputForm(models),
				),
			),
		),
		drawer(chats),
	)
}

func chatMessageEl(m chatMessage) Node {
	if !m.isUser {
		return Div(Class("chat chat-start"),
			Text(m.text),
		)
	}

	return Div(Class("chat chat-end"),
		Div(Class("chat-bubble chat-bubble-neutral"),
			Text(m.text),
		),
	)
}

func thinking() Node {
	return Div(
		ID("thinking_indicator"),
		Class("chat chat-start htmx-indicator"),
		Span(Class("loading loading-dots loading-sm")),
	)
}

func inputForm(models []string) Node {
	return Form(
		Class("p-4 pb-2 card w-full shadow-sm gap-2 grow-0 justify-end"),
		hx.Post("/htmx/post_message"),
		hx.Target("#thinking_indicator"),
		hx.Swap("outerHTML show:bottom"),
		hx.Indicator("#thinking_indicator"),
		Textarea(
			ID("user_input"),
			Name("message"),
			Class("textarea textarea-bordered text-lg flex-1 w-full overflow-y-auto resize-none"),
			Placeholder("Type your message here…"),
			Rows("4"),
		),
		Div(Class("flex justify-between place-items-start"),
			modelsSelect(models),
			Button(Class("btn btn-warning"), Type("submit"),
				Img(
					Src("/static/send-icon.svg"),
					Alt("Send message"),
					Class("fill-current"),
				),
			),
		),
	)
}

func modelsSelect(names []string) Node {
	return Select(
		ID("model_names"),
		Name("model_name"),
		Class("select select-ghost pl-0 w-auto"),
		Map(names, func(name string) Node {
			return Option(Text(name))
		}),
	)
}

func drawer(chats []chatListItem) Node {
	return Div(Class("drawer-side"),
		Div(Class("w-50 bg-base-100 h-full flex flex-col"),
			Div(Class("p-4 border-b border-base-300"),
				Button(Class("btn btn-warning w-full"),
					Text("New Chat"),
				),
			),
			Div(Class("flex-1 overflow-y-auto"),
				Div(Class("menu p-4 space-y-2"),
					Map(chats, chatListItemEl),
				),
			),
		),
	)
}

func chatListItemEl(item chatListItem) Node {
	classNames := "px-3 py-2 rounded-lg hover:bg-base-300"
	if item.isCurrent {
		classNames += " " + "bg-base-300"
	}
	return Div(Class(classNames),
		A(Class("line-clamp-2"),
			Text(item.title),
		),
	)
}
