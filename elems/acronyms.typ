#import "./template.typ": todo

#let glossary_entries = state("glossary_entries", (:))
#let gloss_over(key, short, long) = {
    glossary_entries.update((x) => {
        x.insert(
            key,
            (
                key: key,
                short: short,
                long: long,
                loc: none,
                pages: (),
                list: (),
                link: none,
            )
        )
        x
    })
}
#let gloss(key, suffix: none, short: auto, long: auto, format: "1") = {
    locate(loc => {
        if glossary_entries.at(loc).keys().contains(key) {
            let entry = glossary_entries.at(loc).at(key)
            [
                #if entry.link != none [
                    #entry.link
                ] else [
                    #smallcaps[#entry.short#suffix]]#if (entry.pages.len() <= 0 and short != true) or long == true {
                    [ (#emph(entry.long))]
                }]
        } else {
            todo("Glossary entry not found: " + key)
        }
        glossary_entries.update((x) => {
            let page_number = numbering(format, ..counter(page).at(loc))

            if x.keys().contains(key) and not x.at(key).pages.contains(page_number) {
                x.at(key).pages.push(page_number)
                x.at(key).list.push(link(loc)[#page_number])
            }
            x
        })
    })
}

#let list_of_glossary_entries(title: "Glossary") = {
    [
        #heading(title) <glossary>
    ]

    locate(loc => {
        let value = glossary_entries.final(loc)

        let elems = ()
        for glossary in value.pairs() {
            elems.push(smallcaps(glossary.at(1).short))

            let body = [
                #emph(glossary.at(1).long)
                #box(width: 1fr, repeat[.])
                #glossary.at(1).list.join(", ")
            ]
            
            elems.push(body)
        }

        glossary_entries.update((x) => {
            let out = (:)
            for item in x.pairs() {
                let value = item.at(1)
                value.loc = loc
                out.insert(item.at(0), value)
            }

            out
        })

        table(
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
            ..elems
        )
    })
};