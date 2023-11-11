#import "@preview/polylux:0.3.1": *
#import "../common/colors.typ": *

#import utils: polylux-outline, polylux-progress, current-section, register-section

#let ratio = 1.621784511784512
#let text_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))

#let config(callback) = locate(loc => {
  let cfg = state("ugent-theme-config").at(loc)
  callback(cfg, loc)
})

#let ugent-theme(
  authors: none,
  role: none,
  short-authors: none,
  title: none,
  subtitle: none,
  short-title: none,
  date: datetime.today(),
  email: none,
  mobile: none,
  dept: none,
  research-group: none,
  linkedin: none,
  color: ugent-blue,
  text-color: white,
  logo: "ugent/logo_ugent.png",
  second-logo: "ugent/logo_ea.png",
  body,
  handout: false,
  progress-bar: true,
) = {
  // Set the document properties
  set document(
    author: authors,
    date: date,
  )

  // Configure the page
  set page(
    paper: "presentation-16-9",
    numbering: "1",
    margin: 0pt,
    header: none,
    footer: none,
  )

  // Configure the font
  set text(font: "UGent Panno Text")

  // Additional styling of bold text.
  show strong: set text(fill: ugent-blue)

  enable-handout-mode(handout)

  if type(authors) in ("string", "content") {
    authors = (authors,)
  }

  // Save the configuration
  state("ugent-theme-config").update((
    authors: authors,
    short-authors: short-authors,
    role: role,
    title: title,
    subtitle: subtitle,
    short-title: short-title,
    date: date,
    email: email,
    mobile: mobile,
    dept: dept,
    research-group: research-group,
    linkedin: linkedin,
    color: color,
    text-color: text-color,
    logo: logo,
    second-logo: second-logo,
    handout: handout,
    progress-bar: progress-bar,
  ));

  show figure: align.with(center)

  show figure.caption: it => {
    let supplement = [
      #set text(fill: ugent-blue)
      #smallcaps[*#it.supplement #it.counter.display(it.numbering)*]
    ];

    let gap = 0.64em
    let cell = block.with(
      inset: (top: 0.32em, bottom: 0.32em, rest: gap),
      stroke: (
        left: (
          paint: ugent-blue, 
          thickness: 1.5pt,
        ),
        rest: none,
      )
    )

    grid(
      columns: (5em, auto),
      gutter: 0pt,
      rows: (auto),
      cell(height: auto, stroke: none, width: 5em)[
        #align(right)[#supplement]
      ],
      cell(height: auto)[
        #set text(size: 16pt)
        #align(left)[#it.body]
      ],
    )
  }

  /*show figure: it =>  {
    set figure.caption(position: bottom)
    let supplement = [
      #set text(fill: rgb(30,100,200))
      #smallcaps[*#it.supplement #it.counter.display(it.numbering)*]
    ];

    let gap = 0.64em
    let cell = block.with(
      inset: (top: 0.32em, bottom: 0.32em, rest: gap),
      breakable: true,
      stroke: (
        left: (
          paint: rgb(30,100,200), 
          thickness: 1.5pt,
        ),
        rest: none,
      )
    )

    set text(size: 16pt)
    v(-0.64em)
    grid(
      columns: (5em, 1fr),
      rows: (auto),
      cell(height: auto, stroke: none, width: 5em)[
        #align(right)[#supplement]
      ],
      cell(height: auto)[
        #set text(size: 16pt)
        #align(left)[#it.caption]
      ],
    )
  }*/

  body
}

// Create a progress bar at the bottom of every slide
#let progress-bar(loc) = place(bottom + left, {
  polylux-progress(ratio => {
    box(width: ratio * 100%, height: 2pt, fill: ugent-blue)
  })
})

#let corporate-logo() = {
  let content = config((cfg, _) => {
    if cfg.logo == none {
      panic("No logo provided")
    }

    align(center + horizon, image(cfg.logo))
  })

  pagebreak(weak: true)
  polylux-slide(content)
}

