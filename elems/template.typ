#set page(paper: "a4")

#import "tablex.typ": *
#import "colors.typ": *

#let font_size = 11pt
#let section = state("section", "preface")


// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
#let project(title: "", authors: (), body) = {
    // Set the document's basic properties.
    set document(author: authors, title: title)
    set text(font: "UGent Panno Text", lang: "en", size: font_size, fallback: false)
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
            // text("\u{1F30D}", font: "Segoe UI Emoji", size: 8pt)

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
    set page(numbering: "1 of 1")
    set heading(numbering: "1.1.a", outlined: true)
    set cite(brackets: true, style: "numerical")
    set par(linebreaks: "optimized", justify: true)
    set enum(indent: 0.5cm)
    set list(indent: 0.5cm)
    show par: set block(spacing: 16pt)
    locate(loc => counter(page).update(1))
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
            pagebreak(weak: true)
            block[
                #set text(size: 48pt, font: "Bookman Old Style", weight: "thin", fill: rgb(50%, 50%, 50%))
                #numbering("1.", ..levels)
                
                #set text(size: 28pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #underline(smallcaps(it.body), evade: true, offset: 4pt)

                #v(10pt)
            ]
        } else if it.level == 2 {
            block[
                #set text(size: 22pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #numbering("1.1", ..levels) #underline(smallcaps(it.body), evade: true, offset: 3pt)

                #v(10pt)
            ]
        } else if it.level == 3 {
            block[
                #set text(size: 18pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #numbering("1.1.a", ..levels) #smallcaps(it.body)
            ]
        } else {
            block[
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

    show figure.where(kind: raw): it => style(styles => {
        let content = ()
        let i = 1
        if it.body.func() == raw {
            if it.body.func() == raw {
                for line in item.text.split("\n") {
                    content.push(str(i))
                    content.push(raw(line, lang: item.lang))
                    i += 1
                }
            }
        } else {
            for item in it.body.children {
                if item.func() == raw {
                    for line in item.text.split("\n") {
                        content.push(str(i))
                        content.push(raw(line, lang: item.lang))
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
            #align(center)[
                #box(stroke: 1pt + gray, inset: 0pt, fill: rgb(99%, 99%, 99%), width: 0.8fr)[
                    #set align(left)
                    #table(
                        columns: (auto, 1fr),
                        inset: 5pt,
                        stroke: none,
                        fill: (_, row) => {
                            if calc.odd(row) {
                                luma(240)
                            } else {
                                white
                            }
                        },
                        align: horizon,
                        ..content
                    )
                ]
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

    body
}

#let todo(body) = {
    text(fill: red, body)
}

#let figurex(title: auto, caption: none, ..arg) = {
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

#let text_emoji(content, ..args) = [
  #text(font: "Inter", fallback: false, weight: "extrabold", size: 14pt, ..args)[#content]
]

#let required = text_emoji(fill: green)[✓]
#let not_needed = text_emoji(fill:  red)[\u{2717}]
#let desired = text_emoji(fill: rgb(30,100,200))[\~]

#let required_sml = text_emoji(fill: green, size: font_size - 2pt)[✓]
#let not_needed_sml = text_emoji(fill: red, size: font_size - 2pt)[\u{2717}]
#let desired_sml = text_emoji(fill: rgb(30,100,200), size: font_size - 2pt)[\~]