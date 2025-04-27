#import "../common/colors.typ": *
#import "../common/glossary.typ": gloss-init, gloss, glossary
#import "../common/info.typ": uinfo, udefinition, uquestion, uimportant, uconclusion, ugood, unote
#import "../codly/codly.typ": codly-init, codly, codly-offset, codly-range, no-codly

#let ugent-font = "UGent Panno Text"
#let font-size = 11pt

// Formatting function for a UGent figure captions.
#let ugent-caption(it) = {
  // Check if the caption is valid.
  if type(it) != content or it.func() != figure.caption {
    panic("`ugent-caption` must be provided with a `figure.caption`!")
  }
  
  let supplement = context {
    set text(fill: ugent-blue)
    smallcaps[
      *#it.supplement #it.counter.display(it.numbering)*
    ]
  };
  
  let gap = 0.64em
  let cell = grid.cell.with(
    inset: (top: 0.32em, bottom: 0.32em, rest: gap),
    stroke: (left: (paint: ugent-blue, thickness: 1.5pt), rest: none),
  )
  
  grid(
    columns: (5em, 1fr),
    gutter: 0pt,
    rows: (auto),
    cell(stroke: none, align(right)[#supplement]),
    cell(align(left, it.body)),
  )
}

// This is the entry point of the UGent template
#let ugent-template(
  // The title of your thesis: a string
  title: none,
  // The authors of your thesis: an array of strings
  authors: (),
  // The programming languages you want to use.
  languages: (),
  // The body of your thesis.
  body,
) = {
  // Set the properties of the main PDF file.
  set document(author: authors, title: title)
  
  // Set the basic text properties.
  set text(
    font: ugent-font,
    lang: "en",
    size: font-size,
    fallback: true,
    hyphenate: false,
  )
  
  // Set the basic page properties.
  set page(number-align: right, margin: 2.5cm)
  
  // Set the basic paragraph properties.
  set par(leading: 1em, justify: true)
  
  // Additionally styling for list.
  set enum(indent: 0.5cm)
  set list(indent: 0.5cm)
  
  // Global show rules for links:
  //  - Show links to websites in blue
  //  - Underline links to websites
  //  - Show other links as-is
  show link: it => if type(it.dest) == str {
    set text(fill: ugent-blue)
    underline(it)
  } else {
    it
  }
  
  // Setup the styling of the outline entries.
  show outline.entry: it => {
    if it.element.func() != figure {
      return it
    }
    
    let loc = it.element.location()
    if state("section").at(loc) == "annex" {
      let sup = it.element.supplement
      
      // The annex index
      let idx = numbering("A", ..counter(heading).at(loc))
      let numbers = numbering("1", ..it.element.counter.at(loc))
      let body = it.element.caption.body
      [
        #link(loc)[
          #it.element.supplement\u{a0}#idx.#numbers: #body
        ]#box(width: 1fr, it.fill) #it.page()
      ]
    } else {
      it
    }
  }
  
  // Setting code blocks.
  show: codly-init
  codly(languages: languages, smart-indent: true)
  
  show raw.where(block: true): set align(left)
  
  // Style code blocks.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )
  
  show: gloss-init
  
  body
}

// Formatting function for a UGent heading
#let ugent-heading(
  // Whether to include the big number.
  number: true,
  // Whether first level heading should have a big number.
  big: false,
  // The prefix to place before the number
  prefix: none,
  // The postfix to place after the number
  postfix: " ",
  // Whether to underline both the number and the title.
  underline-all: false,
  // The heading. Must be a heading!
  it,
) = {
  // Check if the heading is valid.
  if type(it) != content or it.func() != heading {
    panic("`ugent-heading` must be provided with a `heading`!")
  }
  
  // Get the current level if needed.
  let current-level = if number == true {
    counter(heading).at(it.location())
  } else {
    none
  }
  
  let level = it.level
  let body = it.body
  let num = it.numbering
  
  let title(size, space: none, underlined: false, local-num: true) = {
    // Disable justification locally
    set par(leading: 1em, justify: false)
    // Show a big number for title level headings
    if number and level == 1 and big {
      set text(size: 80pt, font: "Bookman Old Style", weight: "thin", fill: luma(50%))
      numbering(it.numbering, ..current-level) + "."
      linebreak()
    }
    
    // Set the text to be bold, big, and blue
    set text(size: size, weight: "extrabold", font: ugent-font, fill: ugent-blue)
    
    let num = if number and local-num and (not big or level > 1) {
      prefix
      numbering(it.numbering, ..current-level)
      postfix
    }
    
    // Show the heading
    if not underline-all { num } else { none }
    if underlined {
      underline(evade: true, offset: 4pt, {
        if underline-all { num } else { none }
        smallcaps(body)
      })
    } else {
      smallcaps(body)
    }
    
    if space != none {
      v(space)
    }
  }
  
  if level == 1 {
    // Include a pagebreak before the title.
    pagebreak(weak: true)
    block(breakable: false, title(30pt, space: 0.2em, underlined: true))
  } else if level == 2 {
    block(breakable: false, title(22pt, space: 10pt, underlined: true))
  } else if level == 3 {
    block(breakable: false, title(18pt))
  } else if level == 99 {
    block(breakable: false, title(14pt))
  } else {
    box(title(12pt, local-num: false))
  }
}

