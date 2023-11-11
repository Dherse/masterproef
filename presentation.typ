#import "./elems/slides.typ": *
#import "./elems/ugent-theme.typ": *
#import "./elems/colors.typ": *
#import "./elems/code_blocks.typ": *
#import "./elems/tablex.typ": *

#let date = datetime(year: 2023, month: 06, day: 29).display()

#show: code-blocks
#set page(numbering: "1", footer: [])

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
    handout: false,
)
#set text(font: "UGent Panno Text")
#show strong: set text(fill: ugent-blue)

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

#let text_emoji(content, ..args) = text.with(font: "tabler-icons", fallback: false, weight: "regular", size: 100pt, ..args)(content)

#let lightbulb = text_emoji(fill: earth-yellow, size: 70pt - 2.7pt)[\u{ea51}]
#let lightning = text_emoji(fill: green, size: 70pt - 2.7pt)[\u{ea38}]
#let value = text_emoji(fill: rgb(30,100,200), size: 70pt - 2.7pt)[\u{f61b}]

#let required = text_emoji(fill: green)[\u{ea5e}]
#let not_needed = text_emoji(fill: red)[\u{eb55}]
#let desired = text_emoji(fill: rgb(30,100,200))[\u{f4a5}]

// UGent logo
#slide(theme-variant: "corporate logo")

// Global title slide
#slide(theme-variant: "title slide")

// First section
#new-section("The elevator pitch")
#slide(theme-variant: "section slide")

#slide(title: "Rising to the occasion", theme-variant: "image only", footer: [
  Picture: _Bao Jueming, et al._ @bao_very-large-scale_2023
])[
  #line-by-line()[
    - Photonic circuits are *complex*
    - This complexity is *rising*
    - How to *tame* complexity? #uncover(5)[_abstractions_]
    - Can we learn from *VLSI*? #uncover(5)[_yes_]
  ]
][
  #image("./figures/big_circuit.png", width: 100%)
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
  #only(1, image("./figures/drawio/abstractions_1.png", width: 100%))
  #only((beginning: 2, until: 3), image("./figures/drawio/abstractions_2.png", width: 100%))
  #only(4, image("./figures/drawio/abstractions_comp.png", width: 100%))
  #only(5, image("./figures/drawio/abstractions_sfg.png", width: 100%))
  #only(6, image("./figures/drawio/abstractions_bb.png", width: 100%))
  #only((beginning: 7), image("./figures/drawio/abstractions_qm.png", width: 100%))
]

#slide(
  title: "Introducing PHÔS",
  footer: [
    #only(9)[
      Picture: _Brianne Christopher_ @christopher_calculating_nodate
    ]
  ]
)[
  #only((1, 2, 3, 4, 5, 6, 7, 8))[
    #line-by-line()[
      - PHÔS is a *new language* and the result of this thesis
      - PHÔS is a *domain-specific language*
      - PHÔS describes *photonic circuits*
      - PHÔS is *declarative*
      - PHÔS is *parametric*
      - PHÔS is *expressive*
      - PHÔS is *extensible*
      - PHÔS is *not finished* nor *perfect*
        - We need *you* to make it better!
    ]
  ]
  #only(9, layout(size => style(styles => [
    #show: align.with(center + horizon)
    #let img = image("./figures/ring_resonator_field.png", width: size.width)
    #let dims = measure(img, styles)
    #place(center + horizon)[
      #box(..dims)[
        #img
      ]
    ]
    #place(bottom + right)[
      #not_needed
    ]
  ])))
  #only(10, layout(size => style(styles => [
    #show: align.with(center + horizon)
    #let img = image("./figures/ring_resonator_black_box.png", width: size.width)
    #let dims = measure(img, styles)
    #place(center + horizon)[
      #box(..dims)[
        #img
      ]
    ]
    #place(bottom + right)[
      #required
    ]
  ])))
][
  /*#only((beginning: 1, until: 7), align(center + horizon, image("./figures/drawio/responsibilities-vertical.png", height: 120%)))*/
  #line-by-line(start: 8)[
    - PHÔS is *not* at the component level	
      - #strike[Component design]
      - #strike[Component simulation]
      - #strike[Component optimization]
    - PHÔS is the *function* and *system* levels
      - Filter synthesis
      - Signal flow graph generation
      - Component modeling & instantiation
      - Reconfigurability & tunability
      - Optimization
  ]
]

