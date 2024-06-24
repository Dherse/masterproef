#let entries = {
  let acronyms = yaml("/glossary.yml")
  // Initializing the glossary.
  let entries = (:)
  for (key, value) in acronyms {
    if not "short" in value or not "long" in value {
      panic("Acronym must have a short and long form, for key: " + str(key))
    }

    entries.insert(
      key,
      (
        key: key,
        short: eval(mode: "markup", value.short),
        long: eval(mode: "markup", value.long)
      )
    )
  }

  entries
}

#let __query_labels_with_key(key, before: false) = {
  if before {
    query(selector(label("glossary:" + key))
      .before(here(), inclusive: false))
  } else {
    query(label("glossary:" + key))
  }
}
  
#let gloss(key, suffix: none, short: auto, long: auto) = {
  if not key in entries {
    panic("Glossary key not found: " + key);
  }

  let entry = entries.at(key)
  let long = context {
    let gloss = __query_labels_with_key(key, before: true)
    let in_preface(loc) = state("section").at(loc) == "preface";

    // Find whether this is the first glossary entry.
    let is_long = if long == auto {
      if state("section").get() == "preface" {
        false
      } else {
        gloss.map((x) => x.location()).find((x) => not in_preface(x)) == none
      }
    } else {
      long
    }

    if is_long {
      " (" + emph(entry.long) + ")"
    } else {
      none
    }
  }

  [
    #link(label(entry.key))[#entry.short#suffix#long]
    #label("glossary:" + entry.key)
  ]
}

#let glossary(title: "Glossary") = {
  [
    #heading(title) <glossary>
  ]
  let elems = ();
  for entry in entries.values().sorted(key: (x) => x.key) {
    elems.push([
      #heading(smallcaps(entry.short), level: 99, numbering: "1.")
      #label(entry.key)
    ])

    elems.push({
      emph(entry.long)
      box(width: 1fr, repeat[.])
      context {
        __query_labels_with_key(entry.key)
          .map((x) => x.location())
          .dedup(key: (x) => x.page())
          .sorted(key: (x) => x.page())
          .map((x) => link(x, numbering(x.page-numbering(), ..counter(page).at(x))))
          .join(", ")
      }
    })
  }

  table(
    columns: (auto, 1fr),
    inset: 5pt,
    stroke: none,
    fill: (_, row) => if calc.odd(row) {
      luma(240)
    } else {
      white
    },
    align: horizon,
    ..elems
  )
}

#let gloss-init(body) = {
  show ref: r => if r.element != none and r.element.func() == heading and r.element.level == 99 {
    gloss(str(r.target), suffix: r.citation.supplement)
  } else {
    r
  }

  body
}