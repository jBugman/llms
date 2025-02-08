import envoy
import filepath
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import web/context
import web/router

pub fn main() {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")
  let assert Ok(static_path) = wisp.priv_directory("llms")
  let static_path = filepath.join(static_path, "/static")

  let make_context = fn() { context.Context(static_path:) }

  let assert Ok(_) =
    router.handle_request(_, make_context)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
