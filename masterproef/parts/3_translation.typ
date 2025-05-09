#import "../ugent-template.typ": *

= Translation of intent & requirements <sec_intent>

In @sec_programming_photonic_processors, the different programming ecosystem
components, paradigms and tradeoffs were discussed. In this section, the
translation of the user's intent -- i.e. the design they wish to implement --
will be discussed in further detail. The translation of intent is how the user
will write down their design and how the program translates that design into an
actionable, programmable design. This section will also outline some of the
features needed for easier intent translation. This will be done by discussing
important features such as _tunability_, _reconfigurability_, and _programmability_.
These features revolve around the ability of the user to tune the operation of
their programmed photonic processor as it is running. For this purpose, this
section will introduce novel concepts, such as _constraints_ and their _solver_ and _reconfigurability through branching_.
These two essential concepts will be discussed in detail and synergise to create
an easy-to-use, powerful programming ecosystem for photonic processors.

Additionally to the aforementioned points, several key features were discussed
in @initial_requirements. The features relate to real-time control, which works
in pair with _reconfigurability_ and _tunability_, and simulation, which will
use _constraints_ and its solver. Platform independence, which will be achieved
through the design of a unified vendor-agnostic ecosystem and the visualisation
of the design, which has led to the design of the _marshalling layers_ which
will be discussed in @sec_marshalling.

#udefinition(
  footer: [ Adapted from @noauthor_logic_2023. ],
)[
  *Synthesis* is the process of transforming the description of a desired circuit
  into a physical circuit.
]

Synthesis is the process of transforming the user's code into a physical circuit
on the chip. It is done in a multitude of stages that will be discussed in
@sec_phos. These stages are all required to go from the user's code, which
represents their intent, and turn it into an actionable design that can be
executed on the photonic processor. The synthesis process is complex, involving
many components that all must cooperate. Additionally, some of the tasks that
synthesis must do, such as place-and-route, are computationally intensive and
often regarded as NP-hard.

== Functional requirements

#udefinition(
  footer: [ Adapted from @martin_what_2023. ],
)[
  A *functional requirement* is a requirement that specifies a function that a
  system or component of a system must be able to perform.
]

Before a user can design their circuit, they must list their functional
requirement. These requirements are the functionality that they wish for their
circuit to achieve. As previously discussed, in @sec_language_tool, these
requirements are the most declarative form of the user's intent. However, some
elements will generally be common to all those functional requirements. And can
be seen as the functional requirements for intent translation. These
requirements can be seen in @tab_functional_requirements and are discussed in
the following sections.

