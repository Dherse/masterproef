#let code-blocks(body) = {
    let languages = (
        "rust": ("Rust", "\u{fa53}", rgb("#CE412B")),
        "c": ("C", none, rgb("#283593")),
        "python": ("Python", "\u{ed01}", rgb("#FFD43B")),
        "verilog-ams": ("Verilog-AMS", none, rgb(30,100,200)),
        "vhdl": ("VHDL", text(font: "UGent Panno Text")[</>], gray),
        "spice": ("SPICE", none, rgb("#283593")),
        "phos": ("PHÔS", "\u{ed8a}", rgb("#de8f6e")),
        "js": ("Tokens", "\u{ecd7}", rgb("#656255")),
        "typ": ("Bytecode", "\u{f7ff}", rgb("#6f006f")),
        "typc": ("Bytecode", "\u{f7ff}", rgb("#6f006f")),
    )

    show raw.where(block: false): box.with(
        fill: luma(240),
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2pt,
    )

    show raw.where(block: true): it => {
        // Get the info of the language
        let lang = if it.lang == none {
            (it.lang, none, black)
        } else {
            languages.at(it.lang, default: (it.lang, none, black))
        }
        let lang_icon = if lang == none or lang.at(1) == none {
            none
        } else {
            text(
                font: "tabler-icons", 
                fallback: false, 
                weight: "regular", 
                size: 1em,
            )[#lang.at(1)]
        }
        let lang_box = if lang_icon == none { none } else {
            style(styles => {
                let content = [#lang_icon#lang.at(0)]
                let height = measure(content, styles).height
                box(
                    radius: 2pt, 
                    fill: lang.at(2).lighten(60%), 
                    inset: 0.32em,
                    height: height + 0.32em * 2,
                    stroke: 1.5pt + lang.at(2),
                )[#content]
            })
        }

        // Build the content
        let contents = ()
        let lines = it.text.split("\n").enumerate()
        for (i, line) in lines {
            let line = if line == "" { " " } else { line }

            let content = if i == 0 {
                raw(line, lang: it.lang)
            } else {
                raw(line, lang: it.lang)
            }

            contents.push((
                index: str(i + 1),
                content: content,
            ))
        }

        // Compute the width of the largest number, add the gap
        let width_numbers = 10pt + 0.64em

        let border_color = luma(200) + 1.5pt;
        let cell(i, len, body, ..args) = {
            let radius = (:)
            let stroke = (left: border_color, right: border_color)

            if i == 0 {
                radius.insert("top-left", 0.32em)
                radius.insert("top-right", 0.32em)
                stroke.insert("top", border_color)
            }

            if i == len - 1 {
                radius.insert("bottom-left", 0.32em)
                radius.insert("bottom-right", 0.32em)
                stroke.insert("bottom", border_color)
            }

            radius.insert("rest", 0pt)

            rect(
                inset: (left: width_numbers + 0.48em, rest: 0.64em),
                fill: if calc.rem(i, 2) == 0 {
                    luma(240)
                } else {
                    white
                },
                radius: radius,
                stroke: stroke,
                width: 100%,
                ..args
            )[ #body ]
        }
        align(left, stack(
            dir: ttb,
            ..contents.enumerate().map(((i, x)) => {
                cell(i, contents.len())[
                    #if i == 0 {
                        place(
                            top + right,
                            lang_box,
                            dy: -0.42em,
                            dx: 0.24em,
                        )
                    }
                    #set par(justify: false)
                    #place(x.index, dx: -width_numbers)
                    #x.content
                ]
            })
        ))
    }

    body
}