// This is the entry point of the UGent preface
#let ugent-preface(body) = {
  // Pages in the preface are numbered using roman numerals.
  set page(numbering: "I")
  
  // Titles in the preface are not numbered and are not outlined.
  set heading(numbering: none, outlined: false)
  
  // Show titled without numbering
  show heading: ugent-heading.with(number: false)
  
  // Set that we're in the preface
  state("section").update("preface")
  
  body
}

// Displays all of the outlines in the document.
#let ugent-outlines(
  // Whether to include a table of contents.
  heading: true,
  // Whether to include a list of acronyms.
  acronyms: true,
  // Whether to include a list of figures.
  figures: true,
  // Whether to include a list of tables.
  tables: true,
  // Whether to include a list of equations.
  equations: true,
  // Whether to include a list of listings (code).
  listings: true,
) = {
  if heading {
    outline(title: "Table of contents", indent: auto, depth: 3)
  }
  
  if acronyms {
    glossary()
  }
  
  if figures {
    outline(title: "List of figures", target: figure.where(kind: image))
  }
  
  if tables {
    outline(title: "List of tables", target: figure.where(kind: table))
  }
  
  if equations {
    outline(title: "List of equations", target: figure.where(kind: math.equation))
  }
  
  if listings {
    outline(title: "List of listings", target: figure.where(kind: raw))
  }
}

// Sets up the styling of the main body of your thesis.
#let ugent-body(body) = {
  // Set the pages to show as "# of #" and reset page counter.
  set page(numbering: "1 of 1")
  counter(page).update(1)
  
  // Titles in the preface are not numbered and are not outlined.
  set heading(numbering: "1.1.a", outlined: true)
  
  // Show titled without numbering
  show heading: ugent-heading.with(number: true, big: true)
  
  // Set the basic paragraph properties.
  set par(leading: 1em, justify: true, linebreaks: "optimized")
  
  // Set paragraph spacing.
  set par(spacing: 16pt)
  
  // Number equations.
  set math.equation(numbering: "(1)")
  
  // Set caption styling.
  show figure.caption: ugent-caption
  
  // Make figure breakable.
  show figure: set block(breakable: true)
  
  // Set figure styling: aligned at the center.
  show figure: align.with(center)
  
  // Set that we're in the body
  state("section").update("body")
  
  body
}

// Display the bibliography stylised for UGent.
#let ugent-bibliography(file: "./assets/references.bib", style: "ieee") = {
  show bibliography: it => {
    set heading(outlined: false)
    show heading: it => {
      pagebreak(weak: true)
      set text(size: 30pt, weight: "extrabold", font: ugent-font, fill: ugent-blue)
      underline(smallcaps(it.body), evade: true, offset: 4pt)
      
      v(12pt)
    }
    
    it
  }
  
  bibliography(file, style: style)
}

// Set up the styling of the appendix.
#let ugent-appendix(body) = {
  // Reset the title numbering.
  counter(heading).update(0)
  
  // Number headings using letters.
  set heading(numbering: "A", outlined: false)
  
  // Show titled without numbering.
  show heading: ugent-heading.with(number: true, prefix: "Annex ", postfix: ": ", underline-all: true)
  
  // Set the numbering of the figures.
  set figure(numbering: (x) => {
    let idx = context numbering("A", counter(heading).get().first())
    [#idx.#numbering("1", x)]
  })
  
  // Additional heading styling to update sub-counters.
  show heading: it => {
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)
    
    it
  }
  
  // Set that we're in the annex
  state("section").update("annex")
  
  body
}

/// A figure with a different outline caption and a normal caption.
#let ufigure(outline: none, caption: none, ..args) = {
  if outline == none {
    figure(caption: caption, ..args)
  } else {
    figure(caption: context if state("section").get() == "preface" {
      outline
    } else {
      caption
    }, ..args)
  }
}

#let text_emoji(content, ..args) = text.with(
  font: "tabler-icons",
  fallback: false,
  weight: "regular",
  size: 16pt,
  ..args,
)(content)

#let lightbulb = text_emoji(fill: earth-yellow, size: font-size - 2.7pt)[\u{ea51}]
#let lightning = text_emoji(fill: green, size: font-size - 2.7pt)[\u{ea38}]
#let value = text_emoji(fill: rgb(30, 100, 200), size: font-size - 2.7pt)[\u{f61b}]

#let required = text_emoji(fill: green)[\u{ea5e}]
#let not_needed = text_emoji(fill: red)[\u{eb55}]
#let desired = text_emoji(fill: rgb(30, 100, 200))[\u{f4a5}]

#let required_sml = text_emoji(fill: green, size: font-size - 2.6pt)[\u{ea5e}]
#let not_needed_sml = text_emoji(fill: red, size: font-size - 2.6pt)[\u{eb55}]
#let desired_sml = text_emoji(fill: rgb(30, 100, 200), size: font-size - 2.6pt)[\u{f4a5}]

#let score(score, color: none) = {
  let empty = "\u{ed27}"
  let full = "\u{f671}"
  
  let score = int(calc.round(score))
  
  for _i_ in range(score) {
    text_emoji(full, font: "tabler-icons")
  }
  
  for _i_ in range(5 - score) {
    text_emoji(empty, font: "tabler-icons")
  }
}