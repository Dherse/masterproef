#import "../ugent-template.typ": *

= Programmable photonics <sec_programmable_photonics>

As previously mentioned in @motivation, the primary goal of this thesis is to
find which paradigms and languages are best suited for the programming of
photonic @fpga[s]. However, before discussing these topics in detail, it is
necessary to start discussing the basics of photonic processors. This chapter
will discuss photonic processors, their niche, and how they work. From this, the
chapter will discuss the different types of photonic processors and how they
differ. Finally, this chapter will conclude with the first and most important
assumption made in all subsequent design decisions.

#uinfo[
  This document uses the names photonic @fpga and photonic processor
  interchangeably. They both refer to the same thing: a programmable photonic
  device. The difference is that the former predates the latter in its use.
  Sometimes, they are also called #gloss("fppga", long: true) @perez-lopez_multipurpose_2020.
]

== Photonic processors <photonic_processor>

A photonic @fpga or photonic processor is the optical analogue to the
traditional digital @fpga. It comprises gates connected using waveguides, which
can be programmed to perform some function @capmany_programmable_2016.
However, whereas traditional @fpga[s] use electrical current to carry
information, photonic processors use light confined within waveguides to perform
analog processing tasks.

However, it is interesting to note that, just like traditional @fpga[s], some
devices are more general forms of programmable #gloss("pic", long: true, suffix: "s")@bogaerts_programmable_2020-1 than
others, just like @cpld[s] are less general forms of @fpga[s]. As any @pic with
configurable elements could be considered a programmable @pic, it is reasonable
to construct a hierarchy of programmability, where the most general device is
the photonic processor, which is of interest for this document, going down to
the simplest tunable structures.

Therefore, looking at @pic_hierarchy, one can build four large categories of
@pic[s] based on their programmability. The first one #link(<pic_hierarchy>)[(a)] is
not programmable at all; they require no tunable elements and are, therefore,
the simplest. The second category #link(<pic_hierarchy>)[(b)] contains circuits
that have tunable elements but fixed functions; the tunable element could be a
tunable coupler or phase shifter, and allows the designer to tweak the
properties of their circuit during use for purposes such as calibration,
temperature compensation, or more generally, altering the behaviour of the
circuit. The third kind of @pic is the feedforward architecture #link(<pic_hierarchy>)[(c)],
which means that the light is expected to travel in a specific direction; it is
composed of gates, generally containing tunable couplers and phase shifters.
External devices such as high-speed modulators, amplifiers, and other elements
can be added. Finally, the most generic kind of programmable @pic is the
recirculating mesh #link(<pic_hierarchy>)[(d)], which, while also composed of
tunable couplers and phase shifters, allows the light to travel in either
direction, allowing for more general circuits to be built as explored in
@sec_meshes.

#ufigure(
  kind: image,
  outline: [ A hierarchy of programmable #gloss("pic", long: true, suffix: "s"). ],
  caption: [
    Shows a hierarchy of programmable #gloss("pic", long: true, suffix: "s"),
    starting at the non-programmable single function @pic (a), moving then to the
    tunable @pic (b), the feedforward architecture (c) and finally to the photonic
    processor (d).
  ],
  table(
    columns: (auto, auto),
    stroke: none,
    align: center + horizon,
    image(
      "../assets/drawio/smol/non-programmable-pic.png",
      width: 100%,
      alt: "Shows a non programmable PIC composed of three ports, a double ring resonator filter, a MZI-based modulator and a photodetector.",
    ),
    image(
      "../assets/drawio/smol/tunable-pic.png",
      width: 100%,
      alt: "Shows a non tunable PIC composed of three ports, a double ring resonator filter, where the directional couplers have been replaced with tunable couplers and the rings have been replaced with tunable phase shifter, a MZI-based modulator and a photodetector.",
    ),
    "(a)",
    "(b)",
    image(
      "../assets/drawio/smol/feedforward-pic.png",
      width: 100%,
      alt: "Shows a very simple feedforward PIC composed of eight ports, each going in groups of two to gates. In total, there are five gates.",
    ),
    image(
      "../assets/drawio/smol/recirculating.png",
      width: 100%,
      alt: "Shows a very simple recirculating PIC composed of eight ports, three hexagonal sections, and two modulators.",
    ),
    "(c)",
    "(d)",
  ),
) <pic_hierarchy>

