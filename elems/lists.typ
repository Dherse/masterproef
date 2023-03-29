#let picture_counter = counter("pictures")
#let picture(body, cap: "", label: <picture>) = [
    #box(width: 1fr, height: auto, stroke: black.lighten(80%) + 1pt, inset: 12pt, radius: 5pt)[
        #figure(
            body,
            caption: caption(supplement: "Fig.", counter: picture_counter)[#cap],
        )
        #label
    ]
]

#let table_counter = counter("tabular")
#let tabular(body, cap: "", label: <table>) = [
    #figure(
        body,
        caption: caption(supplement: "Table.", counter: table_counter)[#cap],
    )
    #label
]

#let code_counter = counter("code")
#let code(body, cap: "", label: <code>) = {
    let content = ()
    let i = 1
    for item in body.children {
        if item.func() == raw {
            for line in item.text.split("\n") {
                content.push(str(i))
                content.push(raw(line, lang: item.lang))
                i += 1
            }
        }
    }
    [
        #figure(
            box(stroke: 1pt + gray, inset: 0pt, fill: rgb(99%, 99%, 99%), width: 0.8fr)[
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
            ],
            caption: caption(supplement: "Code.", counter: code_counter)[#cap],
        )
        #label
    ]
}

#let list_of(title, selector) = {
    heading(title)

    locate(loc => {
        let figures = query(figure, after:loc)

        for figure in figures {
            let location = figure.location()
            let page = counter(page).at(figure.location())

            if figure.caption.at("supplement").text != selector {
                continue
            }

            [
                #link(figure.location())[
                    #strong[#ref(figure.label)]: #smallcaps(figure.caption.at("content"))
                ]
                #box(width: 1fr, repeat[.])
                #link(figure.location(), [
                    #numbering("1", ..page)
                ])
                #linebreak()
            ]
        }
    })
}

#let list_of_figures(title: "List of figures") = list_of(title, "Fig.")
#let list_of_tables(title: "List of tables") = list_of(title, "Table.")
#let list_of_codes(title: "List of code fragments") = list_of(title, "Code.")