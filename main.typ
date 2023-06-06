#import "./elems/template.typ": *
#import "./elems/acronyms.typ": *

#show: project.with(
  title: "A software language approach for describing and programming photonics hardware",
  authors: (
    "Sébastien d'Herbais de Thun",
  ),
)

#show: preface.with()

= Acknowledgements
I would like to express my deepest gratitude to Prof. Wim Bogaerts and Prof. Dirk Stroobandt for their time, guidance, patience, and trust in applying for an #emph[FWO] proposal to extend this Master Thesis. Through their advice and guidance, I have gained a breadth of knowledge and understanding that I will carry with me for the rest of my career. It is with great pleasure that I write this document to share my findings with them and others within the community.

I would also like to give my most heartfelt thanks to the best friend one could ever ask for: Thomas Heuschling, for his patience, friendship, guidance and all of the amazing moments we spent throughout our studies. I would also like to thank him for his help in proofreading this thesis and his advice on the PHÔS programming language. I also would like to thank Alexandre Bourbeillon for his help and advice for the creation of the formal grammar of the PHÔS programming language and being a great friend for over a decade.

I must also thank the incredible people that helped me proofread and improve my thesis: Daniel Csillag and Mossa Merhi Reimert for their time, advice and support.

Finally, my parents, Evelyne Dekens and Baudouin d'Herbais de Thun, were also there for me every step of the way and I deeply thank them for their support and listening to my endless rambling about photonics and programming. 

= Remark on the master's dissertation and the oral presentation
This master's dissertation is part of an exam. Any comments formulated by the assessment committee during the oral
presentation of the master's dissertation are not included in this text.

= Abstract
#lorem(30)

// Table of contents
#outline(title: "Table of contents", indent: true, depth: 3)

#show: glossary.with((
    (key: "prg", short: "PRG", long: "Photonics Research Group"),
    (key: "fpga", short: "FPGA", long: "Field Programmable Gate Array"),
    (key: "cpld", short: "CPLD", long: "Complex Programmable Logic Device"),
    (key: "spice", short: "SPICE", long: "Simulation Program with Integrated Circuit Emphasis"),
    (key: "phos", short: "PHÔS", long: "Photonic Hardware Description Language"),
    (key: "pic", short: "PIC", long: "Photonic Integrated Circuit"),
    (key: "rf", short: "RF", long: "Radio Frequency"),
    (key: "verilog-ams", short: "Verilog-AMS", long: "Verilog for Analog and Mixed Signal"),
    (
        key: "verilog-a", 
        short: "Verilog-A", 
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
    (key: "vhdl", short: "VHDL", long: [ #gloss("vhsic", short: true) Hardware Description Language ]),
    (key: "gpl-3-0", short: "GPL-3.0", long: "GNU General Public License version 3.0"),
    (key: "ic", short: "IC", long: "Integrated Circuit"),
    (key: "gpu", short: "GPU", long: [Graphics Processing Unit -- also commonly used for highly parallel computing and machine learning]),
    (key: "cpu", short: "CPU", long: [Central Processing Unit]),
    (key: "llvm", short: "LLVM", long: [Low Level Virtual Machine]),
    (key: "hpc", short: "HPC", long: [High Performance Computing]),
    (key: "fsr", short: "FSR", long: [Free Spectral Range]),
    (key: "hal", short: "HAL", long: [Hardware Abstraction Layer]),
    (key: "eda", short: "EDA", long: [Electronic Design Automation]),
    (key: "lut", short: "LUT", long: [Look Up Table]),
    (key: "mzi", short: "MZI", long: [Mach-Zehnder Interferometer]),
    (key: "io", short: "I/O", long: [Input/Output]),
    (key: "ppa", short: "PPA", long: [Power, Performance, Area]),
    (key: "ecs", short: "ECS", long: [Entity-Component-System]),
))

#outline(title: "List of figures", target: figure.where(kind: image))
#outline(title: "List of tables", target: figure.where(kind: table))
#outline(title: "List of listings", target: figure.where(kind: raw))

#include "./content/this_document.typ"

#locate(loc => {
    if calc.mod(counter(page).at(loc).at(0), 2) == 0 {
        blank-page()
    }
})

#show: content

#include "./content/0_introduction.typ"
#include "./content/1_background.typ"
#include "./content/2_ecosystem.typ"
#include "./content/3_translation.typ"
#include "./content/4_phos.typ"
#include "./content/5_examples.typ"
#include "./content/6_extending.typ"
#include "./content/7_simu.typ"
#include "./content/8_conclusion.typ"

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
