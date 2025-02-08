import gleam/http
import gleam/list
import gleam/result.{try}
import gleam/string
import gleam/string_tree.{type StringTree}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html
import wisp.{type Request, type Response}

import http/api.{type GenerateRequest, GenerateRequest}
import ollama_api

pub fn post_message(req: Request) -> Response {
  use <- wisp.require_method(req, http.Post)
  use form <- wisp.require_form(req)

  use request <- decode_message_request(form)

  wisp.log_info("post_message: " <> request |> string.inspect)

  let result = {
    use completion <- try(ollama_api.get_completion(
      request.model,
      request.prompt,
    ))

    element.fragment([
      user_message_html(request.prompt),
      llm_message_html(completion),
      thinking_placeholder(),
    ])
    |> element.to_string_builder
    |> Ok
  }

  case result {
    Ok(res) -> res |> wisp.html_response(200)
    Error(err) -> {
      wisp.log_error(err |> string.inspect)
      wisp.internal_server_error()
    }
  }
}

fn decode_message_request(
  form: wisp.FormData,
  func: fn(GenerateRequest) -> Response,
) -> Response {
  let res = {
    use message <- try(form.values |> list.key_find("message"))
    use model <- try(form.values |> list.key_find("model_name"))
    GenerateRequest(prompt: message, model:) |> Ok
  }
  case res {
    Ok(req) -> func(req)
    Error(_) -> wisp.bad_request()
  }
}

pub fn model_names(req: Request) -> Response {
  use <- wisp.require_method(req, http.Get)

  case ollama_api.get_tags() {
    Ok(tags) ->
      tags
      |> model_names_html
      |> wisp.html_response(200)

    Error(err) -> {
      wisp.log_error("error getting model names: " <> err |> string.inspect)
      wisp.internal_server_error()
    }
  }
}

fn llm_message_html(message: String) -> Element(a) {
  html.div([a.class("chat chat-start")], [html.text(message)])
}

fn user_message_html(message: String) -> Element(a) {
  html.div([a.class("chat chat-end")], [
    html.div([a.class("chat-bubble chat-bubble-neutral")], [html.text(message)]),
  ])
}

fn thinking_placeholder() -> Element(a) {
  html.div(
    [a.id("thinking_indicator"), a.class("chat chat-start htmx-indicator")],
    [html.span([a.class("loading loading-dots loading-sm")], [])],
  )
}

fn model_names_html(model_names: List(String)) -> StringTree {
  model_names
  |> list.map(fn(model_name) { "<option>" <> model_name <> "</option>" })
  |> string.join("")
  |> string_tree.from_string
}
