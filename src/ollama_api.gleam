import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result

const base_url = "http://localhost:11434"

pub type ApiError {
  FailedHttpCall(httpc.HttpError)
  JsonError(json.DecodeError)
  ApiError(status: Int, response: String)
}

pub fn get_tags() -> Result(List(String), ApiError) {
  let assert Ok(req) = request.to(base_url <> "/api/tags")

  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(FailedHttpCall),
  )

  use _ <- result.try(case resp.status {
    200 -> Ok(Nil)
    status -> Error(ApiError(status, resp.body))
  })

  json.parse(
    resp.body,
    using: decode.at(
      ["models"],
      decode.list(of: decode.at(["name"], decode.string)),
    ),
  )
  |> result.map_error(JsonError)
}

pub fn get_completion(model: String, prompt: String) -> Result(String, ApiError) {
  let assert Ok(req) = request.to(base_url <> "/api/generate")

  let payload =
    json.object([
      #("model", json.string(model)),
      #("prompt", json.string(prompt)),
      #("stream", json.bool(False)),
    ])

  let req =
    req
    |> request.set_body(payload |> json.to_string)
    |> request.set_method(http.Post)

  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(FailedHttpCall),
  )

  use _ <- result.try(case resp.status {
    200 -> Ok(Nil)
    status -> Error(ApiError(status, resp.body))
  })

  json.parse(resp.body, using: decode.at(["response"], decode.string))
  |> result.map_error(JsonError)
}