#let title-slide() = {
  let content = config((cfg, loc) => {
    let box_size = (width: 45.63cm / ratio, height: 18.07cm / ratio)
    let box_inset = (dx: 2.54cm / ratio, dy: 3.87cm / ratio)
    let text_box_inset = (dx: 3.59cm / ratio - box_inset.dx, dy: 6.53cm / ratio - box_inset.dy)
    let text_box_size = (width: 42.18cm / ratio, height: 12.32cm / ratio)
    let subtitle_inset = (dx: 3.59cm / ratio - box_inset.dx, dy: 19.1cm / ratio - box_inset.dy)
    let subtitle_size = (width: 42.18cm / ratio, height: 1.62cm / ratio)

    let body = place(top + left, box({
      set text(size: 60pt, fill: cfg.text-color)
      show text: smallcaps

      underline(cfg.title)
    }, ..text_box_size, ..text_inset), ..text_box_inset)

    let subtitle = place(top + left, box({
      align(horizon, {
        set text(size: 20pt, fill: ugent-accent1)
        show par:  set block(spacing: 10pt)
        cfg.subtitle
      })
    }, ..subtitle_size), ..subtitle_inset)

    if "dept" in cfg or "research-group" in cfg {
      let dept_size = (width: 23.04cm / ratio, height: 1.5cm / ratio)
      let dept_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
      let dept_offset = (dx: 23.84cm / ratio, dy: 1.1cm / ratio)
      place(top + left, box({
        align(horizon, {
          set text(size: 14pt, fill: ugent-blue)
          show par: set block(spacing: 5pt)
          
          if "dept" in cfg {
            smallcaps[*#cfg.dept*]

            if "research-group" in cfg {
              parbreak()
            }
          }

          if "research-group" in cfg {
            smallcaps[#cfg.research-group]
          }
        })
      }, ..dept_size, ..dept_inset), ..dept_offset)
    }

    place(bottom + left, image(cfg.logo, width: 6.41cm / ratio))
    place(top + left, box(fill: cfg.color, body + subtitle, ..box_size), ..box_inset)
    if cfg.second-logo != none {
      place(top + left, image(cfg.second-logo, height: 3.87cm / ratio))
    }

    if cfg.progress-bar {
      progress-bar(loc)
    }
  })

  pagebreak(weak: true)
  polylux-slide(content)
}

#let end-slide() = {
  let content = config((cfg, loc) => {
    set text(font: "UGent Panno Text", fill: cfg.text-color)
    let icon(icon) = text(font: "tabler-icons", size: 24pt, baseline: -4pt, fill: cfg.text-color, icon)
    let added-content = ()
    if "linkedin" in cfg and cfg.linkedin != none {
      added-content.push(icon("\u{ec8c}"))
      added-content.push(link(cfg.linkedin, [ #cfg.authors.at(0) ]))
    }

    let social = {
      set text(size: 24pt)
      table(
        columns: 2,
        stroke: none,
        column-gutter: 0pt,
        inset: 0.2em,
        icon("\u{ec1a}"),
        link("https://www.facebook.com/ugent/", [ Universiteit Gent ]),
        icon("\u{ec27}"),
        link("https://twitter.com/ugent", [ \@ugent ]),
        icon("\u{ec20}"),
        link("https://www.instagram.com/ugent/", [ \@ugent ]),
        icon("\u{ec8c}"),
        link("https://www.linkedin.com/school/ghent-university/", [ Ghent University ]),
        ..added-content,
      )
    }

    let body = {
      set text(size: 24pt, fill: cfg.text-color)
      show par: set block(spacing: 12pt)

      let content = ()
      if "email" in cfg and cfg.email != none {
        content.push(text(size: 25pt, "E"))
        content.push(link(
          "mailto:" + cfg.email,
          text(size: 25pt, cfg.email)
        ))
      }

      if "phone" in cfg and cfg.phone != none {
        content.push(text(size: 25pt, "T"))
        content.push(text(size: 25pt, cfg.phone))
      }
      
      if "mobile" in cfg and cfg.mobile != none {
        content.push(text(size: 25pt, "M"))
        content.push(text(size: 25pt, cfg.mobile))
      }
      
      text(size: 35pt, cfg.authors.join(", "))
      linebreak()
      text(size: 25pt, cfg.role)
      linebreak()
      linebreak()
      smallcaps(text(size: 25pt, cfg.research-group))
      linebreak()
      linebreak()
      table(
        columns: (1cm, auto),
        stroke: none,
        inset: 0pt,
        row-gutter: 0.5em,
        align: left,
        ..content
      )
      align(
        bottom + left,
        link("https://ugent.be", text(size: 25pt, "www.ugent.be"))
      )
    }
    
    let box_size = (width: 45.63cm / ratio, height: 18.07cm / ratio)
    let box_offset = (dx: 2.54cm / ratio, dy: 3.87cm / ratio)
    let icon_box_size = (width: 20.16cm / ratio, height: 10cm / ratio)
    let icon_box_offset = (dx: 24.1cm / ratio, dy: 8.6cm / ratio)
    let icon_box_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
    let body_box_size = (width: 20.6cm / ratio, height: 16.03cm / ratio)
    let body_box_offset = (dx: 3.59cm / ratio, dy: 4.84cm / ratio)
    let body_box_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
    if cfg.logo != none {
      place(bottom + left, image(cfg.logo, width: 6.41cm / ratio))
    }
    place(top + left, box(fill: cfg.color, ..box_size), ..box_offset)
    place(top + left, box(fill: cfg.color, social, ..icon_box_size, ..icon_box_inset), ..icon_box_offset)
    place(top + left, box(fill: cfg.color, body, ..body_box_size, ..body_box_inset), ..body_box_offset)

    if cfg.second-logo != none {
      place(top + left, image(cfg.second-logo, height: 3.87cm / ratio))
    }
    
    if cfg.progress-bar {
      progress-bar(loc)
    }
  })

  pagebreak(weak: true)
  polylux-slide(content)
}

#let section-slide(title) = {
  register-section(title)
  let content = config((cfg, loc) => {
    let box_size = (width: 45.63cm / ratio, height: 21.94cm / ratio)
    let box_inset = (dx: 2.54cm / ratio, dy: 0cm)
    let text_box_inset = (dx: 3.59cm / ratio - box_inset.dx, dy: 9.02cm / ratio - box_inset.dy)
    let text_box_size = (width: 42.18cm / ratio, height: 12.32cm / ratio)
    let text_inset = (inset: (x: text_inset.inset.x, y: 15pt))

    let body = place(top + left, box({
      set text(size: 100pt, fill: cfg.text-color)
      show text: smallcaps
      show text: underline

      align(bottom + left, title)
    }, ..text_box_size, ..text_inset), ..text_box_inset)

    place(top + left, box(fill: cfg.color, body, ..box_size), ..box_inset)
    if cfg.logo != none {
      place(bottom + left, image(cfg.logo, width: 6.41cm / ratio))
    }

    if cfg.progress-bar {
      progress-bar(loc)
    }
  })

  pagebreak(weak: true)
  polylux-slide(content)
}

#let body-slide(box-size, box-inset, ..bodies) = {
  let named = bodies.named()
  let bodies = bodies.pos()
  if bodies == none {
      panic("No bodies provided")
  } else if bodies.len() == 1 {
      bodies.first()
  } else {
    let colwidths = none
    let thisgutter = 5pt

    if "colwidths" in named {
      colwidths = named.colwidths
      if colwidths.len() != bodies.len(){
        panic("Provided colwidths must be of same length as bodies")
      }
    } else {
      colwidths = (1fr,) * bodies.len()
    }

    if "gutter" in named {
      thisgutter = named.gutter
    }

    grid(
      columns: colwidths,
      gutter: thisgutter,
      ..bodies
        .enumerate()
        .map(((i, body)) => body)
    )
  }
}

#let content-image-slide(box-size, box-inset, ..bodies) = {
  if bodies == none {
    panic("missing bodies")
  }

  let bodies = bodies.pos()
  if bodies.len() != 2 {
    panic("content,image must have exactly two bodies, found: " + str(bodies.len()))
  }

  let (content, image) = bodies

  let content_size = (width: 23.45cm / ratio, height: 18.6cm / ratio)
  let content_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
  let image_size = (width: 17.5cm / ratio, height: 18.05cm / ratio)
  stack(
    dir: ltr,
    spacing: 2.3cm / ratio,
    box(..content_size, ..content_inset, content),
    box(..image_size, clip: true, image)
  )
}

