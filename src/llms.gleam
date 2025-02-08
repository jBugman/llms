import envoy
import filepath
import gleam/erlang/process
import gleam/option.{None}
import mist
import wisp

import web/context
import web/router

pub fn main() {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")
  let assert Ok(static_path) = wisp.priv_directory("llms")
  let static_path = filepath.join(static_path, "/static")

  let ctx = context.Context(static_path:, session_id: None, sse: None)

  let assert Ok(_) =
    router.handle_request(_, ctx, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
