#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

= Programmable photonics

As previously mentioned in @motivation, the primary goal of this thesis is to find which paradigms and languages are best suited for the programming of photonic @fpga[s]. However, before discussing these topics in detail, it is necessary to start discussing the basic of photonic processors. This chapter will therefore start by discussing what photonic processors are, what niche they fill and how they work. From this, the chapter will then move on to discuss the different types of photonic processors and how they differ from each other. Finally, this chapter will conclude with the first and most important assumption made in all subsequent design decisions.

#info-box(kind: "info")[
    In this document, the names Photonic @fpga and Photonic Processor are used interchangeably. They are both used to refer to the same thing, that being a programmable photonic device. The difference is that the former predates the latter in its use. Sometimes, they are also called #gloss("fppga", long: true) #cite("perez-lopez_multipurpose_2020").
]

== Photonic processors <photonic_processor>

In essence, a photonic @fpga or photonic processor is the optical analogue to the traditional digital @fpga. It is composed of a certain number of gates connected using waveguides, which can be programmed to perform some function #cite("capmany_programmable_2016"). However, whereas traditional @fpga[s] use electrical current to carry information, photonic processors use light contained within waveguide to perform analog processing tasks.

However, it is interesting to note that, just like traditional @fpga[s], there are devices that are more general forms of programmable #gloss("pic", long: true)#cite("bogaerts_programmable_2020-1") than others, just like @cpld[s] are less general forms of @fpga[s]. As any @pic that has configurable elements could be considered a programmable @pic, it is reasonable to construct a hierarchy of programmability, where the most general device is the photonic processor, which is of interest for this document, going down to the simplest tunable structures.

Therefore, looking at @pic_hierarchy, one can see that four large categories of @pic can be built based on their programmability. The first ones #link(label("pic_hierarchy"))[(a)] are not programmable at all, they require no tunable elements and are therefore the simplest. The second category #link(label("pic_hierarchy"))[(b)] contains circuits that have tunable elements but fixed function, the tunable element could be a tunable coupler, modulator, phase shifter, etc. and allows the designer to tweak the properties of their circuit during use, for purposes such as calibration, temperature compensation, signal modulation or more generally, altering the usage of the circuit. The third kind of @pic is the feedforward architecture #link(label("pic_hierarchy"))[(c)], which means that the light is expected to travel in a specific direction, it is composed of gates, generally containing tunable couplers and phase shifters. Additionally, external devices such as high speed modulators, amplifiers and other elements can be added. Finally, the most generic kind of programmable @pic is the recirculating mesh #link(label("pic_hierarchy"))[(d)], which, while also composed of tunable couplers and phase shifters, allows the light to travel in either direction, allowing for more general circuits to be built as explored in @feedfoward_vs_recirculating.

#figure(
    caption: [
        A hierachy of programmable #gloss("pic", long: true, suffix: "s"), starting at the non-programmable single function @pic (a), moving then to the tunable @pic (b), the feedfoward architecture (c) and finally to the photonic processor (d).
    ],
)[
    #table(
        columns: (auto, auto, auto, auto),
        stroke: none,
        image("../assets/logo_ea.png", width: 100pt),
        image("../assets/logo_ea.png", width: 100pt),
        image("../assets/logo_ea.png", width: 100pt),
        image("../assets/logo_ea.png", width: 100pt),
        "(a)",
        "(b)",
        "(c)",
        "(d)",
    )
]<pic_hierarchy>

In this work, the focus will be on the fourth kind of tunability, the most generic. However, the work can also apply to photonic circuit design in general and is not limited to photonic processors. As will be discussed in @feedfoward_vs_recirculating, the recirculating mesh is the most general kind of programmable @pic, but also the most difficult to represent with a logic flow of operation due to the fact that the light can travel in either direction. Therefore, the following question may be asked:

#info-box(kind: "question", footer: [ This will be answered in @feedforward_approx. ])[
    At a sufficiently high level of abstraction, can a photonic processor be considered to be equivalent to a feedforward architecture?
]

This question, which will be the driving factor behind this first section, will be answered in @feedforward_approx. However, before answering this question, it is necessary to first discuss the different types of photonic processors and how they differ from each other. Additionally, the answer to that question will show that the solution suggested in this thesis is also applicable for feedfoward systems.

=== Components

As previously mentioned, a photonic gate consists of several components. This section will therefore discuss the different components that can be found in a photonic processor and how they work, as well as some of the more advanced components that can also be included as part of a photonic processor.

==== Waveguides

The most basic photonic component that is used in #gloss("pic", suffix: "s") is the waveguide. It is a structure that confines light within a certain area, allowing it to travel, following a pre-determined path from one place on the chip to another. Waveguides are, ideally, low loss, meaning that as small of a fraction of the light as possible is lost as it travels through the waveguide. They can also be made low dispersion allowing for the light to travel at the same speed regardless of its wavelength. This last point allows modulated signals to be transmitted without distortion, which is important for high speed communication.

==== Tunable 2x2 couplers

A 2x2 tunable coupler is a structure that allows two waveguides to interact in a pre-determined way. It is composed of two waveguides whose coupling, that being the amount of light "going" from one waveguide to the other, can be controlled. There are numerous ways of implementing couplers. In @tunable_2x2 an overview of the different modes of operation of a 2x2 coupler is given. It shows that, depending on user input, an optical coupler can be in one of three modes, the first one (b) is the bar mode, where there is little to no coupling between the waveguides, the second one (c) is the cross mode, where the light is mostly coupled from one waveguide to the other and the third one (d) is the partial mode, where the light is partially coupled from one waveguide to the other based on proportions given by the user.