#let image-slide(..args) = {
  let named = args.named()
  let bodies = args.pos()
  if bodies == none {
    panic("missing bodies")
  }

  if bodies.len() != 2 {
    panic("content,image must have exactly two bodies")
  }

  let (content, picture) = bodies
  let content_size = (width: 21.54cm / ratio, height: 19.19cm / ratio)
  let content_offset = (dx: 2.54cm / ratio, dy: 2.81cm / ratio)
  let content_inset = (inset: (x: 0.25cm / ratio, y: 0.3em))
  let content_bg = rgb("#E9F0FA")
  let image_size = (width: 45.62cm / ratio, height: 22cm / ratio - 0.5pt)
  let image_offset = (dx: 2.54cm / ratio + 1pt, dy: 0cm / ratio)

  let content = config((cfg, loc) => {
    place(top + left, box(fill: ugent-blue, ..image_size, clip: true, picture), ..image_offset)
    place(top + left, box(fill: content_bg, ..content_size, ..content_inset, {
      set text(size: 24pt, fill: ugent-blue)
      content
    }), ..content_offset)

    place(bottom + left, image(cfg.logo, width: 6.41cm / ratio))

    if "footer" in named {
      let footer_size = (width: 22.21cm / ratio, height: 1.22cm / ratio)
      let footer_offset = (dx: 18.92cm / ratio, dy: 24.99cm / ratio)
      let footer_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
      place(top + left, ..footer_offset, box(..footer_size, ..footer_inset, {
        set text(size: 17.1pt, fill: ugent-accent2, font: "UGent Panno Text")
        show: align.with(center + horizon)
        named.footer
      }))
    }

    // Show the slide number in the bottom right corner
    {
      set text(fill: ugent-blue, size: 17.1pt)
      let numbering = current-section
      let offset = (dx: 43.31cm / ratio, dy: 24.86cm / ratio)
      let box_size = (width: 1.4 * 2.56cm / ratio, height: 1.44cm / ratio)

      place(top + left, ..offset, box(..box_size, align(horizon + right, numbering)))
    }

    if cfg.progress-bar {
      progress-bar(loc)
    }
  })

  polylux-slide(content)
}

