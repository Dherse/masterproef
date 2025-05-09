#import "../ugent-template.typ": *

= Introduction <intro>

Photonic integrated circuits have become a significant industry in the past few
years. However, their design is still difficult and slow, requiring a lot of
expertise and time. This thesis provides a novel way of designing photonic
circuits using code and a new way of simulating them using a faster simulation
paradigm. This should allow for the rapid prototyping and iteration of photonic
circuits. And the co-simulation of photonic circuits with other system
components. This thesis will focus on its applicability to the field of
programmable photonics, especially recirculating programmable photonics.
However, the concepts and ideas presented in this work apply to the broader
field of photonic circuit design.

To enable rapid development and prototyping, several teams around the world,
including at the @prg, have been researching ways of creating so-called photonic
processors: devices that are generic enough to be reconfigured to meet a variety
of use cases. These devices are generally based on the concept of recirculating
meshes, which allow the designer to create all kinds of different circuits by
simply changing the configuration of the mesh @bogaerts_programmable_2020.
As such, these devices are often referred to as programmable @pic[s]. These
devices were used as inspirations and will be used as demonstration platforms
for the work and mockups presented in this thesis.

This thesis merges aspects from several disciplines, including photonics and
computer science. As such, it will ﬁrst give some background information about
photonics that is required to understand this thesis, followed by an in-depth
analysis of the computer science concepts and paradigms discussed in this
thesis. This analysis will allow for a comparison of existing languages,
paradigms, and techniques and will lead to the development of a novel solution
for photonic circuit design. Then, a discussion will be presented on the
translation of the user's intent and the requirements that must be met to
translate this intent. Finally, a discussion of the language created as part of
this thesis, #gloss("phos", short: true), will be presented, as well as a set of
examples showing its effectiveness and simulation capabilities.

== Motivation <motivation>

There is a need to develop appropriate abstractions and tools for the design of
photonic circuits, especially as it pertains to the programming of so-called
photonic @fpga[s] @bogaerts_programmable_2020-1 or photonic processors.
As with all other types of circuit design, such as digital electronic circuits,
analog electronic circuits, and RF circuits, appropriate abstractions can allow
the designer to focus on the functionality of their design rather than the
implementation @geiger_vlsi_1990. One may draw parallels between the
abstraction levels used when designing circuits and the abstractions used when
designing software. Most notably, the distinction made in the
software-engineering world between imperative and declarative programming. The
former is concerned with the "how" of the program, while the latter is focused
on the "what" of the program @noauthor_imperative_2020.

At a sufficiently high level of abstraction, the designer is no longer focusing
on the implementation details (imperative) of their design but rather on the
functionality and behavioural expectations of their design (declarative) @noauthor_imperative_2020.
In turn, this allows the designer to focus on what truly matters to them: the
functionality of their design.

Much of the design work on photonic circuits is currently done at a low-level of
abstraction, close to the component-level @bogaerts_silicon_2018. This
lack of abstraction leads to several issues for broader access to the fields of
photonic circuit design. Firstly, it requires expertise and understanding of the
photonic components, their physics, and the sometimes complex relationship
between all of their design parameters. Secondly, designing and simulating a
photonic circuit requires a lot of time and effort. Physical simulation of
photonic circuits is slow @bogaerts_silicon_2018 @alerstam_parallel_2008, which
has led to efforts to simulate them using @spice @ye_spice-compatible_2022.
Finally, the design and implementation of photonic circuits are generally
expensive, requiring taping out of the design and working with a foundry for
fabrication. Therefore, the low-level nature of current methods increases the
cost and the time to market for the product @bogaerts_programmable_2020.
Due to this, there is considerable interest in constructing new abstractions,
simulation methods, and design tools for photonic circuits, especially for rapid
prototyping and iteration. This master's thesis aims to find new ways in which
the user can easily design their photonic circuit and program them onto those
programmable @pic[s] @bogaerts_programmable_2020.

Additionally, photonic circuits are often not the only component in a system.
They are often used in conjunction with other technologies, such as analog
electronics, used in driving the photonic components, digital electronics, to
provide control and feedback loops and @rf to benefit from photonics' high
bandwidth and high-speed capabilities @marpaung_integrated_2019.
Therefore, it is of interest to the user to co-simulate @bogaerts_silicon_2018
@sorace-agaskar_electro-optical_2015 their photonic circuits with the other
components of their systems. This problem is partly addressed using @spice
simulation @ye_spice-compatible_2022. However, @spice tools are often
lacking, especially regarding digital co-simulation, making the process
difficult @osti_1488489, relying instead on ill-suited alternatives such
as @verilog-a.

This work will offer a comprehensive solution to these problems by introducing a
new way of designing photonic circuits using code, a novel way of simulating
them, and a complete workflow for designing and programming them. Finally, an
extension of the simulation paradigm will be introduced, allowing for the
co-simulation of the designs with digital electronics, which could, in time, be
extended to analog electronics.

=== Research questions <research-questions>

The main goal of this work is to design a system to program photonic circuits.
It entails:
+ How can the user express their intent?
  - Which programming languages and paradigms are best suited?
  - What workflows are best suited?
  - How can the user test and verify their design?
+ How to translate that intent into a @pic configuration?
  - What does a compiler need to do?
  - How to support future hardware platforms?
  - What are the unit operations that the hardware platform must support?