In this work, the focus will be on the fourth kind of tunability, the most
generic. However, the work can also apply to photonic circuit design in general
and is not limited to photonic processors. As discussed in @sec_meshes, the
recirculating mesh is the most general kind of programmable @pic but also the
most difficult to represent with a logic flow of operation because the light can
travel in either direction. Therefore, the following question may be asked:

#uquestion(
  footer: [ This will be answered in @feedforward_approx. ],
)[
  At a sufficiently high level of abstraction, can a photonic component be
  considered equivalent to a feedforward component?
]

This question, which will be the driving factor behind this first section, will
be answered in @feedforward_approx. However, before answering this question, it
is necessary first to discuss the different types of photonic processors and how
they differ. The answer to that question will also show that the solution
suggested in this thesis also applies to feedforward systems. As this thesis is
not focused on creating a photonic processor, but on the programming of said
processors, building techniques will not be explored in detail.

=== Components <sec_photonic_proc_comp>

As previously mentioned, a photonic gate consists of several components. This
section will therefore discuss the different components that can be found in a
photonic processor and how they work, as well as some of the more advanced
components that can also be included as part of a photonic processor.

==== Waveguides
The most basic photonic component that is used in #gloss("pic", suffix: "s") is
the waveguide. It is a structure that confines light within a specific area,
allowing it to travel, following a pre-determined path from one place on the
chip to another. Waveguides are, ideally, low loss, meaning that as small of a
fraction of the light as possible is lost as it travels through the waveguide.
They can also be made with low dispersion allowing the light to travel at the
same speed regardless of its wavelength. This last point allows modulated
signals to be transmitted without distortion, which is essential for high-speed
communication.

==== Tunable 2x2 couplers
A @2x2 is a structure that allows two waveguides to interact pre-determinedly.
It is composed of two waveguides whose coupling, the amount of light "going"
from one waveguide to the other, can be controlled. There are numerous ways of
implementing couplers. In @tunable_2x2, an overview of the different modes of
operation of a @2x2 are given, along with a basic diagram of a @2x2 #link(<tunable_2x2>)[(a)].
It shows that depending on user input, an optical coupler can be in one of three
modes; the first one #link(<tunable_2x2>)[(b)] is the bar mode, where there is
little to no coupling between the waveguides, the second one #link(<tunable_2x2>)[(c)] is
the cross mode, where the light is mainly coupled from one waveguide to the
other, and the third one #link(<tunable_2x2>)[(d)] is the partial mode, where
the light is partially coupled from one waveguide to the other based on
proportions given by the user.

The first mode #link(<tunable_2x2>)[(b)] allows light to travel without
interacting, allowing for tight routing of light in a photonic mesh. The second
mode is also useful for routing, allowing signals to cross with little
interference. The final state allows the user to combine two optical signals
based on predefined proportions. This is useful for applications such as
filtering for ring resonators or splitting.

#ufigure(
  kind: image,
  outline: [ Different states of a 2x2 optical coupler. ],
  caption: [
    @2x2 (a) and its different states: in "bar" mode (b), in "cross" mode (c), and
    in "partial" mode (d). The blue triangles are optical inputs and outputs.
  ],
)[
  #table(
    columns: 2,
    stroke: none,
    align: center + horizon,
    image(
      "../assets/drawio/smol/2x2_coupler.png",
      width: 80%,
      alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in dashed line and bar in solid line.",
    ),
    image(
      "../assets/drawio/smol/2x2_coupler_bar.png",
      width: 80%,
      alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: bar in solid line.",
    ),
    "(a)",
    "(b)",
    image(
      "../assets/drawio/smol/2x2_coupler_cross.png",
      width: 80%,
      alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in solid line.",
    ),
    image(
      "../assets/drawio/smol/2x2_coupler_partial.png",
      width: 80%,
      alt: "Shows the general structure of a 2x2 coupler, with two ports on each end, inside of the coupler, lines are drawn to show the different paths that light can take: cross in dashed line and bar in solid line.",
    ),
    "(c)",
    "(d)",
  )
]<tunable_2x2>

#unote[
  The colour scheme shown in @tunable_2x2 for the different modes is kept
  throughout this document when showing photonic gates and their modes.
]

There are many construction techniques for building @2x2[s], each with its own
advantages and disadvantages. The most common ones are the Mach-Zehnder
interferometers with two phase shifters. However, other techniques involve using #gloss("mems") or
liquid crystals @bogaerts_programmable_2020-1 @capmany_programmable_2016
@perez_programmable_2019.

