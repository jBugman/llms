import envoy
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import http/router

pub fn main() {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")

  let assert Ok(_) =
    router.handle_request
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