#ufigure(
  caption: [ Functional requirements for intent translation ],
  kind: table,
)[
  #table(
    columns: (2em, 0.1fr, 0.5fr, 0.1fr),
    align: center + horizon,
    stroke: (x: none),
    table.header(
      table.cell(colspan: 2, smallcaps[Requirement]),
      smallcaps[Description],
      smallcaps[Discussion],
    ),
    table.cell(colspan: 2, smallcaps[Ideal behaviour]),
    align(
      left,
    )[
      As discussed in @fppga-difficulties, devices vary from device to device and over
      time and temperature. The user should be able to program the device without
      having to worry about these variations.
    ],
    [ @sec_calibration_and_variation_mitigations ],
    table.cell(rowspan: 3, rotate(-90deg, box(width: 200pt)[#smallcaps[Realtime feedback]])),
    smallcaps[Reconfigurability],
    align(
      left,
    )[
      Reconfigurability allows the user to change the topology of their device at
      runtime. This is useful for several reasons. The primary reason is the ability
      to change behaviour based on configurations or inputs.
    ],
    [ @sec_tunability_reconfigurability ],
    smallcaps[Tunability],
    align(
      left,
    )[
      On the other hand, Tunability does not change the topology in itself, but rather
      changes the behaviour of the mesh through tuning elements already present in the
      mesh. This may be used to vary gains, phase shifters, switches, or couplers to
      affect the behaviour of the mesh. This can also allow the user to build feedback
      loops that they control.
    ],
    [ @sec_tunability_reconfigurability ],
    smallcaps[Programmability],
    align(
      left,
    )[
      In order to be able to make use of tunability and reconfigurability, the user
      must be able to communicate with their programmed device programmatically. This
      is done using a #gloss("hal", long: true) that handles communication with the
      device.
    ],
    [ @sec_programmability ],
    table.cell(colspan: 2, smallcaps[Simulation]),
    align(
      left,
    )[
      Simulation allows the user to test their code, verify whether it works and debug
      it before running it on the device. This is an important feature as it also
      allows the user to experiment without having access to the device.
    ],
    [ @sec_intent_simulation ],
    table.cell(colspan: 2, smallcaps[Platform independence]),
    align(
      left,
    )[
      Platform independence allows the user to focus on their design rather than the
      specific device it is expected to run on. While some degree of platform
      dependence is to be expected, most of the code should be platform-independent
      and allowed to run on any device.
    ],
    [ @sec_platform_independence ],
    table.cell(colspan: 2, smallcaps[Visualisation]),
    align(
      left,
    )[
      Visualisation allows the user to see the result of a simulation, what a
      finalised design looks like, and block diagrams of functionality. All of these
      features can help the user in their design process, but also help the user when
      sharing information with others. Therefore, providing visualisation is
      desirable.
    ],
    [ @sec_visualisation ],
  )
] <tab_functional_requirements>

== Programmability <sec_programmability>

#udefinition(
  footer: [ Adapted from @huang_virtualization_2018. ],
)[
  A *#gloss("hal", long: true)* is a library whose purpose is to abstract the
  hardware with a higher level of abstraction, allowing for easier use and
  programming of the hardware.
]

Programmability refers to the ability of the user to interact with their circuit
while it is running programmatically. This is done using a @hal, which allows
for interoperation between their software and their hardware, completing the
hardware-software codesign loop. The @hal is made of two parts: the core @hal
provided by the device manufacturer and the user @hal generated by the compiler
based on the user's code.

==== Core @hal
As previously mentioned, the core @hal is provided by the device manufacturer
and consists mostly of communication routines. It handles the communication
between the user's software and the device. This @hal is, therefore,
platform-specific and is not generated by the compiler. However, the core @hal
must be able to communicate with the user @hal, which is generated by the
compiler. This is done by enforcing that all @hal[s] implement a common @api
that allows the user to interact with both the core @hal and the user @hal in a
consistent way, making the code as portable as possible.

==== User @hal
The user @hal is a higher-level part of the @hal built from the user's design.
It encapsulates the tunable values, reconfiguration states and detectors that
are defined within the design and allows the user to change these values,
reconfigure the device and readout detectors. All the while using the names the
user-defined for these different values. This allows the user to interact with
the device in a way consistent with their design, making it easier to understand
and use. This should improve productivity and reduce the risk of error in the
hardware-software codesign interface.

==== User @hal template
The user @hal needs to be generated from the user's design; however, there may
be elements of this @hal that are platform specific and, therefore must be
generated instead by the device support package. This is expected to be done by
allowing the device support package to generate part of the user @hal through a
template or custom code. This allows the device support package to provide
platform-specific features to the user @hal or to optimise common
implementations for the platform, further improving the quality and usability of
the generated interface.

== Intrinsic operations <sec_intrinsic_operations>

From the physical properties and features of a photonic processor, as discussed
in @sec_programmable_photonics, one can extract a set of intrinsic operations
that the processor must support. These operations in themselves are not required
to be on the chip, but the support packages of the chip must be able to
understand them and produce errors when they are not implemented. A complete
list with a description can be found in @tab_intrinsic_operations. In this
section, the intrinsic operators will be discussed in more detail.

==== Filter
One of the core operations that almost all photonic circuits perform is
filtering. It is a block that alters the amplitude of an input signal in a
predictable manner based on its spectral content. Due to the prevalence of
filters in photonic circuits, coupled with their special constraint -- see below
-- they benefit from being an intrinsic operation for a photonic processor.
During compilation and before place-and-route, the filter will be synthesised
based on its arguments in order to produce a filter of the desired frequency
response. This synthesised filter will therefore be optimised for the hardware
platform.

There are many different types of filters, the most common ones that can easily
be implemented on a mesh -- are @mzi[s], ring resonators, and lattice filters.
Additionally, compound filters that combine multiple types of filters or more
than one filter can be created; such filters can have improved response or
behave like bandpass filters. Therefore, the compiler's task is to choose the
base filter based on the specification and performance criteria that the user
has set. For example, the user might prioritise optimising for mesh usage rather
than finesse or might optimise for flatness of the phase response rather than
the mesh usage, etc.

==== Gain and loss
All waveguides within a device will cause power loss in the optical signals.
However, this loss may not be sufficient if the user is working with a
high-power signal. Therefore some devices might include special loss elements
whose loss is tunable or at least known. Besides, following the same principle,
some users may want to compensate for this loss by using gain sections or
amplify incoming signals. Optical gain is difficult to obtain on silicon
platforms, just like sources, but it is possible to obtain gain through the use
of rare-earth doped waveguides or other techniques such as micro-transfer
printing. Therefore, the compiler must be able to synthesise gain and loss
sections based on the user's specifications. However, if the device does not
support gain or loss, the compiler should produce an appropriate error for the
user.

==== Modulator and detectors
Two key applications of photonic processors are telecommunication and processing
@rf signals. Therefore, it stands to reason that modulators and detectors are
key components that are expected to be present in most photonic processors.
Additionally, based on the device, there may be an optimal type of modulator for
either type -- phase modulation or amplitude modulation -- and the compiler may
choose an appropriate implementation of the modulator. Additionally, the same is
true for detectors, although they would generally only be used for amplitude
demodulation, with phase coherent demodulation being the responsibility of the
user.

==== Splitters
Signals are often split, and they may be split in specific ratios. For this
reason, a splitter intrinsic operation that splits a signal into $n$ new signals
with weight provided by the user is desirable. Internally, the compiler will
likely have to implement these splitters as 1-to-2 splitters with specific
splitting ratios, but the user should not have to worry about this.
Additionally, the compiler can optimise the placement of these splitters to
minimise the mesh usage, or to minimise non-linear effects in high-power
signals, or maintain phase coherence between signals.

==== Combiners and interferometers
A combiner is the inverse of a splitter. It combines $n$ signals together; it
can operate in one of two modes, it can either try and reach a target power
level -- which can be the maximum power --, or it can interfere with the signals
with their differential phase to create interference. The user is responsible
for choosing which implementation to use. However in cases where the phase is
well known, the compiler may be able to optimise the design by using a phase
coherent combiner, thus not requiring a feedback loop and a phase shifter.

==== Switches
Some devices may have hardware optical switches, while others may need to rely
on feedback loops. Generally, all platforms should be able to support switching.
Whether they rely on purpose-built hardware or on feedback loops does not
matter. Switching can be useful in many applications, including
telecommunication, signal processing, etc. It may be used to route test signals,
route signals conditionally, or implement simple reconfigurability without the
added cost of having more than one mesh.

==== Sources
A lot of applications will need the generation of laser light; while this is
difficult to achieve on silicon, it may be available on some devices. As laser
sources are such an important part of photonics, it is important to at least
plan for sources to be available in the future. Additionally, in some cases, the
compiler may be able to synthesise a source from a gain source, reflectors and
splitters. However, this is not always possible, and the compiler should be able
to produce an error if the user requests a source and none is available.

==== Phase shifter
Phase shifters are a necessary building block for a lot of more complex
structures such as tunable @mzi[s], tunable filters, coherent communication,
power combiners, etc. Therefore, as an integral part of the functioning of
photonic processing, they must be present as an intrinsic operation.
Additionally, they may be used in two different modes: the first mode is as a
phase shifter, shifting the phase of a single signal, and the second mode is as
a differential phase shifter, imposing a phase shift with respect to another
signal. This case is especially interesting as it can be used to implement
complex quadrature modulation schemes. In @sec_examples, examples regarding
coherent communication will be presented that makes use of this intrinsic
operation to implement complex modulation schemes, as well as to implement a
beamforming network.

==== Delay lines
Each waveguide being used on the chip adds latency to the signal. While this
latency may be low at the scale of a modulated signal, it can still be
relatively significant overall. For this reason, the device must provide ways
for the user to align signals in time by using a delay line or multiple wires of
different lengths to match the total optical length. It works nicely with the
ability to express differential constraints, which will be discussed in
@sec_constraints.

==== Coupler
Couplers are part of each photonic gate present in the processor. They have the
ability to couple two signals based on a coupling coefficient. This is a key
intrinsic, as it allows the user to couple signals directly, something that
would otherwise be difficult to implement. In terms of the underlying hardware,
it should be a direct one-to-one relationship with a coupler on the processor
itself. However, the compiler should be able to optimise the coupling
coefficient based on the signal's frequency content and the device's calibration
curves.

==== Sink & empty source
In some cases, the user might want to produce an empty signal or consume a
signal without doing anything with it. For this reason, the compiler should be
able to produce a sink intrinsic operation that consumes a signal with little to
no return losses and an empty source that produces a signal with little to no
power. This is especially useful in cases where the user might want to have a
reference "empty" signal or a signal consumed without any effect on the rest of
the system. An example of such cases is a spectrometer, which wants to switch in
an empty signal to calibrate the dark current of the detectors.

  
#show table.cell: set block(breakable: false)
#ufigure(
  outline: [ Intrinsic operations in photonic processors. ],
  caption: [ Intrinsic operations in photonic processors, with their name, description and
    arguments. For each argument, an icon indicates whether the argument is required
    (#required_sml) or optional (#desired_sml). Additionally, the type of the value
    is also indicated by an icon; it can be optical (#lightbulb), electrical (#lightning),
    or a value (#value). ],
  kind: table,
)[
  #set list(indent: 0cm)
  #table(
    columns: (auto, 1fr, auto),
    align: center + horizon,
    stroke: (x: none),
    table.header(
      smallcaps[*Intrinsic operation*],
      smallcaps[*Description*],
      smallcaps[*Arguments*],
    ),
    smallcaps[*Filter*],
    align(
      left,
    )[
      Filters a given signal at a given wavelength or set of wavelengths. The
      architecture and parameters are derived automatically from its arguments and the
      constraints on its input signal.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightbulb#h(0.1em) Through signal
      - #desired_sml#lightbulb#h(0.1em) Drop signal
      - #required_sml#value#h(0.1em) Wavelength response
    ],
    smallcaps[*Gain/loss*],
    align(
      left,
    )[
      Gain/loss sections allow the user to increase or decrease the power of a signal.
      The platform may not support gain or loss, in which case the operation will
      fail.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightbulb#h(0.1em) Output signal
      - #required_sml#value#h(0.1em) Gain/loss
    ],
    smallcaps[*Modulator*],
    align(
      left,
    )[
      A phase or amplitude modulator that uses an external electrical signal as the
      modulation source. The implementation is chosen by the support package based on
      the type of modulator.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightbulb#h(0.1em) Output signal
      - #required_sml#lightning#h(0.1em) Modulation source
      - #required_sml#value#h(0.1em) Modulation type
    ],
    smallcaps[*Detector*],
    align(left)[
      A detector that converts an optical signal to an electrical signal.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightning#h(0.1em) Output signal
    ],
    smallcaps[*Splitter*],
    align(
      left,
    )[
      A splitter that splits an optical signal into multiple lower-power optical
      signals.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightbulb#h(0.1em) Output signals
      - #required_sml#value#h(0.1em) Splitting ratios
    ],
    smallcaps[*Combiner*],
    align(
      left,
    )[
      A combiner that combines multiple optical signals into a single optical signal.
      At the same time, maximising the total output power.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signals
      - #required_sml#lightbulb#h(0.1em) Output signal
    ],
    smallcaps[*Interferometers*],
    align(
      left,
    )[
      A combiner that interferes multiple optical signals into a single optical
      signal. Does not perform any power optimisation.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signals
      - #required_sml#lightbulb#h(0.1em) Output signal
    ],
    smallcaps[*Switch*],
    align(left)[
      A switch that switches between two optical signals.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightbulb#h(0.1em) Output signal
      - #required_sml#value#h(0.1em) Switch state
    ],
    smallcaps[*Source*],
    align(left)[
      A laser source that generates an optical signal.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Output signal
      - #required_sml#value#h(0.1em) Wavelength
    ],
    smallcaps[*Phase shifter*],
    align(
      left,
    )[
      A phase shifter that shifts the phase of an optical signal. Optionally, performs
      the phase shift in reference to another signal.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #desired_sml#lightbulb#h(0.1em) Reference signal
      - #required_sml#lightbulb#h(0.1em) Output signal
      - #required_sml#value#h(0.1em) Phase shift
    ],
    smallcaps[*Delay*],
    align(left)[
      A delay that delays an optical signal.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) Input signal
      - #required_sml#lightbulb#h(0.1em) Output signal
      - #required_sml#value#h(0.1em) Delay
    ],
    smallcaps[*Coupler*],
    align(left)[
      A coupler that couples two optical signals.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) 1st input signal
      - #required_sml#lightbulb#h(0.1em) 2nd input signal
      - #required_sml#lightbulb#h(0.1em) 1st output signal
      - #required_sml#lightbulb#h(0.1em) 2nd output signal
      - #required_sml#value#h(0.1em) Coupling factor
    ],
    smallcaps[*Sink*],
    align(
      left,
    )[
      A perfect sink that consumes an optical signal with little to no return loss.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) input signal
    ],
    smallcaps[*Empty*],
    align(
      left,
    )[
      A perfect empty signal source that produces an optical signal with little to no
      power.
    ],
    align(left)[
      - #required_sml#lightbulb#h(0.1em) output signal
    ],
  )
] <tab_intrinsic_operations>

