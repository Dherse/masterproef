#import "elems/ieee.typ": *
#show: ieee.with(
  title: "A software language approach for describing and programming photonics hardware",
  abstract: [
    This research presents a novel way of designing and describing photonic circuits, allowing for faster and more productive design and simulation of photonic circuits. This is achieved using a software language approach, where the photonic circuit is described in a software language, which is then compiled into a photonic circuit.
  ],
  authors: (
    (
      name: "Sébastien d'Herbais de Thun",
      department: [#emph[Promoters:] Prof. dr. ir. Wim Bogaerts, Prof. dr. ir. Dirk Stroobandt],
      organization: [Ghent University],
      email: "sebastien.dherbaisdethun@ugent.be"
    ),
  ),
  index-terms: ("Photonic", "Circuit design", "Photonic processors", "Programmable photonic"),
  bibliography-file: "references.bib",
  paper-size: "a4"
)

= Introduction
Integrated photonics is a growing industry that benefits from the high yields and technological maturity of the CMOS industry. However, it has not yet reached the ease of design and simulation that the digital electronics industry has enjoyed for many years. This lack of maturity in the tools and design flows is a hurdle that has led to a slower time to market for photonic integrated circuits. When coupled with the lack of prototyping platforms, it has made integrated photonics an expensive market to enter. In recent years, several teams around the world, including at _Ghent University_, have been working on remediating this issue by developing a prototyping platform called a photonic processor. This processor is a programmable photonic integrated circuit that can prototype photonic circuits and replace photonic ASICs in some applications #cite("bogaerts_ipkiss_2016", "bogaerts_programmable_2020", "bogaerts_silicon_2018").

This paper will introduce a new hardware description language called PHÔS, which aims at providing a software language approach to photonic circuit design, being compatible with both, the programming of photonic processors and the creation of standalone photonic integrated circuits (PICs).

== Paper overview
This paper will start by introducing photonic processors, the niche they fill, and their potential applications. Followed by an introduction to the core concepts of the PHÔS programming language and how PHÔS can be used to describe photonic circuits efficiently and productively. Then, this work will present an example written in PHÔS of a 16-QAM 400Gb/s transmitter, showing how the language can describe a complex photonic circuit. Finally, a discussion of future work and the conclusion will close this paper.

= Photonic processors
Photonic processors, also called photonic FPGAs @perez-lopez_multipurpose_2020, are reprogrammable PICs designed to be generic enough to express most passive photonic circuits @bogaerts_programmable_2020. They are the photonic analogue to digital electronics' FPGAs, with the significant difference being that they represent analog circuits instead of digital ones. Photonic processors are built from gates, seen in @fig_photonic_gates, arranged in hexagonal grids. It also shows the multiple operating modes of a photonic gate: the bar mode #link(<fig_photonic_gates>)[(b)] which does not couple the optical signals together, the cross mode  #link(<fig_photonic_gates>)[(c)] which fully couples the optical signals from one waveguide to the other, and partial mode  #link(<fig_photonic_gates>)[(d)] which partially couples the optical signals from one waveguide to the other. The partial mode can split signals, combine them, interfere them, etc.

#figure(
    caption: "Photonic gate and its states",
    kind: image,
)[
    #table(
        columns: 2,
        stroke: none,
        align: center + horizon,
        image(
            "./figures/drawio/2x2_coupler.png",
            width: 100%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in dashed line and bar in solid line."
        ),
        image(
            "./figures/drawio/2x2_coupler_bar.png",
            width: 100%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: bar in solid line."
        ),
        "(a)",
        "(b)",
        image(
            "./figures/drawio/2x2_coupler_cross.png",
            width: 100%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in solid line."
        ),
        image(
            "./figures/drawio/2x2_coupler_partial.png",
            width: 100%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in dashed line and bar in solid line."
        ),
        "(c)",
        "(d)",
    )
] <fig_photonic_gates>

Photonic gates can be arranged in several ways; the most typical are hexagonal grids, as seen in @fig_photonic_meshes #link(<fig_photonic_meshes>)[(a)], other configurations such as a square mesh @fig_photonic_meshes #link(<fig_photonic_meshes>)[(b)], and triangular meshes @fig_photonic_meshes #link(<fig_photonic_meshes>)[(c)] also exist. However, the hexagonal mesh provides the best routing capabilities. There has been ongoing research into the routing of photonic meshes #cite("kerchove_adapting_2022", "gao_automatic_2022", "kerchove_automated_2023"). However, the placement aspect of photonic processors has not been resolved yet.

