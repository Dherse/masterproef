#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

= Programmable photonics <sec_programmable_photonics>

As previously mentioned in @motivation, the primary goal of this thesis is to find which paradigms and languages are best suited for the programming of photonic @fpga[s]. However, before discussing these topics in detail, it is necessary to start discussing the basic of photonic processors. This chapter will therefore start by discussing what photonic processors are, what niche they fill and how they work. From this, the chapter will then move on to discuss the different types of photonic processors and how they differ from one another. Finally, this chapter will conclude with the first and most important assumption made in all subsequent design decisions.

#info-box(kind: "info")[
    In this document, the names Photonic @fpga and Photonic Processor are used interchangeably. They are both used to refer to the same thing, that being a programmable photonic device. The difference is that the former predates the latter in its use. Sometimes, they are also called #gloss("fppga", long: true) #cite("perez-lopez_multipurpose_2020").
]

== Photonic processors <photonic_processor>

In essence, a photonic @fpga or photonic processor is the optical analogue to the traditional digital @fpga. It is composed of a certain number of gates connected using waveguides, which can be programmed to perform some function #cite("capmany_programmable_2016"). However, whereas traditional @fpga[s] use electrical current to carry information, photonic processors use light contained within waveguide to perform analog processing tasks.

However, it is interesting to note that, just like traditional @fpga[s], there are devices that are more general forms of programmable #gloss("pic", long: true)#cite("bogaerts_programmable_2020-1") than others, just like @cpld[s] are less general forms of @fpga[s]. As any @pic that has configurable elements could be considered a programmable @pic, it is reasonable to construct a hierarchy of programmability, where the most general device is the photonic processor, which is of interest for this document, going down to the simplest tunable structures.

Therefore, looking at @pic_hierarchy, one can see that four large categories of @pic can be built based on their programmability. The first ones #link(<pic_hierarchy>)[(a)] are not programmable at all, they require no tunable elements and are therefore the simplest. The second category #link(<pic_hierarchy>)[(b)] contains circuits that have tunable elements but fixed function, the tunable element could be a tunable coupler, phase shifter, etc. and allows the designer to tweak the properties of their circuit during use, for purposes such as calibration, temperature compensation, or more generally, altering the behaviour of the circuit. The third kind of @pic is the feedforward architecture #link(<pic_hierarchy>)[(c)], which means that the light is expected to travel in a specific direction, it is composed of gates, generally containing tunable couplers and phase shifters. Additionally, external devices such as high speed modulators, amplifiers and other elements can be added. Finally, the most generic kind of programmable @pic is the recirculating mesh #link(<pic_hierarchy>)[(d)], which, while also composed of tunable couplers and phase shifters, allows the light to travel in either directions, allowing for more general circuits to be built as explored in @sec_meshes.

#figurex(
    kind: image,
    title: [ A hierarchy of programmable #gloss("pic", long: true, suffix: "s"). ],
    caption: [
        A hierarchy of programmable #gloss("pic", long: true, suffix: "s"), starting at the non-programmable single function @pic (a), moving then to the tunable @pic (b), the feedfoward architecture (c) and finally to the photonic processor (d).
    ],
)[
    #table(
        columns: (auto, auto),
        stroke: none,
        align: center + horizon,
        image(
            "../figures/drawio/non-programmable-pic.png",
            width: 100%,
            alt: "Shows a non programmable PIC composed of three ports, a double ring resonator filter, a MZI-based modulator and a photodetector."
        ),
        image(
            "../figures/drawio/tunable-pic.png",
            width: 100%,
            alt: "Shows a non tunable PIC composed of three ports, a double ring resonator filter, where the directional couplers have been replaced with tunable couplers and the rings have been replaced with tunable phase shifter, a MZI-based modulator and a photodetector."
        ),
        "(a)",
        "(b)",
        image(
            "../figures/drawio/feedforward-pic.png",
            width: 100%,
            alt: "Shows a very simple feedforward PIC composed for eight ports, each going in groups of two to gates, in total there are five gates."
        ),
        image(
            "../figures/drawio/recirculating.png",
            width: 100%,
            alt: "Shows a very simple recirculating PIC composed for eight ports, three hexagonal sections, and two modulators."
        ),
        "(c)",
        "(d)",
    )
]<pic_hierarchy>