==== Detectors <sec_detectors>

Detectors are used to turn optical signals into electrical signals. In photonic
processors, there are commonly two kinds: low-speed detectors used to measure
optical power at several points inside the processor and high-speed detectors
used to demodulate high-speed signals.

==== Modulators <sec_modulators>

Contrary to detectors, modulators turn electrical signals into optical signals.
They do not do this by producing the optical signal but by modulating the phase
or the amplitude of an existing optical signal.

=== Meshes <sec_meshes>

Four main kinds of meshes can be built for programmable photonics, shown in
@fig_meshes: the feedforward mesh #link(<fig_meshes>)[(a)] and three kinds of
recirculating mesh: hexagonal #link(<fig_meshes>)[(b)], rectangular #link(<fig_meshes>)[(c)],
and triangular meshes #link(<fig_meshes>)[(d)]. It is also possible to create
meshes not made of a single kind of cell, but these will not be discussed in
this thesis. This section will discuss the major differences between the
feedforward and the recirculating architectures. In the case of this thesis,
hexagonal meshes are the primary focus. This is because they are the most
capable kind of meshes @bogaerts_programmable_2020-1.

#ufigure(
  kind: image,
  outline: [ Different kinds of programmable photonic meshes. ],
  caption: [
    The four kinds of programmable meshes: feedforward (a), hexagonal (b),
    rectangular (c), and triangular (d).
  ],
)[
  #let width = 90%
  #table(
    columns: 2,
    stroke: none,
    align: center + horizon,
    image(
      "../assets/drawio/smol/mesh_feedforward.png",
      width: width,
      alt: "Shows a feedforward photonic mesh, setup in a triangular pattern.",
    ),
    image(
      "../assets/drawio/smol/mesh_hexagonal.png",
      width: width,
      alt: "Shows an hexagonal photonic mesh.",
    ),
    "(a)",
    "(b)",
    image(
      "../assets/drawio/smol/mesh_square.png",
      width: width,
      alt: "Shows a square photonic mesh.",
    ),
    image(
      "../assets/drawio/smol/mesh_triangular.png",
      width: width,
      alt: "Shows a triangular photonic mesh.",
    ),
    "(c)",
    "(d)",
  )
]<fig_meshes>

#pagebreak(weak: true)

All of the architectures rely on the same components @bogaerts_programmable_2020-1,
those being #gloss("2x2", suffix: "s", long: true), optical phase shifters and
optical waveguides. These elements are combined in all-optical gates, which can
be configured to achieve the user's intent. Additionally, to provide more
functionality, the meshed gates can be connected to other devices, such as
high-speed modulators, amplifiers, and detectors @bogaerts_programmable_2020-1
@capmany_programmable_2016 @perez_programmable_2019.

The primary difference between the feedforward architecture and the
recirculating architecture is the ability of the designer to make light travel
both ways in one waveguide. As is known @ghatak_introduction_1998, light
can travel in two directions in a waveguide with little to no interactions. This
means that, without additional waveguides or hardware complexity, a photonic
circuit can support two guiding modes, one in each direction. This property can
be used for more efficient routing and creating more complex and varied
structures @bogaerts_programmable_2020-1.

As it has been shown in @perez_programmable_2019, recirculating meshes
can create more advanced structures, such as @iir elements, whereas feedforward
architectures are limited to @fir components. This is due to the inability of
the feedforward architecture to express feedback loops, limiting them to @fir
components, whereas recirculating meshes allow the creation of feedback loops
and @iir components. Indeed, in a feedforward mesh, the typical structure being
built is the Mach-Zehnder interferometer. In contrast, in a recirculating mesh,
one may build structures such as ring resonators, which are inherently @iir
components. Recirculating meshes can also express structures such as @mzi and
can represent both @iir and @fir components.

#uconclusion[
  The recirculating mesh is more capable as it allows feedback loops and @iir
  components, whereas the feedforward mesh is limited to @fir components.
  Additionally, recirculating meshes allow light to travel in both directions in a
  single waveguide, allowing for more efficient routing and complex structures.
]

=== Potential use cases of photonic processors <photonic_processors_use_cases>

