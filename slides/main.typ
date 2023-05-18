#import "./slides.typ": *
#import "../elems/infos.typ": *

#let bad = text(fill: red)[#raw("\u{2718}")]
#let ok = text(fill: green)[#raw("\u{2714}")]
#let mid = text(fill: purple)[#raw("\u{270d}")]

#show: slides.with(
    authors: "Sébastien d'Herbais de Thun",
    title: "Progress update"
)

#set text(font: "UGent Panno Text", lang: "en", fallback: true)

#new-section("Overall progress")

#slide(title: "Writing the thesis")[
    #box(height: 300pt)[
        #columns(2)[
            - #mid Introduction:
                - #bad Actual introduction
                - #ok Scientific motivation
            - #mid Programmable photonics:
                - #ok Basics of photonic processor
                - #mid Components
                - #mid Meshes
                - #mid Circuit representation
                - #ok Feedforward approximation
                - #bad Difficulties
            - #bad Programming of photonic processors
            - #bad Translation of intent
            - #bad The PHÔS programming language
            - #bad Example of photonic circuits
            - #bad Simulation
            - #bad Future work
            - #bad Conclusion
        ]
    ]
]

#slide(title: "Design and architecture")[
    #box(height: 300pt)[
        #columns(2)[
            - #ok Language design: grammar & semantics
            - #mid Constraint solver
            - #ok Compiler architecture:
                - #ok Parser (fully implemented)
                - #ok AST (fully implemented)
                - #ok Code formatting (partially implemented)
                - #ok Type checking
                - #mid AST to HIR
                - #mid HIR to MIR
                - #mid MIR to bytecode
                - #mid Bytecode VM
            - #ok Marshalling layer
            - #ok HAL layer generation
            - #ok 
            - #bad Place and route
        ]
    ]
]