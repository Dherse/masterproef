#import "./elems/template.typ": *
#import "./elems/acronyms.typ": *

#show: project.with(
  title: "A software language approach for describing and programming photonics hardware",
  authors: (
    "Sébastien d'Herbais de Thun",
  ),
)

#show: preface.with()

= Remark on the master's dissertation and the oral presentation
This master's dissertation is part of an exam. Any comments formulated by the assessment committee during the oral
presentation of the master's dissertation are not included in this text.

= Acknowledgements <sec_ack>
I would like to express my deepest gratitude to Prof. dr. ir. Wim Bogaerts and Prof. dr. ir. Dirk Stroobandt for their time, guidance, patience, and trust in applying for an #emph[FWO] proposal to extend this Master Thesis. Through their advice and guidance, I have gained a breadth of knowledge and understanding that I have done my best to share in this thesis. It is with great pleasure that I write this document to share these findings and insights with them and others within the scientific community.

I would also like to give my most heartfelt thanks to the best friend one could ever ask for: ir. Thomas Heuschling, for his patience, friendship, guidance and all of the amazing moments we spent throughout our studies. I would also like to thank him for his help in proofreading this thesis and his advice on the PHÔS programming language. I also would like to thank Alexandre Bourbeillon for his help and advice for the creation of the formal grammar of the PHÔS programming language and being a great friend for over a decade.

I must also thank the incredible people that helped me proofread and improve my thesis: Daniel Csillag and Mossa Merhi Reimert for their time, advice and support. And Léo Masson for his help on programmatic visualization of hexagonal lattices and his advice regarding typesetting.

Finally, my parents, Evelyne Dekens and Baudouin d'Herbais de Thun, were also there for me every step of the way and I deeply thank them for their support and listening to my endless rambling about photonics and programming.

#align(right)[
  -- Sébastien d'Herbais de Thun #linebreak()
  Wavre BE, 16th of June 2023
]

= Permission of use on loan

The author gives permission to make this master dissertation available for consultation and to
copy parts of this master dissertation for personal use. In the case of any other use, the copyright
terms have to be respected, in particular with regard to the obligation to state expressly the
source when quoting results from this master dissertation.

#align(right)[
  -- Sébastien d'Herbais de Thun #linebreak()
  Wavre BE, 16th of June 2023
]

= Abstract
In this thesis, a novel way of programmatically designing photonic circuits is introduced, using a new programming language called PHÔS.

The primary goal of this thesis is the research of which paradigms, techniques, and languages are best suited for programmatic description of photonic circuits, with a special emphasis on programmable photonics as it is being researched at Ghent University. This involves an in-depth analysis of existing programming languages and paradigms, followed by a careful analysis of the functional requirements of photonic circuit design. This analysis highlights the need for a new language dedicated to photonic circuit design, that is able to concisely and effectively express photonic circuits.

The design of this language is then shown, with all of the steps for its implementation carefully detailed. Parts of this language are implemented in a prototype compiler. One of its components called the constraint-solver was the primary focus of this development effort, which has shown to be capable of simulating a large variety of photonic circuits, based on simple constraints and operations. 

Finally, meaningful demonstrations of the capabilities of the language and the constraint-solver are shown.

== Keywords

Programmable photonic, photonic circuit design, programming language, photonic circuit simulation.

// Table of contents
#outline(title: "Table of contents", indent: true, depth: 3)

#let ffi_footnote = locate(loc => if section.at(loc) == "preface" {
  [: a way to call functions from other languages ]
} else {
  footnote[Foreign Function Interface: a way to call functions from other languages ]
})