In this work, the focus will be on the fourth kind of tunability, the most generic. However, the work can also apply to photonic circuit design in general and is not limited to photonic processors. As will be discussed in @sec_meshes, the recirculating mesh is the most general kind of programmable @pic, but also the most difficult to represent with a logic flow of operation due to the fact that the light can travel in either direction. Therefore, the following question may be asked:

#info-box(kind: "question", footer: [ This will be answered in @feedforward_approx. ])[
    At a sufficiently high level of abstraction, can a photonic component be considered to be equivalent to a feedforward component?
]

This question, which will be the driving factor behind this first section, will be answered in @feedforward_approx. However, before answering this question, it is necessary to first discuss the different types of photonic processors and how they differ from one another. Additionally, the answer to that question will show that the solution suggested in this thesis is also applicable for feedfoward systems. As this thesis is not focused on the creation of a photonic processor, but on the programming of said processor, building techniques will not be explored further.

=== Components

As previously mentioned, a photonic gate consists of several components. This section will therefore discuss the different components that can be found in a photonic processor and how they work, as well as some of the more advanced components that can also be included as part of a photonic processor.

==== Waveguides

The most basic photonic component that is used in #gloss("pic", suffix: "s") is the waveguide. It is a structure that confines light within a certain area, allowing it to travel, following a pre-determined path from one place on the chip to another. Waveguides are, ideally, low loss, meaning that as small of a fraction of the light as possible is lost as it travels through the waveguide. They can also be made low dispersion allowing for the light to travel at the same speed regardless of its wavelength. This last point allows modulated signals to be transmitted without distortion, which is important for high speed communication.

==== Tunable 2x2 couplers

A @2x2 is a structure that allows two waveguides to interact in a pre-determined way. It is composed of two waveguides whose coupling, that being the amount of light "going" from one waveguide to the other, can be controlled. There are numerous ways of implementing couplers. In @tunable_2x2 an overview of the different modes of operation of a @2x2 is given, along with a basic diagram of a @2x2 #link(<tunable_2x2>)[(a)]. It shows that, depending on user input, an optical coupler can be in one of three modes, the first one #link(<tunable_2x2>)[(b)] is the bar mode, where there is little to no coupling between the waveguides, the second one #link(<tunable_2x2>)[(c)] is the cross mode, where the light is mostly coupled from one waveguide to the other and the third one #link(<tunable_2x2>)[(d)] is the partial mode, where the light is partially coupled from one waveguide to the other based on proportions given by the user.

The first mode #link(<tunable_2x2>)[(b)], allows light to travel without interacting, allowing for tight routing of light in a photonic mesh. The second mode is also useful for routing, by allowing signals to cross with little to no interference. The final state allows the user to interfere two optical signals together based on predefined proportions. This is useful for applications such as filtering for ring resonators or splitting.

#figurex(
    kind: image,
    title: [ Different states of a 2x2 optical coupler. ],
    caption: [
        @2x2 (a) and its different states: in "bar" mode (b), in "cross" mode (c), and in "partial" mode (d). The blue triangles are optical inputs and outputs.
    ],
)[
    #table(
        columns: 2,
        stroke: none,
        align: center + horizon,
        image(
            "../figures/drawio/2x2_coupler.png",
            width: 80%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in dashed line and bar in solid line."
        ),
        image(
            "../figures/drawio/2x2_coupler_bar.png",
            width: 80%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: bar in solid line."
        ),
        "(a)",
        "(b)",
        image(
            "../figures/drawio/2x2_coupler_cross.png",
            width: 80%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in solid line."
        ),
        image(
            "../figures/drawio/2x2_coupler_partial.png",
            width: 80%,
            alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in dashed line and bar in solid line."
        ),
        "(c)",
        "(d)",
    )
]<tunable_2x2>

#info-box(kind: "note")[
    The color scheme shown in @tunable_2x2 for the different modes is kept throughout this document when showing photonic gates and their modes.
]

There are many construction techniques for building @2x2[s], each with their own advantages and disadvantages. The most common ones are the Mach-Zehnder interferometers with two phase shifters. However, other techniques involve the use of #gloss("mems") or liquid crystals #cite("bogaerts_programmable_2020-1", "capmany_programmable_2016", "perez_programmable_2019").

==== Detectors <sec_detectors>

