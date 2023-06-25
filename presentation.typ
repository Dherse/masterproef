#import "./elems/slides.typ": *
#import "./elems/ugent-theme.typ": *
#import "./elems/colors.typ": *
#import "./elems/code_blocks.typ": *
#import "./elems/tablex.typ": *

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
    linkedin: "https://www.linkedin.com/in/s%C3%A9bastien-d-herbais-de-thun-069913206/",
    theme: ugent-theme(),
    handout: true,
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
    - Code sections will be kept *short*
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

#slide(title: "Levels of abstraction")[
  #line-by-line()[
    - Currently low
    - We want to go higher
    - We want to go *much* higher
    - We need to build abstractions
      #line-by-line(start: 4)[
        - Components (parametric)
        - Signal flow graphs
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

#slide(title: "Translation of intent")[
    - How do we tell the computer what we want? #uncover(2)[*Programming!*]
    - What do we want the computer to do for us? #uncover(4)[*As much as possible!*]
    - How does the computer do it? #uncover(5)[*Compilation, Evaluation, and Synthesis!*]
]

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

#slide(title: "Yes, but why a new language?")[
  #line-by-line()[
    - Existing languages *do not* works for photonics
      - Hardware description languages: #strike[VHDL], #strike[MyHDL]
      - High-level synthesis languages: #strike[SystemC]
      - Analog modeling languages: #strike[Verilog-AMS], #strike[SPICE]
      - Traditional programming languages: #strike[Python], #strike[Rust]
    - Libraries are *not expressive* enough
    - Why? *Because photonics is different*
      - #strike[Sequential] Continuous
      - #strike[Digital] Analog
    - We need a *domain-specific language*
  ]
]

#slide(title: "What do we want the computer to do for us?")[
  #line-by-line()[
    - *Ideal behaviour*: feedback loops, calibration
    - *Simulation*: simulator, interface with existing ones
    - *Platform independence*: process, foundry, processor architecture
    - *Visualization*: signal flow graphs, circuit diagrams
    - *Reconfigurability*: reconfigurability through branching
    - *Tunability*: implicit tunability
    - *Programmability*: hardware abstraction layer (HAL)
  ]
]

#slide(title: "Reconfigurability and Tunability")[
  ```phos
    syn my_circuit(
      input: optical,
      gain: Gain
    ) -> optical {
      if gain > 0 dB {
        input |> amplifier(gain)
      } else {
        input
      }
    }
  ```
][
  #counter(figure.where(kind: image)).update(1)
  #figure(
    caption: [ Signal flow diagram of `my_circuit`, showing the tunable value impacting reconfigurability. ],
    image("./figures/drawio/circuit_diagram.png", width: 90%)
  )
]

#slide(title: "Tying it all together")[
  #line-by-line()[
    - Express *constraints* on the signals and values
    - Used for *verification* and *optimization*
    - Used to *reduce* reconfigurability space
    - Used to *simulate* the circuit
  ]
][
  #uncover(5,
  ```phos
    syn amplifier(
        @power(max(0 dBm - gain))
        input: optical,

        @max(10 dB)
        gain: Gain,
    ) -> @power(input + gain) optical {
        ...
    }
  ```)
]

#slide(title: "What is a circuit made of?")[
  #line-by-line()[
    - *Filters*
    - *Gain* and *loss* elements
    - *Modulators* and *detectors*
    - *Splitters*, *combiners*, and *couplers*
    - *Switches*
    - *Phase shifters* and *delay lines*
    - *Sources*, *sinks*, and *empty* signal
    - Together, these form the *intrinsic operations*
    - *Circuits* are made of *intrinsic operations*
  ]
][
  #uncover(10, figure(
    caption: [ A lattice filter circuit. ],
    image("./figures/drawio/signal_proc.png", width: 80%),
  ))
]

#slide(title: "Overview")[
  #counter(figure.where(kind: image)).update(2)
  #figure(
    caption: [
      Synthesis stages in PHÔS: compilation, evaluation, and synthesis. Shows each step and the corresponding output. The colours describe the responsibility of maintaining each element.
    ],
    image("./figures/drawio/exec_model.png", width: 100%)
  )
]

#new-section("Examples")
#slide(theme-variant: "section slide")

#slide(title: "16-QAM 400 Gb/s modulator")[
  #counter(figure.where(kind: image)).update(3)
  #figure(
    caption: [
      16-QAM modulator circuit diagram.
    ],
    image("./figures/drawio/qam_mod.png", width: 100%)
  )
]

#slide(title: "16-QAM 400 Gb/s modulator (cont.)")[
  #set text(size: 18pt)
  ```phos
    syn coherent_transmitter(
        input: optical,
        [a, b, c, d]: [electrical; 4],
    ) -> optical {
        input
            |> split((1.0, 1.0, 0.5, 0.5))
            |> zip((a, c, b, d))
            |> modulate(Modulation::Amplitude)
            |> constrain(d_phase = 90°)
            |> merge()
    }
  ```
][
  #counter(figure.where(kind: image)).update(4)
  #figure(
    caption: [
      QAM constellation diagram of the modulated output.
    ],
    image("./figures/qam_constellation_only.png", height: 85%)
  )
]

#slide(title: "Lattice filter")[
  #counter(figure.where(kind: image)).update(5)
  #figure(
    caption: [
      Lattice filter circuit diagram.
    ],
    image("./figures/drawio/mzi_lattice.png", height: 90%)
  )
]

#slide(title: "Lattice filter (cont.)")[
  #set text(size: 18pt)
  ```phos
    syn lattice_filter(
      a: optical,
      b: optical,
      filter_kind: FilterKind
    ) -> (optical, optical) {
      filter_kind_coefficients(filter_kind)
        |> fold((a, b), |acc, (coeff, phase)| {
          acc |> coupler(coeff)
              |> constrain(d_phase = phase)
        })                              
    }
  ```
][
  #counter(figure.where(kind: image)).update(5)
  #figure(
    caption: [
      Lattice filter frequency response.
    ],
    image("./figures/lattice_filter.png", width: 100%)
  )
]

#new-section("Conclusion")
#slide(theme-variant: "section slide")

#slide(title: "Future works")[
  - Implementing PHÔS fully
  - Co-simulation with digital and analog circuits
  - Place-and-route
  - Language improvements
  - Advanced constraint inference
]

#slide(title: "Key takeaways")[
  #line-by-line()[
    - Novel programmatic way of describing photonics:
      - Expressive
      - Flexible
      - Reusable
      - Programmable
      - Opens the way to VLSI for photonics
    - Novel constraint system for photonics:
      - Optimization
      - Verification
      - Simulation
  ]
]

#new-section("Thank you for listening")
#slide(theme-variant: "section slide")

#slide(theme-variant: "end")

#hide(bibliography("references.bib", style: "ieee"))

#slide(title: "Sources", scale: false)[
  #set text(size: 12pt)
  #bibliography-outline(title: none)
]