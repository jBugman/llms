import gleam/list
import lustre/attribute.{alt, class, id, name, placeholder, rows, src, type_}
import lustre/element.{type Element}
import lustre/element/html.{
  a, button, div, form, img, input, option, select, span, text, textarea,
} as _

import model.{type ChatID}
import web/hx

pub type Chat {
  Chat(title: String, id: ChatID, is_current: Bool)
}

pub fn body(
  messages: List(Element(a)),
  input_form: Element(a),
  chats: List(Chat),
) -> Element(a) {
  div([class("drawer drawer-open")], [
    input([id("drawer-toggle"), type_("checkbox"), class("drawer-toggle")]),
    div([class("drawer-content flex flex-col")], [
      div([class("flex-1 flex justify-center")], [
        div([class("max-w-5xl w-full flex flex-col h-screen grow gap-4")], [
          div(
            [id("chat_messages"), class("flex-1 overflow-y-auto p-4 space-y-4")],
            messages,
          ),
          input_form,
        ]),
      ]),
    ]),
    drawer(chats),
  ])
}

pub fn llm_message(message: String) -> Element(a) {
  div([class("chat chat-start")], [text(message)])
}

pub fn user_message(message: String) -> Element(a) {
  div([class("chat chat-end")], [
    div([class("chat-bubble chat-bubble-neutral")], [text(message)]),
  ])
}

pub fn thinking_placeholder() -> Element(a) {
  div([id("thinking_indicator"), class("chat chat-start htmx-indicator")], [
    span([class("loading loading-dots loading-sm")], []),
  ])
}

pub fn input_form(models_select: Element(a)) -> Element(a) {
  form(
    [
      class("p-4 pb-2 card w-full shadow-sm gap-2 grow-0 justify-end"),
      hx.post("/htmx/post_message"),
      hx.target("#thinking_indicator"),
      hx.swap("outerHTML show:bottom"),
      hx.indicator("#thinking_indicator"),
    ],
    [
      textarea(
        [
          id("user_input"),
          name("message"),
          class(
            "textarea textarea-bordered text-lg flex-1 w-full overflow-y-auto resize-none",
          ),
          placeholder("Type your message here…"),
          rows(4),
        ],
        "",
      ),
      div([class("flex justify-between place-items-start")], [
        models_select,
        button([class("btn btn-warning"), type_("submit")], [
          img([
            src("/static/send-icon.svg"),
            alt("Send message"),
            class("fill-current"),
          ]),
        ]),
      ]),
    ],
  )
}

pub fn models_select(model_names: List(String)) -> Element(a) {
  select(
    [
      id("model_names"),
      name("model_name"),
      class("select select-ghost pl-0 w-auto"),
    ],
    model_names |> list.map(option([], _)),
  )
}

fn drawer(chats: List(Chat)) -> Element(a) {
  div([class("drawer-side")], [
    div([class("w-50 bg-base-100 h-full flex flex-col")], [
      div([class("p-4 border-b border-base-300")], [
        button([class("btn btn-warning w-full")], [text("New Chat")]),
      ]),
      div([class("flex-1 overflow-y-auto")], [
        div([class("menu p-4 space-y-2")], chats |> list.map(chat_list_item)),
      ]),
    ]),
  ])
}

fn chat_list_item(item: Chat) -> Element(a) {
  let class_names = "px-3 py-2 rounded-lg hover:bg-base-300"
  let class_names = case item.is_current {
    True -> class_names <> " " <> "bg-base-300"
    False -> class_names
  }
  div([class(class_names)], [a([class("line-clamp-2")], [text(item.title)])])
}
