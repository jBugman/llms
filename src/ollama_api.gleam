import gleam/dynamic/decode
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result
import gleam/string
import snag

const base_url = "http://localhost:11434"

pub fn get_tags() -> Result(List(String), _) {
  let assert Ok(req) = request.to(base_url <> "/api/tags")

  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(fn(e) {
      snag.new("failed to make http call: " <> string.inspect(e))
    }),
  )

  use _ <- result.try(case resp.status {
    200 -> Ok(Nil)
    _ -> snag.error("received not ok status")
  })

  json.parse(
    resp.body,
    using: decode.at(
      ["models"],
      decode.list(of: decode.at(["name"], decode.string)),
    ),
  )
  |> result.map_error(fn(e) {
    snag.new("failed parse response: " <> string.inspect(e))
  })
}