There are many use cases for photonic processors, some of which will be shown in
this thesis as examples in @sec_examples. However, this section will first
discuss areas of particular interest for photonic processors. Photonic
processors' first and primary advantage is that they can replace the need to
develop custom @pic[s], which is extremely expensive. They can also be used
during the development of said @pic[s] as a platform for prototyping. Another
one of their advantages, which broadens their reach, is the ability to reprogram
the processor in the field, just like a traditional @fpga. In the following
paragraphs, several broad areas of interest will be discussed, and examples of
applications in those areas will be mentioned. Those areas are
telecommunication, optical computation, @rf processing, and sensing
applications.

==== Telecommunications
The telecommunications industry is one of the largest existing users of photonic
technologies, most notably optical fibers. Therefore, it should come as no
surprise that this is one of the applicative areas of particular interest for
programmable photonics. They can be used by service providers close to their
customers for multiplexing, transceivers, and resource allocations, such as in
fiber-to-the-home deployments @bogaerts_programmable_2020-1.

==== Optical computation
In some cases, such as machine learning, it has been shown that processing can
be accelerated and energy efficiency improved by using photonic processing. As
photonic processors are reprogrammable by nature, they could be used to
accelerate workloads in data centers and edge computing scenarios. Companies
like _LightMatter_ are already making strides in optical computing accelerators
for machine learning applications @demirkiran_electro-photonic_2021.

==== RF processing
@rf processing refers to the concept of processing radio signals using photonic
technologies by modulating the @rf signals of interest onto optical signals and
then benefiting from the low-energy, very high bandwidth of photonic components
to efficiently process signals in the analog domain. This has interest for RADAR
applications, but also mm-Wave communications and 5G @perez-lopez_silicon_2021.

==== Sensing
Sensing can take many forms, such as LiDAR, which is used in self-driving cars,
or even in the medical field, such as in the case of sensing for the detection
of cancerous cells, where a photonic processor could be used to process the
signals produced by a sensor @bogaerts_programmable_2020-1 @daher_design_2022.
In recent years, fiber sensing has been used in many applications, such as
aviation, oil, gas, and more @trutzel_smart_2000 @ashry_review_2022. The
advantages of photonic processors for these use cases allow the reduction of
weight, overall system complexity, and design cost. Therefore, photonic
processors are interesting for sensing applications, as they may significantly
reduce system design costs.

=== Embedding a photonic processor in a larger system <photonic_processors_in_systems>

In this thesis, the focus will mainly be on the design of circuits for photonic
processors. However, one must keep in mind that photonic processors are not
standalone systems but rather components of larger, more complex systems.
Complex systems are rarely limited to a single domain. Indeed, they are often
composed of multiple technologies, such as digital electronics, analog
electronics, photonic circuits, and real-time processing. Therefore, it is
important to understand how photonic processors can be embedded into these
larger systems and how they can be integrated into existing systems. The act of
integrating multiple technologies is often called codesign. Photonic processors
are already a form of codesign since they are composed of both photonic and
electronic components.

==== Integration with electronics
As previously mentioned, photonic processors integrate two types of
electro-optic interfaces: modulators and detectors. These components can be used
to interface the insides of the photonic processor with a larger electronic
scheme. Due to their nature, these components can be used for both digital and
analog electronics. Indeed, photonic processors can be used as analog signal
processors and in mixed-signal systems. This is particularly interesting for @rf
signal processing, as photonic processors can offer high bandwidth, high-speed,
and low energy consumption signal processing, all of which are difficult to
achieve in analog electronics.

==== Integration with software
While this thesis will not discuss integration with electronics at length,
integration with the software will. As discussed in @initial_requirements, there
is an interest in integrating software control over the functionality and
behaviour of photonic processors. Due to their nature, photonic processors
cannot make decisions, but they can be interfaced with software that is able to
process data and make decisions. Additionally, the designer may use software to
create feedback loops to control their photonic circuit from the software.

In @fig_uses, one can see how a photonic processor may be integrated with analog
electronics, digital electronics, and embedded software by using @dac[s] and
@adc[s] to interface with the photonic processor, an @fpga for high-speed
digital processing, and an embedded processor for control. However, while it
does not show how optical inputs and outputs may be used, it provides a
high-level overview of how a photonic processor and some of its internal
components may be interfaced with in a bigger system.