#pagebreak(weak: true)
== Constraints <sec_constraints>

Constraints are a technique for expressing requirements on values and signals.
They are associated with each signal or value to give additional information
regarding its contents. In @sec_future_work, the concept of using constraints
with _refinement types_ will also be discussed as a potential future expansion
of constraints. The core idea of constraints is that the user can use them to
specify additional information about their signals at a given point in the code.
Additionally, they can be used to check the code's validity and infer additional
constraints. This is done by the _constraint solver_. This section will discuss
the multiple aspects of constraints and their use.

#uinfo[
  Constraints in themselves are not a new concept. However, how they are applied
  to include more complex constraints, simulate circuits, and inferrence, does _appear_ to
  be novel.
]

==== Constraints for validation
The primary use of constraints is for the validation of the code. The _constraint solver_ does
this, as discussed later. The constraint solver will use the constraints to
check whether they are compatible with one another. This is done by annotating
some functions with constraints and then checking whether the input signals are
compatible with those constraints. If the constraints are not compatible, a
warning or an error can be presented to the user. 

Constraints can be of many types; the likely most common ones will be
constraints on power, gain, wavelength, delay, and phase. The reason why delay
and phase are different constraints is because they most often will have
different semantics, where phase refers to the phase of the light within the
waveguide, and the delay will mostly impact the delay of the modulated
information on the signal. Since light operates at frequencies much higher than
the @rf range, one can consider the phase of the light to be mostly decoupled
from the signal's phase. These constraints can be used to verify the code's
validity and inform the compiler how to optimise and generate the design. For
example, the user might have a high-power signal coming onto the chip that gets
split. The place-and-route system can either place the splitter close to the
input, increasing mesh usage but reducing non-linearities, or closer to the
components using this light, increasing mesh usage but decreasing
non-linearities. One can use the input power constraint to make a decision since
at high-power, there will be increased non-linearities and losses within the
waveguide. Therefore, the place-and-route can use this information to decide
where to place the splitter. This is just one example of how constraints inform
the compilation system and can be used to optimise the design.

