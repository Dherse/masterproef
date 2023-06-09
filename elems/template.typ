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
        /*header: [
            #set text(14pt)
            #align(right)[
                #locate(loc => {
                    if section.at(loc) != "preface" {
                        let title = query(heading.where(level: 1).before(loc), loc).last();
                        let levels = counter(heading).at(title.location());
                        smallcaps[#numbering("1.", ..levels) #title.body]
                    }
                })
            ]
        ],*/
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
                #set text(size: 48pt, font: "Bookman Old Style", weight: "thin", fill: rgb(50%, 50%, 50%))
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

    show figure: it => style(styles => {
        let supplement = [
            #set text(fill: rgb(30,100,200))
            #smallcaps[*#it.supplement #it.counter.display(it.numbering)*]
        ];
        let gap = 0.64em
        let width = measure(supplement, styles).width;
        let cell = block.with(
            inset: (top: 0.32em, bottom: 0.32em, rest: gap),
            width: width + 2 * gap,
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
            columns: (width, 1fr),
            rows: (auto),
            gutter: 2 * gap,
            cell(height: auto, stroke: none)[ #supplement ],
            cell(height: auto, width: 100%,)[ #it.caption ],
        )
    })

    let languages = (
        "rust": ("Rust", "\u{fa53}", rgb("#CE412B")),
        "c": ("C", [], rgb("#283593")),
        "python": ("Python", "\u{ed01}", rgb("#FFD43B")),
        "verilog-ams": ("Verilog-AMS", [], rgb(30,100,200)),
        "vhdl": ("VHDL", [</>], gray),
        "spice": ("SPICE", [], rgb("#283593")),
        "ts": (ref(label("phos")), [], rgb("#de8f6e")),
    )
    show figure.where(kind: raw): it => style(styles => {
        let content = ()
        let i = 1
        if it.body.func() == raw {
            for line in item.text.split("\n") {
                content.push(str(i))

                if line == "" {
                    content.push(raw(" ", lang: item.lang))
                } else {
                    content.push(raw(line, lang: item.lang))
                }
                i += 1
            }
        } else {
            for item in it.body.children {
                if item.func() == raw {
                    for line in item.text.split("\n") {
                        if i == 1 {
                            let lang = languages.at(item.lang, default: (item.lang, none, black))
                            
                            let lang_icon = if lang.at(1) == none {
                                none
                            } else {
                                text(
                                    font: "tabler-icons", 
                                    fallback: false, 
                                    weight: "regular", 
                                    size: 8pt,
                                )[#lang.at(1)]
                            }

                            let line = layout(size => {
                                let total_width = size.width
                                let width = measure(box(
                                    radius: 2pt, 
                                    fill: lang.at(2).lighten(60%), 
                                    inset: 0.32em
                                )[
                                    #lang_icon
                                    #lang.at(0)
                                ], styles).width

                                place(dx: total_width - width, dy: -0.32em)[
                                    #box(
                                        radius: 2pt, 
                                        fill: lang.at(2).lighten(60%), 
                                        inset: 0.32em
                                    )[
                                        #lang_icon
                                        #lang.at(0)
                                    ]
                                ]
                                
                                if line == "" {
                                    raw(" ", lang: item.lang)
                                } else {
                                    raw(line, lang: item.lang)
                                }
                            })
                            
                            content.push(line)
                        } else {
                            if line == "" {
                                content.push(raw(" ", lang: item.lang))
                            } else {
                                content.push(raw(line, lang: item.lang))
                            }
                        }
                        i += 1
                    }
                }
            }
        }

        let supplement = [
            #set text(fill: rgb(30,100,200))
            #smallcaps[*#it.supplement #it.counter.display(it.numbering)*]
        ];
        let gap = 0.64em
        let width = measure(supplement, styles).width;
        let cell = rect.with(
            inset: (top: 0.32em, bottom: 0.32em, rest: gap),
            width: width + 2 * gap,
            stroke: (
                left: (
                    paint: rgb(30,100,200), 
                    thickness: 0.8pt,
                ),
                rest: none,
            )
        )

        block(
            breakable: true,
        )[
            #let width_numbers = content
                .enumerate()
                .map((it) => measure(str(it.at(0)), styles).width)
                .fold(0pt, (a, b) => calc.max(a, b)) + 0.64em
            #align(center)[
                #set align(left)
                #let border_color = luma(200) + 0.05em;
                #let cell(i, len, body, ..args) = rect(
                    inset: (left: width_numbers + 0.48em, rest: 0.48em),
                    fill: if calc.rem(i, 2) == 0 {
                        luma(240)
                    } else {
                        white
                    },
                    radius: if i == 0 {
                        (top-left: 0.32em, top-right: 0.32em)
                    } else if i == len - 1 {
                        (bottom-left: 0.32em, bottom-right: 0.32em)
                    } else {
                        0pt
                    },
                    stroke: if i == 0 {
                        (top: border_color, left: border_color, right: border_color)
                    } else if i == len - 1 {
                        (bottom: border_color, left: border_color, right: border_color)
                    } else {
                        (left: border_color, right: border_color)
                    },
                    width: 100%,
                    ..args
                )[#body]
                #stack(
                    dir: ttb,
                    ..content.enumerate().map(x => {
                        let (i, it) = x
                        cell(i, content.len())[
                            #place(dx: -width_numbers)[ #str(i + 1) ]
                            #it
                        ]
                    })
                )
            ]
            
            #v(-0.64em)
            #grid(
                columns: (width, 1fr),
                rows: (auto),
                gutter: 2 * gap,
                cell(height: auto, stroke: none)[ #supplement ],
                cell(height: auto, width: 100%,)[ #it.caption ],
            )
        ]
    })
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