import gleam/dynamic/decode
import gleam/http.{Get as GET, Post as POST}
import gleam/json
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

import ollama_api

pub fn tags(req: Request) -> Response {
  use <- wisp.require_method(req, GET)

  case ollama_api.get_tags() {
    Ok(tags) ->
      tags
      |> json.array(json.string)
      |> json.to_string_tree
      |> wisp.json_response(200)

    Error(err) -> handle_api_error(err)
  }
}

type GenerateRequest {
  GenerateRequest(model: String, prompt: String)
}

fn generate_request_decoder() -> decode.Decoder(GenerateRequest) {
  use model <- decode.field("model", decode.string)
  use prompt <- decode.field("prompt", decode.string)
  decode.success(GenerateRequest(model:, prompt:))
}

pub fn generate(req: Request) -> Response {
  use <- wisp.require_method(req, POST)
  use json_body <- wisp.require_json(req)

  let result = {
    use request <- result.try(
      decode.run(json_body, generate_request_decoder())
      |> result.map_error(fn(err) {
        let err = "failed to decode request: " <> err |> string.inspect
        json_error(err, 400)
      }),
    )

    let GenerateRequest(model, prompt) = request

    use response <- result.try(
      ollama_api.get_completion(model, prompt)
      |> result.map_error(handle_api_error),
    )

    Ok(response)
  }

  case result {
    Ok(response) -> {
      json.object([#("response", json.string(response))])
      |> json.to_string_tree
      |> wisp.json_response(200)
    }

    Error(err) -> err
  }
}

fn handle_api_error(err: ollama_api.ApiError) -> Response {
  case err {
    ollama_api.FailedHttpCall(e) -> json_error(e, 500)

    ollama_api.JsonError(e) -> json_error(e, 500)

    ollama_api.ApiError(status, response) ->
      json.object([
        #("status", json.int(status)),
        #("msg", json.string(response)),
      ])
      |> json.to_string_tree
      |> wisp.json_response(status)
  }
}

fn json_error(err, code: Int) -> Response {
  let msg = err |> string.inspect

  json.object([#("error", json.string(msg))])
  |> json.to_string_tree
  |> wisp.json_response(code)
}
