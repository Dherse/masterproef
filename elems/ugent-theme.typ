#import "./slides.typ": *
#import "./colors.typ": *
#import "./code_blocks.typ": *

#let ratio = 1.621784511784512

#let text_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))

#let scale-size-comp(body, box-size, box-inset, styles) = {
    let body-size = measure(body, styles)
    
    if body-size.width > box-size.width - box-inset.inset.x {
        (box-size.width - box-inset.inset.x) / body-size.width
    } else if body-size.height > box-size.height - box-inset.inset.y {
        (box-size.height - box-inset.inset.y) / body-size.height
    } else {
        1.0
    }
}

#let scale-size(body, box-size, box-inset) = /*style(styles => {
    let scale-factor = scale-size-comp(box(width: box-size.width - box-inset.inset.x, body), box-size, box-inset, styles)

    scale(x: scale-factor * 100%, y: scale-factor * 100%, body)
})*/ body

#let ugent-theme(
    color: ugent-blue,
    text-color: white,
    logo: "ugent/logo_ugent.png",
    second-logo: "ugent/logo_ea.png",
) = data => {
    let progress-bar() = place(bottom + left, locate(loc => {
        let top = logical-slide.at(loc).at(0)
        let top_end = logical-slide.final(loc).at(0)
        let progress = top / top_end * 100%

        box(width: progress, height: 2pt, fill: ugent-blue)
    }))

    let first-slide(..) = align(center + horizon, image(logo))
    
    let title-slide(slide-info, bodies) = {
        if bodies.len() != 0 {
            panic("title slide of default theme does not support any bodies")
        }

        set text(font: "UGent Panno Text")

        let box_size = (width: 45.63cm / ratio, height: 18.07cm / ratio)
        let box_inset = (dx: 2.54cm / ratio, dy: 3.87cm / ratio)
        let text_box_inset = (dx: 3.59cm / ratio - box_inset.dx, dy: 6.53cm / ratio - box_inset.dy)
        let text_box_size = (width: 42.18cm / ratio, height: 12.32cm / ratio)
        let subtitle_inset = (dx: 3.59cm / ratio - box_inset.dx, dy: 19.1cm / ratio - box_inset.dy)
        let subtitle_size = (width: 42.18cm / ratio, height: 1.62cm / ratio)

        let body = place(top + left, box({
            set text(size: 60pt, fill: text-color)
            show text: smallcaps

            underline(data.title)
        }, ..text_box_size, ..text_inset), ..text_box_inset)

        let subtitle = place(top + left, box({
            align(horizon, {
                set text(size: 20pt, fill: ugent-accent1)
                show par:  set block(spacing: 10pt)
                data.subtitle
            })
        }, ..subtitle_size), ..subtitle_inset)

        if "dept" in data or "research-group" in data {
            let dept_size = (width: 23.04cm / ratio, height: 1.5cm / ratio)
            let dept_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
            let dept_offset = (dx: 23.84cm / ratio, dy: 1.1cm / ratio)
            place(top + left, box({
                align(horizon, {
                    set text(size: 14pt, fill: ugent-blue)
                    show par: set block(spacing: 5pt)
                    
                    if "dept" in data {
                        smallcaps[*#data.dept*]

                        if "research-group" in data {
                            parbreak()
                        }
                    }

                    if "research-group" in data {
                        smallcaps[#data.research-group]
                    }
                })
            }, ..dept_size, ..dept_inset), ..dept_offset)
        }

        place(bottom + left, image(logo, width: 6.41cm / ratio))
        place(top + left, box(fill: color, body + subtitle, ..box_size), ..box_inset)
        if second-logo != none {
            place(top + left, image(second-logo, height: 3.87cm / ratio))
        }

        progress-bar()
    }

    let end(slide-info, bodies) = {
        set text(font: "UGent Panno Text", fill: text-color)

        let icon(icon) = text(font: "tabler-icons", size: 24pt, baseline: -4pt, fill: text-color, icon)

        let added-content = ()

        if "linkedin" in data {
            added-content.push(icon("\u{ec8c}"))
            added-content.push(link(data.linkedin, [ #data.authors.at(0) ]))
        }

        let social = {
            set text(size: 24pt)
            table(
                columns: 2,
                stroke: none,
                column-gutter: 0cm / ratio,
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
            set text(size: 24pt, fill: text-color)
            show par: set block(spacing: 12pt)

            let content = ()
            if "email" in data {
                content.push(text(size: 25pt, "E"))
                content.push(link(
                    "mailto:" + data.email,
                    text(size: 25pt, data.email)
                ))
            }

            if "phone" in data {
                content.push(text(size: 25pt, "T"))
                content.push(text(size: 25pt, data.phone))
            }
            
            if "mobile" in data {
                content.push(text(size: 25pt, "M"))
                content.push(text(size: 25pt, data.mobile))
            }
            
            text(size: 35pt, data.authors.join(", "))
            linebreak()
            text(size: 25pt, "Student")
            linebreak()
            linebreak()
            smallcaps(text(size: 25pt, "Photonics Research Group"))
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
        place(bottom + left, image(logo, width: 6.41cm / ratio))
        place(top + left, box(fill: color, ..box_size), ..box_offset)
        place(top + left, box(fill: color, social, ..icon_box_size, ..icon_box_inset), ..icon_box_offset)
        place(top + left, box(fill: color, body, ..body_box_size, ..body_box_inset), ..body_box_offset)

        if second-logo != none {
            place(top + left, image(second-logo, height: 3.87cm / ratio))
        }
        
        progress-bar()
    }

    let section-slide(slide-info, bodies) = {
        if bodies.len() != 0 {
            panic("title slide of default theme does not support any bodies")
        }

        set text(font: "UGent Panno Text")

        let box_size = (width: 45.63cm / ratio, height: 21.94cm / ratio)
        let box_inset = (dx: 2.54cm / ratio, dy: 0cm)
        let text_box_inset = (dx: 3.59cm / ratio - box_inset.dx, dy: 9.02cm / ratio - box_inset.dy)
        let text_box_size = (width: 42.18cm / ratio, height: 12.32cm / ratio)
        let text_inset = (inset: (x: text_inset.inset.x, y: 15pt))

        let body = place(top + left, box({
            set text(size: 100pt, fill: text-color)
            show text: smallcaps
            show text: underline

            align(bottom + left, section.display())
        }, ..text_box_size, ..text_inset), ..text_box_inset)

        place(top + left, box(fill: color, body, ..box_size), ..box_inset)
        place(bottom + left, image(logo, width: 6.41cm / ratio))
        progress-bar()
    }

    let body_slide(slide-info, bodies, box-size, box-inset) = {
        if bodies == none {
            panic("No bodies provided")
        } else if bodies.len() == 1 {
            if (not "scale" in slide-info) or slide-info.scale {
	            scale-size(bodies.first(), box-size, box-inset)
            } else {
                bodies.first()
            }
	    } else {
            let colwidths = none
            let thisgutter = 5pt

            if "colwidths" in slide-info {
                colwidths = slide-info.colwidths
                if colwidths.len() != bodies.len(){
                    panic("Provided colwidths must be of same length as bodies")
                }
            } else {
                colwidths = (1fr,) * bodies.len()
            }

            if "gutter" in slide-info {
                thisgutter = slide-info.gutter
            }

            grid(
                columns: colwidths,
                gutter: thisgutter,
                ..bodies
                    .enumerate()
                    .map(((i, body)) => 
                    if (not "scale" in slide-info) or slide-info.scale {
                        scale-size(
                            body,
                            (
                                width: box-size.width / colwidths.len() - (colwidths.len() - 1) * thisgutter, height: box-size.height / (1 + calc.rem(bodies.len(), colwidths.len()))
                            ),
                            box-inset
                        )
                    } else {
                        body
                    })
            )
        }
    }

    let content_image_slide(slide-info, bodies) = {
        if bodies == none {
            panic("missing bodies")
        }

        if bodies.len() != 2 {
            panic("content,image must have exactly two bodies")
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

    let slide(slide-info, bodies, kind: "slide") = {
        set text(font: "UGent Panno Text", size: 22pt)

        let box_size = (height: 18.6cm / ratio, width: 43.61cm / ratio)
        let box_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))

        let body = if kind == "slide" {
            body_slide(slide-info, bodies, box_size, box_inset)
        } else if kind == "content,image" {
            content_image_slide(slide-info, bodies)
        } else if kind == "image" {
            if bodies == none or bodies.len() != 1 {
                panic("image slide must have exactly one body")
            }

            body_slide(slide-info, bodies, box_size, box_inset)
        } else if kind == "end" {
            content_end(slide-info, bodies)
        } else {
            panic("Unknown kind: " + kind)
        }

        let elems = ()

        // If we have a title, append it to the list of elements
        if "title" in slide-info {
            let text_box_size = (width: 43.63cm / ratio)
            let text_inset = (inset: (x: text_inset.inset.x, y: 10pt))
            elems.push(
                box(..text_box_size, ..text_inset, {
                    set text(size: 50pt, weight: "light", fill: ugent-blue)
                    show text: smallcaps
                    show text: underline

                    align(horizon + left, slide-info.title)
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

        place(bottom + left, image(logo, width: 6.41cm / ratio))

        if "footer" in slide-info {
            let footer_size = (width: 22.21cm / ratio, height: 1.22cm / ratio)
            let footer_offset = (dx: 18.92cm / ratio, dy: 24.99cm / ratio)
            let footer_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
            place(top + left, ..footer_offset, box(..footer_size, ..footer_inset, {
                set text(size: 17.1pt, fill: ugent-accent2)
                show text: set align(center + horizon)
                slide-info.footer
            }))
        }

        if "date" in slide-info {
            let date_size = (width: 6.38cm / ratio, height: 1.22cm / ratio)
            let date_offset = (dx: 11.31cm / ratio, dy: 24.99cm / ratio)
            let date_inset = (inset: (x: 0.25cm / ratio, y: 0.13cm / ratio))
            place(top + left, ..date_offset, box(..date_size, ..date_inset, {
                set text(size: 17.1pt, fill: ugent-accent2)
                show text: set align(left + horizon)
                slide-info.date
            }))
        }

        // Show the slide number in the bottom right corner
        {
            set text(fill: ugent-blue, size: 17.1pt)
            let numbering = locate(loc => {
                let top = logical-slide.at(loc)
                numbering("1", top.at(0))
            })
            let offset = (dx: 43.31cm / ratio, dy: 24.86cm / ratio)
            let box_size = (width: 1.4 * 2.56cm / ratio, height: 1.44cm / ratio)

            place(top + left, ..offset, box(..box_size, align(horizon + right, numbering)))
        }

        progress-bar()
    }

    let default = slide.with(kind: "slide")
    let image-content = slide.with(kind: "content,image")
    let image = slide.with(kind: "image")

    (
        "corporate logo": first-slide,
        "title slide": title-slide,
        "section slide": section-slide,
        "image content": image-content,
        "image": image,
        "end": end,
        "default": default,
    )
}