==== Constraints for simulation
Additionally to the aforementioned constraints, one can also express constraints
that are useful for simulation, such as noise sources, modulation inputs, etc.
These constraints do not make sense for the compilation process as they are not
actionable at compile time; however, they are actionable for creating more
realistic, closer-to-physical simulations. These special constraints can be used
for a variety of things and are in essence non-synthesisable, whereas the other
constraints are synthesisable.

These non-synthesisable constraints, can be coupled with synthesisable
constraints to create a more realistic yet very inexpensive simulation. As will
be discussed in @sec_intent_simulation, simulating circuits using constraints is
extremely fast. And due to the integration of constraints within the language,
as discussed in @sec_phos_constraints, makes them an inherent part of the user's
design. This means that accurate, yet fast simulations are always available to
the user.

==== Constraints for optimisation
As previously mentioned, constraints can be used as indicators for stages within
the synthesis process. Therefore, it stands to reason that constraints can be
used to optimise the design. The compiler can use constraints to remove
unnecessary components or to optimise the placement of said components. For
example, a signal going through a filter might have a constraint on the
wavelength, and the filter might also have a constraint on the wavelength. If
the compiler can prove that the filter is not needed, it can remove the filter
altogether. Alternatively, if it detects that there would be no signal left
after the filter, it can remove the filter and all dependent components,
simplifying the design. Additionally, the user might specify optimisation
targets that the place-and-route may try to reach. These targets may relate to
the mesh usage, non-linearities, or other metrics. The place-and-route can use
these targets and constraints to optimise the design to the user's
specifications.

==== Constraints as real-time feedback
As discussed in @sec_detectors, power detectors on the chip can be used for
monitoring purposes. These detectors are expected to be implicitly and
automatically used most of the time through intrinsic components and their
platform-specific implementation. However, it can be interesting to give access
to these monitors to the user. This can be done by using constraints on the
power and gain. These constraints can be used to check whether constraints on
power and gain are respected while the device is running, notifying the user if
they are not. This allows the user to add detection of erroneous events, such as
the loss of an input or failure to meet gain requirements. This can be used to
notify the user's control software of the error so that they may react
appropriately to it. Indeed, through the use of detectors, and especially
implicit detectors, the user may gain insight into the state of the device.

==== Categories of constraints
Using the aforementioned sections, one can categorise constraints into three
distinct categories: synthesisable constraints, which are used for real-time
feedback, simulation constraints, which are used for simulation, and meta
constraints, which are only used by the compiler. These three categories are not
mutually exclusive: most constraints can be used by the compiler and for
simulation, but some of them are only used for these purposes. Therefore, one
can see all constraints as being a hierarchy that can be seen in
@fig_constraint_hierarchy. It shows that all constraints are simulation
constraints, some of which are meta constraints, and some of those are also
synthesisable constraints. In @tab_constraint_types, the different types of
constraints are listed along with their category and a short explanation.

#ufigure(
  outline: [ Hierarchy of constraints. ],
  caption: [
    Hierarchy of constraints, showing that all constraints are simulation
    constraints, within that are meta constraints within which are synthesisable
    constraints.
  ],
  kind: image,
  image(
    "../assets/drawio/constraint_hierarchy.svg",
    width: 40%,
    alt: "Shows three ellipsis contained within one another, the center one is annotated as \"Synthesisable\", the middle one as \"Simulation\", and the outer one as \"Meta\".",
  ),
) <fig_constraint_hierarchy>