#figure(
    caption: "Common mesh topologies in photonic processors",
    kind: image,
)[
    #table(
        columns: 3,
        stroke: none,
        align: center + horizon,
        image(
            "./figures/drawio/mesh_hexagonal.png",
            width: 100%,
            alt: "Shows a hexagonal photonic mesh."
        ),
        image(
            "./figures/drawio/mesh_square.png",
            width: 100%,
            alt: "Shows a square photonic mesh."
        ),
        image(
            "./figures/drawio/mesh_triangular.png",
            width: 100%,
            alt: "Shows a triangular photonic mesh."
        ),
        "(a)",
        "(b)",
        "(c)",
    )
] <fig_photonic_meshes>

== Use cases
Besides their use as prototyping platforms, there are situations where photonic processors may be used independently and integrated into a system directly. Photonic processors can be used in many fields, such as telecommunication, sensor, medical, and quantum computing. This section will discuss some of the use cases of photonic processors.

=== Telecommunication
Telecommunication is among the most significant driving forces behind the demand for PICs. Therefore, it is no surprise that they are also a significant potential market for photonic processors. Indeed, photonic processors can be used to create transceivers for high-speed communication and route optical signals in data centers and field deployments. This makes them an ideal candidate for fiber deployments and 5G networks. Additionally, their strong capabilities in processing RF signals can be used to create 5G base stations for beamforming and signal processing.

=== Sensors
Fiber sensors have been used in many industries, including gas and oil, aerospace, and the medical sector. They are used to measure temperature, pressure, strain, and other physical quantities. Photonic processors can be used to create the base stations for these sensors, being responsible for signal production, processing, and data analysis.

=== Medical
The medical industry has been using optical fibers for a long time, and photonic processors can be used as processing units for these fibers. They can also be included in the RF processing chains of equipment like MRI machines.

All of these factors combined place photonic processors in a unique way where they can be integrated into many existing technologies and fields, making them a promising technology.

#colbreak(weak: true)
= PHÔS
This paper will present the PHÔS programming language, beginning with the reasoning behind its creation, then its core concepts, and finally, its syntax and semantics.

== Motivation
Many programming languages exist, but none meet the unique requirements of describing photonic circuits. They all lack one of the desirable features for photonic design. Indeed, photonic designs have some unique challenges due to the very nature of light:
- Waveguides can carry two modes, one in either direction
- The light can have a broad spectrum
- Light is phase-sensitive
- Signals modulated on the light are delay sensitive

Additionally, photonic circuits have some unique requirements:
- Devices should behave ideally
- The design should be reconfigurable, tunable, and programmable
- The design should be platform independent

These challenges and requirements make it difficult for existing languages to describe photonic circuits intuitively and efficiently. Therefore, a new language is needed to describe photonic circuits, this language, PHÔS, is presented in this paper.

== Core concepts

PHÔS is a language based on traditional imperative programming, with features from functional and dataflow programming languages. It is a strongly typed language with a type system inspired by _Rust_'s and a syntax inspired by _Rust_'s, _Python_'s, and _Elixir_'s. PHÔS separates hardware synthesis into three stages: compilation, evaluation, and synthesis. During compilation, the user's code is turned into a bytecode representing their code, which contains information about the program's structure, types, functions, and signal flow. The bytecode is executed during evaluation, and the program's output is computed. Parts of the program that depend on tunable values are collected for further processing. The output of the evaluation stage is a graph representing the program's signal flow. This graph is then used to synthesise the program into a photonic circuit. Some of the core concepts will be discussed in the following few sections.

=== Constraints
Constraints are placed on values and signals to inform PHÔS of what values or content is expected at any point in the program. These constraints can then be used for validation of the design and to optimise the design. Constraints are also used when simulating the circuit to make the simulation quicker and more efficient.

=== Tunable values
Like any other variables or argument, tunable values are declared in the source code. Only when the user instantiates the module are the tunable values configured; this occurs during the evaluation stage. When this happens, as the user's program is being evaluated, all operations that cannot be performed due to missing values are collected into stacks for further processing.

