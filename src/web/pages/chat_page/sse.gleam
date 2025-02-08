import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist

import web/context.{type Context}

pub type SSE {
  GenerationDone(response: String)
}

pub fn handle_request(req: Request(c), ctx: Context) -> Response(rd) {
  todo
  // mist.server_sent_events(req, )
}