#show: glossary.with((
    (key: "prg", short: "PRG", long: "Photonics Research Group"),
    (key: "fpga", short: "FPGA", long: "Field Programmable Gate Array"),
    (key: "cpld", short: "CPLD", long: "Complex Programmable Logic Device"),
    (key: "spice", short: [_SPICE_], long: "Simulation Program with Integrated Circuit Emphasis"),
    (key: "phos", short: [_PHÔS_], long: "Photonic Hardware Description Language"),
    (key: "pic", short: "PIC", long: "Photonic Integrated Circuit"),
    (key: "rf", short: "RF", long: "Radio Frequency"),
    (key: "verilog-ams", short: [_Verilog-AMS_], long: "Verilog for Analog and Mixed Signal"),
    (
        key: "verilog-a", 
        short: [_Verilog-A_], 
        long: [ A continuous-time subset of #gloss("verilog-ams") ]
    ),
    (key: "fir", short: "FIR", long: "Finite Impulse Response"),
    (key: "iir", short: "IIR", long: "Infinite Impulse Response"),
    (key: "dsp", short: "DSP", long: "Digital Signal Processor"),
    (key: "fppga", short: "FPPGA", long: "Field Programmable Photonic Gate Array"),
    (key: "2x2", short: "2x2 tunable coupler", long: "A tunable coupler with two inputs and two outputs"),
    (key: "mems", short: "MEMS", long: "Microelectromechanical Systems"),
    (key: "hdl", short: "HDL", long: "Hardware Description Language"),
    (key: "rtl", short: "RTL", long: "Register Transfer Level"),
    (key: "asic", short: "ASIC", long: "Application Specific Integrated Circuit"),
    (key: "api", short: "API", long: "Application Programming Interface"),
    (key: "dsl", short: "DSL", long: "Domain Specific Language"),
    (key: "jtag", short: "JTAG", long: [ Joint Test Action Group -- A standard for testing integrated circuits]),
    (key: "sql", short: "SQL", long: "Structured Query Language"),
    (key: "ide", short: "IDE", long: "Integrated Development Environment"),
    (key: "lsp", short: "LSP", long: "Language Server Protocol"),
    (key: "tdd", short: "TDD", long: "Test Driven Development"),
    (key: "http", short: "HTTP", long: [ Hypertext Transfer Protocol -- the protocol used for web navigation ]),
    (key: "ip", short: "IP", long: "Intellectual Property"),
    (key: "dry", short: "DRY", long: "Don't Repeat Yourself"),
    (key: "hls", short: "HLS", long: "High Level Synthesis"),
    (key: "vhsic", short: "VHSIC", long: "Very High Speed Integrated Circuit"),
    (key: "vhdl", short: [_VHDL_], long: [ #gloss("vhsic", short: true) Hardware Description Language ]),
    (key: "gpl-3-0", short: "GPL-3.0", long: "GNU General Public License version 3.0"),
    (key: "ic", short: "IC", long: "Integrated Circuit"),
    (key: "gpu", short: "GPU", long: [Graphics Processing Unit -- also commonly used for highly parallel computing ]),
    (key: "cpu", short: "CPU", long: [Central Processing Unit]),
    (key: "llvm", short: [_LLVM_], long: [Low Level Virtual Machine]),
    (key: "hpc", short: "HPC", long: [High Performance Computing]),
    (key: "fsr", short: "FSR", long: [Free Spectral Range]),
    (key: "hal", short: "HAL", long: [Hardware Abstraction Layer]),
    (key: "eda", short: "EDA", long: [Electronic Design Automation]),
    (key: "lut", short: "LUT", long: [Look Up Table]),
    (key: "mzi", short: "MZI", long: [Mach-Zehnder Interferometer]),
    (key: "io", short: "I/O", long: [Input/Output]),
    (key: "ppa", short: "PPA", long: [Power, Performance, Area]),
    (key: "ecs", short: "ECS", long: [Entity-Component-System]),
    (key: "adt", short: "ADT", long: [Algebraic Data Type]),
    (key: "si", short: "SI", long: [Système international -- the international system of units]),
    (key: "ast", short: "AST", long: [Abstract Syntax Tree]),
    (key: "vm", short: "VM", long: [Virtual Machine]),
    (key: "cst", short: "CST", long: [Concrete Syntax Tree]),
    (key: "hir", short: "HIR", long: [High-level Intermediate Representation]),
    (key: "mir", short: "MIR", long: [Mid-level Intermediate Representation]),
    (key: "gadt", short: "GADT", long: [Generalized Algebraic Data Type]),
    (key: "cfg", short: "CFG", long: [Control Flow Graph]),
    (key: "mit", short: "MIT", long: link("https://opensource.org/license/mit/")[The _MIT_ license]),
    (key: "bc", short: "BC", long: [Bytecode]),
    (key: "ffi", short: "FFI", long: [Foreign Function Interface #ffi_footnote]),
    (key: "smt", short: "SMT", long: [Satisfiability Modulo Theories]),
    (key: "prbs", short: "PRBS", long: [Pseudo Random Binary Sequence]),
    (key: "adc", short: "ADC", long: [Analog to Digital Converter]),
    (key: "dac", short: "DAC", long: [Digital to Analog Converter]),
    (key: "soa", short: "SOA", long: [ Semiconductor Optical Amplifier ]),
    (key: "qam", short: "QAM", long: [ Quadrature Amplitude Modulation ]),
    (key: "awgn", short: "AWGN", long: [ Additive White Gaussian Noise ]),
    (key: "snr", short: "SNR", long: [ Signal to Noise Ratio ]),
    (key: "ber", short: "BER", long: [ Bit Error Rate ]),
    (key: "evm", short: "EVM", long: [ Error Vector Magnitude ]),
    (key: "mvm", short: "MVM", long: [ Matrix Vector Multiplication ]),
))


#outline(title: "List of figures", target: figure.where(kind: image))
#outline(title: "List of tables", target: figure.where(kind: table))
#outline(title: "List of listings", target: figure.where(kind: raw))

#include "./content/this_document.typ"

#show: content

#include "./content/0_introduction.typ"
#include "./content/1_background.typ"
#include "./content/2_ecosystem.typ"
#include "./content/3_translation.typ"
#include "./content/4_phos.typ"
#include "./content/5_examples.typ"
#include "./content/6_future_work.typ"
#include "./content/7_conclusion.typ"

#pagebreak(weak: true)
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

#show: annex
#include "./content/a_annexes.typ"
