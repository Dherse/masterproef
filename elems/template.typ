#import "./lists.typ": *

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
        #set text(size: 30pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
        #set par(leading: 0.4em, justify: false)
        #underline(smallcaps(it.body), evade: true, offset: 4pt)
        #v(0.2em)
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

    show heading: it => locate(loc => {
        let levels = counter(heading).at(loc)
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
        } else {
            block[
                #set text(size: 16pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
                #numbering("1.1.a", ..levels) #smallcaps(it.body)
            ]
        }
    })

    body
}

#let todo(body) = {
    text(fill: red, body)
}