=== Reconfigurability through branching
PHÔS handles the reconfigurability of the circuit it produces through branching in its source code; when tunable values are present, these branches represent the boundaries of reconfigurability regions. PHÔS discards the branches that are not needed based on the constraints of the tunable values. These constraints allow PHÔS to produce a reconfigurable and tunable circuit while avoiding the unnecessary work of unreachable states.

=== Intrinsic operations
PHÔS decomposes the user's program during evaluation into a series of intrinsic operations. These operations are the unit operations performed on the signal in the circuit. These operations are then used to synthesise the circuit.

== Syntax and semantics

As previously mentioned, PHÔS follows a syntax familiar to many programmers, as it takes inspiration from _Python_ and other _C_-like languages. This section will present the syntax and semantics of PHÔS. In @lst_hello_world, the classic "Hello, world!" program is presented in PHÔS. This program is composed of a single function printing the classic message.

#figure(caption: ["Hello, world!" in PHÔS. ])[
```phos
fn hello_world() {
    print("Hello, world!");
}
```
] <lst_hello_world>

=== Synthesisable blocks
PHÔS makes a semantic difference between functions and synthesisable blocks. Synthesisable blocks are similar to functions but can take in and return signals. This distinction encourages the user to separate the concerns between their parameters' computation and the circuit's signal flow they are trying to build. In @lst_syn_block, such a synthesisable block performs filtering on an input signal. It also shows some of the unique features of PHÔS, such as using the pipe operator (`|>`) to chain operations and the ability to express SI units directly in the code.

#figure(caption: [Synthesisable block in PHÔS. ])[
```phos
syn my_circuit(input: optical) -> optical {
    optical |> filter(1550 nm, bandwidth = 10 GHz)
}
```
] <lst_syn_block>

=== Constraints

Constraints are expressed in PHÔS using decorators on input arguments and output values. This syntax may be changed in the future, but as of the writing of this paper, it is the syntax used. In @lst_constraints, the `@power` decorator represents that the signal has specific power content.

#figure(caption: [Synthesisable block with constraints in PHÔS. ])[
```phos
syn my_circuit(
    @power(0 dBm) input: optical
) -> optical {
    optical |> filter(1550 nm, bandwidth = 10 GHz)
}
```
] <lst_constraints>

= 16-QAM 400Gb/s transmitter

After this short introduction to the PHÔS language, this section will present a 16-QAM 400Gb/s transmitter designed using PHÔS. This example is based on the work by _Talkhooncheh, Arian Hashemi, et al._ @talkhooncheh_200gbs_2023. The code of this example can be found in @lst_16qam, showing the circuit as taking four electrical inputs, which are the four binary sources that will be modulated. It also takes an optical signal, which is the source laser. It then splits the laser source into four signals, one for each binary source. These signals are then modulated using amplitude modulation. Their phases are then constrained to be within 90° of each other. Finally, the four signals are merged back into a single signal.

#figure(
    caption: "16-QAM 400Gb/s transmitter designed using PHÔS.",
)[
```phos
syn coherent_transmitter(
    input: optical,
    (a, b, c, d): (
        electrical,
        electrical,
        electrical,
        electrical
    ),
) -> optical {
    input
        |> split((1.0, 1.0, 0.5, 0.5))
        |> zip((a, c, b, d))
        |> modulate(type = Modulation::Amplitude)
        |> constrain(d_phase = 90°)
        |> merge()
}
```
]<lst_16qam>

This circuit can be simulated using the simulator that is built into PHÔS, called the constraint-solver. It uses the constraints and intrinsic operations of the user's circuit to quickly simulate the circuit. In this case, on a modern _AMD_ CPU, the circuit was simulated for 10ns with a timestep of 10ps in only 750ms. The result of this simulation is the constellation shown in @fig_16qam, showing the circuit indeed performs as expected.

#figure(
    caption: [ Constellation diagram of the 16-QAM 400Gb/s transmitter. ],
    kind: image
)[
    #image(
        "./figures/qam_constellation_only.png",
        width: 100%
    )
]<fig_16qam>

= Conclusion

This paper demonstrated a novel way of describing photonic circuits using code. Moreover, while the language is not fully implemented yet, it shows promising results, can easily express complex systems, and performs fast yet accurate simulations.

== Future work

More work is required to complete the PHÔS ecosystem, starting with the complete implementation of the language, research into provers for the constraint system, and the development of place-and-route algorithms for the circuit synthesis.