#slide(title: "About this presentation")[
  #one-by-one()[
    - Elevator pitch
    - Programmatic description: an overview
    - Example: 16-QAM modulator
    - Example: Lattice filter
    - Conclusion
    - Future work
  ]
]

#new-section("Programmatic description: an overview")
#slide(theme-variant: "section slide")

#slide(title: "Translation of intent")[
    - How do we tell the computer what we want? #uncover((beginning: 2, until: 4))[*Programming!*]
    - What do we want the computer to do for us? #uncover((beginning: 3, until: 4))[*As much as possible!*]
    - How does the computer do it? #uncover((beginning: 4, until: 4))[*Compilation, Evaluation, and Synthesis!*]
]

#slide(title: "How do you describe photonic circuit?", colwidths: (50%, 50%))[
  #line-by-line()[
    - Scaling graphical circuits is *really* hard
    - Graphical circuits are *inflexible*
    - Graphical circuits are not *reusable*
    - Graphical circuits are not *expressive*
  ]
  #uncover(4, align(bottom)[
    #align(center, image("./figures/drawio/mzi_lattice.png", width: 80%))
  ])
][
  #line-by-line()[
    - Scaling code is *really* easy
    - Code is *flexible*
    - Code is easily *reusable*
    - Code is *expressive*
  ]
  #uncover(4, align(bottom)[
    #set text(size: 18pt)
    ```phos
    filter_kind_coefficients(filter_kind)
      |> fold((a, b), |acc, (coeff, phase)| {
        acc |> coupler(coeff)
            |> constrain(d_phase = phase)
      })
    ```
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
  #align(center, image("./figures/drawio/circuit_diagram.png", width: 90%))
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

#slide(title: "What is a circuit made of?", colwidths: (1fr, 1fr))[
  #line-by-line()[
    - *Filters*
    - *Gain* and *loss* elements
    - *Modulators* and *detectors*
    - *Splitters* and *combiners*
    - *Couplers*
    - *Switches*
    - *Phase shifters* and *delay lines*
    - *Sources*
    - *Sinks*, and *empty* signals
    - Together, these form the *intrinsic operations*
    - *Circuits* are made of *intrinsic operations*
  ]
][
  #layout(size => alternatives(rest: align(center + horizon, image("./figures/drawio/signal_proc.png", width: 100%)))[
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/filter.png", width: size.width)
      *Wavelength* constraint
    ]
  ][
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/gain_loss.png", width: size.width)
      *Power* constraint
    ]
  ][
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/modulator.png", width: size.width)
      (no constraint)
      #image("./figures/drawio/intrinsics/detector.png", width: size.width)
      (no constraint)
    ]
  ][
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/splitter.png", width: size.width)
      *Power* constraint
      #image("./figures/drawio/intrinsics/merger.png", width: size.width)
      *Power* constraint
    ]
  ][
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/coupler.png", width: size.width)
      (no constraint)
    ]
  ][
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/switch.png", width: size.width)
      (no constraint)
    ]
  ][
    #align(center + horizon)[
      #image("./figures/drawio/intrinsics/phase_shifter.png", width: size.width)
      *Phase* constraint
      #image("./figures/drawio/intrinsics/delay_line.png", width: size.width)
      *Delay* constraint
    ]
  ][
    #align(center + horizon)[
      #align(right, image("./figures/drawio/intrinsics/source.png", width: size.width / 1.45))
      *Power* and *Wavelength* constraint
    ]
  ][
    #align(center + horizon)[
      #align(left, image("./figures/drawio/intrinsics/sink.png", width: size.width / 1.45))
      (no constraint)
      #align(right, image("./figures/drawio/intrinsics/empty.png", width: size.width / 1.45))
      *Power* and *Wavelength* constraint
    ]
  ][
    #align(center + top, layout(size => {
      if size.width > 1000000pt or size.height > 1000000pt {
        return []
      }
      tablex(
        columns: (size.width / 3, ) * 3,
        inset: 10pt,
        outset: 0pt,
        align: center + horizon,
        stroke: none,
        image("./figures/drawio/intrinsics/filter.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/gain_loss.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/modulator.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/detector.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/splitter.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/merger.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/coupler.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/switch.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/phase_shifter.png", width: size.width / 3),
        image("./figures/drawio/intrinsics/delay_line.png", width: size.width / 3),
        align(right, image("./figures/drawio/intrinsics/source.png", width: size.width / (3 * 1.45))),
        align(left, image("./figures/drawio/intrinsics/sink.png", width: size.width / (3 * 1.45))),
        [],
        align(right, image("./figures/drawio/intrinsics/empty.png", width: size.width / (3 * 1.45))),
      )
    }))
  ][
    #align(center + horizon, image("./figures/drawio/signal_proc.png", width: 100%))
  ])
]

