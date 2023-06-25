#import "./elems/slides.typ": *
#import "./elems/ugent-theme.typ": *
#import "./elems/colors.typ": *
#import "./elems/code_blocks.typ": *

#let date = datetime(year: 2023, month: 06, day: 29).display()

#show: code-blocks

#show: slides.with(
    authors: "Sébastien d'Herbais de Thun",
    short-authors: "S. d'Herbais de Thun",
    title: [ A software language approach for describing and programming photonics hardware ],
    subtitle: [
        Master's thesis defence - Sébastien d'Herbais de Thun - 29th of June 2023
        #linebreak()
        Promoters: Prof. dr. ir. Wim Bogaerts, Prof. dr. ir. Dirk Stroobandt
    ],
    short-title: [ Defence of Master's thesis ],
    date: date,
    email: "sebastien.dherbaisdethun@ugent.be",
    mobile: "+32 (0) 473 12 86 57",
    dept: "Department of Information Technology",
    research-group: "Photonics Research Group",
    theme: ugent-theme(),
    handout: false,
)

#show strong: set text(fill: ugent-blue)

#set figure(numbering: "1")
#show figure: it =>  {
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
  align(center)[
    #it.body
  ]
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
}

// UGent logo
#slide(theme-variant: "corporate logo")

// Global title slide
#slide(theme-variant: "title slide")

#slide(title: "About this presentation")[
  #one-by-one()[
    - Introduction
    - Elevator pitch
    - Programmatic description: an overview
    - Example: 16-QAM modulator
    - Example: Lattice filter
    - Conclusion
    - Future work
  ]
]

#slide(title: "To code, or not to code")[
  - Not everybody is a programmer #show: pause(2); *and that's okay!*
    - Code sections will kept *short*
    - The language is *familiar*
    - Code will be *explained*
    - Code is shown in *boxes*
  #show: pause(3)
  - Code is *non-exhaustive*
  #show: pause(4)
  - Code is *not optimized*
  #show: pause(5)
  - Code is *illustrative*
][
  #show: pause(2)
  ```python
  print('Hello, world!')
  ```
  ```phos
  fn main() {
      print("Hello, world!")
  }
  ```
]

// First section
#new-section("The elevator pitch")
#slide(theme-variant: "section slide")

#slide(title: "Why programming?", colwidths: (50%, 50%))[
  #line-by-line()[
    - Scaling circuits is *really* hard
    - Circuits are *inflexible*
    - Circuits are not *reusable*
    - Circuits are not *expressive*
  ]
  #counter(figure.where(kind: image)).update(0)
  #uncover(4, align(bottom)[
    #figure(caption: [ A lattice filter circuit. ])[
      #image("./figures/drawio/mzi_lattice.png", width: 80%)
    ]
  ])
][
  #line-by-line()[
    - Scaling code is *really* easy
    - Code is *flexible*
    - Code is easily *reusable*
    - Code is *expressive*
  ]
  #counter(figure.where(kind: raw)).update(0)
  #uncover(4, align(bottom)[
    #figure(caption: [ A lattice filter as code. ])[
      ```phos
      filter_kind_coefficients(filter_kind)
        |> fold((a, b), |acc, (coeff, phase)| {
          acc |> coupler(coeff)
              |> constrain(d_phase = phase)
        })   
      ```
    ]
  ])
]

#slide(title: "Levels of abstraction")[
  #line-by-line()[
    - Currently low
    - We want to go higher
    - We want to go *much* higher
    - We need to build abstractions
      #line-by-line(start: 4)[
        - Components (parametric)
        - Signal flow graphs
        - Black boxes
        - ???
      ]
  ]
][
  #counter(figure.where(kind: image)).update(1)
  #figure(caption: [ Levels of abstraction in photonic circuit design. ], kind: image)[
    #image("./figures/drawio/abstractions.png", width: 100%)
  ]
]

#slide(title: "Introducing PHÔS")[
  #line-by-line()[
    - PHÔS is a *domain-specific language*
    - PHÔS describes *photonic circuits*
    - PHÔS is *declarative*
    - PHÔS is *parametric*
    - PHÔS is *expressive*
    - PHÔS is *extensible*
  ]
][
  #line-by-line(start: 5)[
    - PHÔS is the *function* and *system* levels
      - Filter synthesis
      - Signal flow graph generation
      - Component instantiation
      - Reconfigurability & tunability
      - Optimization
    - PHÔS is *not* at the component level	
      - #strike[Component design]
      - #strike[Component simulation]
      - #strike[Component optimization]
  ]
]

#new-section("Programmatic description: an overview")
#slide(theme-variant: "section slide")

#slide(title: "Why a new language?")[
  #line-by-line()[
    - Existing languages *do not* works for photonics
      - Hardware description languages: #strike[VHDL], #strike[MyHDL]
      - High-level synthesis languages: #strike[SystemC]
      - Analog modeling languages: #strike[Verilog-AMS], #strike[SPICE]
      - Traditional programming languages: #strike[Python], #strike[Rust]
    - Libraries are *not expressive* enough
    - Why? *Because photonics is different*
    - We need a *domain-specific language*
  ]
]

#slide(title: "")[

]

#new-section("Examples")
#slide(theme-variant: "section slide")

#new-section("Conclusion")
#slide(theme-variant: "section slide")

#slide(title: "Sources", scale: false)[
  #set text(size: 12pt)
  #bibliography-outline(title: none)
]

#new-section("Thank you for listening")
#slide(theme-variant: "section slide")

#slide(theme-variant: "end")

#hide(bibliography("references.bib", style: "ieee"))