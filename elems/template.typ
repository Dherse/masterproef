#set page(paper: "a4")

#import "tablex.typ": *
#import "colors.typ": *

#let mode = "print"

#let font_size = 11pt
#let section = state("section", "preface")

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
#let project(title: "", authors: (), body) = {
    // Set the document's basic properties.
    set document(author: authors, title: title)
    set text(
        font: "UGent Panno Text",
        lang: "en",
        size: font_size,
        fallback: false,
        hyphenate: false,
    )
    set page(
        number-align: right,
        margin: 2.5cm,
    )

    // Main body.
    set par(leading: 1em, justify: true)

    body
}

#let preface(body) = {
    set page(numbering: "I")
    set heading(numbering: none, outlined: false)

    show link: it => {
        if type(it.dest) == "string" {
            set text(fill: ugent-blue)
            {
                show: underline.with()
                it
            }

            if mode != "print" {
                text(" \u{1F30D}", font: "Segoe UI Emoji", size: 8pt)
            }
        } else {
            it
        }
    }

    show heading: it => {
        if it.level == 1 {
            pagebreak(weak: true)
            block[
                #set text(size: 30pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #set par(leading: 0.4em, justify: false)
                #underline(smallcaps(it.body), evade: true, offset: 4pt)
                #v(0.2em)
            ]
        } else if it.level == 2 {
            block[
                #set text(size: 22pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #underline(smallcaps(it.body), evade: true, offset: 3pt)

                #v(10pt)
            ]
        } else if it.level == 3 {
            block[
                #set text(size: 18pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #smallcaps(it.body)
            ]
        } else {
            block[
                #set text(size: 14pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #smallcaps(it.body)
            ]
        }
    }
    body
}

#let content(body) = {
    set heading(numbering: "1.1.a", outlined: true)
    set cite(brackets: true, style: "numerical")
    set par(linebreaks: "optimized", justify: true)
    set enum(indent: 0.5cm)
    set list(indent: 0.5cm)
    show par: set block(spacing: 16pt)
    section.update("body")

    show link: it => {
        if type(it.dest) == "string" {
            set text(fill: ugent-blue)
            show: underline.with()
            it
        } else {
            it
        }
    }

    show heading: it => {
        let levels = counter(heading).at(it.location())
        if it.level == 1 {
            if levels.at(0) != 1 {
                pagebreak(weak: true)
            }
            block(breakable: false)[
                #set text(size: 80pt, font: "Bookman Old Style", weight: "thin", fill: rgb(50%, 50%, 50%))
                #numbering("1.", ..levels)
                
                #set text(size: 28pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #underline(smallcaps(it.body), evade: true, offset: 4pt)

                #v(10pt)
            ]
        } else if it.level == 2 {
            block(breakable: false)[
                #set text(size: 22pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #numbering("1.1", ..levels) #underline(smallcaps(it.body), evade: true, offset: 3pt)

                #v(10pt)
            ]
        } else if it.level == 3 {
            block(breakable: false)[
                #set text(size: 18pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #numbering("1.1.a", ..levels) #smallcaps(it.body)
            ]
        } else {
            block(breakable: false)[
                #set text(size: 14pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #smallcaps(it.body)
            ]
        }
    }

    show figure: it =>  {
        let supplement = [
            #set text(fill: rgb(30,100,200))
            #smallcaps[*#it.supplement #it.counter.display(it.numbering)*]
        ];

        let gap = 0.64em
        let cell = block.with(
            inset: (top: 0.32em, bottom: 0.32em, rest: gap),
            breakable: true,
            stroke: (
                left: (
                    paint: rgb(30,100,200), 
                    thickness: 0.8pt,
                ),
                rest: none,
            )
        )

        align(center)[
            #it.body
        ]
        v(-0.64em)
        grid(
            columns: (58pt, 1fr),
            rows: (auto),
            cell(height: auto, stroke: none, width: 58pt)[#align(right)[#supplement]],
            cell(height: auto)[#align(left)[#it.caption]],
        )
    }

    let languages = (
        "rust": ("Rust", "\u{fa53}", rgb("#CE412B")),
        "c": ("C", none, rgb("#283593")),
        "python": ("Python", "\u{ed01}", rgb("#FFD43B")),
        "verilog-ams": ("Verilog-AMS", none, rgb(30,100,200)),
        "vhdl": ("VHDL", text(font: "UGent Panno Text")[</>], gray),
        "spice": ("SPICE", none, rgb("#283593")),
        "phos": (ref(label("phos")), "\u{ed8a}", rgb("#de8f6e")),
        "js": ("Tokens", "\u{ecd7}", rgb("#656255")),
        "typ": (ref(label("bc")), "\u{f7ff}", rgb("#6f006f")),
        "typc": (ref(label("bc")), "\u{f7ff}", rgb("#6f006f")),
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
                size: 8pt,
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
                    stroke: 0.25pt + lang.at(2),
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

        let border_color = luma(200) + 0.05em;
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

        align(left)[
            #block(height: auto, breakable: true)[
                #stack(
                    dir: ttb,
                    ..contents.enumerate().map(i => {
                        let (i, x) = i
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
                )
            ]
        ]
    }

    set page(numbering: "1 of 1")
    counter(page).update(1)

    body
}

#let todo(body) = {
    text(fill: red, body)
}