Detectors are used to turn an optical signals into an electrical signals. In photonic processors, there are commonly two kinds, the first being low speed detectors used to measure optical power at several points inside of the processor, and high speed detectors that are used to demodulate high speed signals. There are generally built from photodiodes, however other building techniques exist. For the purposes of this thesis, only the overall functionality needs to be understood.

==== Modulators <sec_modulators>

Modulates are, contrary to detectors, used to turn an electrical signals into an optical signals. They do not do this by producing the signal, but by modulating the phase or the amplitude of the optical signal. There are several kinds of modulators, for high speed modulators, they are generally built from drop @reed_silicon_2010.

=== Meshes <sec_meshes>

There are four kinds of meshes that can be built for programmable photonics, shown in @fig_meshes: the feedforward mesh #link(<fig_meshes>)[(a)], and three kinds of recirculating mesh: hexagonal #link(<fig_meshes>)[(b)], rectangular #link(<fig_meshes>)[(c)], and triangular meshes #link(<fig_meshes>)[(d)]. Additionally, it is also possible to create meshes which are not made of a single kind of cell, but these will not be discussed in this thesis. This section will discuss the major differences between the feedforward and the recirculating architectures. In the case of this thesis, hexagonal meshes are the primary focus, this is due to the fact that they are the most capable kind of meshes @bogaerts_programmable_2020-1.

#figurex(
    kind: image,
    title: [ Different kinds of programmable photonic meshes. ],
    caption: [
        The four kinds of programmable meshes: feedforward (a), hexagonal (b), rectangular (c), and triangular (d).
    ],
)[
    #table(
        columns: 2,
        stroke: none,
        align: center + horizon,
        image(
            "../figures/drawio/mesh_feedforward.png",
            width: 90%,
            alt: "Shows a feedforward photonic mesh, setup in a triangular pattern."
        ),
        image(
            "../figures/drawio/mesh_hexagonal.png",
            width: 90%,
            alt: "Shows an hexagonal photonic mesh."
        ),
        "(a)",
        "(b)",
        image(
            "../figures/drawio/mesh_square.png",
            width: 90%,
            alt: "Shows a square photonic mesh."
        ),
        image(
            "../figures/drawio/mesh_triangular.png",
            width: 90%,
            alt: "Shows a triangular photonic mesh."
        ),
        "(c)",
        "(d)",
    )
]<fig_meshes>

All of the architectures rely on the same components #cite("bogaerts_programmable_2020-1"), those being #gloss("2x2", suffix: "s", long: true), optical phase shifters and optical waveguides. These elements are combined in all-optical gates which can be configured to achieve the user's intent. Additionally, to provide more functionality, the meshed gates can also be connected to other devices, such as high speed modulators, amplifiers, etc. #cite("bogaerts_programmable_2020-1", "capmany_programmable_2016", "perez_programmable_2019").

The primary difference between a feedfoward architecture and a recirculating architecture, is the ability for the designer to make light travel both ways in one waveguide. As is known #cite("ghatak_introduction_1998"), in a waveguide light can travel in two direction with little to no interactions. This means that, without any additional waveguides or hardware complexity, a photonic circuit can be made to support two guiding modes, one in each direction. This property can be used for more efficient routing along with the creation of more complex and varied structures #cite("bogaerts_programmable_2020-1").

As it has been shown#cite("perez_programmable_2019"), recirculating meshes offer the ability to create more advanced structures such as @iir elements, whereas feedforward architectures are limited to @fir components. This is due to the inability of feedfoward system to express feedback loops, limiting them to @fir components, whereas recirculating meshes allow the creation of feedback loops and therefore @iir components. Indeed, in a feedforward mesh, the typical structure being built is the Mach-Zehnder interferometer, whereas in a recirculating mesh, one may build structures such as ring resonators, which are inherently @iir components. Additionally, recirculating mesh are still capable of expressing structures such as @mzi, meaning that they are capable of representing both @iir components, but also @fir components.

#info-box(kind: "conclusion")[
    The recirculating mesh is more capable as it allows feedback loops, and therefore @iir components, whereas the feedforward mesh is limited to @fir components.
]

=== Potential use cases of photonic processors <photonic_processors_use_cases>