The first mode (b), allows light to travel without interacting, allowing for tight routing of light in a photonic mesh. The second mode is also useful for routing, by allowing signals to cross with little to no interference. The final state allows the user to interfere two optical signals together based on predefined proportions. This is useful for applications such as filtering for ring resonators or splitting.

#figure(
    caption: [
        Different states of a 2x2 optical coupler, (a) a simplified coupler, (b) in "bar" mode, (c) in "cross" mode, (d) in "partial" mode.
    ],
)[
    #table(
        columns: (auto, auto, auto, auto),
        stroke: none,
        image("../assets/logo_ea.png", width: 100pt),
        image("../assets/logo_ea.png", width: 100pt),
        image("../assets/logo_ea.png", width: 100pt),
        image("../assets/logo_ea.png", width: 100pt),
        "(a)",
        "(b)",
        "(c)",
        "(d)",
    )
]<tunable_2x2>

There are many construction techniques for building 2x2 couplers, each with their own advantages and disadvantages. The most common ones are the Mach-Zehnder interferometers with two phase shifters. However, other techniques involve the user of #gloss("mems") or liquid crystals #cite("bogaerts_programmable_2020-1", "capmany_programmable_2016", "perez_programmable_2019").

==== Detectors

#todo("todo")

=== Meshes

#todo("todo")

=== Fast modulators

=== Fast detectors

=== Amplifiers

=== Filters

=== Feedforward and recirculating mesh <feedfoward_vs_recirculating>

Both architecture rely on the same components #cite("bogaerts_programmable_2020-1"), those being #gloss("2x2", suffix: "s", long: true), optical phase shifters and optical waveguides. These elements are combined in all-optical gates which can be tuned to achieve the user's intent. Additionally, to provide more functionality, the meshed gates can also be connected to other devices, such as high speed modulators, amplifiers, etc. #cite("bogaerts_programmable_2020-1", "capmany_programmable_2016", "perez_programmable_2019")

The primary difference between a feedfoward architecture and a recirculating architecture, is the ability for the designer to make light travel both ways in one waveguide. As is known #cite("ghatak_introduction_1998"), in a waveguide light can travel in two direction with little to no interactions. This means that, without any additional waveguides or hardware complexity, a photonic circuit can be made to support two guiding modes, one in each direction. This property can be used for more efficient routing #todo[cite] along with the creation of more structures.

As it has been shown#cite("perez_programmable_2019"), recirculating meshes offer the ability to create more advanced structures such as @iir elements, whereas feedforward architectures are limited to @fir systems. This is due to inherent infinite impulse response of the ring resonator cell, while in a feedforward architecture, the Mach-Zehnder interferometers have a finite impulse response. But, not only does the recirculating mesh allow the creation of @iir cells, it still allows the designer to create @fir cells when needed.

=== Potential use cases of photonic processors <photonic_processors_use_cases>

=== Embedding of photonic processor in a larger system <photonic_processors_in_systems>

== Circuit representation <circuit_repr>

=== Bi-directional systems

=== Feedforward approximation <feedforward_approx>

As mentioned in @photonic_processor, a type of photonic processor is the feedfoward processor, which, assumes that light "flows" from an input port to an output port in a single direction. However, we are interested in the more complex, more capable processor that uses recirculating meshes. Therefore, one may wonder if the assumption that one can design a generic circuit using a feedforward approximation is valid. In this section, we will show that, given a sufficient level of abstraction, any bi-directional photonic circuit can be represented by an equivalent, higher-level, feedforward circuit.

Theory has shown that one may view a waveguide as a four port devices, with each end of the waveguide being composed of two ports: an incoming and an outgoing port. This is due to the fact that, in a waveguide, light can travel in both directions with little to no interactions. This means that, in a waveguide, one can have two guiding modes, one in each direction @xing_behavior_2017. Therefore, one can already see that each physical port, as well as each waveguide in the device can be split into two ports, one for each direction. This is a common approximation done in many simulation tools that assume that each signal is an #emph[analytical signal] at a fixed wavelength in a single mode @bogaerts_silicon_2018.

This therefore gives the first approximation: each physical port is split into two ports, one for each direction. This means that, from the perspective of a user, they can easily split the light incoming from a port and process it in the desired way. And they can easily output light that has been processed into a port with little to no interactions with the rest of the circuit. This is the first step in the feedforward approximation.

The second step in this approximation is to show that, given a sufficient level of abstraction, any circuit can be represented as an element that has zero or more input ports and zero or more output ports. But, as previously mentioned, some circuits, such as ring resonators, have an #gloss("iir", long: true) that requires a recirculating mesh to be built. This is where the abstraction comes into play. One can view a ring resonator as a black box that has input and output ports and that has a certain scattering matrix that links each pair of input and output port as can be seen in @black_box.

#figurex(
    title: [ A black box representation of a ring resonator. ],
    caption: [
        A black box representation of a ring resonator. The input and output ports are labeled as $a_"in", b_"in"$ and $a_"out", b_"out"$ respectively.",
    ],
)[
    #image("../figures/ring_resonator_black_box.png", width: 200pt)
]<black_box>

#info-box(kind: "conclusion")[
    It has been shown that, given a sufficient level of abstraction, any bi-directional photonic circuit can be represented by an equivalent, higher-level, feedforward circuit. This result is crucial for the formulation of the requirements for the programming interface of such a photonic processor. And is the basis on which the rest of this document is built.
]

== Difficulties <fppga-difficulties>

=== Wavelength as a continuum

=== Amplitude as a continuum

=== Temperature dependence

=== Manufacturing tolerances

=== Non-linearities


== Initial design requirements <initial_requirements>

=== Interfacing <interface>

=== Programming <programming>

=== Reconfigurability <reconfigurability>

=== Tunability <tunability>