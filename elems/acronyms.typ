#import "./template.typ": todo, section

#let glossary_entries = state("glossary_entries", (:))

#let query_labels_with_key(loc, key, before: false) = {
    if before {
        query(selector(label("glossary:" + key)).before(loc, inclusive: false), loc)
    } else {
        query(selector(label("glossary:" + key)), loc)
    }
}

#let gloss(key, suffix: none, short: auto, long: auto) = {
    locate(loc => {
        let glossary_entries = glossary_entries.final(loc);
        if key in glossary_entries {
            let entry = glossary_entries.at(key)

            let gloss = query_labels_with_key(loc, key, before: true)

            let in_preface(l) = section.at(l) == "preface";
            let is_first_in_preface = gloss.map((x) => x.location()).find((x) => in_preface(x)) == none;
            let is_first = gloss.map((x) => x.location()).find((x) => not in_preface(x)) == none;

            let long = if ((in_preface(loc) and is_first_in_preface)) or long == true {
                [ (#emph(entry.long))]
            } else if (not in_preface(loc) and (is_first and short != true)) or long == true {
                [ (#emph(entry.long))]
            } else {
                none
            }

            [
              #link(label(entry.key))[#entry.short#suffix#long]
              #label("glossary:" + entry.key)
            ]
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
            x.insert(entry.key, (key: entry.key, short: entry.short, long: entry.long))
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
                query_labels_with_key(loc, entry.key)
                    .map((x) => x.location())
                    .sorted(key: (x) => x.page())
                    .fold((values: (), pages: ()), ((values, pages), x) => if pages.contains(x.page()) {
                        (values: values, pages: pages)
                    } else {
                        values.push(x)
                        pages.push(x.page())
                        (values: values, pages: pages)
                    })
                    .values
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
        if r.element != none and r.element.func() == heading and r.element.level == 99 {
            gloss(str(r.target), suffix: r.citation.supplement)
        } else {
            r
        }
    }

    body
};