#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/lists.typ": *
#import "../elems/template.typ": todo
#import "./glossary.typ": *

= Programmable photonics

As previously mentioned in @motivation, the primary goal of this thesis is to find which paradigms and languages are best suited for the programming of photonic #gloss("fpga", suffix: "s"). However, before discussing these topics in detail, it is necessary to start discussing the basic of photonic processors. This chapter will therefore start by discussing what photonic processors are, what niche they fill and how they work. From this, the chapter will then move on to discuss the different types of photonic processors and how they differ from each other. Finally, this chapter will conclude with the first and most important assumption made in all subsequent design decisions.

#info_box(kind: "info")[
    In this document, the names Photonic #gloss("fpga") and Photonic Processor are used interchangeably. They are both used to refer to the same thing, that being a programmable photonic device. The difference is that the former predates the latter in its use. Sometimes, they are also called #gloss("fppga", long: true) #cite("perez-lopez_multipurpose_2020").
]

== Photonic processors

In essence, a photonic #gloss("fpga") or photonic processor is the optical analogue to the traditional digital #gloss("fpga"). It is composed of a certain number of gates connected using waveguides, which can be programmed to perform some functions #cite("capmany_programmable_2016"). However, whereas traditional #gloss("fpga", suffix: "s") uses electrical current to carry information, photonic processor uses light contained within waveguide.

However, it is interesting to note that, just like traditional #gloss("fpga", suffix: "s"), there are devices that are more general forms of programmable #gloss("pic", long: true)#cite("bogaerts_programmable_2020-1") than others. As any #gloss("pic") that has configurable elements could be considered a programmable #gloss("pic"), it is reasonable to construct a hierarchy of programmability, where the most general device is the photonic processor, which is of interest for this document, going down to the simplest tunable structures.

Therefore, looking at @pic_hierachy, one can see that there are four large categories of #gloss("pic") based on their programmability. The first ones (a) are not programmable at all, they require no tunable elements and are therefore the simplest. The second category (b) contains circuits that have tunable elements but fixed function, the tunable element could be a tunable coupler, modulator, phase shifter, etc. and allows the designed to tweak the properties of their circuit during use. The third kind of #gloss("pic") is the feedforward architecture (c), which means that the light is expected to travel in a specific direction, it is composed of gates, generally containing tunable couplers and phase shifters. Additionally, external devices such as high speed modulators, amplifiers and other elements can be added. Finally, the most generic kind of programmable #gloss("pic") is the recirculating mesh (d), which, while also composed of tunable couplers and phase shifters, allows the light to travel in either direction, allowing for more general circuits to be built as explored in @feedfoward_vs_recirculating.

#picture(
    cap: [
        A hierachy of programmable #gloss("pic", long: true, suffix: "s"), starting at the non-programmable single function #gloss("pic") (a), moving then to the tunable #gloss("pic") (b), the feedfoward architecture (c) and finally to the photonic processor (d).
    ],
    label: <pic_hierachy>
)[
    #table(
        columns: (auto, auto, auto, auto),
        stroke: none,
        none,
        none,
        none,
        none,
        "(a)",
        "(b)",
        "(c)",
        "(d)",
    )
]

In this work, the focus will be on the fourth kind of tunability, the most generic. However, the work can also apply to photonic circuit design in general and is not limited to photonic processors. As will be discussed in @feedfoward_vs_recirculating, the recirculating mesh is the most general kind of programmable #gloss("pic"), but also the most difficult to represent with a logic flow of operation due to the fact that the light can travel in either direction. Therefore, the following question may be asked:

#info_box(kind: "question")[
    At a sufficiently high level of abstraction, can a photonic processor be considered to be equivalent to a feedforward architecture?

    #box(stroke: none)[
        #v(-12pt)
        #set text(fill: info_stroke(kind: "question"))
        #repeat(strong("  -  "))
    ]
    This will be answered in @feedforward_approx.
]


=== Feedforward and recirculating mesh <feedfoward_vs_recirculating>

Both architecture rely on the same components #cite("bogaerts_programmable_2020-1"), those being 2x2 tunable couplers, optical phase shifters and optical waveguides. These elements are combined in all-optical gates which can be tuned to achieve the user's intent. Additionally, to provide more functionality, the meshed gates can also be connected to other devices, such as high speed modulators, amplifiers, etc. #cite("bogaerts_programmable_2020-1", "capmany_programmable_2016", "perez_programmable_2019")

The primary difference between a feedfoward architecture and a recirculating architecture, is the ability for the designer to make light travel both ways in one waveguide. As is known #cite("ghatak_introduction_1998"), in a waveguide light can travel in two direction with little to no interactions. This means that, without any additional waveguides or hardware complexity, a photonic circuit can be made to support two guiding modes, one in each direction. This property can be used for more efficient routing #todo[cite] along with the creation of more structures.

As it has been shown#cite("perez_programmable_2019"), recirculating meshes offer the ability to create more advanced structures such as #gloss("iir") elements, whereas feedforward architectures are limited to #gloss("fir") systems. This is due to inherent infinite impulse response of the ring resonator cell, while in a feedforward architecture, the Mach-Zehnder interferometers have a finite impulse response. But, not only does the recirculating mesh allow the creation of #gloss("iir") cells, it still allows the designed to create #gloss("fir") cells if needed.

=== Potential use cases of photonic processors <photonic_processors_use_cases>

=== Embedding of photonic processor in a larger system <photonic_processors_in_systems>

== Circuit representation <circuit_repr>

=== Bi-directional systems

=== Feedforward approximation <feedforward_approx>

#info_box(kind: "important")[
    It has been shown that, given a sufficient level of abstraction, any bi-directional photonic circuit can be represented by an equivalent, higher-level, feedforward circuit. This result is crucial for the formulation of the requirements for the programming interface of such a photonic processor. And is the basis on which the rest of this document is built.
]

== Initial design requirements <initial_requirements>

=== Interfacing <interface>

=== Programming <programming>

=== Reconfigurability <reconfigurability>

=== Tunability <tunability>