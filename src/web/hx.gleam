import lustre/attribute

pub fn hx(name: String, value: String) {
  attribute.attribute("hx-" <> name, value)
}

pub fn post(path: String) {
  hx("post", path)
}

pub fn target(id: String) {
  hx("target", id)
}

pub fn swap(value: String) {
  hx("swap", value)
}

pub fn indicator(id: String) {
  hx("indicator", id)
}
