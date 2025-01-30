import gleam/http.{Get as GET}
import gleam/json
import gleam/string_tree
import snag
import wisp.{type Request, type Response}

import ollama_api

pub fn handle_request(req: Request) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["api", "tags"] ->
      case req.method {
        GET -> tags(req)
        _ -> wisp.method_not_allowed([GET])
      }

    _ -> wisp.not_found()
  }
}

fn tags(_req: wisp.Request) -> wisp.Response {
  case ollama_api.get_tags() {
    Ok(tags) ->
      tags
      |> json.array(json.string)
      |> json.to_string_tree
      |> wisp.json_response(200)

    Error(err) ->
      err
      |> snag.line_print
      |> string_tree.from_string
      |> wisp.html_response(500)
  }
}

fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  handle_request(req)
}
