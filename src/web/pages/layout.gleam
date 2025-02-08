import lustre/attribute.{class, href, rel, src, type_} as a
import lustre/element.{type Element}
import lustre/element/html.{head, html, link, meta, script} as h

pub fn page_layout(title: String, body: Element(a)) -> Element(a) {
  html([a.attribute("lang", "en"), a.attribute("data-theme", "business")], [
    head([], [
      meta([a.charset("UTF-8")]),
      meta([
        a.name("viewport"),
        a.content("width=device-width, initial-scale=1.0"),
      ]),
      link([rel("icon"), type_("image/svg+xml"), href("/static/favicon.svg")]),
      h.title([], title),
      link([rel("stylesheet"), type_("text/css"), href("/static/main.css")]),
      script([src("https://unpkg.com/htmx.org@2.0.4")], ""),
    ]),
    h.body([class("min-h-screen bg-base-200")], [body]),
  ])
}