There are many uses cases for photonic processors, some of which will actually be shown in this thesis as examples in @sec_examples. However, this section will first discuss areas of particular interest for photonic processors. The first and primary advantage of photonic processors, is that they can replace the need to develop custom @pic[s], which is extremely expensive. They can also be used during the development of said @pic[s] as a platform for prototyping. Another one of their advantages, which broadens their reach, is the ability to reprogram the processor in the field, just like a traditional @fpga. In the following paragraphs, several broad areas of interest will be discussed, along with examples of applications in those areas. Those areas are namely, telecommunication, optical computation, @rf processing, and sensing applications.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Telecommunications*]
}
The telecommunications industry is one of the largest existing user of photonic technologies, most notably optical fibers. Therefore, it should come as no surprises that this is one of the applicative areas of particular interests for programmable photonics. They can be used by service providers close to their customers for multiplexing, transceivers, and resource allocations in fiber-to-the-home deployments @bogaerts_programmable_2020-1.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Optical computation*]
}
In some cases, such as machine learning, it has been shown that processing can be accelerated and energy efficiency improved by using photonic processing. As photonic processors are, by their nature, reprogrammable, they could be used as a tool for acceleration of workloads in the datacenter and edge computing scenarios. Companies such as _LightMatter_ are already making strides in optical computing accelerators for machine learning applications @demirkiran_electro-photonic_2021.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*RF processing*]
}
@rf processing refers to the concept of processing radio signals using photonic technologies, by means of modulating the @rf signals of interest onto optical signals, and then benefiting from the low-energy, very high bandwidth of photonic components to efficiently process signals in the analog domain. This as interest for RADAR applications, but also mm-Wave communications, and 5G @perez-lopez_silicon_2021.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Sensing*]
}
Sensing can take many forms, such as LiDAR, which is used in self-driving cars, or even in the medical field, such as in the case of sensing for the detection of cancerous cells, where a photonic processor could be used to process the signals produced by a sensor #cite("bogaerts_programmable_2020-1", "daher_design_2022"). Additionally, in recent years, fiber sensing has been used in many applications, such as aviation, oil and gas, and even more fields #cite("trutzel_smart_2000", "ashry_review_2022"). The advantages of photonic processors for these use cases, allow the reduction of weight, overall system complexity, and design cost. Therefore, photonic processors are of interest for sensing applications, as they can significantly reduce system design cost.

=== Embedding of photonic processor in a larger system <photonic_processors_in_systems>

In this thesis, the focus will mostly be on the design of circuits for photonic processors, however, one must keep in mind that photonic processors are not standalone systems, but rather components of larger, more complex systems. Complex systems are rarely limited to a single domain, indeed they are often composed of multiple technologies, such as digital electronics, analog electronics, photonic circuits, realtime processing, etc. Therefore, it is important to understand how photonic processors can be embedded in these larger systems, but also how it can be integrated in existing systems as well. The act of integrating multiple technologies together is often called codesign. Photonic processors in themselves are already a form of codesign, as they are composed of both photonic and electronic components. But in this section, the focus will be on how photonic processors can be integrated in larger designs.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Integration with electronics*]
}
As previously mentioned, photonic processors integrate two kinds of electro-optic interfaces: modulators and detectors. These components can be used to interface the insides of the photonic processor with a larger electronic scheme. Due to their nature, these components can be used for both digital electronics and analog electronics. Indeed, photonic processors can therefore be used as analog signal processors, and be used in mixed-domain systems. This is of particular interest for @rf signal processing, as photonic processors can offer high bandwidth, high speed, and low energy consumption signal processing, all of which are difficult to simultaneously achieve in analog electronics.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Integration with software*]
}
While integration with electronics will not be discussed at length in this thesis, integration with software will. As will be discussed later on in this section, in @initial_requirements, there is an interest in integration software control over the functionality and behaviour of photonic processors. Due to their nature, photonic processors cannot take decisions, but they can be interface with software that is able to process data and make decisions. Additionally, software may be used by the designer, to create feedback loops to control their photonic circuit from software.

In @fig_uses, one can see how a photonic processor may be integrated with analog electronics, digital electronics, and embedded software. By using @dac[s] and @adc[s] to interface with the photonic processor, an @fpga for high speed digital processing, and an embedded processor for control. However, while it does not show how external inputs and outputs may be used, it provides a high-level overview of how a photonic processor may be interfaced in a bigger system, as well as some of its internal components.

