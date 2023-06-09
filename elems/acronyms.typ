#import "./template.typ": todo, section

#let glossary_entries = state("glossary_entries", (:))

#let gloss(key, suffix: none, short: auto, long: auto) = {
    locate(loc => {
        if glossary_entries.at(loc).keys().contains(key) {
            let entry = glossary_entries.at(loc).at(key)

            let in_preface(l) = section.at(l) == "preface";
            let is_first_in_preface = entry.locations.find((x) => in_preface(x)) == none;
            let is_first = entry.locations.find((x) => not in_preface(x)) == none;

            let long = if (in_preface(loc) and is_first_in_preface) or long == true {
                [ (#emph(entry.long))]
            } else if not in_preface(loc) and (is_first and short != true) or long == true {
                [ (#emph(entry.long))]
            } else {
                none
            }

            link(label(entry.key))[#smallcaps[#entry.short#suffix]#long]

            glossary_entries.update((x) => {
                if x.keys().contains(key) and not x.at(key).pages.contains(numbering(loc.page-numbering(), ..counter(page).at(loc))) {
                    x.at(key).pages.push(numbering(loc.page-numbering(), ..counter(page).at(loc)))
                    x.at(key).locations.push(loc)
                }
                x
            })
        } else {
            todo("Glossary entry not found: " + key)
        }
    })
}

#let glossary(title: "Glossary", entries, body) = {
    [
        #heading(title) <glossary>
    ]

    glossary_entries.update((x) => {
        for entry in entries {
            x.insert(entry.key, (key: entry.key, short: entry.short, long: entry.long, locations: (), pages: ()))
        }

        x
    })

    let elems = ();
    for entry in entries.sorted(key: (x) => x.key) {
        elems.push[
            #heading(smallcaps(entry.short), level: 99)
            #label(entry.key)
        ]
        elems.push[
            #emph(entry.long)
            #box(width: 1fr, repeat[.])
            #locate(loc => {
                glossary_entries
                    .final(loc)
                    .at(entry.key)
                    .locations
                    .sorted(key: (x) => x.page())
                    .map((x) => link(x)[#numbering(x.page-numbering(), ..counter(page).at(x))])
                    .join(", ")
            })
        ]
    }

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

    show ref: r => {
        locate(loc => {
            let term = str(r.target)
            let res = query(r.target, loc)

            // If the source exists and is the glossary (heading level 99)
            if res.len() > 0 and res.first().func() == heading and res.first().level == 99 {
                gloss(term, suffix: r.citation.supplement)
            } else {
                r
            }
        })
    }

    body
};