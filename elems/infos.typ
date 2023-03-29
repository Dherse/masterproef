#let info_settings = (
    info: (
        prefix: none,
        icon: "circle-info",
        fill_color: rgb("#e6f7ff"),
        stroke_color: rgb("#91d5ff"),
    ),
    question: (
        prefix: none,
        icon: "circle-question",
        fill_color: rgb("#8B008B").lighten(90%),
        stroke_color: rgb("#8B008B").darken(20%),
    ),
    important: (
        prefix: none,
        icon: "circle-exclamation",
        fill_color: rgb("#228B22").lighten(90%),
        stroke_color: rgb("#228B22").darken(20%),
    ),
    note: (
        prefix: [ *Remarks:* ],
        icon: "note-sticky",
        fill_color: rgb("#FFD700").lighten(90%),
        stroke_color: rgb("#FFD700").darken(20%),
    ),
);

#let info_stroke(kind: "info") = info_settings.at(kind).stroke_color

#let info_box(body, kind: "info", radius: 5pt) = {
    let settings = info_settings.at(kind);
    box(
        width: 0.8fr,
        fill: settings.fill_color,
        stroke: 1pt + settings.stroke_color,
        radius: radius,
        inset: 0pt,
    )[
        #table(
            columns: (auto, 1fr),
            inset: 8pt,
            stroke: none,
            align: horizon,
            image("../assets/solid/" + settings.icon + ".svg", width: 32pt, height: 32pt),
            [
                #settings.prefix
                #body
            ]
        ) 
    ]
}