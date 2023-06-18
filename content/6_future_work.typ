#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

= Future work <sec_future_work>

This section will give short introductions to some of the interesting research topics and areas that are related to PHÔS.

== Implementation

As of writing this thesis, @phos is still very much in its infancy, while the first two elements of its compilation pipeline are implemented, many of its components need implementing. However, this document outline in great details what each component should do, and how they should generally do it. This means that the implementation of @phos is mostly a matter of time and effort.

== Dependent types & refinement types <sec_refinement_types>

#info-box(kind: "definition")[
    *Dependent types* are types that depend on values. For example, in the case of @phos, they could depend on an argument such as the center wavelength of a filter.
]

#info-box(kind: "definition")[
    *Refinement types* are types that are refined by predicates. In the case of @phos, they could be used to refine the types using constraints.
]

One potential improvement to the @phos language is the use of dependent and refinement types. Together, this would allow the typing of different synthesizable block to be stronger and have stronger guarantees over the validity of the design. While @phos already implements those partly in its current architecture, they are not integrated as part of the types, instead being additional values carried by the types. This means that the compiler, in its current design iteration, is limited on the complexity of constraint it can properly verify. This is a limitation that can be lifted by integrating dependent and refinement types as part of the type system, where constraints would be part of the type definition, and the compiler would be able to fully verify them at compile time, adding further verification of the user's design. However, refinement types in particular are not trivial to implement, and would require a lot of work and research to be properly integrated into the language.

== Advanced constraint solving & constraint inference

In its current iteration, the constraint system cannot infer new constraints, only existing ones. This means that a circuit that behaves as a filter must be manually annotated with a filter constraint to be recognized as one. This is a limitation that may be able to be lifted by being able to infer new constraints rather than just existing ones. This would allow the compiler to recognize more complex circuits, without the user having to manually annotate it as such. This could be implemented by automatically running frequency domain analysis over portions of the code, by using a set of predefined rules to infer constraints from the circuit's structure, by using machine learning to infer constraints from the circuit's structure, or by using a combination of those methods. This is an area with the potential for new and interesting research with applications outside of photonics as well.

== Co-simulation with digital electronic

While it is not implemented yet, it would be relatively easy and interesting to interface the constraint solver with digital electronic simulation. This could be done with a tool such as _Verilator_ and by using an event-driven simulation model. The constraint solver could run, until a digital even is triggered, such as the rising edge of a clock, and then the digital simulation would be run, at which point the constraint solver would be running again, taking into effect the changes done by the digital simulation. This would continue as long as the simulation is running. This would allow the co-simulation of @phos code with digital electronic, and would allow the simulation of larger parts of a system.

== Place-and-route

While algorithm for the routing of photonic components on photonic processor have been created, there are no complete place-and-route solutions for photonic processors.

== Programming of generic photonic circuits <sec_phos_generic>

This thesis is mostly focused on photonic processors, however, @phos can be used for the creation of generic photonic circuits. By replacing the platform-support package with a photonic development kit would allow the user to create any circuit. This development kit would then interface with a manufacturer's PDK, allowing the user to create custom chips from their design. Some parts of the design would need to be done externally, such as placement, but there are already tools for that, such as _Luceda's IPKISS_. This is made especially easy through the marshalling library, discussed in @sec_marshalling, which allows the user to easily interface with a _Python_-based PDK.

== Language improvements <sec_lang_improvements>

Several language improvements and additions should be made to make development easier, such as adding error handling, generics, bitflags, macros, reflection, meta programming, algebraic effects, incremental compilation, and more. This section will give a short introduction to each of those topics, and how they could be used in @phos.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Bitflags*]
}
Bitflags are similar in principle to enumerations, but they allow for more than one value to be set at a time. This is useful for the creation of flags, replacing list of booleans with a single value containing all of the boolean values, each encoded on one bit.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Generics*]
}
Generics were discussed in @sec_typing under the more formal name of polymorphism, currently the @phos design does not involve generics for simplicity. However, due to the complexity of the type system, generics would be very useful and would allow for less "magic" functions, such as `map` which can take any type. This would allow the user to implement complex polymorphic functions themselves rather than being forced to defer to implementation within the compiler.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Traits and type classes*]
}
If generic types were to be implemented, traits would need to also be implemented, traits define a set of functions that a type must implement to be considered to implement the trait. This is similar to interfaces in object-oriented programming, but with the difference that traits can be implemented on types that are not defined in the same module as the trait. This is useful for the creation of generic functions that can be used on any type that implements the trait. This can be done rather easily be relying on _Rust_'s _Chalk_ library, which is a trait solver @chalk.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Error handling*]
}
Currently @phos has no facilities for evaluation errors, this is an oversight and an error handling model must be added. This could be done with a `Result` type, or with exceptions. The advantage of the `Result` type is that it is explicit, and that it forces the user to handle the error, while the advantage of exceptions is that they are implicit. However, having a `Result` type would require generics to be implemented first, as it would need to be generic over the value and error types.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Macros and reflection*]
}
It was discussed @sec_ast_desug, that @phos could benefit from macros, macros are functions called by the compiler, during compilation, that transform the input @ast into a new @ast. They can be used to generate complex code from simpler code. However, @phos could also benefit from compile-time reflection, allowing the user to write compile plugins that can introspect the program and modify it while it is compiling. It could be used to have the same effect as macros, but would be much more capable, as it would allow the user to introspect the program and modify it, rather than just transform the @ast.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Incremental compilation*]
}
Currently, @phos does not support incremental compilation, this is a limitation that should be lifted. Incremental compilation is the ability to only recompile the parts of the program that have changed, rather than recompiling the whole program. However, in the case of @phos, compilation is not the slowest part of the process, and it would be useful to be able to perform increment place-and-route, rather than just incremental compilation. This could potentially make the development of large circuits much faster, by reusing the placement and routing of unchanged parts of the circuit.
