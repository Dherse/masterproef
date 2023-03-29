#set heading(numbering: none, outlined: false)
#set page(numbering: "I")
#show heading: it => block[
    #set text(size: 30pt, weight: "extrabold", font: "UGent Panno Text", fill: rgb(30,100,200))
    #set par(leading: 0.4em, justify: false)
    #underline(smallcaps(it.body), evade: true, offset: 4pt)
    #v(0.2em)
]

= Acknowledgements

#pagebreak()
= Remark on the master's dissertation and the oral presentation

#pagebreak()
= Abstract

#pagebreak()
#outline(title: "Table of contents", indent: true)

#pagebreak()
= Glossary

#pagebreak()
= List of figures

#pagebreak()
= List of tables

#pagebreak()
= List of code listings

#set heading(numbering: "1.1.a", outlined: true)
#locate(loc => counter(page).update(1))


#pagebreak()
= Introduction <intro>
== Motivation <motivation>
=== Research questions <research-questions>


#pagebreak()
= Programmable photonics
== Photonic processors
=== Feedforward and recirculating mesh <feedfoward_vs_recirculating>
=== Potential use cases of photonic processors <photonic_processors_use_cases>
=== Embedding of photonic processor in a larger system <photonic_processors_in_systems>
== Circuit representation <circuit_repr>
=== Bi-directional systems
=== Feedforward approximation <feedforward_approx>
== Initial design requirements <initial_requirements>
=== Interfacing <interface>
=== Programming <programming>
=== Reconfigurability <reconfigurability>
=== Tunability <tunability>


#pagebreak()
= Programming of photonic processors
== Analysis of existing software ecosystems
=== Compiler and runime
=== Code editors
=== Formatting
=== Linting
=== Testing
=== Debugging
== Analysis of programming paradigms
=== Imperative programming
=== Functional programming
=== Object-oriented programming
=== Logic programming
=== Dataflow programming

#pagebreak()
= Translation of intent

#pagebreak()
= The PHÔS programming language

#pagebreak()
= Examples of photonic circuit programming

#pagebreak()
== Using traditional programming languages <the_good_the_bad_and_the_ugly>

#pagebreak()
= Extending PHÔS to generic circuit design
= Simulation in PHÔS

#pagebreak()
== Co-simulation with digital electronic
== Towards co-simulation with analog electronic

#pagebreak()
= Future work

#pagebreak()
= Conclusion
= Conclusion
= Conclusion
= Conclusion
= Conclusion
= Conclusion
= Conclusion
= Conclusion
