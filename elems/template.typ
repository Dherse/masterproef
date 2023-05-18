#set page(paper: "a4")

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

    show heading: it => block[
        #if it.level == 1 [
            #set text(size: 30pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
            #set par(leading: 0.4em, justify: false)
            #underline(smallcaps(it.body), evade: true, offset: 4pt)
            #v(0.2em)
        ] else [
            #it.body
        ]
    ]
    body
}

#let content(body) = {
    set page(numbering: "1 of 1")
    set heading(numbering: "1.1.a", outlined: true)
    set cite(brackets: true, style: "numerical")
    set par(linebreaks: "optimized", justify: true)
    show par: set block(spacing: 16pt)
    locate(loc => counter(page).update(1))
    section.update("body")

    show heading: it => {
        let levels = counter(heading).at(it.location())
        if it.level == 1 {
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

    show figure.where(kind: raw): it => {
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

        align(center)[
            #block(
                breakable: false,
            )[
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
            #v(0.64em, weak: true)
            #it.supplement
            #it.counter.display(it.numbering)
            : #it.caption
        ]
    }

    body
}

#let todo(body) = {
    text(fill: red, body)
}