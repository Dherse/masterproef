#import "./elems/template.typ": *
#import "./elems/acronyms.typ": *

#show: project.with(
  title: "PHÔS: A Photonic Hardware Description Language",
  authors: (
    "Sébastien d'Herbais de Thun",
  ),
)

#show: preface.with()

= Acknowledgements
I would like to give my most heartfelt thanks to the best friend one could ever ask for: Thomas Heuschling for his patience,
friendship, guidance and all of the amazing moments we spent throughout our studies. I would also thank Prof. Wim Bogaerts and
Prof. Dirk Stroobandt for their time, patience and trust in applying for an FWO proposal to extend this Master Thesis. And finally,
I would like to thank Alexandre Bourbeillon for his help and advices for the creation of the grammar, parser and compiler of the PHÔS
programming language.

#pagebreak()
= Remark on the master's dissertation and the oral presentation
This master's dissertation is part of an exam. Any comments formulated by the assessment committee during the oral
presentation of the master's dissertation are not included in this text.

#pagebreak()
= Abstract

#lorem(30)

// Table of contents
#pagebreak()
#outline(title: "Table of contents", indent: true)

#pagebreak()
#include "./content/glossary.typ"
#list_of_glossary_entries()

#pagebreak()
#list_of_figures()

#pagebreak()
#list_of_tables()

#pagebreak()
#list_of_codes()

#show: content.with()

#include "./content/0_introduction.typ"

#pagebreak()
#include "./content/1_background.typ"

#pagebreak()
#include "./content/2_ecosystem.typ"

#pagebreak()
#include "./content/3_translation.typ"

#pagebreak()
#include "./content/4_phos.typ"

#pagebreak()
#include "./content/5_examples.typ"

#pagebreak()
#include "./content/6_extending.typ"

#pagebreak()
#include "./content/7_simu.typ"

#pagebreak()
#include "./content/8_conclusion.typ"

#pagebreak()
#show bibliography: it => {
    set heading(outlined: false)
    show heading: it => [
        #set text(size: 30pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
        #underline(smallcaps(it.body), evade: true, offset: 4pt)

        #v(12pt)
    ]

    it
}
#bibliography("references.bib", style: "ieee")