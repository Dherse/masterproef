#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

#blank-page()
= Conclusion

In this thesis, a new approach for the description and subsequent programming of photonic processors combined an easy-to-use programming language with powerful new features, such as constraints, reconfigurability through branching, and tunability. Together, these features create a modern, flexible, and novel hardware description language that is able to describe a wide range of photonic circuits and can be used for both the development of circuits for photonic processors, as well as the development of standalone photonic circuits.

This design was created after a thorough analysis of existing programming languages and paradigms was performed, shedding light on each language's strengths, weaknesses, and applicability. The analysis showed that modern languages with fully-featured first-party ecosystems are good candidates for developing a new language and implementing libraries but that a new hardware description language was needed overall. This new language, called @phos, results from months of research and development and is the first hardware description language to combine aspects of modern programming languages with unique features designed specifically for photonic circuits.

Through the analysis of relevant, real-world examples, this thesis has shown that @phos is a powerful language that is appropriate and useful for the development of photonic circuits. The examples have shown that @phos is able to concisely describe complex circuits, their constraints, and functionality while still being easy to read and understand. Additionally, it was demonstrated that the constraint solver used for simulations is, despite its early stage, already usable to create meaningful results and that the simulation of photonic circuits can be done quickly and efficiently.

@phos has also been designed so that it can be created by a relatively small team, by reusing existing algorithms and libraries available in both the _Rust_ and _Python_ ecosystems. This makes @phos an ideal candidate for future development of photonic circuit programming, as it is easy to expand, modify, and maintain.

Finally, the design of the @phos language has shed light on new areas of research into which photonic circuit programming can be expanded, including the development of a new, more powerful constraint solver, the use of state-of-the-art type systems for improved correctness, and the ability to use the language for the development of non-traditional computing such as analog computing.