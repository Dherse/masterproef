#import "./ugent-template.typ": *

#let code-icon(icon) = text(
  font: "tabler-icons",
  fallback: false,
  weight: "regular",
  size: 8pt,
  icon,
)

// Instantiate the template
#show: ugent-template.with(
  authors: ("Sébastien d'Herbais de Thun",),
  title: "A software language approach for describing and programming photonics hardware",
  languages: (
    rust: (name: "Rust", icon: code-icon("\u{fa53}"), color: rgb("#CE412B")),
    c: (name: "C", icon: none, color: rgb("#283593")),
    python: (name: "Python", icon: code-icon("\u{ed01}"), color: rgb("#FFD43B")),
    verilog-ams: (name: "Verilog-AMS", icon: none, color: rgb(30, 100, 200)),
    vhdl: (name: "VHDL", icon: text(font: "UGent Panno Text")[</>], color: gray),
    spice: (name: "SPICE", icon: none, color: rgb("#283593")),
    phos: (
      name: ref(label("phos")),
      icon: code-icon("\u{ed8a}"),
      color: rgb("#de8f6e"),
    ),
    js: (name: "Tokens", icon: code-icon("\u{ecd7}"), color: rgb("#656255")),
    typ: (
      name: gloss("bc", short: true, long: false),
      icon: code-icon("\u{f7ff}"),
      color: rgb("#6f006f"),
    ),
    typc: (
      name: gloss("bc", short: true, long: false),
      icon: code-icon("\u{f7ff}"),
      color: rgb("#6f006f"),
    ),
  ),
)

#show raw.where(lang: none, block: true): it => context {
  let old = state("codly-numbers-format").get()
  codly(numbers-format: (..) => none)
  it
  codly(numbers-format: old)
}

// Load additional syntax definitions.
#set raw(syntaxes: (
  "./assets/Phos.sublime-syntax",
  "./assets/SystemVerilog.sublime-syntax",
  "./assets/VHDL.sublime-syntax",
))

// Here we include your preface, go and edit it!
#include "./parts/preface.typ"

// Here we now enter the *real* document
#show: ugent-body

// Here we include your chapters, go and edit them!
#include "./parts/0_introduction.typ"
#include "./parts/1_background.typ"
#include "./parts/2_ecosystem.typ"
#include "./parts/3_translation.typ"
#include "./parts/4_phos.typ"
#include "./parts/5_examples.typ"
#include "./parts/6_future_work.typ"
#include "./parts/7_conclusion.typ"

// Here we display the bibliography loaded from `references.bib`
#ugent-bibliography()

// Here begins the appendix, go and edit it!
#include "./parts/appendix.typ"