#let figurex(title: auto, caption: none, breakable: true, ..arg) = {
    let caption = locate(loc => {
        if section.at(loc) == "preface" {
            if title == auto {
                caption
            } else {
                title
            }
        } else {
            caption
        }
    })
    
    figure(caption: caption,..arg)
}

#let text_emoji(content, ..args) = text.with(font: "tabler-icons", fallback: false, weight: "regular", size: 16pt, ..args)(content)

#let lightbulb = text_emoji(fill: earth-yellow, size: font_size - 2.7pt)[\u{ea51}]
#let lightning = text_emoji(fill: green, size: font_size - 2.7pt)[\u{ea38}]
#let value = text_emoji(fill: rgb(30,100,200), size: font_size - 2.7pt)[\u{f61b}]

#let required = text_emoji(fill: green)[\u{ea5e}]
#let not_needed = text_emoji(fill: red)[\u{eb55}]
#let desired = text_emoji(fill: rgb(30,100,200))[\u{f4a5}]

#let required_sml = text_emoji(fill: green, size: font_size - 2.6pt)[\u{ea5e}]
#let not_needed_sml = text_emoji(fill: red, size: font_size - 2.6pt)[\u{eb55}]
#let desired_sml = text_emoji(fill: rgb(30,100,200), size: font_size - 2.6pt)[\u{f4a5}]

#let blank-page() = page(numbering: none)[
    #align(center + horizon)[
        #text(fill: gray, size: 14pt)[This page is intentionally left blank.]
    ]
]

#let score(score, color: none) = {
    let empty = "\u{ed27}"
    let full  = "\u{f671}"

    let score = int(calc.round(score))

    for _i_ in range(score) {
        text_emoji(full, font: "tabler-icons")
    }

    for _i_ in range(5 - score) {
        text_emoji(empty, font: "tabler-icons")
    }
}


#let annex(body) = {
    counter(heading).update(0)
    set heading(numbering: "A", outlined: false)

    show heading: it => {
        if it.level == 1 {
            pagebreak(weak: true)
            block[
                #set text(size: 30pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #set par(leading: 0.4em, justify: false)
                #underline(smallcaps[Annex #counter(heading).display(it.numbering): #it.body], evade: true, offset: 4pt)
                #v(0.2em)
            ]
        } else if it.level == 2 {
            block[
                #set text(size: 22pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #underline(smallcaps(it.body), evade: true, offset: 3pt)

                #v(10pt)
            ]
        }
    }
    body
}