#let slide(kind: "slide", ..bodies) = {
  let named = bodies.named()
  let content = {
    set text(font: "UGent Panno Text", size: 22pt)

    let box_size = (height: 18.6cm / ratio, width: 43.61cm / ratio)
    let box_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))

    let body = if kind == "slide" {
      body-slide(box_size, box_inset, ..bodies)
    } else if kind == "content,image" {
      content-image-slide(box_size, box_inset, ..bodies)
    } else if kind == "image" {
      align(center + horizon, body-slide(box_size, box_inset, ..bodies))
    } else if kind == "outline" {
      body-slide(box_size, box_inset, ..bodies)
    } else {
      panic("Unknown kind: " + kind)
    }

    config((cfg, loc) => {
      let elems = ()

      // If we have a title, append it to the list of elements
      if "title" in named {
        let text_box_size = (width: 43.63cm / ratio)
        let text_inset = (inset: (x: text_inset.inset.x, y: 10pt))
        elems.push(
          box(..text_box_size, ..text_inset, {
            set text(size: 50pt, weight: "light", fill: ugent-blue)
            show text: smallcaps
            show text: underline

            align(horizon + left, named.title)
          })
        )
      }
      elems.push(box(..box_size, ..box_inset, body))

      place(
        top + left,
        dx: 2.54cm / ratio, 
        dy: 0.7cm / ratio,
        stack(
          dir: ttb,
          spacing: 0.75cm / ratio,
          ..elems
        )
      )

      if cfg.logo != none {
        place(bottom + left, image(cfg.logo, width: 6.41cm / ratio))
      }

      if "footer" in named {
        let footer_size = (width: 22.21cm / ratio, height: 1.22cm / ratio)
        let footer_offset = (dx: 18.92cm / ratio, dy: 24.99cm / ratio)
        let footer_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
        place(top + left, ..footer_offset, box(..footer_size, ..footer_inset, {
          set text(size: 17.1pt, fill: ugent-accent2)
          show: align.with(center + horizon)
          named.footer
        }))
      }

      if "date" in named {
        let date_size = (width: 6.38cm / ratio, height: 1.22cm / ratio)
        let date_offset = (dx: 11.31cm / ratio, dy: 24.99cm / ratio)
        let date_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
        place(top + left, ..date_offset, box(..date_size, ..date_inset, {
          set text(size: 17.1pt, fill: ugent-accent2)
          show text: set align(left + horizon)
          named.date
        }))
      }

      // Show the slide number in the bottom right corner
      {
        set text(fill: ugent-blue, size: 17.1pt)
        let numbering = current-section
        let offset = (dx: 43.31cm / ratio, dy: 24.86cm / ratio)
        let box_size = (width: 1.4 * 2.56cm / ratio, height: 1.44cm / ratio)

        place(top + left, ..offset, box(..box_size, align(horizon + right, numbering)))
      }

      if cfg.progress-bar {
        progress-bar(loc)
      }
    })
  }

  pagebreak(weak: true)
  polylux-slide(content)
}

#let outline-slide() = slide(kind: "outline", title: "Outline", polylux-outline())