#slide(title: "Overview")[
  #align(center + horizon, image("./figures/drawio/exec_model.png", width: 100%))
]

#new-section("Examples")
#slide(theme-variant: "section slide")

#slide(title: "16-QAM 400 Gb/s modulator")[
  #align(center + horizon, image("./figures/drawio/qam_mod.png", width: 100%))
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
  #stack(
    dir: ttb,
    spacing: 1em,
    align(center + horizon, image("./figures/drawio/qam_mod.png", width: 100%)),
    align(center, image("./figures/qam_constellation_only.png", height: 70%)),
  )
]

#slide(title: "Lattice filter")[
  #align(center, image("./figures/drawio/mzi_lattice.png", height: 90%))
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
  #align(center, image("./figures/drawio/mzi_lattice.png", width: 80%))
  #align(center, image("./figures/lattice_filter.png", width: 90%))
]

#new-section("Conclusion")
#slide(theme-variant: "section slide")

#slide(title: "Future works")[
  - Implementing PHÔS fully
  - Co-simulation with digital and analog circuits
  - Place-and-route
  - Language improvements
  - Advanced constraint inference
  - #smallcaps[*Test all the things!*]
]

#slide(title: "Key takeaways")[
  #line-by-line()[
    - Novel programmatic way of *describing photonics*:
      - *Expressive*, *flexible*, *reusable*, and *programmable*
      - Opens the way to *VLSI for photonics*
    - Novel *constraint system* for photonics:
      - *Optimization*, *verification*, *simulation*
    - Now we need *you* to *improve* it!
  ]
]

#new-section("Thank you for listening")

#hide(heading(level: 99, "end"))
#logical-slide.update(0)
#set page(numbering: "I")

#slide(theme-variant: "section slide")
#hide(heading(level: 99, "end"))
#logical-slide.update(0)

#slide(theme-variant: "end")
#hide(heading(level: 99, "end"))
#logical-slide.update(0)

#hide(bibliography("references.bib", style: "ieee"))

#slide(title: "Sources", scale: false)[
  #set text(size: 12pt)
  #bibliography-outline(title: none)
]
#hide(heading(level: 99, "end"))
#logical-slide.update(0)

#new-section("Backup")
#slide(theme-variant: "section slide")

#slide(title: "Why a compiled language?")[
  - Why not an intepreted language like Python?
    - *Stack collection* for tunability, reconfigurability, and programmability
    - *Static analysis* with a prover
    - Good *separation of concerns*
    - Dynamic languages are *error prone*
]

#slide(title: "")[
]