#pagebreak(weak: true)
#ufigure(
  caption: [ Different constraints on signals along with their category and a short
    explanation. ],
  kind: table,
)[
  #table(
    columns: (2em, 0.2fr, 1fr),
    align: center + horizon,
    stroke: (x: none),
    table.header(
      [],
      smallcaps[Constraint],
      smallcaps[Description],
    ),
    table.cell(rowspan: 2, rotate(-90deg, box(width: 200pt)[#smallcaps[Synthesisable]])),
    smallcaps[Power],
    align(
      left,
    )[
      Power constraints are used to specify the power of a signal. At runtime, it can
      check whether signals are present and within certain power budgets by using
      detectors.
    ],
    smallcaps[Gain],
    align(
      left,
    )[
      Gain constraints are used to specify the gain created by a component. It can use
      detectors around a gain section to check whether a gain section is able to meet
      its parameters and to allow feedback control.
    ],
    table.cell(rowspan: 3, rotate(-90deg, box(width: 200pt)[#smallcaps[Meta]])),
    smallcaps[Wavelength],
    align(
      left,
    )[
      Wavelength constraints are used to specify the wavelength content of a signal.
      This is used for the optimisation of filters and other wavelength-dependent
      components.
    ],
    smallcaps[Delay],
    align(
      left,
    )[
      Delay constraints are used to specify the actual, minimum, or maximum delay of a
      signal. This can be used to meet delay requirements after place-and-route.
    ],
    smallcaps[Phase],
    align(
      left,
    )[
      Phase constraints are used to specify the differential phase of a signal. This
      can be used to ensure that phase-sensitive circuits are able to work as
      intended.
    ],
    table.cell(rowspan: 2, rotate(-90deg, box(width: 200pt)[#smallcaps[Simulation]])),
    smallcaps[Noise],
    align(
      left,
    )[
      Noise constraints are used to add noise to a signal. This can be used to
      simulate noise sources and to simulate the impact of noise on a device.
    ],
    smallcaps[Modulation],
    align(left)[
      Modulation constraints are used to specify the modulation of a signal.
    ],
  )
] <tab_constraint_types>

==== Constraints on values
Expanding upon the concept of constraints further, adding constraints on values
other than signals is possible. It can allow the user to set specific
constraints, typically on numerical values, that can be used for two purposes.
The first purpose is to allow the validation of values automatically without
needing to write manual tests for values; this is often called a _precondition_.
The second purpose, which is further explained in
@sec_tunability_reconfigurability, is the ability to discover reconfigurable
states that cannot be reached based on the constraints. This is an optimisation
that can be done relatively easily by the compiler.

==== Constraint inference
Constraints propagate through operations done in succession. Each intrinsic
operation done on a signal adds its own constraints to the existing constraints.
This allows the compiler to infer constraints on intermediary and output signals
based on existing constraints and the constraints of the intrinsic operations.
The compiler does this to allow the user to specify as few constraints as
possible while still being able to infer the constraints on the signals. This
feature is critical for the usability of the ecosystem, as it reduces the burden
placed on the user of manually annotating their functions and signals with
constraints. The constraints of entire functions can be computed and then
summarised -- i.e. simplified and grouped together -- which simplifies the role
of the simulator as it is simply using these simplified constraints and applying
them to input spectrums and signals. This leads to a more efficient simulation
which is much faster than traditional physical simulations. This is examined
further in @sec_constraint_solver.

==== Constraint solver
The solver is the tool that the compiler uses to summarise and check
constraints. It will summarise the constraints on each signal such that it can
easily be simulated, and it will verify that constraints are compatible.
Additionally, in cases where the constraints depend on tunable values -- i.e.
values that can be changed at runtime -- the solver can use a prover and the
constraints on the tunable value to determine whether the constraints are
compatible. This is done by using a prover such as _Z3_ @z3. However, this is a
very computationally expensive process and must therefore, only be performed
when necessary. The compiler will only use the prover when the constraints
depend on tunable values. Therefore, one can see the constraint solver as a tool
composed of two subsystems, the first one, computing and verifying constraints
based on known data, it is simpler and faster, and the second one, computing and
verifying constraints based on tunable values, it is more complex, relying
instead on a prover. 

==== Limitations of constraints
There are, however limitations of the constraint system, most notably that,
using the aforementioned constraint solver, constraints are limited to
exclusively feedforward system. This is due to constraints being calculated one
after the other, not allowing cyclic dependencies. And as discussed in
@feedforward_approx, one can represent any recirculating circuit as a
feedforward system. However, there is one necessary condition for this to hold:
it _must_ be at a higher level of abstraction. When building the higher-level
abstractions, this axiom cannot be assumed to be true, as the user is writing
them at a lower level of abstraction. Therefore, the constraint system is
limited in such cases, and the system must provide an "escape hatch" which
allows the user to manually specify constraints at the edges of their
abstractions, such that the compiler can use them outside of the abstraction
while pausing constraint computation inside. When using this feature, the user
can now express recirculating circuits easily by using the escape hatch to
specify constraints on insufficient feedforward signals.

#uconclusion[
  Constraints can be used to validate signals, eliminate branches, and simulate
  the design. They are implemented using the constraint solver, combining
  constraints or using the _Z3_ prover to verify constraints @z3. However, they
  are limited to feedforward systems, and therefore an escape-hatch is needed to
  specify constraints on recirculating circuits.
]

== Tunability & Reconfigurability <sec_tunability_reconfigurability>

#udefinition[
  *Tunability* is the ability to change the value of a parameter at runtime to
  impact the behaviour of the programmed device.
]

Tunable values are values that can be interacted with, by the user, at runtime.
They can be any non-signal value in the user's program, typically numerical
values, that the user defines as being tunable values. These values can be seen
as tuning knobs that the user can access at runtime to change their circuit's
behaviour and implement their custom feedback loops. Tunable values can impact
several parts of the design at once. For example, a single value may determine
the centre frequency of operation of a bank of filters, all of them being tuned
at once. This makes tunable values especially powerful as their impact can be
propagated through the entire design.

The core idea behind tunable values is that the user can now represent parts of
the parameters of their design as runtime values that can be interacted with
while keeping all of the derived values within the circuit code itself. This
design aims to make hardware-software codesign easier and more productive.
Instead of having the complex relationships between parameters expressed within
the "software" part of hardware-software codesign, they can be directly
expressed on what they impact: the "hardware" part. This makes the design
process more intuitive and removes the potential for discrepancies between the
hardware and the software.

Additionally, the user should be able to name and access their tunable values by
name within their code. This further improves the usability of the system, as it
removes the need to maintain complex, error-prone tables of registers and their
corresponding values. Instead, the user can address their tunable value
naturally through its name, and the @hal can take care of the rest: translating
these names and values into an appropriate set of registers and values.

This means that the physical parameters of each element can be represented as
natural parameters -- i.e. numerical values -- while the underlying hardware
uses lower-level likely binary values and flags. This also improves the
development experience of the device provider, as they can now integrate the
code required to do data conversion within their platform-support package,
further simplifying the development of new support packages.

Furthermore, the use of constraints on values, such as explained in
@sec_constraints, can be used by the compiler to further detect the need for
reconfigurability automatically without additional user input. It can also be
used to validate that when a tunable value is changed in the user's software, it
meets its requirements, ensuring that the user cannot change the value to an
invalid one, where the device might then operate in an undefined state.

#udefinition[
  *Reconfigurability* is the ability to change the topology of the device at
  runtime and, therefore its behaviour.
]

Additionally, one of the most important functional requirements is the
reconfigurability. Its goal is to allow the user to reconfigure the mesh -- or
only parts of it -- while the device is running. This can be achieved in several
ways, but the most natural way is to use branches within the code to determine
the boundaries between reconfigurability regions. Then, through the use of
tunable values, these regions can be automatically selected based on their
value.

However, this brings a set of difficult problems to solve, the first of which is
the ability to determine whether a state is even reachable. However, this can be
done using constraints; through the constraint solver for tunable constraints,
one can verify which states are reachable and discard those unreachable. This is
a powerful optimisation, as it greatly decreases the amount of states that need
to be place-and-route, and, therefore, the amount of time needed to compile the
mesh.

Indeed, considering the following example, the user instantiates a mesh
containing $64$ input signals and $64$ output signals. Each input signal can go
into one of two filters based on branching. This, therefore, means that there
are $2^64$ possible states. It can easily be understood that this is an
intractable problem, as synthesising the project would be almost impossible.
However, if the system can determine that only two states are reachable for each
signal, this comes down to $128$ states, which is much more tractable.
Therefore, one can see that there is an interest in reducing the number of
states that need to be synthesised. One such way is by using the constraint
solver to eliminate unreachable states. The second way is by finding subsets of
the overall circuits that are independent of one another and, therefore, can be
mostly synthesised in isolation.

Neither of those two tasks is trivial, they can be seen as similar to the
halting problem, which is undecidable, and therefore, it is desirable to let the
user specify some of the state reduction manually, letting the user take care of
parts of the more complex cases. One can draw a parallel between this and the
use of the escape-hatch for constraints, as it is a similar concept, where the
user can specify constraints manually at the edge of abstraction, while here,
the user can specify how to reduce the number of states manually. However,
limiting the maximum number of iterations, the recursion depth, or both can make
the halting problem decidable. However, despite being decidable, it still incurs
a high computational cost. Therefore, one can expect that state reduction will
also be computationally expensive.

In @fig_reconfigurability, one may see what reconfigurability might look like on
a fictitious device, where based on an input variable, a simple boolean in this
case, the device will use either of two meshes. Each state #link(<fig_reconfigurability>)[(a)] and #link(<fig_reconfigurability>)[(b)] represents
a different mesh that implements a different filter. In this example, the user
would have created a tunable boolean that they can set at runtime, and based on
its value, the appropriate mesh will be selected.

#ufigure(
  kind: image,
  outline: [ Example of reconfigurability on a fictitious device. ],
  caption: [
    Example of reconfigurability on a fictitious device. Each state (a) and (b)
    represent a different filter. The second (b) filter has a longer ring and a
    higher @fsr than the first one (a). Squares of different colours represent
    photonic gates in different states: blue represents through gates, green
    represents cross gates, and yellow represents partial gates. The grey triangles
    represent optical ports.
  ],
  table(
    columns: 2,
    stroke: none,
    image(
      "../assets/drawio/reconf_ex_a.svg",
      alt: "Shows a photonic processor's mesh configured with a simple ring resonator filter.",
      width: 200pt,
    ),
    image(
      "../assets/drawio/reconf_ex_b.svg",
      alt: "Shows a photonic processor's mesh configured with a simple longer ring resonator filter.",
      width: 200pt,
    ),
    [(a)],
    [(b)],
  ),
) <fig_reconfigurability>

#uconclusion[
  Reconfigurability allows the user to create modular designs, where, at runtime,
  the user can select a different state to fit their needs. Reconfigurability is
  achieved through the branching of the code. The user can specify tunable values
  that are used to select the appropriate branch. The number of states is
  exponential but can be decreased using the constraint solver to remove
  unnecessary branches by finding independent mesh subsets and letting the user
  manually specify some of the state reduction.
]

#pagebreak(weak: true)

== Simulation <sec_intent_simulation>

As previously discussed, the user must also be able to simulate their circuit.
The traditional physical simulation approach is slow; therefore, finding
solutions to make simulations faster may be desirable. As was discussed in
@motivation, there is ongoing research in using @spice to simulate photonic
circuits. Additionally, some of this work is being conducted at the @prg. One of
the main advantages of this solution, as opposed to the one presented below, is
that it allows for recirculating meshes. However, it is not as fast as the
solution presented in this document, and therefore, it is not as well suited for
the use case of this project.

Additionally, the #gloss("spice")-based simulations may be able to incorporate
more effects, such as the effects of the non-linearity of components, which may
lead to more accurate simulations. Despite this, the user may not want a
physically correct simulation. Instead, they may want a fast simulation
representative of their circuit without all the physical hardware limitations.
In essence, this is similar to simulations for electronic @hdl development,
where the simulations are not physical yet are still representative.

The simulation scheme that is suggested in this research is to use constraints
to simulate the circuit. The idea is that the constraint solver can be used to
summarise the constraints on each net. It can then be used to calculate
analytically the value of each net and, therefore, the value of each signal. The
main difference with other approaches is that this can be done very quickly with
relatively simple code due to the relative simplicity of constraints. This
simplicity improves the simulation's performance, as discussed in
@sec_constraint_solver, but also decreases the work required to maintain and
update this simulator as time goes on.

In practice, simulations would be separated into two categories: time domain
simulation, which takes one or more signals modulated onto carrier optical
signals and simulates their processing and a frequency domain simulation which
looks at the frequency and phase response of the device. The reasoning behind
this separation is as follows: due to the extremely high frequency of light,
accurately representing light in the time domain is extremely difficult, as it
requires very small time steps. Instead, if using the frequency domain, one can
decouple the modulated signals by using the spectral envelope of the modulated
signal as the input to the simulation. This, therefore, allows for easy analysis
of the spectral performance without the computation cost of small timesteps.
Then, in the time domain, the user specifies sets of wavelengths which are then
modulated with the signal of interest, which can be passed through the device.
This allows time domain simulation to use much bigger time steps on the
modulating signal's period rather than timesteps on the light's period.

However, this introduces a limitation; due to this dichotomy, the user must
simulate both effects separately and analyse the results. While this makes the
simulation process more limited, it also makes it more flexible, as if the user
only needs one of the simulation kinds, they can avoid needing to simulate the
other, decreasing computation time further.

==== Simulation ecosystem
There exist many tools for the simulation of photonic circuits. Additionally,
there also exist a lot of tools for the kind of resolution that is being done.
It is, therefore, of interest to reuse as many existing tools as possible. As
long as these tools are free, they do not incur a cost on the user's end.
Additionally, by reusing existing tools, the user can benefit the ecosystem
surrounding these solutions and the community using them. Furthermore, it also
simplifies the simulation ecosystem's development, as it no longer requires
writing the entire simulation ecosystem from scratch. Instead, reusing existing
tools and using the best-in-class tools for each task.

== Platform independence <sec_platform_independence>

As the development of photonic processors continues, new devices must be
expected to bring new features, different hardware programming interfaces, and
characteristics. Ideally, all of the code would be backward and forward
compatible, being able to be programmed on an older or a newer device with
little to no adjustments. Therefore, one must plan for platform support right at
the core of the design of a photonic processor ecosystem. In this document,
several approaches will be suggested for tackling this issue. These approaches
are meant to be used in conjunction with each other.

==== Standard library
All platforms must share a common standard library containing base building
blocks and more advanced synthesis tools -- i.e., filter synthesis -- that is
common across all devices. This library must be able to be used by all devices.
Therefore, it must be able to be compiled into the intrinsic operations
mentioned in @sec_intrinsic_operations. Additionally, providing common building
blocks and abstraction makes developing circuits targetting photonic processors
easier. This is similar to the standard library for regular software
development, where the language provides a set of functionalities out-of-the-box
that the user can use.

==== Platform support packages
Each platform must come with a platform-support package that implements several
tools: a hardware programmer for programming the circuit onto the device; a
compatibility layer for the standard library such that the standard library is
compatible with the hardware; some device-specific libraries for additional
features if needed; a place-and-route implementation, it may be shared across
many devices, but the support package must at least list compatible
place-and-route implementations. With these components, the user's circuit
should be able to be compiled while using the standard library and then
programmed onto the device for a working circuit.

==== Hardware abstraction layer
Each platform must come with a @hal which allows the user to interact with the
device programmatically at runtime. This @hal must provide features for
communicating, setting tunable components and reading the state of the device.
The @hal can be reused across devices as long as the devices have similar
hardware interfaces. In @sec_hal, this will be further discussed, including how
parts of the @hal can be generated based on the user's design for improved
usability and easier hardware-software codesign.

==== Constraint packages
It must also come with information regarding delays and phase response of its
different components, as well as the capabilities of some of its components like
amplifiers, modulators, etc. This information can be used by the constraint
solver and the simulation ecosystem to more accurately represent the
capabilities of the circuit and allow the user to make informed decisions.
Additionally, a platform may come with additional simulation-specific
constraints for more accurate simulations and the additional information
provided by the constraint packages.

== Visualisation <sec_visualisation>

Several types of simulations may be useful for the user: the user might want to
visualise the generated circuit mesh superimposed onto a schematic
representation of the device to verify that no critical components were removed
through constraints, to see the usage at a glance, or to visualise whether the
place-and-route performed adequately. This visualisation is already presented in
the existing library and exists in @eda tools for photonics. Therefore, such
visualisation facilities must be offered to the user. Mainly due to the fairly
early research stage, the ability to communicate results visually is critical to
the user's understanding of the results. Another kind of visualisation the user
will want is the simulation results. Therefore, the ecosystem must provide easy
visualisation of results.

==== Applying @dry
As is the case of the simulation ecosystem, one can reuse existing tools and
libraries for visualisation that are already on the market. This applies the #gloss("dry", long: true) principles,
where one can reuse existing tools and libraries rather than rewriting them from
scratch. This also allows the user to benefit from the large ecosystem of
existing visualisation tools and to use the tools they are most familiar with or
that give the best results for their application. Examples of such
visualisations can be seen in @fig_reconfigurability, which shows the mesh and
the state of each gate, and a simulation result in
@fig_simulation_result_example, which shows the results of a time-domain
simulation using the aforementioned constraint solver.

#ufigure(
  kind: image,
  outline: [ Example visualisation of a time-domain simulation result. ],
  caption: [
    Example visualisation of a time-domain simulation result, showing a $10 "Gb/s"$ modulated
    @prbs $15$ sequence on top of a $1550 "nm"$ carrier. The simulation was
    performed using the constraint solver. Shown is a $10 "ns"$ window of the
    simulation. The simulation was run for a total of $1 "µs"$ with an average
    execution time of $9 "ms"$. The simulation simulates a laser source with noise
    and the rise and fall time of the modulated signal, the rise and fall time being $50 "ps"$.
  ],
  image(
    "../assets/simu_example.svg",
    alt: "Shows the startup of a 10Gb/s modulated optical signal with noise, rise and fall time.",
    width: 100%,
  ),
)<fig_simulation_result_example>

== Calibration and variation mitigations <sec_calibration_and_variation_mitigations>

Photonic circuits can be susceptible to manufacturing variations and temperature
variations. Therefore, each device must come with mitigation techniques that can
aid in making the device behave as ideally as possible. This is expected to
generally be done using calibration curves or calibration @lut[s]. And by using
feedback loops to ensure that a component behaves as expected. For example, a
power combiner might maximise power output using a feedback loop on a phase
shifter to create constructive interference.

==== Feedback loops
Feedback loops are essential to overcoming variations, especially those caused
by temperature variations. A feedback loop can read a power monitor on the chip
and adjust the tunable value of another element. Feedback loops can be built-in,
as in added automatically by the compiler for specific tasks, based on the
device support package and the intrinsics being used. Or they can be created
manually by the user, in which case they must write code that, using the @hal,
reads the sensors and then writes to whichever tunable value they need.

==== Wavelength dependence
Additionally, to manufacturing variability and temperature dependence, the
device's response is also wavelength dependent. This is due to the physical
properties of the materials from which the device is made of. Hence there are no
easy ways of mitigating these effects. However, by using constraints, the
compiler can know which wavelengths are expected in which component, and
similarly to using calibration curves for device-to-device variability, it can
use similar response curves to adjust the circuit to the expected wavelength.
This is expected to be done automatically by the compiler, but it requires that
the user specifies wavelength constraints.

== Resource management

Another aspect of designing circuits for programmable devices, whether they be
traditional processors, @fpga[s] or photonic processors, is resource management.
A limited number of elements are built into the hardware, and the user must be
able to use these elements as efficiently as possible. This may be especially
true for photonic processors where the number of gates is currently relatively
small. Below is @tab_resources, which lists potential resources that may be
present on the device. These resources are obtained from the description of
intrinsic values in @sec_intrinsic_operations and the components of a photonic
processor detailed in @photonic_processor.

#ufigure(
  caption: [ List of device resources and their description. ],
  kind: table,
  table(
    columns: (auto, 1fr),
    align: center + horizon,
    stroke: (x: none),
    table.header(
      smallcaps[*Resource*],
      smallcaps[*Description*],
    ),
    smallcaps[*Photonic gate*],
    align(
      left,
    )[
      The photonic gate is the core element of the photonic processor; it can be
      arranged in a grid, whether square, triangular or hexagonal. It generally
      contains a 2-by-2 tunable coupler and power detectors for monitoring. It is used
      to process the light and to route the light around the chip.
    ],
    smallcaps[*High-speed detector*],
    align(
      left,
    )[
      High-speed detectors are used to demodulate the light; they can operate either
      in an amplitude demodulation scheme or be used with interference to perform
      phase demodulation.
    ],
    smallcaps[*High-speed modulator*],
    align(
      left,
    )[
      High-speed modulators are used to modulate the light; they can operate either in
      a phase modulation scheme or be used with a @mzi to perform amplitude
      modulation.
    ],
    smallcaps[*Laser source*],
    align(
      left,
    )[
      Laser sources are used to generate light at a given wavelength directly inside
      the device. Due to the devices being made in silicon, there are none on existing
      prototypes. However, they may be added using epitaxial growth or micro-transfer
      printing.
    ],
    smallcaps[*Gain section*],
    align(
      left,
    )[
      Gain sections are used to amplify the light, generally made of a semiconductor
      optical amplifier or an erbium-doped waveguide section. As with laser sources,
      there are currently no gain sections on prototypes.
    ],
    smallcaps[*Optical port*],
    align(
      left,
    )[
      These ports at the edge of the device can be used to couple light in and out of
      the device.
    ],
    smallcaps[*Switch*],
    align(
      left,
    )[
      Switches can be either implemented using the mesh and couplers, using a power
      splitter with its coupling coefficient controlled by a tunable value, or built
      into the device as dedicated hardware. There are no dedicated hardware switches,
      but they may be added in future devices.
    ],
  ),
) <tab_resources>

#pagebreak(weak: true)
== Responsibilities and duties

#ufigure(
  outline: [ Responsibilities of each actor in the ecosystem. ],
  caption: [
    The responsibilities of each actor in the ecosystem, elements in orange, are the
    responsibility of the ecosystem developer. It includes the compiler, constraint
    solver and standard library. It also contains parts of the @hal generator. The
    elements in blue are the responsibility of the chip designer. It includes the
    device itself, the core @hal, and the device support package. Elements in green
    are the responsibility of the user. This includes the user's design and the
    user's control software. It also shows the different components of the ecosystem
    that have been discussed so far and their overall interaction with one another.
  ],
  image("../assets/drawio/smol/responsibilities.png"),
) <fig_responsibilities>

