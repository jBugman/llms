import gleam/http/response
import wisp.{type Request, type Response}

import http/api

pub fn handle_request(req: Request) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["api", "tags"] -> api.tags(req)

    ["api", "generate"] -> api.generate(req)

    _ -> wisp.not_found()
  }
}

fn middleware(req: Request, handle_request: fn(Request) -> Response) -> Response {
  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  handle_request(req) |> add_dev_cors_headers
}

fn add_dev_cors_headers(resp: Response) -> Response {
  resp
  |> response.set_header("Access-Control-Allow-Origin", "http://localhost:3000")
  |> response.set_header(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, DELETE, OPTIONS",
  )
  |> response.set_header(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization",
  )
  |> response.set_header("Access-Control-Allow-Credentials", "true")
  |> response.set_header("Access-Control-Max-Age", "86400")
}