#ufigure(
  outline: [
    Figure showing the integration of a photonic processor with electronics and
    software.
  ],
  caption: [
    Figure showing the integration of a photonic processor with electronics and
    software. It shows how a photonic processor is composed of the photonic @ic,
    @adc[s], and @dac[s] to interface with its integrated controller. It then shows
    how the overall photonic processor may be integrated with digital electronics
    and software running on an embedded processor. Blue elements represent digital
    electronics, while green elements represent analog electronics.
  ],
)[
  #image(
    "../assets/drawio/smol/uses.png",
    width: 70%,
    alt: "Shows a photonic processor interfaced to two DACs and to ADCs on either side, communicating with an FPGA, the FPGA then communicates to an embedded processor, which itself communicates to the digital integrated controller for the photonic processor. This integrated controller then controls a set of ADCs and DACs inside of the photonic processor to control the photonic gates in the processor.",
  )
] <fig_uses>

== Circuit representation <circuit_repr>

When creating tools for circuit design, it is important to carefully consider
how the circuit will be represented, as both the users of the tool, and its
developers, will need to interact with this model for many steps in the design
process, such as for simulation, optimisation, synthesis, and validation. As far
as this thesis is concerned, it will use one of the most common photonic circuit
representations, the netlist. In addition, the guided mode in each direction of
the waveguides will be represented as a separate net.

#udefinition(
  footer: [ Adapted from @netlist. ],
)[
  A *netlist* is a list of components and their connections used to represent a
  photonic circuit. A *net* is a connection between two components, which
  represents a waveguide.
]

Netlists are common abstractions in electronics to represent a list of
components and their connections. However, in the case of photonics, the
definition is altered and made more limited: in electronics, a net can be
connected to many components. However, in the case of a photonic circuit, the
port of a component is only ever connected to the port of another component,
never more. This is because, in this thesis, splitters are considered components
in and of themselves; therefore, splitting the signal is equivalent to adding a
component to the circuit.

Bidirectional ports, such as the ones on the edge of a photonic processor, are
represented as two separate logical ports, one for each direction: incoming and
outgoing light. This representation is acceptable because light can travel in
both directions in photonic waveguides with little to no interaction. Therefore,
one can model these modes as being two separate signals @xing_behavior_2017.
This model is beneficial in the case of recirculating photonic meshes, as it
helps distinguish the direction of the light in the circuit, making it easier to
efficiently reuse photonic gates for bidirectional signal routing.

=== Feedforward approximation <feedforward_approx>

As mentioned in @photonic_processor, a type of programmable photonic @ic is the
feedforward processor, which assumes that light travels from an input port to an
output port in a single direction. However, this thesis is focused on the more
general kind of processor that uses recirculating meshes. Therefore, one may
wonder whether it is possible to model components using a feedforward
approximation. Indeed, this section will discuss the axiom that any photonic
circuit can be represented as a feedforward circuit, given a sufficiently high
level of abstraction.

From theory, it is known that light can travel in both directions of a waveguide
with little to no interactions @xing_behavior_2017. Additionally, the scattering
matrix defining the circuit is symmetric for reciprocal and time-invariant
components. Conveniently, it so happens that most passive, or pseudo-passive#footnote[Components that are actively powered, but slow varying enough to be considered
  passive.] photonic components are reciprocal and time-invariant. Therefore,
most photonic components can always be represented under this formalism. For
components that are not reciprocal, one can split the component into two
components, one for each direction, and model them as a set of separate
components. Finally, components that are not time-invariant, such as modulators,
can be modelled as time-invariant components as long as the variation in time is
slow enough, compared to the oscillation period of the light, such that it can
be considered constant. Finally, for components such as isolators, one can
consider them a three-port device with two inputs, one being sunk, the other
not, and one output.

Some components may be difficult to accurately model in this formalism. For
example, @soa[s] can be challenging to express in this formalism since their
gain is spread over both modes. However, this can be solved by modelling the
@soa as a unidirectional component. This removes the ability to model the @soa
as a bidirectional component, but it is a reasonable approximation for most
cases. Additionally, if the user needs to model the @soa as a bidirectional
component, they could model it as two components whose exact response depends on
the other component.

Intuitively, one can think of these abstracted models as black boxes, where the
contents do not matter as long as the expected functionality is present. For
example, a ring resonator can be modelled as a black box with two inputs and two
outputs, where the input and output ports are labelled as $a_"in", b_"in"$ and $a_"out", b_"out"$ respectively.
This is shown in @fig_ring_resonator_black_box. In this model, one can use the
properties of a ring resonator to model the relations between these ports.

