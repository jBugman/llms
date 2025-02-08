import gleam/bit_array
import gleam/crypto
import gleam/http
import gleam/http/cookie
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import wisp

const cookie_name = "llms_session"

const cookie_max_age = 86_400

pub type SessionID {
  SessionID(String)
}

pub fn get_session_id(
  request: Request(c),
  secret_key_base: String,
) -> Option(SessionID) {
  get_cookie(request, secret_key_base)
  |> option.from_result
  |> option.map(SessionID)
  //  {
  //   Ok(value) -> SessionID(value)
  //   Error(_) -> SessionID(wisp.random_string(16))
  // }
}

pub fn set_cookie(
  resp: Response(rd),
  value: String,
  secret_key_base: String,
) -> Response(rd) {
  let attributes =
    cookie.Attributes(
      ..cookie.defaults(http.Https),
      max_age: option.Some(cookie_max_age),
    )
  let value =
    crypto.sign_message(<<value:utf8>>, <<secret_key_base:utf8>>, crypto.Sha512)
  resp
  |> response.set_cookie(cookie_name, value, attributes)
}

pub fn get_cookie(
  request: Request(c),
  secret_key_base: String,
) -> Result(String, Nil) {
  use value <- result.try(
    request
    |> request.get_cookies
    |> list.key_find(cookie_name),
  )
  use value <- result.try(
    crypto.verify_signed_message(value, <<secret_key_base:utf8>>),
  )
  bit_array.to_string(value)
}