As with most ecosystems, the responsibilities for the development of different
parts and the duties of maintaining these parts are split between different
actors. In this case, one can see the ecosystem being designed in this thesis as
having four actors: the user who is responsible for the design of their circuit,
their own control software, the maintenance of their code, and the compatibility
of this code with the ecosystem. The second actor is the developer of the
ecosystem itself, their responsibility is spread among several tasks, from the
programming ecosystem components discussed in
@sec_programming_photonic_processors, to the standard library, and the
constraint solver. Due to the critical importance of these tools, the duties of
maintaining some degree of backward and forward compatibility along with making
sure that the tools are as bug-free as possible falls on the ecosystem
developer. The third actor is the chip provider, they design the actual physical
layer: the photonic processor. Because of this, they must also produce the
device support package and the core @hal. Their responsibilities are to ensure
that their device is compatible with the common parts of the ecosystem, that
their devices can work in expected use scenarios, and to provide the @hal
generator. The fourth and final actor are all of the external tool provider,
those can be libraries developers, @eda tool developers, etc. Most of the time,
their projects' licenses will remove any and all responsibilities from their
user. Therefore, special care must be taken when integrating external tools and
libraries so that trustworthy actors maintain them. A summary of these
responsibilities and their interactions with one another can be seen in
@fig_responsibilities.