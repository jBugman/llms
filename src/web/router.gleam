import gleam/http/response
import wisp.{type Request, type Response}

import web/api
import web/context.{type Context}
import web/pages/chat_page/chat_page

const auth_cookie_name = "llms_session"

pub fn handle_request(req: Request, make_context: fn() -> Context) -> Response {
  let ctx = make_context()
  use req <- middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> chat_page.index(req)

    ["htmx", "post_message"] -> chat_page.post_message_htmx(req)

    ["api", "tags"] -> api.tags(req)

    ["api", "generate"] -> api.generate(req)

    _ -> wisp.not_found()
  }
}

fn middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Request) -> Response,
) -> Response {
  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  use <- wisp.serve_static(req, under: "/static", from: ctx.static_path)

  let user_id = case wisp.get_cookie(req, auth_cookie_name, wisp.Signed) {
    Ok(cookie) -> cookie
    Error(_) -> wisp.random_string(32)
  }

  wisp.log_debug("user_id: " <> user_id)

  handle_request(req)
  |> add_dev_cors_headers
  |> wisp.set_cookie(req, auth_cookie_name, user_id, wisp.Signed, 60 * 60 * 24)
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
