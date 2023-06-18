#import "ieee.typ": *
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

Photonic processors can be used in many fields, such as telecommunication, sensor, medical, and quantum computing. This section will discuss some of the use cases of photonic processors.

= PHÔS

= 16-QAM 400Gb/s transmitter

= Conclusion

== Future work