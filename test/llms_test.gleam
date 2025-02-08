import dotenv_gleam

import llms

pub fn main() {
  dotenv_gleam.config()
  llms.main()
}
