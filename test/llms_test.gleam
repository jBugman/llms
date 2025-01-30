import gleam/dynamic/decode
import gleam/json
import gleeunit
import gleeunit/should
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn json_test() {
  let text = simplifile.read("test/test.json")
  should.be_ok(text)
  let assert Ok(json_string) = text

  json.parse(
    from: json_string,
    using: decode.at(
      ["models"],
      decode.list(of: decode.at(["name"], decode.string)),
    ),
  )
  |> should.equal(Ok(["deepseek-r1:32b", "llama3.2:latest"]))
}
