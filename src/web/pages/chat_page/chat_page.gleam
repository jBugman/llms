import gleam/http
import gleam/list
import gleam/result
import gleam/string
import lustre/element
import wisp.{type Request, type Response}

import ollama_api
import web/api

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
