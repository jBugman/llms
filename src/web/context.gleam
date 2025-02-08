import gleam/erlang/process.{type Subject}
import gleam/option.{type Option}

import web/auth.{type SessionID}

pub type Context {
  Context(
    static_path: String,
    session_id: Option(SessionID),
    sse: Option(Subject(SSE)),
  )
}

pub type SSE {
  GenerationDone(response: String)
}
