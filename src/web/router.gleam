import gleam/http/request
import gleam/http/response
import gleam/option.{type Option, None, Some}
import mist
import wisp
import wisp/wisp_mist

import web/api
import web/auth
import web/context.{type Context, Context}
import web/pages/chat_page/chat_page
import web/pages/chat_page/sse

const auth_cookie_name = "llms_session"

pub fn handle_request(
  req: request.Request(mist.Connection),
  ctx: Context,
  secret_key_base: String,
) -> response.Response(mist.ResponseData) {
  let session_id = auth.get_session_id(req, secret_key_base)

  // case session_id {
  //   Some(session_id) -> {
  //     let ctx = Context(..ctx, session_id:)
  //     handle_authorized_request(req, ctx, secret_key_base)
  //   }
  //   None -> {
  //     // response.Response()
  //     resp |> auth.set_cookie(ctx.session_id, secret_key_base)
  //   }
  // }
  todo
}

// fn auth_middleware(
//   req: request.Request(mist.Connection),
//   ctx: Context,
//   secret_key_base: String,
// ) -> response.Response(mist.ResponseData) {
//   case request.path_segments(req) {
//     ["login"] -> {
//       todo
//     }
//   }
// }

// fn handle_authorized_request(
//   req: Request,
//   ctx: Context,
//   secret_key_base: String,
// ) -> Response {
//   case request.path_segments(req) {
//     ["sse", "generation"] -> sse.handle_request(req, ctx)
//     _ -> wisp_mist.handler(handle_request_wisp(_, ctx), secret_key_base)(req)
//   }
// }

pub fn handle_request_wisp(req: wisp.Request, ctx: Context) -> wisp.Response {
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
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
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

fn add_dev_cors_headers(resp: wisp.Response) -> wisp.Response {
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
