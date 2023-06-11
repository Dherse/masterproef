#import "../elems/infos.typ": *

= Accessibility in this document

Short overview of accessibility and readability features of this document.

=== Accessibility

This document was designed with accessibility to color blind and visually impaired people in mind. The colors used are generally chosen to have good contrast for color blind individuals, as can be seen #link("https://coolors.co/1e64c8-1e6465-1f1c5c-e0a458-6f006f")[here]. Most colored elements are accompanied by an icon, generally from the unicode standard to make it screen reader friendly. Additionally, all images have alternate text descriptions.

=== Navigation

All elements and references are clickable for ease of navigation in the document. Additionally, all figures, table, glossary entries, and references are clickable and will take you to the appropriate section. External links, those being links that lead to a website,  are highlighted in blue and underlined.

=== Info boxes

For improved readability and breaking up of the monotony of the text, this document uses info boxes. These boxes are used to highlight important information, such as definitions, remarks, conclusion and important hypotheses. Below you will find a full list of the different types of info boxes used in this document.

#info-box(kind: "definition", footer: [ Definition usually have a source in the footer ])[
    This is a *definition*, the word or phrase in bold is the term being defined. They are generally Adapted from the literature and are used for important elements that are not common knowledge for photonic engineers.
]

#info-box(kind: "info")[
    This is an info box, it contains information that is tangential or useful for the understanding of the document, but not essential.
]

#info-box(kind: "question", footer: [ The footer contains a link to where the question is answered. ])[
    This is a question box, it contains an important research question or hypothesis that is being investigated in the document.
]

#info-box(kind: "conclusion")[
    This is a conclusion or summary box, it contains a summary with key information that are needed for subsequent sections. Additionally, this is where answers to questions and hypothesis are given.
]