#ufigure(
  outline: [ A black box representation of a ring resonator. ],
  caption: [
    A black box representation of a ring resonator. The input and output ports are
    labelled as $a_"in", b_"in"$ and $a_"out", b_"out"$ respectively.,
  ],
)[
  #image(
    "../assets/ring_resonator_black_box.png",
    width: 200pt,
    alt: "Shows an unloaded microring resonator, with two inputs and two outputs, respectively labelled as a_in, b_in, a_out, b_out.",
  )
]<fig_ring_resonator_black_box>

#uconclusion[
  It has been shown that, given a sufficient level of abstraction, any
  bidirectional photonic circuit can be represented by an equivalent,
  higher-level, feedforward circuit. This result is crucial for formulating the
  requirements for the programming interface of such a photonic processor.
]

== Non-idealities <fppga-difficulties>

Like all other photonic components, photonic processors are impacted by
non-idealities, temperature dependence, and manufacturing variabilities. These
impact the well-functioning of the circuit programmed within the processor.
Therefore, one must consider this impact when designing the circuit, or
programming the design, in the case of a photonic processor. However, photonic
processors should mitigate these variations as much as possible, as they are
high-level design platforms, to allow for a more efficient design process. This
section will discuss these non-idealities, and solutions to automatically
mitigate their impact will be proposed.

==== Temperature dependence
Most photonic components exhibit a temperature dependence, which can be
exploited to build structures such as phase shifters. However, undesired
temperature changes can impact the circuit in unexpected ways. One traditional
way to mitigate temperature changes is to maintain the device at a constant
temperature using external means, such as Pelletier elements. However, this
limits the potential use cases of the device, as such means tend to be bulky and
power-hungry. 

==== Wavelength dependence
In addition to the temperature dependence mentioned above, photonic components
also exhibit a strong wavelength dependence. Part of this dependence is desired,
such as in the case of wavelength filters. Nevertheless, in all other cases, the
user expects that the device behaves with a flat frequency response. Therefore,
photonic processors must also provide mitigations for this dependence.

==== Manufacturing variability
Variabilities in the manufacturing process of the @pic cause the third kind of
non-idealities; they can introduce all kinds of non-idealities, such as higher
losses, reflections, and more. The imperfection of the manufacturing process
causes these variabilities; therefore, the resulting devices are not identical.
This means that the user's design will work differently from one chip to the
next. However, one of the goals of photonic processors is to act as a high-level
design platform, which means that the user should not have to worry about these
variabilities. 

== Initial design requirements <initial_requirements>

This section will discuss the basic design requirements for a programming
interface to photonic processors. These requirements form the base of the design
of the programming interface and are, therefore, crucial to the design of the
interface. More requirements and details for each will be provided in
@sec_intent.

==== High-level of abstraction & modularity
Ideally, the programming interface of photonic processors should be high-level
enough that it is entirely abstracted from the underlying hardware, making it
easier to design circuits. Furthermore, the interface should be modular,
allowing users to build complex circuits from smaller, simpler building blocks.
This is a crucial requirement, as it allows the user to build complex circuits
from incrementally more complex building blocks, allowing them to build more
advanced circuits without understanding the underlying hardware.

==== Platform independence
The code should work across devices with little to no adjustment. This would
avoid the fracturing of the ecosystem that can be observed in @fpga[s], as well
as reduce the burden of the user to port their code to different devices.

==== Tunability and reconfigurability
Ideally, the user would want to tune their design while it is running, allowing
them to build feedback loops of their control and adjust their design's
behaviour on the fly; this functionality is called tunability. Furthermore, the
user might want to completely replace parts of their device's functionality
without reprogramming the entire device. This is called reconfigurability. These
two features work hand-in-hand, providing a powerful tool for the user to build
their designs and fully exploit the photonic processor's field-programmable
nature.

==== Solutions to non-idealities
One can categorise the previously mentioned non-idealities into time-invariant
non-idealities and time-variant ones. The former does not change over time, such
as manufacturing variabilities. It, therefore, can be compensated by using
calibration tables that are uniquely generated for each chip or batches of
chips. Time variant non-idealities, however, require an active approach, such as
feedback loops, which the design solution for these photonic processors must
provide for the user. In order to build these feedback loops, measurements must
be taken of the signals of interest. These measurements are taken inside the
photonic processor using photodetectors built into the chip. These measurements
allow the integrated control system to adjust components, such as gain sections
or phase shifters, to compensate for the non-idealities.