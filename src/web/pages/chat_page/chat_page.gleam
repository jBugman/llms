import gleam/http
import gleam/list
import gleam/result
import gleam/string
import lustre/element
import wisp.{type Request, type Response}

import ollama_api
import web/api
import web/pages/chat_page/html
import web/pages/layout

pub fn index(req: Request) -> Response {
  use <- wisp.require_method(req, http.Get)

  let chats = [
    html.Chat(
      title: "Gleam Programming Discussion",
      id: wisp.random_string(8),
      is_current: True,
    ),
    html.Chat(
      // spellchecker:disable-next-line
      title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      id: wisp.random_string(8),
      is_current: False,
    ),
  ]

  let messages = [
    html.user_message("Hello, how are you?"),
    html.llm_message("I'm fine, thank you!"),
    html.thinking_placeholder(),
  ]

  //   case ollama_api.get_tags() {
  //     Ok(tags) ->
  //       tags
  //       |> model_names_html
  //       |> element.fragment
  //       |> element.to_string_builder
  //       |> wisp.html_response(200)
  let model_names = ["o3-mini", "deepseek-r1"]

  let models_select = html.models_select(model_names)
  let input_form = html.input_form(models_select)

  let body = html.body(messages, input_form, chats)

  layout.page_layout("Local LLM Chat", body)
  |> element.to_document_string_builder
  |> wisp.html_response(200)
}

pub fn post_message_htmx(req: Request) -> Response {
  use <- wisp.require_method(req, http.Post)
  use form <- wisp.require_form(req)

  use request <- decode_message_request(form)

  wisp.log_info(request |> string.inspect)

  let result = {
    use completion <- result.try(ollama_api.get_completion(
      request.model,
      request.prompt,
    ))

    element.fragment([
      html.user_message(request.prompt),
      html.llm_message(completion),
      html.thinking_placeholder(),
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
  func: fn(api.GenerateRequest) -> Response,
) -> Response {
  let res = {
    use message <- result.try(form.values |> list.key_find("message"))
    use model <- result.try(form.values |> list.key_find("model_name"))
    api.GenerateRequest(prompt: message, model:) |> Ok
  }
  case res {
    Ok(req) -> func(req)
    Error(_) -> wisp.bad_request()
  }
}