#figurex(
    title: [
        Figure showing the integration of a photonic processor with electronics and software.
    ],
    caption: [
        Figure showing the integration of a photonic processor with electronics and software. It shows how a photonic processor is composed of the photonic @ic, but also of @adc[s] and @dac[s] to interface with its integrated controller. It then shows how the overall photonic processor may be integrated with digital electronics and software running on an embedded processor. Blue elements represent digital electronics, while green elements represent analog electronics.
    ]
)[
    #image(
        "../figures/drawio/uses.png",
        width: 70%,
        alt: "Shows a photonic processor interfaced to two DACs and to ADCs on either side, communicating with an FPGA, the FPGA then communicates to an embedded processor, which itself communicates to the digital integrated controller for the photonic processor. This integrated controller then controls a set of ADCs and DACs inside of the photonic processor to control the photonic gates in the processor."
    )
] <fig_uses>

== Circuit representation <circuit_repr>

When creating tools for circuit design, it is important to careful consider how the circuit will be represented, as both the users of the tool, and its developers, will need to interact with this model for many steps in the design process, such as for simulation, optimization, synthesis, and validation. As far as this thesis is concerned, it will use one of the most common photonic circuit representation, that of the netlist. In addition, the guided mode in each direction of the waveguides will be represented as a separate net.

#info-box(kind: "definition", footer: [ Adapted from @netlist. ])[
    A *netlist* is a list of components and their connections, which is used to represent a photonic circuit. A *net* is a connection between two components, which represents a waveguide.
]

Netlists are a common abstractions in electronics to represent a list of components and their connections. However, in the case of photonics, the definition is altered and made more limited: in electronics, a net can be connected to many components, however, in the case of a photonic circuit, the port of a component is only ever connected to the port of another component, never more. This is because in this thesis, splitters are considered to be components in and off themselves, therefore splitting the signal is the equivalent to adding a component to the circuit.

Bidirectional ports, such as the ones on the edge of a photonic processor, are represented as two separate logical ports, one for each direction: incoming and outgoing light. This is acceptable because in photonic waveguides, light can trave in both direction with little to no interaction. Therefore, one can model these modes as being two separate signals @xing_behavior_2017. This model is particularly helpful in the case of recirculating photonic meshes, as it helps distinguish the direction of the light in the circuit, making it easier to efficiently reuse photonic gates for bidirectional signal routing.

=== Feedforward approximation <feedforward_approx>

As mentioned in @photonic_processor, a type of programmable photonic @ic is the feedfoward processor, which, assumes that light travels from an input port to an output port in a single direction. However, this thesis is focused on the more general kind of processor that uses recirculating meshes. Therefore, one may wonder whether it is possible to model components using a feedforward approximation. Indeed, in this section, it will be discussed the axiom that any photonic circuit can be represented as a feedforward circuit, given a sufficiently high level of abstraction.

From theory, it is known that light can travel in both directions of a waveguide with little to no interactions @xing_behavior_2017. Additionally, for reciprocal, and time invariant components the scattering matrix defining the circuit is symmetric. Conveniently, it so happens that most passive, or pseudo-passive#footnote[Components that are actively powered, but slow varying enough to be considered passive. ] photonic components are reciprocal, and time invariant, therefore, most photonic components can always be represented under this formalism. For components that are not reciprocal, one can simply split the component into two components, one for each direction, and model them as set of separate components. Finally, components that are not time invariant, such as modulators, can be modeled as time invariant components as long as the variation in time is slow enough, compared to the oscillation period of the light, to be considered constant. Finally, for components such as isolators, one can consider them as a three port device with two inputs one being sunk, while the other is not, and one output.

Some components may be difficult to accurately model in this formalism, for example @soa[s] can be difficult to express in this formalism since their gain is spread over both modes. However, this can be solved by modeling the @soa as a unidirectional component. This removes the ability to model the @soa as a bidirectional component, but it is a reasonable approximation for most cases. Additionally, if the user were to really need to model the @soa as a bidirectional component, they could model it as two components whose exact response depends on the other component.

Intuitively, one can think of these abstracted models as black boxes, where the contents do not matter as long as the expected functionality is present. For example, a ring resonator can be modeled as a black box with two inputs and two outputs, where the input and output ports are labeled as $a_"in", b_"in"$ and $a_"out", b_"out"$ respectively. This is shown in @fig_ring_resonator_black_box. In this model, one can use the properties of a ring resonator to model the relations betweens these ports.

