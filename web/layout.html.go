package web

import (
	. "maragu.dev/gomponents"
	. "maragu.dev/gomponents/html"
)

func pageLayout(title string, body Node) Node {
	return Doctype(HTML(Lang("en"), Attr("data-theme", "business"),
		Head(
			Meta(Charset("UTF-8")),
			Meta(Name("viewport"), Content("width=device-width, initial-scale=1")),
			Link(Rel("icon"), Type("image/svg+xml"), Href("/static/favicon.svg")),
			TitleEl(Text(title)),
			Link(Rel("stylesheet"), Type("text/css"), Href("/static/main.css")),
			Script(Src("/static/htmx.min.js")),
		),
		Body(Class("min-h-screen bg-base-200"), body),
	))
}