#figurex(
    title: [ A black box representation of a ring resonator. ],
    caption: [
        A black box representation of a ring resonator. The input and output ports are labeled as $a_"in", b_"in"$ and $a_"out", b_"out"$ respectively.,
    ],
)[
    #image(
        "../figures/ring_resonator_black_box.png",
        width: 200pt,
        alt: "Shows an unloaded microring resonator, with two inputs and two outputs, respectively labeled as a_in, b_in, a_out, b_out."
    )
]<fig_ring_resonator_black_box>

#info-box(kind: "conclusion")[
    It has been shown that, given a sufficient level of abstraction, any bidirectional photonic circuit can be represented by an equivalent, higher-level, feedforward circuit. This result is crucial for the formulation of the requirements for the programming interface of such a photonic processor. And is the basis on which the rest of this document is built.
]

== Non-idealities <fppga-difficulties>

Photonic processors, like all other photonic components are impacted by non-idealities, temperature dependence, and manufacturing variabilities. These impact the well-functioning of the circuit programmed within the processor. Therefore, one must take this impact into account when designing the circuit, or programming the design, in the case of a photonic processor. However, photonic processors, as high-level design platforms, should mitigate these variations as much as possible, to allow for a more efficient design process. In this section, these non-idealities will be discussed, and solutions to automatically mitigate their impact will be proposed in the following section.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Temperature dependence*]
}
Most photonic components exhibit a temperature dependence, which can be exploited to build structures such as phase shifters. However, undesired temperature changes can impact the circuit in unexpected ways. One of the traditional ways of mitigating temperature changes is to maintain the device at a constant temperature using external means, such as Pelletier elements. However, this limits the potential use cases of the device, as such means tend to be bulky, and power hungry. 

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Wavelength dependence*]
}
In addition to the aforementioned temperature dependence, photonic components also exhibit a strong wavelength dependence. Part of this dependence is desired, such as in the case of wavelength filters. Nevertheless, in all other cases, the user expects that the device behaves with a flat frequency response. Therefore, photonic processors must also provide mitigations for this dependence.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Manufacturing variability*]
}
The third kind of non-idealities is caused by variabilities in the manufacturing process of the @pic. These variabilities are due to the fact that the manufacturing process is not perfect, and therefore, the resulting devices are not identical. This means that the user's design will work differently from one chip to the next. However, one of the goals of photonic processors is to act as a high-level design platform, which means that the user should not have to worry about these variabilities. 

== Initial design requirements <initial_requirements>

In this section, the basic design requirements for a programming interface to photonic processors will be discussed. These requirements form the base of the design of the programming interface, and are therefore crucial to the design of the interface. More requirements, and more details for each of them will be provided in @sec_intent.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*High-level of abstraction & modularity*]
}
Ideally, the programming interface of photonic processors should be high-level enough that it is completely abstracted from the underlying hardware, making it easier to design circuits. Furthermore, the interface should be modular, allowing the user to build complex circuits from smaller, simpler, building blocks. This is a crucial requirement, as it allows the user to build complex circuits from incrementally more complex building blocks, which in turn allows the user to build complex circuits without having to understand the underlying hardware.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Platform independence*]
}
Code should work across devices with little to no adjustment, this would avoid the fracturing of the ecosystem that can be observed in @fpga[s], as well as reducing the burden of the user to port their code to different devices.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Tunability and reconfigurability*]
}
Ideally, the user would want to tune their design while it is running, allowing them to build feedback loops of their own control, as well as adjusting the behaviour of their design on the fly. Furthermore, the user might want to completely replace parts of the functionality of their device, without having to reprogram the entire device. This is called reconfigurability. These two features work hand-in-hand, and provide a powerful tool for the user to build their designs, and fully exploit the field-programmable nature of the photonic processor.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Solutions to non-idealities*]
} One can categorize the previously mentioned non-idealities in two categories: time invariant non-idealities, and time variant ones. The former do not change over time, such as manufacturing variabilities, and therefore can be compensated for using calibration tables that are uniquely generated for each chip, or batches of chips.  Time variant non-idealities, however, require an active approach, such as feedback loops, which the design solution for these photonic processors must provide for the user. In order to build these feedback loops, measurements must be taken of the signals of interest. These measurements are taken inside of the photonic processor, by using photodetectors built into the chip. These measurements allow the integrated control system to make adjustments to components, such as gain sections, or phase shifters, to compensate for the non-idealities.