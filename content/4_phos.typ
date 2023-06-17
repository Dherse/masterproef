#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *
#import "../elems/tablex.typ": *
#import "../elems/hexagonal.typ": hexagonal_interconnect, f

= The PHÔS programming language <sec_phos>

Based on all of the information that has been presented so far regarding translation of intent and requirements (@sec_intent), programming paradigms (@sec_paradigms), and with the inadequacies of existing languages (@sec_language_summary), it is now apparent that it may be interesting to create a new language which would benefit from dedicated semantics, syntax, and integrate elements from fitting programming paradigms for the programming of photonic processors. This language should be designed in such a way that it is able to easily and clearly express the intent of the circuit designer, while also being able to translate this code into a programmable format for the hardware. Additionally, this language should be similar enough to languages that are common within the scientific community such that it is easy to learn for engineers, and leverage existing tools. Finally, this language should be created in such a way that it provides both the level of control needed for circuit design, and the level of abstraction needed to clearly express complex ideas. Indeed, the language that is presented in this thesis, @phos, is designed to fulfill these goals.

In the following sections, the initial specification, the syntax, constraint system, and other various elements of the language will be discussed. Then, in @sec_examples, examples will be shown how the language can be used to express various circuits. However, before discussing the language in itself, it is important to discuss the design of the languages, the existing languages it draws inspiration from, and the lessons it incorporates from them.

== Design <sec_design>

#info-box(kind: "info")[
    The name of the language, @phos, is a reference to the ancient Greek word for light or daylight, φῶς (phôs).
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Inspiration*]
}
@phos primarily takes inspiration from _Python_ and _Rust_ for its syntax, while incorporating elements from functional languages such as _Elixir_#footnote[_Elixir_ has not been discussed in this thesis, but it provides the piping operator which is incorporated into @phos.]. Its semantics, especially as they relate to signals, are inspired by traditional hardware description languages, most notably _SystemVerilog_ and #emph[@vhdl]. Other semantics, as they relate to values, are inspired by _Rust_. Other elements, such as comments are inspired by the _C_ family of languages, while documentation comments are inspired by _Rust_ as well.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Synthesizable*]
}
@phos separates regular functions from synthesizable blocks, whereas synthesizable blocks are able to interact with signals, regular functions are forbidden from operating on signals. This is done to ensure that branching reconfigurability computations are only done on synthesizable blocks. Ideally, synthesizable blocks would be kept as short as possible while functions can be much longer.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Paradigm*]
}
@phos is an imperative language with many functional elements, it purposefully keeps the easier aspects of imperative programming, while incorporating functional elements to make it both easier to reason about and easier to synthesize into hardware. The language is purposefully kept simple, with only a few elements from each paradigm, to ensure that it is easy to learn and easy to use. Form follows function, and the language is designed to be used by engineers and researchers, not by computer scientists.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constraints*]
}
@phos can express constraints directly in its syntax, this is opposed to other languages such as @vhdl and _SystemVerilog_ which require timing constraints to be specified externally. This is done to ensure that the constraints are always in sync with the code, and that the constraints are always available at a glance. Additionally, @phos uses a constraint system that is compatible with both signals and regular values, this is done for several purpose, chief among them is to ensure that reconfigurability regions can be minimized as discussed later on, in @sec_branching_reconfig.

== PHÔS: an initial specification <sec_spec>

This section serves as an initial specification or reference to the @phos programming language. It contains the elements and semantics that have already been well defined and are unlikely to change. Therefore, this section is not a complete specification as that would require that the language be more mature, however it serves as an in-depth introduction into the concepts, paradigms, and semantics of the language. Most parts of the specification are companied by a short example to illustrate the syntax and the semantics of the language. Additionally, some elements are further explored in subsequent section of this chapter, with only the basics being presented here.

=== Execution model <sec_exec_model>

@phos is a photonic hardware description language, due to its unique requirements, it is not designed in a traditional way and instead separates the compilation to hardware into three distinct steps: compilation, evaluation, and synthesis. The compilation step is responsible for taking the source code, written in human-readable text, and turning it into an executable form called the bytecode, see @sec_mir_to_bytecode. Followed by the evaluation, the evaluation interprets the bytecode, performs several tasks discussed in @sec_vm, and produces a tree of intrinsic operations, constraints and collected stacks. This tree is then synthesized into the output artefacts of the language, namely, the user @hal and a programming file for programming the photonic processor. The execution model is shown graphically in @fig_exec_model, showing all of the major components of the language and how they interact with each other. Further on, more details will be added as more components are discussed.

#figurex(
    title: [ Execution model of the @phos programming language ],
    caption: [
        Execution model of the @phos programming language, showing the three distinct stages. Responsibilities use the same color code as @fig_responsibilities, showing the ecosystem components in orange, the user's code in green, the platform specific code in blue, and the third party code in purple.
    ]
)[
    #image(
        "../figures/drawio/exec_model.png",
        width: 100%,
        alt: "Shows the execution model as the user code and the std lib going into the compiler, along with the platform support package. The result is bytecode which goes into the virtual machine in the evaluation stage. The VM communicates with the constraint solver and the Z3 prover to produce the constraints & intrinsic operations. These are then fed into the synthesizer which produces the user HAL and the programming binary for the photonic processor, all the while using the platform HAL generator and the place-and-route."
    )
]<fig_exec_model>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Function execution model*]
}
The execution model of functions in the @phos programming language is similar to that of _Java_ and _C_, every statement is terminated by a semicolon (`;`), with the exception of automatic return statements. @phos is single threaded and exclusively execute statement in the order that they are written in. Branching causes the @vm to jump from one place in the code to another. Function calls are executed by jumping to the entry point of the callee function, executing it in sequence, then returning to the next statement in the caller. Statements are therefore indivisible units of work. Additionally, @phos has order of precedence for its operators, therefore the order of execution of operators is not necessarily the order in which they are written. However, the order of statements is always the order in which they are written. Statements being composed of operators and operands, the order of execution of operators is determined by their precedence, with the highest precedence being executed first. The precedence of operators is shown in @tbl_op_precedence.

#figurex(
    title: [ Operator precedence in @phos. ],
    caption: [
        Operator precedence in @phos, from highest to lowest. Operators with the same precedence are executed from left to right. The precedence of operators is used to determine the order of execution of operators in a statement. The associativity of the operator is also shown, it can be left-associative, right-associative or neither for special operators that only have one operand.
    ]
)[
    #tablex(
        columns: (auto, 1fr, auto),
        align: center + horizon,
        auto-vlines: false,
        repeat-header: true,

        smallcaps[*Precedence*],
        smallcaps[*Operator*],
        smallcaps[*Associativity*],

        1,
        align(left)[ Conditional statements, loops, parenthesized expressions, unconstrained block, empty expressions ],
        align(left)[ Left ],

        2,
        align(left)[ Function calls],
        align(left)[ Left ],

        3,
        align(left)[ Array indexing ],
        align(left)[ Left ],

        4,
        align(left)[ Field access ],
        align(left)[ Left ],

        5, 
        align(left)[ Type casting ],
        align(left)[ Left ],

        6,
        align(left)[ Raising to a power ],
        align(left)[ Right ],

        7,
        align(left)[ Unary operators: negation, bitwise complement, logical complement ],
        align(left)[ Right ],
        
        8,
        align(left)[ Multiplication, division, remainder ],
        align(left)[ Left ],

        9,
        align(left)[ Addition, subtraction ],
        align(left)[ Left ],

        10,
        align(left)[ Bitwise shift left, bitwise shift right ],
        align(left)[ Left ],

        11,
        align(left)[ Bitwise and ],
        align(left)[ Left ],

        12,
        align(left)[ Bitwise xor ],
        align(left)[ Left ],

        13,
        align(left)[ Bitwise or ],
        align(left)[ Left ],

        14,
        align(left)[ Equality operators: equal, not equal ],
        align(left)[ Left ],

        15,
        align(left)[ Relational operators: less than, less than or equal, greater than, greater than or equal ],
        align(left)[ Left ],

        16,
        align(left)[ Logical and ],
        align(left)[ Left ],

        17,
        align(left)[ Logical or ],
        align(left)[ Left ],

        18,
        align(left)[ Pipe operator ],
        align(left)[ Right ],

        19,
        align(left)[ Range operators: inclusive range, exclusive range ],
        align(left)[ Neither ],

        20,
        align(left)[ Assignment operators: assign, add assign, subtract assign, multiply assign, divide assign, remainder assign, bitwise and assign, bitwise or assign, bitwise xor assign, bitwise shift left assign, bitwise shift right assign ],
        align(left)[ Neither ],

        21,
        align(left)[ Closures ],
        align(left)[ Neither ],

        22,
        align(left)[ Control flow operators: break, continue, return, and yield ],
        align(left)[ Neither ]
    )
] <tbl_op_precedence>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Synthesizable execution model*]
}
Synthesizable blocks follow a different execution model due to reconfigurability: when a block of code cannot be evaluated, it is analyzed to remove as much code as possible before being collected into a stack. The stack is then stored along with the intrinsic subtree of that reconfigurability region. Additionally, synthesizable block produce intrinsic operations and constraints that are stored in a global tree of operations in order to produce the expected output.

=== Typing system

@phos uses a typing system similar to _C_, it does not support object oriented programming. It has a basic type system as the complexity of actual code is expected to be relatively low. This limitation is put in place such that the language is easier to use with constraints, and especially with provers for reconfigurability. This means that the typing system is generally simple to use and understand. Overall, @phos' typing system is static and strong. Meaning that all values have a fixed type at compile time, and that implicit type conversions do not occur. This aims at reducing the potential for errors, as well as improving the clarity of @api[s] and @ip[s] designed with @phos.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Static type checking and inference*]
}
@phos is statically typed, but offers type inference as a means of reducing the annotation burden on the user. Essentially, type inference tries to figure out what the type of a value is based on the operations being performed and the type of the values it is produced from. In the case of @phos, this will be performed using the 
_Hindley-Milner_ algorithm, which is a de-facto standard in modern programming languages #cite("milner_theory_1978", "rust_compiler"). Additionally, due to the simple type system employed by @phos, it should be generally easier for the compiler to infer the types of values as conflicts are less likely to occur.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constraints and typing*]
}
In this initial design of @phos, constraints are seen as metadata on values and signals. This is a simpler approach that decreases the initial development complexity. However, it is limiting and makes design error only visible during the evaluation phase of the compiler. For this reason, it could be improved using the concept of _refinement types_ @freeman_refinement_1991, which would allow the compiler to check for errors in constraints earlier, this is further discussed in @sec_future_work.

=== Mutability, memory management and purity

@phos does only allow mutating of state, following the functional approach of limiting side effects @mailund_functional_2017, this makes the work of the prover used for reconfigurability easier. It also ensures that all functions are pure functions, something that can be exploited by the compiler to optimize the code, as well as be used in future iterations of the design to provide features such as memoization for faster compile time. This also means that @phos does not have a garbage collector, as it does not need to manage memory. As the lifetime of all values is predictable, @phos can simply discard values when they fall out of scope. This is done by the compiler, and does not require any action from the user. This is a deliberate choice to reduce the complexity of the compiler.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Limitations of immutability and purity*]
} Immutability make global state management difficult, requiring the user of a state monad to manage state @haskell_state_monad. However, @phos does not need global mutable state, as it is not a general purpose programming language. Indeed, due to the hardware-software codesign nature of @phos, it is expected that the user will manage global state within their own software layer, leaving their @phos codebase free of global state. Additionally, purity disallows the user of side effects, which removes the ability of the user from performing @io operations, such as reading from a file, which makes the language inherently safer to use. However, this also means that @phos cannot be used for general purpose programming, and is limited to the domain of photonic circuit design.

=== Signal types and semantics <sec_signal_types>

@phos distinguishes between the `electrical` and `optical` types. They mostly share the same semantics, with the exception that electrical signals cannot be operated upon. In the following paragraphs, the semantics of each will be discussed with examples.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Optical*]
} Optical signals follow a _drive-once_, _read-once_ semantics, meaning that they must be produced by a source element and must be consumed by a sink element, signals cannot be empty or be discarded without being used. The goal of this semantic is to make signals less error prone by avoiding the possibility of signals being left unconnected. Additionally, the _drive-once_ semantics ensure that signals are split explicitly by the user and not implicitly with difficult to predict results. Consider the example in @lst_ex_opt_splitting, depending on the compiler's implementation, it may lead to two splitting schemes, both shown in @fig_ex_opt_splitting, it shows that with an automatic scheme, based on the compiler architecture, it may lead to two different results. However, with an explicit scheme, the user is able to clearly define the splitting scheme, and the compiler no longer has to make any assumptions about the splitting scheme. Additionally, optical signals only support being passed into, used, or sourced inside of synthesizable blocks. This restriction aims at making the work of the compiler easier and creating a stronger distinction for users.

#figurex(caption: [ Optical signal splitting example ])[
    ```phos
let a = source(1550 nm, -10 dBm)
 
let b = a |> gain(5 dB)
let c = a |> filter(center: 1550nm, bandwidth: 10 GHz)
let d = a |> modulate(external_signal, type_: Modulation::Amplitude)
    ```
] <lst_ex_opt_splitting>

#figurex(
    caption: [
        Automatic optical signal splitting schemes, showing the two possible automatic splitting scheme, using either a cascade architecture (a), or a parallel architecture (b). It leads in different power ratios to all of the downstream elements.
    ],
    title: [ Automatic optical signal splitting schemes. ],
    kind: image
)[
    #table(
        columns: 2,
        stroke: none,
        image(
            "../figures/drawio/optical_splitting_a.svg",
            alt: "Cascade architecture, showing that the source produce a signal which is split into 0.5 for b, 0.25 for c and 0.25 for d"
        ),
        image(
            "../figures/drawio/optical_splitting_b.svg",
            alt: "Parallel architecture, showing that the source produce a signal which is split into 0.33 for b, 0.33 for c and 0.33 for d"
        ),
        [ (a) ],
        [ (b) ],
    )
] <fig_ex_opt_splitting>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Electrical*]
} Electrical signals do not allow any operations on them apart from being used in `modulate` and `demodulate` intrinsic operators. The reasoning behind this limitation is that, as present, there are no plans for analog processing in the electrical domain. And this feature is not yet implemented. Therefore, electrical signals are only ever used to modulate optical signals, or are produced as the result of demodulating optical signals. It is possible that, in the future, some analog processing features may be added, such as gain, splitting, etc., but as it is currently not planned, electrical signals are not allowed to be used in any other way. Electrical signals follow the same semantics as optical signals: _drive-once_, _read-once_.


=== Primitive types and primitive values

@phos aims at providing primitive types that are useful for the domain of optical signal processing. As such, it provides a limited set of primitive types, not all of which are synthesizable. To understand how primitive types are synthesizable, see @sec_stack_collection. In @tab_primitive_types, the primitive types are listed, along with a short description. Primitive types are all denoted by their lowercase identifiers, this is a convention to make a distinction between composite types and primitive types. These primitive types are very similar to those found in other high-level programming languages such as _Python_ @python_reference.

#figurex(
    title: [ Primitive types in @phos. ],
    caption: [
        Primitive types in @phos, showing the primitive types and their description. For numeric types, the minimum and maximum values are shown.
    ],
    kind: table
)[
    #tablex(
        columns: (auto, 1fr, auto, auto),
        align: center + horizon,
        auto-vlines: false,
        repeat-header: true,

        smallcaps[*Primitive type*],
        smallcaps[*Description*],
        smallcaps[*Minimum value*],
        smallcaps[*Maximum value*],
        `optical`, align(left)[ An optical signal, with _drive-once_, _read-once_ semantics. ], [-], [-],
        `electrical`, align(left)[ An electrical signal, with _drive-once_, _read-once_ semantics. ], [-], [-],
        `any`, align(left)[ Any value, used for generic functions. ], [-], [-],
        `empty`, align(left)[ An empty value, equivalent to `null` is many other languages. ], [-], [-],
        `string`, align(left)[ A character list, encoded at UTF-8. ], [-], [-],
        `char`, align(left)[ A unicode scalar value @unicode10. ], [-], [-],
        `bool`, align(left)[ A boolean value, taking either `true` or `false` as a value. ], [-], [-],
        `int`, align(left)[ A signed integer value, 64 bit wide. ], [$-2^63$], [$2^63 - 1$],
        `uint`, align(left)[ A unsigned integer value, 64 bit wide. ], [$0$], [$2^64 - 1$],
        `float`, align(left)[A floating point number, 64 bit wide. Represents a number in the IEEE 754 format @ieee_754_1985. ], [$-1.798 dot 10^308$], [$1.798 dot 10^308$],
        `complex`, align(left)[A complex floating point number, 128 bit wide. It consists of a real and imaginary part, both a floating point number. ], [-], [-]
    )
] <tab_primitive_types>


=== Composite types, algebraic types, and aliases

#info-box(kind: "definition", footer : [ Adapted from @algebraic_data_type ])[
    *#gloss("adt", long: true)* is a type composed of other types, there exists two categories of @adt: *sum types* and *product types*. Product types are commonly tuples and structures. Sum types are usually enums, also referred to as *tagged unions*.
]

@phos has the ability of expressing @adt in the forms of enums, enums are enumeration of $n$ variants, each variant can be one of three types: a unit variant, that does not contain any other data, a tuple variant, that contains $m$ values of different types, or a struct variant that also contains $m$ values of different types, but supports named fields. Enums are defined using the `enum` keyword followed by an identifier and the list of variants. In @lst_ex_enum, one can see an example of an enum definition, showing the syntax for the creation of such an enum. Enums are a sum type, as they are a collection of variants, each variant being a product type. Enums are a very powerful tool for expressing @adt, and are used extensively in @phos and languages that support sum types.

#block(breakable: false)[
    #figurex(
        title: [ Example in @phos of an @adt type. ],
        caption: [
            Example in @phos of an @adt type, showing all three variant kinds: `A` a unit variant, `B` a tuple variant, and `C` a struct variant.
        ]
    )[
        ```phos
enum EnumName {
    A,
    B(int, string),
    C {
        first_value: int,
        second_value: AnotherType
    }
}
        ```
    ] <lst_ex_enum>
]

#info-box(kind: "definition", footer: [ Adapted from @aggregate_type ])[
    *Composite types* are types that are composed of other types, whether they be primitive types or other composite types. They are also called *aggregate types* or *structured types*. They are a subset of @adt.
]

Additionally, @phos also supports product types and more generally composite types. Composite types are any type that is made of one or more other type. They can be one of five types: a unit structure, a tuple structure, a record structure with fields, a tuple, and an array of $n$ items of the same type. The syntax of these five types can be see in @lst_ex_composite. This variety in typing allows for precise control of values and their representation. It allows the user to chose the best type for their current situation, such as anonymous tuples for temporary values, or named records for more complex structures.

#block(breakable: false)[
    #figurex(
        title: [ Example in @phos of composite types. ],
        caption: [ 
            Example in @phos of composite types, showing all five kinds: `A` a unit structure, `B` a tuple structure, `C` a record structure, `D` a tuple, and arrays.
        ]
    )[
        ```phos
/// A unit struct
struct A;
 
/// A tuple struct
struct A(uint, string, B);
 
/// A record struct
struct B {
    name: string,
    complex_signal: complex
}
 
/// an enum type is not named and can be declared inline.
(uint, string, A)
 
/// Arrays are defined with a type `A` and a size `10`.
[A; 10]
        ```
    ] <lst_ex_composite>
]

@phos also supports type aliases, which is the action of locally renaming a type, this can be used to indicate in code the semantic behind the value: instead of being a numeric value, it can now be expressed as a `Voltage`, etc. This is done by using the `type` keyword, followed by the new name and the type alias, this is shown in @lst_ex_alias.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of type aliases, showing the creation of a `Voltage` type alias for `int`.
        ]
    )[
        ```phos
type Voltage = int;
        ```
    ] <lst_ex_alias>
]

=== Automatic return values

@phos support automatic return values, when the compiler sees that the final statement in a block is an expression that is not terminated by a semicolon, it will automatically return the value of that expression. This makes code more concise and readable, as shown in @lst_ex_auto_return, in (a) the example is shown with automatic return, and in (b) the example is shown with explicit return. Additionally, it allows code blocks to be used as expressions, which is generally a useful feature.

#block(breakable: false)[
    #figurex(
        kind: raw,
        title: [ Example in @phos of automatic and explicit return values. ],
        caption: [ 
            Example in @phos of automatic return values, showing the difference between automatic return (a) and explicit return (b).
        ]
    )[
        #table(
            columns: (1fr, 1fr),
            stroke: none,
            align: center + horizon,
            ```phos
fn add(a: int, b: int) -> int {
    a + b
}
            ```,
            ```phos
fn add(a: int, b: int) -> int {
    return a + b;
}
            ```,
            [ (a) ], [ (b) ],
        )
    ] <lst_ex_auto_return>
]


=== Units, prefixes, and unit semantics

One of the unique features of @phos is the built-in @si unit system. It is comprised of all of the @si units, with the exception of the candela, and some of the compound units, the list of units are: seconds, amperes, volts, meters, watts, hertz, joules, ohms, henries, farads, coulombs, and siemens. This set of unit comprises more units than is typically used in photonics, and this is done such that more circuits may be designed using the language in the future, as discussed in @sec_phos_generic. Additionally to @si units, @si prefixes are also supported from $10^(-18)$ to $10^12$. Support for decibels is also included, the following decibel units are supported: relative (dB), relative to the carrier (dBc), relative to a milliwatt (dBm), and relative to a watt (dBW). Finally, due to the prevalence of angles in photonics for phase controls, radians and degrees are also natively supported. It is also important to note that this list can very easily be expanded to include more units, prefixes, as the language is designed to be extensible. In @lst_ex_units, one can see the syntax for the usage of some of the units, decibels and angles.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of @si units.
        ]
    )[
        ```phos
/// 1 milliwatt
1 mW
dBm

// 1 degree
1 deg
0.01745 rad
1°

// 1 kilohertz
1 kHz
1e3 Hz
        ```
    ] <lst_ex_units>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Unit semantic*]
}
Instead of implementing a complete unit conversion system, at present, @phos is not intended to support conversion of units of different types, meaning that power is always power and that multiplying a power with time is invalid. To do so would require a complete unit conversion system, which is not planned for @phos. Units are the same regardless of prefixes, which are converted by the compiler into the base, unprefixed, unit before execution begins.


=== Tuples, iterable types, and iterator semantics

Tuples are a kind of product type that links one or more values together within a nameless container. They are often used as output values for functions, as they allow for multiple values to be returned. In @phos, tuples have two different semantics: on one the one hand they can be used as storages for values, as in most modern languages, but on the other hand, they can be used as iterable values, which is a feature that is not present in many languages. Rather than having the concept of a list or collection, @phos supports unsized tuples. The general form of tuples as container can be seen in @lst_ex_tuple_container.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of tuples as containers.
        ]
    )[
        ```phos
/// A tuple container containing b, c, and d
let a = (b, c, d)

/// A tuple as a type containing values of type B, C, and D
type A = (B, C, D)
        ```
    ] <lst_ex_tuple_container>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Unsized tuples*]
}
Unsized tuples are a special kind of tuple which allows the last element to be repeating, it uses a special ellipsis (`...`) syntax to indicate that the last element is repeating. This is useful for representing lists, as @phos does not support lists otherwise. This is a purposeful decision, as it allows to extend the concept of pattern matching, discussed in @sec_patterns, beyond simple fixed sized tuples and into the realm of dynamically sized lists. The general form of unsized tuples can be seen in @lst_ex_unsized_tuple.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of unsized tuples as containers.
        ]
    )[
        ```phos
/// A simple unsized tuple: (B, B, B, B, ...)
type E = (B...)

/// A more complex unsized tuple: (B, C, D, D, D, ...)
/// On the the type `D` is repeating
type A = (B, C, D...)
        ```
    ] <lst_ex_unsized_tuple>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Iterable tuples*]
}
Unsized tuples lead well into the idea of tuples as iterable values. Iterable values are values that can be used for enumerations in a loop or for using iterators. In @phos, all tuples are iterable, and iterable collections can have heterogeneous types, meaning that they can iterate over values of different types. This allows the user to iterate over tuples of different signal types, values, etc. The general form of iterable tuples can be seen in @lst_ex_iterable_tuple.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of iterable tuples.
        ]
    )[
        ```phos
// Iterating over a list of elements
// It would print:
// 1
// 2
// 3
for a in (1, 2, 3) {
    print(a)
}
        ```
    ] <lst_ex_iterable_tuple>
]


=== Patterns <sec_patterns>

Patterns are used for pattern matching and destructuring, and are a core part of the language. They are used for matching values, tuples, and other types. They are also used to destructure complex values into their constituents. Patterns are used in many statements, such as the `match` statement, the `let` variable assignment statement, the `for` loop statement, and function argument declarations. The general form of pattern can be see in @lst_ex_pattern.

#figurex(
    caption: [ 
        Example in @phos of patterns.
    ]
)[
    ```phos
// Destructuring of tuples: (a = 1, b = 2, c = 3)
let (a, b, c) = (1, 2, 3)
// Destructuring of tuples with trailing: (a = 1, b = (2, 3))
let (a, b...) = (1, 2, 3)
// Destructuring of a data structure: (a = 1, b = 2, c = 3)
let MyStruct { a, b, c } = MyStruct { a: 1, b: 2, c: 3 }
// Pattern matching for branching:
match (a, b, c) {
    // Matches exactly a tuple of three elements containing 1, 2, and 3
    (1, 2, 3) => print("Matched"),
    // Wildcard pattern
    _ => print("Not matched")
}
    ```
] <lst_ex_pattern>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Exhaustiveness*]
}
In order for match statements to be correct, the compiler must be able to prove, based on the types, that a match statement is exhaustive. This is intended to be implemented using a similar algorithm to _Rust_'s compiler @rust_compiler. This is a very important feature, as it allows the compiler to prove that all possible cases are covered, and that the program will not crash due to a missing case. This is especially important with a point discussed in @sec_tunability_reconfigurability, which enables reconfigurability to work reliably.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Pattern matching and reconfigurability*]
}
As previously mentioned, exhaustiveness helps ensure that reconfigurability is reliably achievable, as it allows the compiler to prove that all possible cases are covered. Additionally, the compiler can use constraints to remove branches that it can prove will never be taken. This is a very important and powerful feature as it decreases the configuration space of the user's design, and it allows the compiler to be faster and optimize the user's design further.


=== Branching and reconfigurability <sec_branching_reconfig>

@phos supports branching as many other languages do, however, due to its use as a photonics @hdl, @phos has the special ability to use branching as boundaries for reconfigurability regions in synthesizable contexts. This feature was previously discussed in @sec_tunability_reconfigurability. The general form of branching can be seen in @lst_ex_branching. Reconfigurability through branching is designed to be very simple to use, the user can simply branch in their code, if the compiler detects that signals are being used across the branches, it will automatically create a new reconfigurability region, meaning that the work is implicit and the user does not need to do anything special to enable reconfigurability.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of branching.
        ]
    )[
        ```phos
// Simple branching
if a == 1 {
    print("a is 1")
} else {
    print("a is not 1")
}

// Branching with multiple conditions
if a == 1 && b == 2 {
    print("a is 1 and b is 2")
} elif a == 1 && b == 3 {
    print("a is 1 and b is 3")
} else {
    print("a is not 1 or b is not 2 or 3")
}

// Branching using match statements
match (a, b) {
    (1, 2) => print("a is 1 and b is 2")
    (1, 3) => print("a is 1 and b is 3")
    _ => print("a is not 1 or b is not 2 or 3")
}
        ```
    ] <lst_ex_branching>
]


=== Variables, mutability, and tunability

Variables in @phos are declared with the `let` keyword, followed by a pattern for the variable name, followed optionally by the type of the variable, and then followed by the assignment to the value. In @phos, variables cannot be uninitialized, and must be assigned a value when they are declared, with the notable exception of signals in unconstrained contexts, see @sec_unconstrained, which have a special semantics. Variables are immutable, this makes the work of the prover for reconfigurability easier, if the user whishes to update a value, they can simply recreate it. This also makes the language simpler, as the user does not need to worry about the value of a variable changing. The general form of variable declaration can be seen in @lst_ex_variable_declaration.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of variable declaration, assignment, and update.
        ]
    )[
        ```phos
// Simple declaration
let a = 5

// Destructuring declaration
let (a, b...) = (1, 2, 3)

// Declaration with type
let a: uint = 5

// Declaration with destructuring and type
let (a, b...): (uint, uint...) = (1, 2, 3)

// Updating of a value
let a = 6
let a = a + 5
        ```
    ] <lst_ex_variable_declaration>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Tunability*]
}
Tunability is handled by passing a tunable value as an argument to the top-level component of the design. From then on, all subsequent use of this tunable value will also be turned automatically into tunable values. It is a simple implementation that allows the user to provide tunability and reconfigurability easily with minimal impact to the code. This therefore means that all code is generally tunable, and the user does not need to worry about the tunability of their code, as the compiler will handle it for them. However, if the user were to require a function not to be tunable due to its complexity, they can simply make it as `static`, indicating that it cannot be tunable. An example of both use cases is provided in @lst_ex_tunability.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of tunability.
        ]
    )[
        ```phos
// Tunable function
fn add(a: uint, b: uint) -> uint {
    return a + b
}

// Untunable function with static
fn add(a: static uint, b: static uint) -> uint {
    return a + b
}
        ```
    ] <lst_ex_tunability>
]


=== Piping operator and semantics

One of the key features of the @phos programming language that makes it easier to use for photonic circuit design, is the ability to use the piping operator `|>` to chain functions together. This allows the user to write code in a more natural way, and allows the user to write code that is more readable. The piping operator is a binary operator with semantics that are more advanced than other binary operators: first, it can operate on any value, passing the output of one expression into the input of another, and the second is that it can pattern match the values to create more complex calls. The general form of the piping operator can be seen in @lst_ex_piping_operator.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of the piping operator.
        ]
    )[
        ```phos
// Function that performs the addition of two numbers using piping
fn add_with_pipe(a: uint, b: uint) -> uint {
    return (a, b) |> add
}

// Simple addition function
fn add(a: uint, b: uint) -> uint {
    return a + b
}

        ```
    ] <lst_ex_piping_operator>
]

#info-box(kind: "definition", footer: [ Adapted from @osullivan_real_2010. ])[
    *Monadic operations* are operations that take a value and a function, and return a new value. They are common in functional programming languages, and are useful for manipulating data. They generally use the function provided as an argument to process the value, and return a new value.
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Operation on iterators*]
}
In addition to operating on values, the standard library will contain many common operations on iterators, such as mapping using the `map` and `flat_map` functions, two types of monadic bind operations, and filtering using the `filter` function. These operations are common in functional programming languages, and are useful for manipulating data. The general form of these operations can be seen in @lst_ex_iterator_operations.
#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of the piping operator on iterable values.
        ]
    )[
        ```phos
// Function that performs the addition of two numbers using piping
// Folding is a common operation on iterators, and is used to reduce
// the values of an iterator into a single value, with a starting value
// and a closure that takes the accumulator and the current value and
// returns the new accumulator
fn add_with_pipe(a: uint, b: uint) -> uint {
    return (a, b) |> fold(0, |acc, x| acc + x)
}
        ```
    ] <lst_ex_iterator_operations>
]


=== Function and synthesizable blocks

@phos separates functions into three categories: functions denoted by the keyword `fn`, and synthesizable blocks denoted by the keyword `syn`. They are designated in such a way to create clearer separation between the concerns of the user, and to allow the compiler to better separate the different functions of the code. All functions in @phos, regardless of their type, are subject to constraints and the constraint solver, whether these constraints be expressed on values, or on signals.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Functions*]
}
Function represent code that cannot consume nor produce signals, whether electrical or optical. They can only process primitive types, composite types, and @adt[s]. They are intended to separate any coefficient computation from the signal path, creating a strong separation between the two. An example could be a lattice filter, it implements a series of coefficients, which are likely to be computed by a function, instead of computing them inline with the signal, they can be computed in a function and then joined with the signal in a synthesizable block. Function branches do not represent reconfiguration boundaries, which greatly simplifies the work of the compiler. An example of a function can be seen in @lst_ex_function.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of a function.
        ]
    )[
        ```phos
// Function that performs the sum of $n$ numbers
fn sum(a: (uint...)) -> uint {
    a |> fold(0, |acc, x| acc + x)
}
        ```
    ] <lst_ex_function>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Synthesizable blocks*]
}
Synthesizable functions have the added semantic of being able to source and sink signals. They are intended to represent the signal path, and are the only functions that can be used to create reconfiguration boundaries. They can be used to create a synthesizable block that can be tuned or reconfigured at runtime. An example of a synthesizable block can be seen in @lst_ex_synthesizable_block.

#block(breakable: false)[
    #figurex(
        title: [ 
            Example in @phos of a synthesizable block.
        ],
        caption: [
            Example in @phos of a synthesizable block, showing an @mzi built discretely using the `split`, `constrain` and `merge` functions.
        ]
    )[
        ```phos
// Synthesizable block that performs the filtering of an input signal using an MZI
// The MZI is built using the following actions:
//  1. The `input` signal is split into two signals using a 50/50 splitter
//  2. The two signals are constrained to have a phase difference of 30 degrees
//  3. The two signals are interfered using a 50/50 combiner
// This forms the basic structure of a Mach-Zehnder interferometer
syn filter(input: optical) -> optical {
    input |> split((0.5, 0.5))
          |> constrain(d_phase: 30 deg)
          |> merge()
}
        ```
    ] <lst_ex_synthesizable_block>
]


=== Modules and imports

Most programming languages have module systems, which allow the user to organize their code into different files or folders, with nested modules. It generally avoids file being overly long, and makes the code tidier and easier to understand. @phos is no different in that regard, it adopts the module system of _Python_, where each file represents a different module, with files in folder representing submodules of the folder. The module system of @phos is very simple, but it does allow for cyclic dependencies, while cyclic dependencies tend to increase the complexity of the compiler, it is relatively easy to overcome and makes the language easier to use.

Modules are then imported using the `import` keyword, importing allows the user to import code from a module, and they can then chose what they want to import, whether it is everything, a specific submodule, or a specific function. The import system also allows the user to locally rename imported elements, such that they can avoid conflicting names. An example of an import can be seen in @lst_ex_import.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of an import.
        ]
    )[
        ```phos
// Importing the module `std::intrinsic` and renaming it to `intrinsic`
import std::intrinsic as intrinsic;

// Importing the syn `filter` from the module `std::intrinsic`
import std::intrinsic::syn::filter;

// Importing everything from the module `std::intrinsic`
import std::intrinsic::syn::*;

// Importing the syn `filter` and `gain` from the module `std::intrinsic`
import std::intrinsic::syn::{filter, gain};
        ```
    ] <lst_ex_import>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Visibility*]
}
In @phos, all elements that are declared are always public, due to the expected low number of users of the language, it makes sense that all elements declared into a module be made public, such that code reuse can be maximized. This also means that there is no need for the concept of visibility as it exists in many other languages, that have special keywords like `pub`, `public`, or `private` to define the visibility of an item.


=== Closures and partial functions

Closures are anonymous functions that are defined inline with the rest of the code. As with most modern languages, @phos supports closures. Closures are a source of complication for the compiler, it is very difficult for the compiler to keep track of value movement in closures and it is even more difficult to keep track of signal movement and usage for closures. Therefore, while signals are allowed to be used within closures, this cannot be checked at compile time and therefore must be checked by the @vm at a much later stage. An example of a closure can be seen in @lst_ex_closure.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of a closure.
        ]
    )[
        ```phos
// Closure that performs the sum of $n$ numbers
let sum = |a: (uint...)| -> uint {
    a |> fold(0, |acc, x| acc + x)
};
        ```
    ] <lst_ex_closure>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Signals in closures*]
}
Due to their _drive-once_, _read-once_ semantics, signals are an especially difficult case for closures. Normally, closures are allowed to capture variables from their environment, and are equivalent to functions. However, signals are not normal variables, and the capturing mechanism has to be different. For this reason, closures are separated into three types: `Fn` which are closures that operate like regular functions, `Syn` which are closures that operate like regular synthesizable blocks, while they can process signals, they cannot capture signals, `SynOnce` which are closure that are synthesizable, but must called once, essentially following the same _drive-once_, _read-once_ semantic as other signals. The difference between the three kind can be seen in @lst_ex_closure_kind.

#figure(
    kind: raw,
    caption: [ 
        Example in @phos of an `Fn` closure (a), a `Syn` closure (b), and a `SynOnce` closure (c).
    ],
)[
    ```phos
// (a) `Fn` closure
let c = 1;
let fn_closure = |a: uint| -> uint {
    a + c
};
 
// (b) `Syn` closure
let syn_closure = |a: optical| -> (optical...) {
    a |> split((0.5, 0.5))
};
 
// (c) `SynOnce` closure
let a = source(1550 nm)
let syn_once_closure = || -> (optical...) {
    a |> split((0.5, 0.5))
};
    ```
] <lst_ex_closure_kind>

#info-box(kind: "definition", footer: [ Adapted from @peyton_jones_how_2004 ])[
    *Partial functions* are functions which are *partially applied*, meaning that parts of their argument are already applied, and that the new function can be called with only the missing arguments. Partial functions are therefore functions with lower arity.
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Partial functions*]
}
In @phos, partial functions are created with the keyword `set`, it produces a closure with the same semantics as previously discussed, but with the added ability to be called with less arguments than the closure expects. Additionally, the caller of the closure may override already `set` arguments by referring to them by name. An example of a partial function can be seen in @lst_ex_partial.
#figure(
    kind: raw,
    caption: [ 
        Example in @phos of partial function in @phos.
    ],
)[
    ```phos
fn add(a: uint, b: uint) -> uint {
    a + b
}
 
let add_1 = set add(1);
 
print(add_1(2)); // prints 3
    ```,
] <lst_ex_partial>



=== Loops, recursion, and turing completeness

#info-box(kind: "definition", footer: [ Adapted from @cs390. ])[
    *Turing completeness* is used to express the power of a data manipulation system, it is a measure of the ability of a system to perform all calculable computations.
]

@phos does not aim to be a Turing complete, as it does not need to be used for generic purposes. Due to the exponential complexity of reconfigurability states as the program is allowed to loop and recurse, @phos places a hard limit on the following elements: the number of iterations, the depth of recursion, and the number of optical intrinsic operations that can be performed. The goal of these measures is to avoid the compiler taking too long to try and compile a program for which no device is big enough to fit it. The compiler will therefore reject programs that exceed these limits. The limits are set to be high enough that they should not be reached in most cases, but low enough that the compiler can reject programs that are too complex to be compiled. Additionally, some of these limits can be changed by the user using the marshalling layers (see @sec_marshalling).

For the aforementioned reason, @phos does not have infinite loops but only iterative loops that iterate over an input value. This limits the risk of the user falling into the iteration limit, as the number of iterations is known. An example of a loop can be seen in @lst_ex_loop.

#figure(
    kind: raw,
    caption: [ 
        Example in @phos of a loop.
    ],
)[
    ```phos
for i in 0..5 {
    print(i);
}
    ```,
] <lst_ex_loop>


=== Constraints <sec_phos_constraints>

#info-box(kind: "info")[
    It has been discussed that the syntax of constraints should be changed to declutter function/synthesizable block signatures. This would allow constraints to be cleaner, and would ideally be expressed as its own part of the signature, rather than being defined with the arguments. However, this has not yet been designed, and is therefore not discussed further in this document.
]

@phos models constraints as additional data carried by values and signals, it applies the semantics discussed in @sec_constraints. In the current iteration of the design, constraints are therefore a evaluation-time concept that cannot be checked by the compiler. This is a limitation of the current design, and will be addressed in future iterations. An example of a constraint can be seen in @lst_ex_constraint.

#figure(
    kind: raw,
    caption: [ 
        Example in @phos of a constrained synthesizable block.
    ],
)[
    ```phos
// Performs an optical gain on an input signal,
// the maximum input power is `10dBm - gain`,
// the gain is constrained to be between 0 and 10dB.
syn gain(
    @max_power(10dBm - gain)
    input: optical,
    @range(0dB, 10dB)
    gain: Gain,
) -> @gain(gain) optical {
    ...
}
    ```
] <lst_ex_constraint>


=== Unconstrained <sec_unconstrained>

As mentioned in @sec_constraints, constraints only work for non-cyclic cases#footnote[That is, constraints that do not depend on themselves.], however this limitations removes the advantage of having a recirculating mesh inside of the photonic processor. Therefore, as was previously mentioned, @phos must provide a way to express blocks where the constraints are not automatically inferred, but must be manually specified. This is done by using the `unconstrained` keyword, which allows the user to specify the constraints manually at the boundary of a synthesizable block. An example of an unconstrained block can be seen in @lst_ex_unconstrained.

Additionally, unconstrained block allow the user to create their own signal, without needing to use a source intrinsic. This semantic is useful for creating recirculating elements in the photonic processor, as it allows the user to create temporary variables containing signals.

#figure(
    kind: raw,
    caption: [ 
        Example in @phos of an unconstrained synthesizable block.
    ],
)[
    ```phos
// A ring resonator implemented using an unconstrained block
unconstrained syn ring_resonator(
    input: optical,

    @range(0.0, 1.0)
    coupling: float,

    @min(6)
    length: Length,
) -> @frequency_response(response(coupling, length)) optical {
    // Create a new internal signal
    let ring: optical;

    // Create the output signal
    let output: optical;

    // Use an intrinsic coupler
    (input, ring)
        |> std::intrinsic::coupler(coupling)
        |> constrain(dlen = length)
        |> (output, ring);

    output
}

// Returns the frequency response of a ring resonator given its arguments.
fn response(coupling: float, length: Length) -> FrequencyResponse {
    ...
}
    ```
] <lst_ex_unconstrained>

=== Stack collection and synthesizable non-signal types <sec_stack_collection>

One of the issues that arises from tunability, and especially with reconfigurability, is that the tunable values can be of any type, and therefore need to be converted into the values that the physical hardware can interpret. When designing the circuit, or the hardware platform package, it is natural to convert these meaningful high level values into lower level, less explicit values using @phos. Ideally, as much as the conversion as possible should be done in @phos, such that the circuit code can act as a source of truth and decrease the complexity of the hardware-software codesign. But this creates an issue: when using tunable value, the @phos @vm cannot compute these low-level values directly, as it does not know the value of the tunable value. Additionally, when tunable values lead to reconfigurability, the @vm cannot evaluate the conditions that lead to reconfigurability statically.

Therefore, it is required the parts of the code that perform conversion between high-level values and low-level values be synthesizable. Of course, the photonic processor being an analog processor, it is not possible to perform this synthesis on the actual mesh. However, as mentioned in @sec_programmability, one of the compilation artefact is the user @hal, which is generated for the user based on their design. It would therefore be possible to collect these operations and package them into the hal, such that when the user programmatically tunes their design, the conversion is done inside of the user @hal and sent to the processor's controller as a low-level value. The name is based off of the fact that @phos uses a stack-based virtual machine, and that the operations are collected into the user @hal and converted into _Rust_ (the implementation language of the @hal) automatically by the compiler.

#info-box(kind: "definition")[
    *Stack collection* is the process of collecting the operations that convert high-level values into low-level values, and packaging them into the user @hal.
]

Stack collection is therefore an automatic feature performed by the compiler, its goal is to evaluate as much as possible at compile time, as a means to decrease the amount of work being done inside of the user @hal, and collect the stack operations that are relevant to the conversion. From these collected stacks, it can easily evaluate the conditions that lead to reconfigurability, and package them into the user @hal. Nonetheless, one problem remains: which reconfigurability states must be kept past this point, as explained in @sec_tunability_reconfigurability, the compiler can discard as many reconfigurability states as possible based on constraints and using a prover like _Z3_ @z3. 

=== Language items and statements

Language items and statements, are the hierarchy of language elements that can be used to create a program. They are the most basic elements of the language, and are used to create more complex elements. They are the building blocks of the language, and are the elements that are used to create the @ast. They are the most important elements of the language, and are the ones that are the most likely to be modified in the future. The language items and statements of @phos are listed in @tab_lang_items_statements along with a short description and a short example.

#figurex(
    kind: table,
    title: [ The list of language items and statements supported in @phos ],
    caption: [ 
        The list of language items and statements supported in @phos, along with a short description and a short example. Additionally lists whether the element is an item or a statement, or both, where a statement is a language element that can be used as an expression, and an item is a language element that cannot be used as an expression, but can be used as a top level declaration.
        #underline[Legend]: #required_sml means yes, #not_needed_sml means no.
    ]
)[
    #tablex(
        columns: (auto, 0.2fr, 0.2fr, 0.5fr, 1fr),
        align: left + horizon,
        auto-vlines: false,
        repeat-header: true,

        align(center)[#smallcaps[*Element*]],
        align(center)[#smallcaps[*Item*]],
        align(center)[#smallcaps[*Statement*]],
        align(center)[#smallcaps[*Description*]],
        align(center)[#smallcaps[*Example*]],

        align(center)[#smallcaps[*Import*]],
        align(center)[#required],
        align(center)[#required],
        align(left)[ Imports a module into the current module. ],
        ```phos
import std::intrinsic as intrinsic;
        ```,

        align(center)[#smallcaps[*Function*]],
        align(center)[#required],
        align(center)[#required],
        align(left)[ Declares a function. ],
        ```phos
fn sum(a: (uint...)) -> uint {
    a |> fold(0, |acc, x| acc + x)
}
        ```,

        align(center)[#smallcaps[*Synthesizable*]],
        align(center)[#required],
        align(center)[#not_needed],
        align(left)[ Declares a synthesizable function. ],
        ```phos
syn gain(input: optical) -> optical {
    input |> std::intrinsic::gain(10 dB)
}
        ```,

        align(center)[#smallcaps[*Type alias*]],
        align(center)[#required],
        align(center)[#not_needed],
        align(left)[ Declares a type alias. ],
        ```phos
type Voltage = float;
        ```,

        align(center)[#smallcaps[*Constant*]],
        align(center)[#required],
        align(center)[#required],
        align(left)[ Declares a constant. ],
        ```phos
const PI = 3.141592;
        ```,

        align(center)[#smallcaps[*Structure*]],
        align(center)[#required],
        align(center)[#not_needed],
        align(left)[ Declares a new data structure. ],
        ```phos
struct Point {
    x: float,
    y: float
}
        ```,

        align(center)[#smallcaps[*Enumeration*]],
        align(center)[#required],
        align(center)[#not_needed],
        align(left)[ Declares a new @adt. ],
        ```phos
enum Color {
    Red,
    Green,
    Blue,
}
        ```,

        align(center)[#smallcaps[*Local*]],
        align(center)[#not_needed],
        align(center)[#required],
        align(left)[ Declares a new local variable ],
        ```phos
let (a, b...) = (1, 2, 3);
        ```,

        align(center)[#smallcaps[*Expression*]],
        align(center)[#not_needed],
        align(center)[#required],
        align(left)[ Declares a new expression. ],
        ```phos
1 + 2
        ```,
    )
] <tab_lang_items_statements>

#pagebreak(weak: true)
=== Expressions

Expressions are a subset of statements, that operate on one or more values and may produce an output value. A complete list of @phos expression is available in @tab_exprs.
#figurex(
    kind: table,
    title: [ The list of language expressions supported in @phos ],
    caption: [ 
        The list of language expressions supported in @phos, along with a short description and a short example. Additionally lists whether the expression is a control flow expression, constant expression, unary expression, binary expression, or special expression. Where a control flow expression is an expression that can be used to control the flow of the program, a constant expression is a value that can be determined at compile time, a unary expression is an expression that takes only one argument, a binary expression is an expression that takes two arguments, and a special expression is an expression that is not easily categorized and that performs more complex actions, with well defined semantics.
    ]
)[
    #tablex(
        columns: (0.1fr, 0.5fr, 1fr, 1fr),
        align: left + horizon,
        auto-vlines: false,
        repeat-header: true,

        colspanx(2)[
            #align(center)[#smallcaps[*Expression*]]
        ],
        align(center)[#smallcaps[*Description*]],
        align(center)[#smallcaps[*Example*]],

        rowspanx(8)[
            #align(center)[#rotate(-90deg)[#box(width: 200pt)[#smallcaps[*Control flow*]]]]
        ],

        align(center)[#smallcaps[*Block*]],
        align(left)[ Declares a new block of code. ],
        ```phos
{
    let a = 10;
    a + 20
}
        ```,

        align(center)[#smallcaps[*If/Else/Elif*]],
        align(left)[ A conditional statement for branching. ],
        ```phos
if a > b { a } else { b }   
        ```,

        align(center)[#smallcaps[*Match*]],
        align(left)[ A conditional statement for branching. ],
        ```phos
match a {
    1 => "one",
    _ => "other"
}
        ```,

        align(center)[#smallcaps[*Loop*]],
        align(left)[ A loop statement. ],
        ```phos
for i in 0..5 {
    print(i)
}
        ```,

        align(center)[#smallcaps[*Return*]],
        align(left)[ Returns a value from a function. ],
        ```phos
return 1
        ```,

        align(center)[#smallcaps[*Break*]],
        align(left)[ Breaks out of a loop. ],
        ```phos
for i in 0..5 {
    break;
}
        ```,

        align(center)[#smallcaps[*Continue*]],
        align(left)[ Continues a loop, terminating the current iteration and moving on the the next one. ],
        ```phos
for i in 0..5 {
    continue;
}
        ```,

        align(center)[#smallcaps[*Yield*]],
        align(left)[ Yields a value from an iterator. ],
        ```phos
for i in 0..5 {
    yield i;
}
        ```,
        

        rowspanx(4)[
            #align(center)[#rotate(-90deg)[#box(width: 200pt)[#smallcaps[*Constant*]]]]
        ],

        align(center)[#smallcaps[*Path*]],
        align(left)[ A path to a value, constant, or other item. ],
        ```phos
std::intrinsic::gain
float::PI
        ```,

        align(center)[#smallcaps[*Identifier*]],
        align(left)[ A name that refers to a value, constant, or other item. ],
        ```phos
gain
PI
        ```,


        align(center)[#smallcaps[*Literal*]],
        align(left)[ A literal value. ],
        ```phos
1 dBc
true
0.5 MHz
        ```,

        align(center)[#smallcaps[*None*]],
        align(left)[ The none value. ],
        ```phos
none
        ```,

        rowspanx(3)[
            #align(center)[#rotate(-90deg)[#box(width: 200pt)[#smallcaps[*Unary*]]]]
        ],

        align(center)[#smallcaps[*Negation*]],
        align(left)[ Negates a value. ],
        ```phos
-1
        ```,

        align(center)[#smallcaps[*Not*]],
        align(left)[ Negates a boolean value. ],
        ```phos
!true
        ```,

        align(center)[#smallcaps[*Binary not*]],
        align(left)[ Negate a binary value. ],
        ```phos
!0xFF
        ```,

        rowspanx(19)[
            #align(center)[#rotate(-90deg)[#box(width: 200pt)[#smallcaps[*Binary*]]]]
        ],

        align(center)[#smallcaps[*Addition*]],
        align(left)[ Adds two values. ],
        ```phos
1 + 2
        ```,

        align(center)[#smallcaps[*Subtraction*]],
        align(left)[ Subtracts two values. ],
        ```phos
1 - 2
        ```,

        align(center)[#smallcaps[*Multiplication*]],
        align(left)[ Multiplies two values. ],
        ```phos
1 * 2
        ```,

        align(center)[#smallcaps[*Division*]],
        align(left)[ Divides two values. ],
        ```phos
1 / 2
        ```,

        align(center)[#smallcaps[*Modulo*]],
        align(left)[ Calculates the remainder of a division. ],
        ```phos
1 % 2
        ```,

        align(center)[#smallcaps[*Exponentiation*]],
        align(left)[ Raises a value to a power. ],
        ```phos
1 ** 2
        ```,

        align(center)[#smallcaps[*Bitwise and*]],
        align(left)[ Performs a bitwise and operation. ],
        ```phos
1 & 2
        ```,

        align(center)[#smallcaps[*Bitwise or*]],
        align(left)[ Performs a bitwise or operation. ],
        ```phos
1 | 2
        ```,

        align(center)[#smallcaps[*Bitwise xor*]],
        align(left)[ Performs a bitwise xor operation. ],
        ```phos
1 ^ 2
        ```,

        align(center)[#smallcaps[*Bitwise shift left*]],
        align(left)[ Performs a bitwise shift left operation. ],
        ```phos
1 << 2
        ```,

        align(center)[#smallcaps[*Bitwise shift right*]],
        align(left)[ Performs a bitwise shift right operation. ],
        ```phos
1 >> 2
        ```,

        align(center)[#smallcaps[*Less than*]],
        align(left)[ Checks if a value is less than another. ],
        ```phos
1 < 2
        ```,

        align(center)[#smallcaps[*Less than or equal*]],
        align(left)[ Checks if a value is less than or equal to another. ],
        ```phos
1 <= 2
        ```,

        align(center)[#smallcaps[*Greater than*]],
        align(left)[ Checks if a value is greater than another. ],
        ```phos
1 > 2
        ```,

        align(center)[#smallcaps[*Greater than or equal*]],
        align(left)[ Checks if a value is greater than or equal to another. ],
        ```phos
1 >= 2
        ```,

        align(center)[#smallcaps[*Equal*]],
        align(left)[ Checks if a value is equal to another. ],
        ```phos
1 == 2
        ```,

        align(center)[#smallcaps[*Not equal*]],
        align(left)[ Checks if a value is not equal to another. ],
        ```phos
1 != 2
        ```,

        align(center)[#smallcaps[*Logical and*]],
        align(left)[ Checks if two boolean values are both true. ],
        ```phos
true && false
        ```,

        align(center)[#smallcaps[*Logical or*]],
        align(left)[ Checks if either of two boolean values are true. ],
        ```phos
true || false
        ```,

        rowspanx(13)[
            #align(center)[#rotate(-90deg)[#box(width: 200pt)[#smallcaps[*Special*]]]]
        ],

        align(center)[#smallcaps[*Pipe*]],
        align(left)[ Pipes a value into a function. ],
        ```phos
1 |> f
        ```,

        align(center)[#smallcaps[*Parenthesized*]],
        align(left)[ Groups an expression. ],
        ```phos
(1 + 2) * 3
        ```,

        align(center)[#smallcaps[*Tuple*]],
        align(left)[ Creates a tuple. ],
        ```phos
(1, 2)
        ```,

        align(center)[#smallcaps[*Cast*]],
        align(left)[ Casts a value to a different type. ],
        ```phos
1 as uint
        ```,

        align(center)[#smallcaps[*Index*]],
        align(left)[ Indexes into a value. ],
        ```phos
a[1]
        ```,

        align(center)[#smallcaps[*Member access*]],
        align(left)[ Accesses a member of a value. ],
        ```phos
a.b
        ```,

        align(center)[#smallcaps[*Function call*]],
        align(left)[ Calls a function. ],
        ```phos
f(1, 2)
        ```,

        align(center)[#smallcaps[*Method call*]],
        align(left)[ Calls a method. ],
        ```phos
a.f(1, 2)
        ```,

        align(center)[#smallcaps[*Partial*]],
        align(left)[ Partially applies a function. ],
        ```phos
set f(1)
        ```,

        align(center)[#smallcaps[*Closure*]],
        align(left)[ Creates a closure. ],
        ```phos
|x| x + 1
        ```,

        align(center)[#smallcaps[*Range*]],
        align(left)[ Creates a range. ],
        ```phos
1..2 1..=2 ..3 4..
        ```,

        align(center)[#smallcaps[*Array*]],
        align(left)[ Creates an array. ],
        ```phos
[1, 2]
        ```,

        align(center)[#smallcaps[*Object instance*]],
        align(left)[ Creates an object instance. ],
        ```phos
A {a: 1, b: 2}
B(1, 2)
MyEnum::A
C
        ```,
    )
] <tab_exprs>

== Standard library <sec_stdlib>

In addition to the language itself, @phos will come with a standard library: a library of functions and synthesizable blocks that come with the language. The standard library will be written in a mixture of @phos for synthesizable blocks and functions, and some native _Rust_ code for either performance critical sections, or areas where external libraries are required. The standard library will be organized as logically as possible, providing the necessary building blocks for new users to be productive with the language. However, the standard library will be limited in scope such that it does not become a burden to maintain. Relying instead on third-party libraries and @ip[s] for more complex functionality. A notable goal of the standard library is to provide synthesizable blocks for all common functions, like modulators, filters, and so on. But not for more complex functionality like larger components, or even entire systems.

Most intrinsic operations discussed in @sec_intrinsic_operations are more complex than they first appear. As previously mentioned in @sec_programmable_photonics, most photonic components are actually reciprocal, meaning that they are the same whether light is travelling forwards or backwards. Additionally, waveguides support two modes, one in each direction, meaning that each device may be used for two purposes. Removing the user's ability to exploit these properties would be greatly limiting, and as such, the standard library must provide ways of accessing these fully-featured intrinsic operations. However, the user cannot be expected to only program using these low level primitives, Furthermore, as they are mostly unconstrained and would require constrained blocks to be used to their full extent, due to the limitation on constraints regarding cyclic dependencies. Therefore, one of the main goals of the standard library is to provide higher-level primitives that wrap these unconstrained intrinsic operations into constrained block following the feedforward approximation (@feedforward_approx).

The standard library should also decouple synthesizable blocks from computational methods. For example, a filter block may need other functions to compute the coupling coefficient, or the length of a ring resonator. These functions will need to be part of the standard library to offer filter synthesis, but they should be accessible separately, such that if a user wishes to implement some function themselves, they can rely on the existing code present in the standard library to make their work easier. This also means that the standard library should be as modular as possible, perhaps even in the future allowing users to replace default behaviour in the standard library with their own implementations. This modularity also helps in the development of the platform support packages, as these need to be able to support the standard library, something that may be done by replacing parts of the standard library with platform specific implementations, while keeping the exposed @api the same.

Finally, the standard library can serve as a series of examples for new users. A photonic engineer, that is knowledgeable with photonic circuit design would benefit from the standard library as a source of high quality examples onto which they may base themselves. Similarly, a software engineer, that is knowledgeable with software development, but not photonic circuit design, would benefit from the standard library as a source of high quality examples of basic building blocks of photonic circuits. The standard library should be written in a way that is easy to understand, and that is well documented, such that it can serve as a learning resource for new users.


#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constrain*]
}
A unique feature of the standard library is the `constrain` method, it is used to impose differential constraints on signals. This means that constraints over delay or phase, which are always relative, can be expressed between signals. This tells the synthesizer to ensure that these constraints are respected between signals. Indeed, if it were not for this method, the user could not easily represent phase matched or delay matched signals. During the examples, in @sec_examples, the use of this method will become clear, and its implication and why it is so important will be discussed.

#pagebreak(weak: true)
== Compiler architecture <sec_arch>

The design of the @phos compiler is inspired in parts by _Clang_'s, _Rust_'s, and _Java_'s compilers #cite("clang_internals", "rust_compiler", "openjdk_hotspot"). As previously mentioned, the compilation of a @phos program into a circuit design that can be programmed onto a photonic processor is a three step process: compilation, evaluation, and synthesis. The compiler as it is referred in this section performs the compilation step. Therefore, as previously mentioned in @sec_exec_model, it has the task for taking the user's code as an input and producing bytecode for the #gloss("vm", long: true). The compiler is written in _Rust_, and is split into several components, each with a specific purpose. As will be discussed in subsequent sections, the @phos compiler is composed of a _lexer_, a _parser_, an _#gloss("ast", long: true)_, a _desugaring_ step, a _high-level intermediary representation_, a _medium-level intermediary representation_, and a _bytecode_ generator. The multiple stages of the compiler are illustrated in @fig_compiler_arch.

#info-box(kind: "important")[
    The overall architecture and components of the @phos compiler are similar in design to _Rust_'s compiler @rust_compiler, this is done purposefully for two reasons. First, _Rust_ as a language is advanced, and has a well design compiler, and as such is a good source of reference materials. Second, the @phos compiler is written in _Rust_, and as such, it can reuse existing code and algorithms from both, the extended ecosystem of language development libraries in _Rust_, and from the _Rust_ compiler itself. As the _Rust_ compiler is released under an @mit license, it can legally be used as a source of inspiration and code for the @phos compiler.
]

#figurex(
    title: [ Compiler architecture of the @phos programming language ],
    caption: [
        Compiler architecture of the @phos programming language, showing that the user code flows into the different stages of the compiler. All of these stages producing the bytecode that can be evaluated.

        This figure uses the same color scheme as @fig_responsibilities, showing the ecosystem components in orange, the user's code in green, and the platform specific code in blue.
    ]
)[
    #image(
        "../figures/drawio/compiler_arch.png",
        width: 80%,
        alt: "Shows the compiler architecture of the PHÔS programming language: going from user code into lexing, into parsing, into desugaring, into AST-to-HIR, into HIR-to-MIR, into bytecode generation. To produce the bytecode that can be executed by the VM."
    )
]<fig_compiler_arch>

=== Lexing <sec_lexing>

#info-box(kind: "definition", footer: [ Adapted from @nystrom_crafting_2021. ])[
    *Lexing* is the process of taking a stream of characters and converting it into a stream of tokens. A token is a sequence of characters that represent a unit of meaning in the language.
]

As this definition implies, this lexer turns a series of character from the human-readable @phos code, into a series of tokens, which can be seen as words of the language. Some of those words have special significance, such as `+`, which represent an addition, others such as an open parenthesis (`(`) simply represents an open parenthesis. At this stage of the compilation process, there is no meaning associated with each tokens, meaning that they are separate entities that the compiler is yet to associate into bigger, more meaningful units. The @phos lexer is implemented using the _Logos_ library in _Rust_ @logos. _Logos_ is a lexer generator, meaning that it allows the creation of extremely fast lexers very easily, and is used by other open source projects @logos_dependents.

In @lst_lexing_ex, one can see the process that turns a simple piece of code into a series of tokens that can be used by the parser. The code is first split into a series of characters, which are then fed into the lexer. The lexer then produces a series of tokens, which are then printed to the console. One can also see that the comment in line one, has been removed. Indeed, the lexer discards all unnecessary tokens, such as linebreak, whitespace, and comments. This is done to simplify the parsing process, as the parser does not need to deal with those tokens, and can focus on the tokens that are meaningful to the language.

Additionally, and not shown in @lst_lexing_ex, the @phos lexer preserves the span where the token is found in the source code. This is used to generate more meaningful error by indicating the location of the error in the source code. This is done by associating the said span with each token produced by the lexer.

#figurex(
    kind: raw,
    title: [ Example of lexing in @phos ],
    caption: [
        Example of lexing in @phos, showing a code sample (a) and the output of the lexer (b). Note that the indentation in (b) is solely for readability purposes, and is not part of the output of the lexer.
    ],
)[
    #table(
        columns: (0.8fr, 1fr),
        stroke: none,
        ```phos
// Adds two numbers together.
fn add(a: int, b: int) -> int {
    a + b
}
        ```,
        ```js
Keyword("fn") Identifier("add")
    OpenParen 
        Identifier("a") Colon Identifier("int") Comma
        Identifier("b") Colon Identifier("int") 
    CloseParen Arrow Identifier("int") OpenBrace 
        Identifier("a") Plus Identifier("b") 
    CloseBrace
        ```,
        align(center)[(a)],
        align(center)[(b)]
    )
] <lst_lexing_ex>

=== Parsing <sec_parsing>

#info-box(kind: "definition", footer: [ Adapted from @nystrom_crafting_2021. ])[
    *Parsing* is the action of taking a stream of tokens, and turning it into a tree of nested elements that represent the grammatical structure of the program.
]

Before parsing the language, one must first describe the grammar of the language. For the @phos programming language, the full grammar is present in @anx_phos_grammar. There exists many families of grammars as seen in @fig_parser_hierarchy. The more complex the grammar is, the more complex of a parser it will require. It is important to note that @fig_parser_hierarchy describes grammars not languages, languages can be expressed using multiple grammars, and some grammars for a given language can be simpler @cs143. Every grammar can be expressed with a grammar of a higher level, but the reverse is not true.

@phos has an LL(K) grammar, meaning that it can be read from #strong[L]eft-to-right with #strong[L]eftmost derivation, with $k$ token lookahead, meaning that the parser can simply move left to right, only ever applying rules to elements on the left, and needs to look up to $k$ tokens ahead of the current position to know which rule to apply. This is a fairly complex grammar to express and to parse. The parser for @phos is implemented using the _Chumsky_ library (named after _Noam Chomsky_) in _Rust_ @chumsky. _Chumsky_ is a parser combinator generator, meaning that it allows the creation of complex parsers with relatively little code. Because of the properties of _Chunmsky_, the parser for the @phos language is fairly simple 1600 lines of code, and is relatively easy to understand. It is the task of the parser to use the @phos grammar to produce an #gloss("ast", long: true), this tree represents the syntax and groups tokens into meaningful elements.

Additionally, the grammar of @phos contains the priority of operations, meaning that the resulting @ast is already correct with regards to the order of operations, something that otherwise would need to be done using @ast transformations in the next step of the compilation process. This further increases the complexity of the grammar, and the complexity of the parser, but simplifies the next steps of the compilation process.

#figurex(
    title: [ Hierarchy of grammars that can be used to describe a language. ],
    caption: [
        Hierarchy of grammars that can be used to describe a language. The grammars are ordered from the most powerful to the least powerful. The most powerful grammars are able to describe any unambiguous language, whereas the least powerful grammars are only able to describe a subset of the languages @cs143. As @phos does not use an ambiguous grammar and they are very difficult to describe and parse, they are not discussed further.
    ],
)[
    #image(
        "../figures/drawio/parser-hierarchy.png",
        width: 90%,
        alt: "Shows the hierarchy of parser, showing that for unambiguous grammars, the subsets are LR(K), LR(1), LALR(1), SLR(1), LR(0), LL(K), LL(1), LL(0). Ambiguous grammars also exists but they are not discussed further."
    )
] <fig_parser_hierarchy>

#pagebreak(weak: true)
=== The abstract syntax tree <sec_ast>

The #gloss("ast", long: true) is the result of the previous compilation step -- parsing -- and it is a tree-like data structure that represents the syntax of the user's code in a meaningful way. It shows the elements as bigger groups than tokens, such as expressions, synthesizable blocks, etc. The @ast is the base data structure on which all subsequent compilation steps are based. The @ast would also used by the @ide to provide code completion, syntax highlighting, and code formatting.

Just as is the case for parsing, syntax trees have a hierarchy, it generally consists of two categories: the #gloss("cst", long: true) and the #gloss("ast", long: true). The @cst aims at being a concrete representation of the grammar, being as faithful as possible, keeping as much information as possible. On the other hand, an @ast only keep the information necessary to perform the compilation, therefore, it is generally simpler and smaller than an equivalent @cst. However, while this can be seen as a hierarchy, it is more of a spectrum, as the @ast can be made more concrete and closer to a @cst depending on the needs. In fact, the @ast of @phos keeps track of all tokens, and their position in the source code, making it possible to reconstruct the original source code from the @ast. The only thing it discards are whitespaces, linebreaks, and comments. Additionally, the @ast of @phos also keeps track of spans where the code comes from, just like in the lexer, it is used to provide better error messages.

Building on top of the example shown in @lst_lexing_ex, the @ast for the function `add` would look like @lst_ast_ex. Additionally, an overview of the data structure required to understand this part of the @ast is shown in @anx_ast_overview. Some details have been omitted for brevity, and to focus on the relevant parts of the @ast. However, one can still see the tree-like structure of the @ast, and the many different kinds of data structures that it requires. In fact, the current @ast for @phos is composed of 250 different data structures. This shows how complex the @ast can be, and how much work is required to build it. However, having a good @ast as the basis of the compilation process is crucial as it can be easily modified, expanded, and transformed to perform the compilation. Additionally, the breadth of data that it contains can be used to implement other elements of the ecosystem, such as code formatters, code highlighters, and linters, all tools that have been discussed at length and that are essential to provide a good developer experience.

#figurex(
    title: [
        Partial result of parsing @lst_lexing_ex.
    ],
    caption: [
        Partial result of parsing @lst_lexing_ex, showing the tree-like structure of nested data structures. The @ast is a tree-like data structure that represent the syntax of the user's code. In this case, it shows a function which name is an identifier `add`, and that has two arguments: `a` and `b`, both of type `it`, it has a return type of type `int`, and a body that is a block containing a single expressions, which is a call to the `+` operator, with the arguments `a` and `b`.
    ]
)[
    #image(
        "../figures/drawio/ex_ast_out.png",
        width: 90%,
        alt: "Partial result of parsing @lst_lexing_ex, showing the tree-like structure of nested data structures. The AST is a tree-like data structure that represent the syntax of the user's code. In this case, it shows a function which name is an identifier add, and that has two arguments: a and b, both of type it, it has a return type of type int, and a body that is a block containing a single expressions, which is a call to the + operator, with the arguments a and b."
    )
] <lst_ast_ex>

=== Abstract syntax tree: desugaring, expansion, and validation <sec_ast_desug>

#info-box(kind: "info")[
    From this point in the document, the language is not yet implemented and therefore does not exist. These following steps are therefore not implemented, and are only description of what will be done when the language is fully implemented.
]

#info-box(kind: "definition", footer: [ Adapted from @nystrom_crafting_2021. ])[
    *Syntactic sugar* is syntax that is intended to make things easier to read, express, or understand.
]

The first step in the compilation process is to remove syntactic sugar, as it is not useful for the compiler and is only intended to make the code easier to read and write. Therefore, this syntactic sugar can be simplified into simpler syntactic blocks. Additionally, in the same stage, the @ast is expanded to include more information. In the case of the @phos programming language, this will involve the following:
- Feature gate checking;
- Transforming all automatic return statements into explicit return statements;
- Name resolution;
- Macro expansion;
- and @ast validation.

For this section, the example shown in @lst_desug_ex will be used, it shows a simple circuit involving a filter, a gain section that is gated behind a feature flag, implicit returns and imports. Since macros don't yet have a fixed syntax for a language, and are left as future work, see @sec_lang_improvements, there will not be an example involving macros.

#figurex(
    kind: raw,
    caption: [
        Example used to show the desugaring, @ast expansion, and @ast validation in @phos.
    ],
)[
    ```phos
import std::{filter, gain};
/// Processes a signal using one of two filters based on feature flags
syn process_signal(signal: optical) -> optical {
    signal |> internal_process()
}
/// If the library supports gain, add some gain after the filter
#[feature(gain)]
syn internal_process(signal: optical) -> optical {
    signal |> filter(1550 nm, 10 GHz) |> gain(10 dB)
}
/// If the library does not support gain, just filter the signal
#[feature(not(gain))]
syn internal_process(signal: optical) -> optical {
    signal |> filter(1550 nm, 10 GHz)
}
    ```
] <lst_desug_ex>

#info-box(kind: "note")[
    The processes being described in this section are done at the @ast level. However here, for the sake of clarity, source code is shown instead of the @ast for each step in this compilation stage.
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Feature gate checking*]
}
In this step, the syntax is checked for feature gates, and only the parts of the @ast not gated by feature gates are kept. Meaning that feature flags are evaluated and the part of the @ast that cannot be compiled with the current set of feature flags are removed. For code involving feature flags, this reduces the complexity of the @ast, and the amount of work the compiler must do. This step is done as early as possible to further reduce the amount of work the compiler must do. Continuing on from @lst_desug_ex, in @lst_feature_flag_ex, it can be observed that the `gain` section has been removed, assuming that the `gain` feature flag is not enabled. The comments are also removed as the parser does not include comments in the @ast.

#figurex(
    kind: raw,
    caption: [
        Demonstration of feature gate checking in @phos, using the example from @lst_desug_ex.
    ],
)[
    ```phos
import std::{filter, gain};
syn process_signal(signal: optical) -> optical {
    signal |> internal_process()
}
syn internal_process(signal: optical) -> optical {
    signal |> filter(1550 nm, 10 GHz)
}
    ```
] <lst_feature_flag_ex>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Automatic return statement*]
}
In this process, all automatic return statement that are present at the end of a block are transformed into explicit return statement, such that the rest of the compiler need only look for explicit return statements. This is done to simplify subsequent compilation steps. Building on from @lst_desug_ex, one can see in @lst_return_ex that the automatic return statements have been transformed into an explicit return statements.

#figurex(
    kind: raw,
    caption: [
        Example used to show the desugaring of return statements, @ast expansion, and @ast validation in @phos.
    ],
)[
    ```phos
import std::{filter, gain};
syn process_signal(signal: optical) -> optical {
    return signal |> internal_process();
}
syn internal_process(signal: optical) -> optical {
    return signal |> filter(1550 nm, 10 GHz);
}
    ```
] <lst_return_ex>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Name resolution*]
}
At this stage, the compiler has not yet resolved all of the path to the different items that are being used. Therefore, in this steps, all import statements and path expressions are inlined and resolved. This means that after this process, import statements will no longer be needed nor used, and all relative path to items will be replaced by their absolute path. Additionally, it is at this stage that the compiler checks for the existence of the items being used. If they do not exist, the compiler will return an error. Continuing on from @lst_desug_ex, in @lst_name_res_ex, one can see that the import statements have been removed, and the path to the items have been resolved, further simplifying the @ast (shown here as code for clarity). As the type `optical` is a built-in type in @phos, it does not get resolved, it is always valid.

#figurex(
    kind: raw,
    caption: [
        Example of name resolution in @phos, using the example from @lst_desug_ex.
    ],
)[
    ```phos
syn process_signal(signal: optical) -> optical {
    return signal |> self::internal_process();
}

syn internal_process(signal: optical) -> optical {
    return signal |> std::filter(1550 nm, 10 GHz);
}
    ```
] <lst_name_res_ex>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Macro expansion*]
}
Depending on the type of macros being implemented in @phos, they may be operating at the @ast level. If that were to be the case, macros would be expanded in this stage. Macro expansion refers to the compiler replacing the macro calls within the code, with the output produced by the macro. This is done at this stage, because the @ast has not yet been checked. Meaning that the code produced by the macro, if it were to be erroneous, would still be verified and not assumed correct. As the example in @lst_desug_ex does not contain any macros, the @ast remains unchanged.

It is also important to note, that @phos may benefit more from reflection level macros, rather than @ast level macros. This is because @phos is at its core, a high-level language, and therefore, macro creators may be interested in also operating at a higher level of symbolic representation than the @ast. However, this is neither a requirement, nor has either solution been implemented yet. Additionally, both solutions are suitable and can be implemented at the same time.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*@ast validation*]
}
@ast validation involves the process of verifying that the @ast is correct. This means that the more complex syntactic rules, that were not expressed in the grammar, are checked. They are checked on the @ast because it makes the grammar of the language simpler, simplifying the parser too. Additionally, it can perform basic checks based on rules. While these rules are not yet clear for @phos, they will need to be defined in the future. It is important to note that @ast validation should not involve any complex analysis, such as type checking, as these are easier to implement on the @hir.

=== AST lowering, type inference, and exhaustiveness checking <sec_ast_to_hir>

As this point in the compilation pipeline, much of the initial complexity of the user's code has been removed, however many critical aspects of compiling the language have not been performed yet. Most notably with regards to type inference, type checking and exhaustiveness checking. These functions are all performed on the @hir, but at this point, the compiler still only has the @ast. Therefore, the first process in this step is to lower the @ast. Essentially, the compiler must transform the @ast into a lower level, simpler form of the code, called the @hir.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*@ast lowering*]
}
Lowering from the @ast to the @hir requires removing all of the elements of the language that are not needed for type analysis which is the focus of this compiler step. Due to the previous step having decreased language complexity using desugaring, the @ast is already less complex. However, it still contains elements that are not needed for type analysis, such as names. Indeed, variable names, type names, etc. are only useful for humans, it is easier for a computer to understand these as numerical identifiers (IDs). Therefore, in this process, the name of all values are replaced with generated IDs. Additionally, the tree-like data structure can be flattened by using node IDs instead of pointers to nodes. This decreases the complexity of the data structure and makes traversal, and most importantly queries easier to perform. Indeed, queries need to be performed on the @hir to find elements and apply rules for @hir to @mir lowering.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Type inference*]
}
After lowering the @ast into the @hir, the compiler will now try and infer the types of all values, based on existing annotation and some rules. When the compiler has inferred the type of a value, it will explicitly annotate that value with its type, that way, each value has its type known at each point in the code, such that further checks can be performed. Continuing with @lst_desug_ex, one can see what the resulting, fully annotated code would look like in @lst_type_inf_ex. It shows what the code would look like, if this were valid syntax, after @ast lowering and explicit type annotation.

#figurex(
    kind: raw,
    title: [ Example of name stripping and type inference in @phos ],
    caption: [
        Example of name stripping and type inference in @phos, showing the process of name stripping and type inference, using the example from @lst_desug_ex. All nodes are annotated with their type, all variables, arguments, function names, etc. have been renamed with an ID shown here as `$n`, where `n` is a number.

        Note that this is not valid @phos syntax and is only used to illustrate the process of name stripping and type inference. In practice, the @hir would be a flattened tree-like data structure, similar to the @ast, not a textual representation.
    ],
)[
    ```phos
syn $0($1: optical) -> optical {
    return (($1: optical) |> ($2(): optical)): optical;
}
syn $2($1: optical) -> optical {
    return (($1: optical) |> ($3((1550 nm: Wavelength), (10 GHz: Frequency)); optical)): optical;
}
    ```
] <lst_type_inf_ex>

As with most modern programming languages with type inference, @phos will use the _Hindley-Milner_ algorithm #cite("milner_theory_1978", "hindley_principal_1969"). It is an algorithm that is capable of inferring the type of a value, with little to no type annotations. This makes development easier, as less manual work of annotating types is required. Additionally, it is a convenient algorithm to use as there are many resources available about it, and many libraries implementing it already, meaning that the development burden caused by type inference is significantly lower.

Additionally, the _Hindley-Milner_ algorithm supports polymorphism, while this feature is not yet integrated into the syntax and feature set of the @phos language, it may be of interest as it can allow more advanced types to be expressed. However, this is not a priority for the language, and therefore, it is not yet designed into the language nor is it designed into the compiler architecture.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Exhaustiveness checking*]
} Exhaustiveness checking is the process of verifying that the user has covered all possible cases in a pattern matching statement. This can be done with the algorithm presented by _Karachalias et al._ #cite("karachalias_gadts_2015", "kalvoda_structural_2019"), it is an algorithm that is capable of checking for pattern exhaustiveness even in very complex cases, such as when using @gadt[s], a generalized form of previously mentioned @adt[s]. However, in the case @phos, this task is made more complex by constraints. Indeed, the compiler tries to verify that all cases are covered, but constraints may reduce the amount of cases that are valid. Take the example shown in @lst_exhaustiveness_ex: gain as a numerical value can take any value in the range $[0, infinity[$, however in this example, it can take a value only in the range $[0 "dB", 10 "dB"]$. When looking at this code, the compiler, if it does not exploit constraints, will declare that the `match` statement on line $9$ is not exhaustive, despite it being exhaustive in the context created by the constraints.

As a means of alleviating this issue, the compiler can either force the user to always be exhaustive even when it is not necessary, or can exploit constraints and utilize them as a means of improving exhaustiveness checking. This can be done in multiple ways, including using the prover to verify that all cases are covered, however this approach is likely to be slow and difficult to implement. Others revolve around the use of refinement types and guarded recursive data type constructors #cite("xi_guarded_2003"). However, these techniques are not yet fully explored and are not yet integrated into the compiler architecture, and further research and experimentation is needed to determine which technique is the most appropriate for the @phos language. This topic is further discussed in @sec_refinement_types.

#figurex(
    kind: raw,
    title: [
        Example of exhaustiveness checking in @phos when using constraints.
    ],
    caption: [
        Example of exhaustiveness checking in @phos when using constraints. In this example, the compiler should be able to detect that the `match` statement on line $9$ is exhaustive given the constraints on line $6$, but it is a difficult problem to solve and requires further research.
    ],
)[
    ```phos
// Performs gain on an optical signal, depending on the gain, it will
// either use a short gain section or a long gain section.
syn example(
    signal: optical,

    @range(1dB, 10dB)
    gain: Gain,
) -> optical {
    match gain {
        1dB..5dB => signal |> short_gain(gain),
        5dB..=10dB => signal |> long_gain(gain),
    }
}
    ```
] <lst_exhaustiveness_ex>


=== Constant evaluation, control flow, liveness, and pipe desugaring <sec_mir_to_mir>

After processing the @hir, it is reduced into an even simpler form based on a #gloss("cfg", long: true). During this stage, almost all of the elements of the language are removed, even conditional branching is now implemented using `goto` operations. All of this with the aim of making the code as easy to analyze as possible. From this stage, as everything as been reduced to the most basic elements, the compiler can now do some optimization, it can compute the values of all constants and inline them where they are used, it can also perform control flow optimizations, such as performing liveness analysis, which is the process of determining which code is used and which is not, and removing the parts that are not used. Finally, it can remove pipe operators replacing them instead of function calls, performing the pattern matching at compile time.

Using the aforementioned analysis, the compiler can now also detect whether all signals are being used, and if not, it can create an error for the user, indicating which part of the code is problematic. This is a useful feature of the compiler, as it enforces that all signals are at least _read-once_, which is part of the signal semantics discussed in @sec_signal_types. The way in which liveness and dead code elimination can be done is through the use of the @cfg, as it allows the compiler to easily determine which code does not contribute to the final result, and therefore can be removed, it detects unused signal simply by checking whether any signals are used within dead code.


#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Control Flow Graph*]
}
A @cfg, as the name implies, is a graph data structure that represents each operation being done as a node of the graph, with the different branches of the code being represented as edges. This means that all orphan sections are not accessed through the main entry point and can therefore be easily discarded. In @lst_cfg_ex, one can see a simple example checking whether a number is prime (a) and its expanded version (b). The expanded version corresponds to an approximation of what code *equivalent* to the @mir would look like, with all types specified, the `for` loop replaced with a `goto` statement and labels. As was the case in previous examples of lower-level constructs, this code is not valid @phos, and is purely for demonstration purposes.
#figurex(
    caption: [
        @cfg created from the code in @lst_cfg_ex. It shows the different branches of the code, with the first branch relating to the iteration from `2` to `number`, and the second branch relating to the `if` statement checking whether the number is divisible by `i`. It shows that each branch is made of individual statements, and that the `if` and `match` statements are represented as branches with two possible outcomes.
    ],
    title: [ @cfg created from the code in @lst_cfg_ex. ],
    kind: image
)[
    #image(
        "../figures/drawio/is_even_cfg.png",
        width: 70%,
        alt: "Shows a control flow graph, showing first a block of code `let i = 2`, followed by `let iterator = 0..number`, followed by `let tmp = iterator.next()`, and `match tmp`. An arrow annotated as `none` goes to the left to a single block `return true`. An arrow annotated as `i` goes to two blocks: `let tmp2 = number % i` and `tmp == 0`. From that last block, an arrow annotated `true` goes to `return false`, and an arrow annotated `false` goes back to `let tmp = iterator.next()`."
    )
] <fig_cfg_ex>

#figurex(
    caption: [
        Code example in @phos and code-equivalent representation of its @mir expanded version. Shows a function computing whether a number is prime before (a) and after expansion (b). The code in (b) is not valid @phos, and is purely for demonstration purposes.
    ],
    title: [ Code example in @phos and code-equivalent representation of its @mir expanded version. ],
    kind: raw
)[
    #table(
        columns: 2,
        stroke: none,
        ```phos
// Checks if the number is prime
fn is_prime(number: int) -> bool {
    let i = 2;
    for i in 0..number {
        if number % i == 0 {
            return false;
        }
    }

    true
}
        ```,
        ```phos
// Checks if the number is prime
fn is_prime(number: int) -> bool {
    let i: int = 2;
    let iterator: Iterator = 0..number;

    top:
        let tmp = iterator.next();
        match tmp {
            i => {
                let tmp2: int = number % i;
                if tmp2 == 0 {
                    return false;
                }

                goto top;
            }
            none => goto ret,
        }

    ret:
        return true;
}
        ```,
        [ (a) ],
        [ (b) ],
    )
] <lst_cfg_ex>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constant inlining*]
}
It is at this stage of the compilation pipeline that all constants are evaluated and replaced. The reason why @phos does this step is not for performance, as in most other languages, but for simplicity. As the @vm will use a prover to verify aspects of the code in scenarios where reconfigurability is used, the code produced by the compiler must be as simple as possible to simplify this process as much as possible. For this reason, as constant evaluation is relatively easy to perform, it is done during compilation. In @lst_const_inlining, one can see a piece of code before constant inlining (a), after constant inlining (b), and after constant evaluation (c). It also shows that operations that produce constant values within the user's code are also computed, further reducing the complexity of the code.

#figurex(
    caption: [
        Code example in @phos, showing the original code (a), the code after constant inlining (b), and the code after constant evaluation (c).
        
        These operations would normally be done in the @mir stage, and therefore would not be visible in code, but for demonstration purposes, they are shown here as valid @phos code.
    ],
    title: [ Code example in @phos, showing constant inlining and evaluation. ],
    kind: raw
)[
    #block[
    #table(
        columns: 3,
        stroke: none,
        ```phos
const MY_CONST: int
    = 32;

fn add_my_const(
    a: int
) -> int {
    a + 2 * MY_CONST + 5
}
        ```,
        ```phos
fn add_my_const(
    a: int
) -> int {
    a + 2 * 32 + 5
}
        ```,
        ```phos
fn add_my_const(
    a: int
) -> int {
    a + 69
}
        ```,
        [ (a) ],
        [ (b) ],
        [ (c) ],
    )]
] <lst_const_inlining>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Pipe desugaring*]
}
The final syntactic sugar that has yet to be simplified, is the pipe operator (`|>`). This operator is used on iterable tuples to pass data from one function or synthesizable block to another easily while keeping the code readable. The pipe operator performs pattern matching on its input values, and into the function arguments it is piping into. Doing so is quite difficult, which is why it is performed close to the end of all transformations. As this stage, the types are all known, operations have been simplified to the maximum, and therefore, it is the easiest point in the compilation process for the compiler to perform this transformation. In @lst_pipe_desugaring, one can see a piece of code before pipe desugaring (a), and after pipe desugaring (b), while both of these expressions are equivalent, the former is easier to read and understand. In more complex cases, where the pipe operator is used to pattern match over multiple values, this simplification is more complex. 

#figurex(
    caption: [
        Code example in @phos, showing the original code (a), and the code after pipe desugaring (b).
        
        These operations would normally be done in the @mir stage, and therefore would not be visible in code, but for demonstration purposes, they are shown here as valid @phos code.
    ],
    title: [ Code example in @phos, showing pipe desugaring. ],
    kind: raw
)[
    #table(
        columns: 2,
        stroke: none,
        ```phos
// Returns the sum of all inputs,
// also returns true if the sum is even
fn sum(inputs: (int...)) -> (int, bool) {
    inputs
        |> fold(0, |acc, x| acc + x)
        |> map(|x| (x, x % 2 == 0))
}
        ```,
        ```phos
// Returns the sum of all inputs,
// also returns true if the sum is even
fn sum(inputs: (int...)) -> (int, bool)  {
     map(fold(inputs, 0, |acc, x| acc + x), |x| (x, x % 2 == 0))
}
        ```,
        [ (a) ],
        [ (b) ],
    )
] <lst_pipe_desugaring>

#pagebreak(weak: true)
=== PHÔS bytecode <sec_mir_to_bytecode>

#info-box(kind: "definition", footer: [ Adapted from @java_se_specs. ])[
    The *bytecode* is a binary representation of the original source code, that has been processed by the compiler to be verified for correctness, simplified, and optimised. It is an executable representation, made of instructions, that can be executed by the #gloss("vm", long: true).
]

From the @cfg built in the previous step, it is now relatively easy to move to a bytecode representation. This is done by replacing all simplified expression with bytecode instructions. The bytecode of the @phos language is greatly inspired by _Java_'s bytecode @java_se_specs. With the addition of a few key features, most notably special instructions representing the intrinsic signal operations, discussed in @sec_intrinsic_operations, and constraints which are added as special instructions on values. The @phos bytecode also removes some of the instructions that are not needed, since @phos does not distinguish between 32-bit and 64-bit values, @phos is not object oriented and does not need object-related information and instructions, finally, @phos does not have a concept of exceptions, and therefore does not need instructions related to exception handling.

Because of these properties, the instruction set of the @phos language is fairly simple, additionally some instructions are more generic than in _Java_, for example @phos does not distinguish between integer and floating-point operations, and therefore has a single instruction for arithmetic operations, which can be used for both integer and floating-point values. The @phos bytecode is also stack-based, meaning that all operations are performed on a stack, and all values are pushed and popped from the stack, this will be discussed in more detail in @sec_stack_based. The full instruction set of the @phos #gloss("vm", long: true) can be found in @tbl_instruction_set.

Finally, along with the bytecode, the previously built @cfg is also included, with its node now replaced with the position of the relevant instructions. The reasoning behind this inclusion is as follows: as the @vm will need to prove that some branches can be taken, while others cannot, it will need to build branching information either way. Instead of having to rebuild the @cfg in the @vm, it is instead packed along with the bytecode as a means of reducing computation time. This gives a dual purpose to the @cfg, as it is used both in the compiler, and in the @vm.

#info-box(kind: "note")[
    It is likely that as the development of the @phos language continues, the instruction set will be expanded and refined, and therefore the instruction set shown in @tbl_instruction_set may not be the final instruction set of the @phos #gloss("vm", long: true).
]

#figurex(
    title: [ Instruction set of the @phos #gloss("vm", long: true). ],
    caption: [ Instruction set of the @phos #gloss("vm", long: true). Showing the instruction and its static arguments (i.e arguments that are produced during compilation), and the operations that each instruction does on the stack. ],
    kind: table,
)[
    #tablex(
        columns: (0.7fr, 0.5fr, 0.8fr),
        align: center + top,
        auto-vlines: false,
        repeat-header: true,

        rowspanx(2)[#smallcaps[*Instruction*]],
        smallcaps[*Stack operations*],
        rowspanx(2)[#smallcaps[*Description*]],
        (), [ \[before\] #sym.arrow \[after\]], (),

        ```typc
call_fn[
    <function_id>
]
        ```,
        ```
[
    arg0,
    arg1,
    ...
] → result
        ```,
        align(horizon)[
            Calls the function with the given ID, the arguments are obtained from the function definition, and then popped from the stack, the result of the function call is pushed onto the stack.
        ],

        ```typc
call_method[
    <type>, 
    <function_id>
]
        ```,
        ```
[
    arg0,
    arg1,
    ...
] → result
        ```,
        align(horizon)[
            Calls the method with the given ID on the given type, the arguments are obtained from the function definition, and then popped from the stack, the result of the function call is pushed onto the stack.
        ],

        ```typc
goto[
    <label>
]
        ```,
        ```
[] → []
        ```,
        align(horizon)[
            Jumps to the given label. Used when branching.
        ],

        ```typc
pop[
    <n>
]
        ```,
        ```
[ a0,  a1, ... ] → []
        ```,
        align(horizon)[
            Pops the given number of values `n` from the stack and discards them.
        ],

        ```typc
repeat[
    <n1>,
    <n2>
]
        ```,
        ```
[ a0,  a1, ... ] → [
    [a0,  a1, ... ],
    [a0,  a1, ...] ,
    ... 
]
        ```,
        align(horizon)[
            Repeats the `n2` top values of the stack `n1` times, and pushes the result onto the stack.
        ],

        ```typc
const[ <value> ]
        ```,
        ```
[] → [ <value> ]
        ```,
        align(horizon)[
            Pushes the given constant value onto the stack, can be an `int/uint`, a `float`, a `bool`, a `string`, a `char`, a `complex`, or a function, which are used for passing closures to other functions.
        ],

        ```typc
return[]
        ```,
        ```
[ a0,  a1, ... ] → []
        ```,
        align(horizon)[
            Returns from the current function, popping all of the remaining values from the stack and returning them as a tuple. If the stack is empty, returns an empty tuple, which is equivalent to the `none` value.
        ],

        ```typc
none[]
        ```,
        ```
[] → [ none ]
        ```,
        align(horizon)[
            Pushes the `none` value onto the stack.
        ],

        ```typc
load[ <id> ]
        ```,
        ```
[] → [
    a0,
    a1,
    ...,
    len
]
        ```,
        align(horizon)[
            Loads the value with the given local variable ID onto the stack. If it is a tuple, expands the tuple into `len` values on the stack, also pushes the tuple length onto the stack. The first `n` local variables are reserved for the arguments of the function, where `n` is the number of arguments of the function.
        ],

        ```typc
store[
    <id>,
]
        ```,
        ```
[
    a0,
    a1,
    ...,
    len
] → []
        ```,
        align(horizon)[
            Stores the top `len` values of the stack into the local variable with the given ID, if `len` is more than one, then stores them as a tuple. The first `n` local variables are reserved for the arguments of the function, where `n` is the number of arguments of the function.
        ],

        ```typc
get[
    <type_id>,
    <field_id>
]
        ```,
        ```
[ instance ] → [ 
    a0,
    a1,
    ...,
    len
]
        ```,
        align(horizon)[
            Gets the field with the given ID `field_id` from the given type `type_id`, and pushes it onto the stack. If it is a tuple, expands the tuple into `len` values on the stack, also pushes the `len` of the tuple onto the stack. Pops the instance of the type from the stack.
        ],

        ```typc
push[
    <type_id>,
    <field_id>,
],
        ```,
        ```
[
    instance,
    a0,
    a1,
    ...,
    len
] → [ ]
        ```,
        align(horizon)[
            Stores the top `len` elements from the stack into the field with the given ID `field_id` from the given type `type_id`. If it is a tuple, expands the tuple into `len` values on the stack. Pops the instance of the type from the stack.
        ],

        ```typc
new[
    <type_id>,
    <variant_id>,
],
        ```,
        ```
[
    a0,
    a1,
    ...
] → [ instance ]
        ```,
        align(horizon)[
            Creates a new instance of the variant `variant_id` of given type `type_id`, and pushes it onto the stack. The arguments are obtained from the type definition, and then popped from the stack. For structs, the `variant_id` are ignored.
        ],

        ```typc
branch[
    <false_offset>
]
        ```,
        ```
[
    a0,
] → []
        ```,
        align(horizon)[
            Takes the top value from the stack, if it is `false`, then jumps to the given offset. Otherwise, continues execution at the next instruction.
        ],

        ```typc
flag[ <flag> ],
        ```,
        ```
        [] → []
        ```,
        align(horizon)[
            Gets the given flag, and pushes it onto the stack as a boolean value. The flags are produced by the previous operation. The valid flags are `overflow`, `underflow`, `div_by_zero`, `invalid`, `inexact`, `unimplemented`, `unreachable`. Used for branching.
        ],

        ```typc
unary[
    <op>
]
        ```,
        ```
[ a0, ] → [ a1 ]
        ```,
        align(horizon)[
            Takes the top value from the stack, applies the given unary operator `op` to it, and pushes the result onto the stack. The valid unary operations are numerical negation (`-`), logical negation (`!`), and bitwise negation (`~`).
        ],

        ```typc
binary[
    <op>
]
        ```,
        ```
[ a0, a1 ] → [ a2 ]
        ```,
        align(horizon)[
            Takes the top two values from the stack, applies the given binary operator `op` to them, and pushes the result onto the stack. The valid binary operations are addition (`+`), subtraction (`-`), multiplication (`*`), division (`/`), modulo (`%`), exponentiation (`**`), bitwise and (`&`), bitwise or (`|`), bitwise xor (`^`), bitwise left shift (`<<`), bitwise right shift (`>>`), equality (`==`), inequality (`!=`), less than (`<`), less than or equal (`<=`), greater than (`>`), greater than or equal (`>=`), logical and (`&&`), and logical or (`||`).
        ],

        ```typc
cast[
    <type_id>
]
        ```,
        ```
[ a0, ] → [ a1 ]
        ```,
        align(horizon)[
            Takes the top value from the stack, cast it to the given type `type_id`, and pushes the result onto the stack. The valid conversions are `int`, `uint`, `float`, `bool`, `string`, `char`, and `complex`. Only primitive values may be converted in this way.
        ],

        ```typc
insert[]
        ```,
        ```
[
    value,
    offset,
    len
] -> [ ... ]
        ```,
        align(horizon)[
            Inserts the given `value` into the stack at the given `offset`, `len` times. This allows the insertion of values into the middle of the stack, as well as interspersing values into the stack. In the cast of the stack `[a0, a1, a2, "hello", 1, 3]`, calling `insert` will result in the stack `[a0, "hello", a1, "hello", a2, "hello"]`.
        ],

        ```typc
intrinsic[
    <intr>
]     
        ```,
        ```
[ a0, a1, ... ] → [ a2, a3, ... ]
        ```,

        align(horizon)[
            Execute the given photonic intrinsic operation `intr`, see @sec_intrinsic_operations, based on the intrinsic value, pops the arguments from the stack, and pushes the result onto the stack.
        ],

        ```typc
constraint[
    <constr>
]
        ```,
        ```
[ 
    signal,
    a0,
    a1,
    ...
] → [ ]
        ```,
        align(horizon)[
            Applies the given photonic constraint `constr`, see @sec_constraints, based on the constraint value, pops the arguments from the stack, and pushes the result onto the `signal`.
        ],
    )
] <tbl_instruction_set>


=== Compiler complexity <sec_comp_complexity>

As one can see from the previous sections, the @phos compiler is more complex than one might expect. However, there are good reasons why the compiler is so complex, a lot of the features that have been discussed in @sec_intent and in this chapter are rather difficult to implement. They require a lot of modern features and tight coupling with provers for constraints and intrinsics. These tasks are not easy in isolation, but when they are combined, they become even more difficult to implement. When taking this into account, the complexity of the compiler is not that surprising. Essentially, the compiler simplifies the code as much as reasonably possible, such that the resulting bytecode is easy to interpret and execute, easy to collect stacks for tunable values, and such that it is easy to process using a prover. Additionally, this complexity makes the compiler modular, which allows for easy extension and rework of the language, something that will need to be done as the language evolves.

#info-box(kind: "conclusion")[
    The @phos compiler translates source code into a bytecode format used by the @vm for evaluation. It first turns the code into a computer-understandable representation called the @ast. Then the @ast goes through three transformation stage. Called the @hir, the @mir, and finally the bytecode.
]

#pagebreak(weak: true)
== The virtual machine <sec_vm>

After investigating the components and stages of the compiler, the analysis of the #gloss("vm", long: true) can proceed. Recalling the execution model of @phos, discussed in @sec_exec_model, the role that the @vm fills is the evaluation of the bytecode. Therefore, the behaviour of the virtual machine is discussed, including how the @vm works, how it uses a stack for computation, and how it executes the bytecode. Additionally, the section discusses the result of the evaluation, namely, the tree of intrinsic operations, collected stacks, and constraints. However,  the suitability of existing virtual machines must also be discussed, as it is important to understand why an existing virtual machine was not used.

=== Why not use an existing VM? <sec_existing_vm>

One may wonder why @phos does not use an existing virtual machine and requires a custom built one. The reason for this is that existing @vm[s] are not suitable for the semantics and execution model of @phos. This can be explained by looking at the artefacts produced by the execution process, previously shown in @fig_exec_model, it must produce three components, all of which would be hard, if not impossible, to properly extract and process within an existing implementation.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Stack collection*]
}
One of the key functions of the virtual machine is to detect which parts of the code cannot be evaluated based on tunable values, as was discussed in @sec_tunability_reconfigurability, and collect them to be included in the user @hal. This requires tight integration in the @vm, as it must support doing partial computation and collect all of the instructions it cannot execute. This is not a feature that is supported by any existing @vm that was investigated, and it would be difficult to implement in an existing @vm.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constraints and intrinsic*]
}
Another feature of the @phos @vm is the ability to collect constraints and intrinsic operations and to produce a tree of these values, representing the signal flow of the circuit. While this can be implemented in a traditional language, it would require an extensive library to be included along with the bytecode, which would make the bytecode harder to generate. Additionally, this means that these operations would no longer be expressed as dedicated bytecode instructions, but rather as regular function calls, tightly coupling the aforementioned library and the bytecode, greatly increasing the burden of maintenance and development of the language.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Simplicity*]
}
Existing @vm[s] often support many features that are simply not needed for @phos, such as object oriented programming, or memory recollection schemes like garbage collection. @phos is not a general purpose language, and as such, can work with a limited set of features. This means that the complexity of the @vm can be significantly reduced to only contain the elements relevant to @phos. This can help improve performance, and reduce the size of the @vm, making it easier to distribute to users.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Licensing*]
}
Finally, existing @vm[s] may be subject to licenses, while intellectual property has not been discussed in this document, it is important to be aware of issues that can arise when using other people's code, or more generally, intellectual property. Therefore, if the @vm is written from scratch, it can be licensed in a way that is compatible with the @phos license, whichever that may be.

=== Stack-based architecture <sec_stack_based>

#info-box(kind: "definition", footer: [ Adapted from @cormen_introduction_2009. ])[
    A *stack* is a data structure that follows the last-in-first-out (LIFO) principle. This means that the last element that was added to the stack is the first one to be removed. Stacks usually only implement two operations: `pop` to remove the last element, and `push` to add an element to the top of the stack.
]

So far, the mention of the _stack_ has been made several times, however, no clear definition had been provided. This definition, along with the reasoning behind the choice of a stack-based architecture, is discussed in this section. The stack, is a data structure that holds the values required during the evaluation of a given block of code. The stack is used to store all intermediary values needed for computation, when a new value is needed, it is pushed onto the stack, and when a bytecode instruction is executed, full list in @sec_mir_to_bytecode, the instruction pops the elements that it needs from the stack, processes them, and once it is done, it pushes all of the output values to the stack again. Later on in this section, an example is provided showing the execution of a simple function.

The stack is convenient, because it can be very effectively implemented, it is a common data structure that is easy to implement and very fast. Additionally, it means that all short-lived values are stored inline, and do not require any additional memory allocation. This is important, as it means that the @vm does not need to implement a garbage collector, which would be a significant burden on the development of the @vm. Furthermore, the stack also plays very nicely with the automatic memory management scheme used by _Rust_ -- the language in which @phos will be implemented -- as it allows values that are removed from the stack and no longer used to be automatically discarded, further simplifying the implementation of the @vm.

One of the special aspects of the @phos @vm, that one may notice from the list of instructions in @sec_mir_to_bytecode, is that arrays of values in @phos are all pushed to the stack, and that @phos allows for quite complex operations on the stack. The reasoning behind this decision is to make the @vm very powerful and to be able to express complex operations in relatively few instructions. This allows the work of the user @hal generator, discussed in @sec_hal, to be even easier. It also means that fewer instructions must be provided to the prover for branch elimination and constraint checking, and therefore the interface between the prover and the @vm will be easier to create.

=== Signals, constraints, and intrinsics

As previously mentioned, one of the tasks of the @vm is to collect the different intrinsic operations and their constraints, in order to build a tree representing the signal processing. This is done through the `intrinsic` and `constraint` instructions. These special instructions take signals and arguments and instead of only pushing results to the stack, they also can internally add information to a global tree of signals. This is done transparently from the user, and is how the @vm can perform store these signals. In @lst_tree_ex, one can see a simple program splitting, filtering and then adding gain to a signal, then in @fig_tree_ex, one can see the signal processing tree with the added constraints. In cases where reconfigurability would also be present, collected stacks would also be appended to a special reconfigurability node, which would be used to differentiate the different configurations of the circuit.

#block(breakable: false)[
#table(
    columns: 2,
    stroke: none,
    [
        #figurex(
            caption: [
                Code example in @phos, showing a simple photonic circuit splitting a signal, then filtering both signals, and finally adding gain to one of the signals.
            ],
            title: [ Code example in @phos, showing the signal processing tree. ],
            kind: raw
        )[
            ```phos
// Returns the sum of all inputs,
// also returns true if the sum is even
syn process(
    input: optional
) -> (optical, optical) {
    input |> split((0.5, 0.5))
        |> map(filter(1550 nm, 10 GHz))
        |> (_, gain(10 dB))
}
            ```
        ] <lst_tree_ex>
    ],
    [
        #figurex(
            caption: [
                Signal flow diagram of @lst_tree_ex, showing the splitting of the input signal, followed by the filtering of both signals, and finally the gain of one of the signals. The green boxes represent the intrinsic operations, the blue boxes represent the constraints, the arrows represents the flow of the signal.
            ],
            title: [ Signal flow diagram of @lst_tree_ex. ],
            kind: image
        )[
            #image(
                "../figures/drawio/signal_proc.png",
                alt: "Shows a tree of signals, at the top is input, followed by splitter, the first branch shows a filter with a wavelength constraint, and the second branch shows a filter with a wavelength constraint followed by a gain"
            )
        ]<fig_tree_ex>
    ],
)
]

=== Example of bytecode execution <sec_ex_bytecode_exec>

In this section, a simple example of code will be shown, along with its resulting bytecode. The code is shown in @lst_bytecode_example (a) and the resulting bytecode is shown in @lst_bytecode_example (b). The function being compiled is a simple accumulating sum that also computes whether the sum is even or not. In (b), one can see the bytecode is containing a total of $22$ instructions. The instructions would be purely binary values, however, they are shown as text for convenience and readability. One can see that the two closures at line $5$ and $6$ where respectively turned into two anonymous functions called `__anonym_0` and `__anonym_1`, normally these would have numeric IDs instead of names, but names are provided for clarity. This code uses the `load`, `pop`, `binary`, `return`, `repeat`, `const` and `call_fn` instructions, which can all be found in the previously shown @tbl_instruction_set.

An example of execution and the state of the stack will now be shown, the function `sum` will be called with the iterable tuple `(1, 2, 3, 4, 5)`. The execution diagram of the `sum` function can be seen in @anx_bytecode_execution, in @fig_annex_execution. It shows the stack after each step of the execution of the function. It also gives symbolic meaning to the values, showing integers as `int(x)`, length as `len(x)`, and functions as `fn(x)`. From this figure, one can see that the `load` instruction pushes all of the values of argument `inputs` onto the stack, followed by the length of the argument $5$ in this case. Then, when constants are pushed, the whole stack moves up and the new value is added. When calling functions, the whole stack is consumed and the result is pushed onto the stack. The `pop` instruction is used to remove the top value from the stack, and the `return` instruction is used to return the top values from the stack. Additionally, one can see that the `const[ 1 ]` being performed is used to add the length of the argument before calling `map`, this is because map expects an iterable tuple as an input, and produces an iterable tuple. The result of this execution is then returned, with the tuple `(15, true)`.

#block(breakable: false)[
#figurex(
    caption: [
        Code example in @phos, showing the original code (a), and the bytecode after compilation (b).
        
        The bytecode would normally be, as the name implies, binary, however here it is shown in a textual format for clarity.
    ],
    title: [ Code example in @phos, showing original code and resulting bytecode. ],
    kind: raw
)[
    #table(
        columns: 2,
        stroke: none,
        ```phos
// Returns the sum of all inputs,
// also returns true if the sum is even
fn sum(inputs: (int...)) -> (int, bool) {
    inputs
        |> fold(0, |acc, x| acc + x)
        |> map(|x| (x, x % 2 == 0))
}
        ```,
        ```typc
fn @__anonym_0(@0: int, @1: int) -> int:
  load[ @0 ]   pop[ 1 ]
  load[ @1 ]   pop[ 1 ]
  binary[ + ] return[] 

fn @__anonym_1(@0: int) -> (int, bool):
  load[ @0 ]    pop[ 1 ]
  repeat[1, 1]  const[ 2 ]
  binary[ % ]   const[ 0 ]
  binary[ =​= ]  return[]

fn @sum(@0: (int...)) -> (int, bool):
  load[ @0 ]           const[ 0 ]
  const[ @__anonym_0 ] call_fn[ @fold ]
  const[ 1 ]           const[ @__anonym_1 ]
  call_fn[ @map ]      pop[ 1 ]
  return[]
        ```,
        [ (a) ],
        [ (b) ],
    )
] <lst_bytecode_example>
]

=== Partial evaluation <sec_partial_eval>

#info-box(kind: "definition", footer: [ Adapted from @jones_partial_1993 ])[
    *Partial evaluation* is a technique for specializing a program with respect to some of its arguments. The result is a new program that only requires the remaining arguments to run. The new program is generally smaller.
]

It has been shown that the @vm executes bytecode, however, one may wonder how the @vm handles tunable values. The answer is that the @vm will use _partial evaluation_. Meaning that the @vm will collect the code impacted by the tunable values, and will try and evaluate as much of the code as possible, while leaving the code it cannot evaluate as is. This means that the @vm will produce a new program that performs the same functionality as the user's original program, but specialized based on the static inputs, needing only the tunable values as inputs for it to be complete.

Additionally, it will still analyze the intrinsic operations -- impacted by tunability -- that are present within the user's design, and collect them separately such that they can still be synthesized. These operations, also depend on tunable values, but using the constraints on those tunable values, if any, the compiler will still be capable, in most cases, of synthesizing them into a photonic mesh. This will allow the @vm to produce a special subtree of the signal flow tree, that represents tunable sections, along with their intrinsic operations and constraints, but requiring tunable values for finalization.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Tunability failures*]
}
In some cases, if tunable values are not sufficiently constrained, the synthesis of these components may fail. In such cases, the user will be invited to provide more constraints, such that the synthesizer can produce the photonic mesh for the given intrinsic operation. If however, the user were not to be able to provide these additional constraint, they would need to rework their design to either avoid the use of broad range tunable values, or to be able to provide the additional constraints. Therefore, one may understand tunable values as a tool to help the user tune their photonic circuit, but not as a tool for broad range reconfiguration.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Broad-range reconfiguration*]
}
As previously mentioned, if tunability has failed, the user must be able to constrain their tunability values more, in some cases, this may prove difficult. However, @phos also provides the ability of creating reconfigurability regions, which are regions of the photonic circuit that can be reconfigured. The way in which the user may be able to constrain their tunable values, is by using reconfigurability regions. If they can partially constrain their tunable values, such that it can be used for reconfigurability, in addition to tunability, then the synthesizer will be able to produce a photonic mesh for their design.

Looking at @lst_broad_ex, in (a), one can see a circuit that relies on broad-range reconfigurability if parameter `gain` is not constrained, and the platform only supports a short gain in the range $[0"dB"..5"dB"]$, or a long gain in the range $]5"dB", 10"dB"]$, the synthesizer will fail to make the circuit. However, if the user were to constrain the `gain` in the range supported by the platform then match on the gain to create either a `short_gain` section or a `long_gain` section, the code would be synthesizable, this second case is shown in (b).

However, when looking at this code (b), one might think that it is much longer than the original code (a), however, most of this complexity would actually be contained within the standard library, and the user would only need to add the `range` constraint on their gain to match their platform's capabilities.

#figurex(
    caption: [
        Code example in @phos, showing the original unsynthesizable code (a), and the fixed code (b)
    ],
    kind: raw
)[
    #table(
        columns: 2,
        stroke: none,
        ```phos
syn my_module(
    input: signal,
    the_gain: Gain
) -> signal {
    input |> gain(the_gain)
}
        ```,
        ```phos 
syn my_module(
    input: signal,
    @range(0 dB ..= 10 dB)
    the_gain: Gain
) -> signal {
    match the_gain {
        0 dB..=5 dB => input
            |> short_gain(the_gain),
        5 dB..=10 dB => input
            |> long_gain(the_gain),
    }
}
        ```,
        [ (a) ],
        [ (b) ],
    )
] <lst_broad_ex>

== Synthesis <sec_synthesis>

Now that the first two steps in the overall synthesis of a @phos design, namely compilation and evaluation, have been explained, the last step is to synthesize the design. This step is likely to be the most complex, and a lot of work is still needed both at the design stage, and at the algorithm stage. However, the goal of this section is to explain the general idea behind the synthesis of a @phos design. Therefore, this section can be assumed to be less precise and formal than previous ones, focusing more on overall ideas and concepts, rather than on specific details.

The core goal of the synthesis stage, is to take the signal flow tree produced by the @vm and turn it into two things: the user @hal that the user can use to interact with their design, and the binary programming files used by the actual hardware. These two goals are very different, and by far the simplest is the generation of the user @hal. The generation of the binary programming files, require processing all of the constraints and all of the intrinsics into gate descriptions, followed by placing them on the chip and routing between them. This is a problem that is already incredibly difficult for traditional @fpga[s] to solve, but it exacerbated by, both the two modes that can be supported in waveguides, but also by the recirculating hexagonal nature of the mesh. Therefore, synthesis of a @phos design is incredibly difficult and computationally expensive, and is still an active area of research.

Among the ongoing work that has been happening, including at the @prg, the modelling of the circuit meshes in a graph structure has been done @chen_graph_2020. In @fig_graph_representation, one can see the graph representation of a single photonic gate, as well as a junction in an hexagonal photonic mesh, and in @fig_graph_representation_mesh, one can see a set of gates in a mesh. In their work, Xiangfeng Chen, et al. show that by incorporating relevant metrics in the mesh edges, they can achieve efficient routing in a photonic mesh. This is a very promising result, and can be used as the basis for future research. Indeed, research is already ongoing at Ghent University to further this routing, however they are not yet at the point of incorporating more complex photonic components inside of the mesh @kerchove_adapting_2022. Other work has implemented automatic realization of circuits on photonic meshes, which is closer to what is needed for synthesis, but it is still incomplete @gao_automatic_2022.

#figurex(
    title: [
        Graph representation of a single photonic elements.
    ],
    caption: [
        Graph representation of a single photonic gate (a), and of a complete junction in a photonic mesh (b). Based on the work of Xiangfeng Chen, et al. @chen_graph_2020. (b) is composed of three unit cells shown in (a), showing the direction that light is travelling in, and all of the possible connections.
    ],
    kind: image,
)[
    #table(
        columns: 2,
        stroke: none,
        image("../figures/drawio/graph_representation.png", height: 160pt),
        f(160pt),
        [ (a) ],
        [ (b) ],
    )
] <fig_graph_representation>

=== From intrinsic operations to gates

The first step in synthesizing the circuit, is determining for each intrinsic operation being done in the circuit, what gates are required to implement it. Some intrinsics have one-to-one mapping with photonic gates, such as phase shifters, splitters, and couplers, for these this tasks should be relatively easy. However, other intrinsic operations, such as modulators, detectors, sources are not part of the mesh and are, in fact, components placed on the edges of the mesh. Finally, other intrinsic operations are actually compounded operations, that can result in more than one photonic gate. This means that each type of intrinsic operation, will need to be decomposed into their component photonic gates. Some of them, such as edge devices, do not need to become a specific gate, rather they need to be assigned a location, such that they can be routed to during place-and-route.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Filter synthesis*]
}
Filters are purposefully made into their own intrinsic operation despite being compound components. As was explained in @sec_intrinsic_operations, filters may be optimized based on the platform, for example, some platforms may even have built-in tunable filters placed on the edge. Therefore, the platform is responsible for the synthesis of the filters. As the synthesizer is provided with the input wavelength constraint, and the expected wavelength response, wether it be a bandpass filter, or any other filter, it should be able to synthesize the filter into its component gates. In some cases, it is possible that filter synthesis might fail, in such cases, the synthesizer should produce an error for the user.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Tunability*]
}
At this point, some components may depend on tunable values, nonetheless, the synthesis tool must be capable of handling tunable components. Meaning that it must understand that components are tunable within a certain range, indicated with constraints, and still produce the appropriate gates. This task should generally be relatively similar to regular intrinsic-to-gate translation, assuming that the parts of the standard library implemented for the platform were done correctly. Indeed, the task of separating widely tunable values into smaller tunable ranges, is in parts, the task of the designer, in other parts, the task of the standard library as it is implemented by the chip designer. This means that, at this point in the synthesis pipeline, all tunable intrinsic operations should be synthesizable. If they are not, then the platform support package would be to blame, since it would mean that its implementation of the standard library is invalid.

=== Place-and-route <sec_place_and_route>

As was previously discussed, there are currently no algorithms that can place and route all of the components that can be present in a mesh. Since @phos provides the constraints on each signals to the place-and-route engine, it is expected that it will utilize those constraints to improve its placement and routing. Furthermore, the place-and-route algorithm will be provided by optimization targets by the user, these targets should be an indication of what matters most for the user: the area that a given circuit occupies, the power consumed by the circuit, or the optical losses in the circuits. Additionally, in some cases, the user may want to create their own metric for further customization. Finally, despite there being no place-and-route algorithm, there are a number of routing algorithms that are being developed, including at Ghent University, which are showing promising results @kerchove_automated_2023. Once routing has been improved, these algorithms may be able to be included in place-and-route implementations.
 
=== Hardware abstraction library <sec_hal>

Another task of the synthesizer is to generate the user @hal. To do this, it will use pre-made routine, that have yet to be designed, coupled with the platform support package, which will provide information with regards to interconnecting the generated, high-level user @hal and the low level core @hal provided my the chip designer. This task is expected to be relatively simple, as it is mostly a matter of connecting the dots between the two @hal. Additionally, the user @hal would be generated in _Rust_, in a way that is compatible with #gloss("ffi", long: true) for interoperability with _C_ and _C++_.

#info-box(kind: "conclusion")[
    At this point, little is known about the exact way that the synthesizer will work, however, this section has hopefully provided pointers that may be used in future research for the implementation of this stage.
]

== Constraint solver and provers <sec_constraint_solver>

In the previous sections, the mention of the constraint solver and of the user of prover has been discussed extensively. However, the exact way in which these tools will be used has not been discussed. This section will attempt to provide a brief overview of the way that these tools will be used. First, the constraint solver will be discussed, followed by the prover.

=== Constraint solver

The constraint solver is a software that can, given a set of intrinsic operations and constraints, solve the state of a signal at any point in the signal chain. It does this in one of two modes: in frequency domain analysis, it will only look at a subset of relevant intrinsic, and compute the spectrum at each step of the signal chain. In time domain analysis, it will process complex amplitude signals modulated onto carrier wavelength, and at each time $t$, it will process the effect that each constraint has on the signal.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Limitations of frequency domain analysis*]
}
In frequency domain mode, the constraint solver must have the values of all tunable values set before it starts executing. This is because, for proper frequency domain analysis, the system must be time invariant, meaning that it must be in steady state. While it is possible, assuming slow varying tunable values, to perform frequency domain analysis, it is currently not planned, and the constraint solver is not yet designed with this in mind.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Co-simulation*]
}
Through the marshalling layers, which will be discussed in @sec_marshalling, the constraint solver will be able to communicate with user code, in order to co-simulate both the user's software, and the user's photonic design. This will allow the user to test their design programmatically rather than manually. This will also allow the user to simulate tunability and reconfigurability.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Simulating tunability*]
}
The constraint solver is capable of simulating tunability in the time domain, by updating the signal flow graph based on the tunable values, it can easily reflect any changes in the tunable values. This can be leverage, in combination with co-simulation, to test whether the user's feedback loops work as intended. Allowing simulation and verification of the overall design, rather than just parts of it. All of the values that might still need to be computed, can be done using the @vm, since the @vm produces a partially evaluated bytecode, the constraint solver only needs to provide the @vm with the values of the tunable values to obtain the signal flow graph.

=== Prover

#info-box(kind: "definition", footer: [ Adapted from @z3prover. ])[
    *#gloss("smt", short: true) problems* are decision problems of logical formulas with respect to combinations of background theories. This means that it verifies whether mathematical formulas are satisfiable.
]

Theorem provers like _Z3_ are called @smt provers, they can be provided with set of theories and rules and verify whether they are satisfied @z3prover. Provers like _Z3_ are especially well suited for program verification, which is the area of interest in this thesis. In the case of @phos, the prover is expected to be used for multiple areas: verifying constraint compatibility, verifying that tunable code respects constraints, verifying exhaustiveness of pattern matches, and determining which reconfigurability branches are reachable. In the following sections, each of these use cases will be discussed.

#info-box(kind: "note")[
    The features discussed in this section are all complex, and while they may appear simple on the surface, translating them into @smt[s] is a complex task, and will require further research.
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constraint compatibility*]
}
A prover can relatively express, the mathematic relations between constraints, this means that a prover like _Z3_ can be used to check whether two constraints are compatible with one another. This would be used as part of the compilation and evaluation processes.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Tunable code*]
}
Tunable code is turned into a partially evaluated program, as discussed in @sec_partial_eval, these programs can be fed into a prover, which can verify whether the program, irrespective of its inputs, respects the constraints that were provided to it. This would be used as part of the evaluation process.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Exhaustiveness*]
}
As was discussed, when presented with constraints, it is very difficult for the compiler to verify exhaustiveness, however, a prover can be used to verify whether a pattern matching expression is exhaustive given a set of constraints. This would be used as part of the compilation process.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Reachability*]
}
The evaluation stage, when encountering tunability, may have more reconfigurability states that needed given the current constraints, just like with exhaustiveness checking, a prover can be used to verify whether branches are even reachable, if they are not, then they can safely be discarded, and the synthesizer will have less work to perform.

== Marshalling library <sec_marshalling>

Now that all of the synthesis steps of the @phos programming language have been discussed, one must now focus on interoperating all of these components. As well as how @phos can leverage existing software. This section will discuss the marshalling library, which is the component that will be used to interconnect all of the elements of the @phos ecosystem.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*What's in a name?*]
}
Marshalling is a term used in Computer Science to describe the transforming of representation of objects into formats suitable for transmission @marshalling_cs. Indeed, in the case of @phos, the marshalling library will be used to move data around between the different step, but also be used to allow the user to configure each step in the synthesis chain to their requirements. In that way, it performs both the traditional marshalling role -- that of assembling and arranging @marshalling -- but also the Computer Science term of transforming and moving data. Therefore, the goal of the marshalling library is to facilitate moving the data around the different pieces of the @phos ecosystem in a programmatic way. Thinking back to the ecosystem analysis performed in @sec_programming_photonic_processors, this is a replacement to the build tools and the compiler. Offering ways for the user to programmatically and dynamically configure the different steps of the synthesis chain.

#figurex(
    title: [ Overview of the marshalling library. ],
    caption: [
        Overview of the marshalling library, it shows all of the different components of the synthesis toolchain of @phos, and how they are interconnected using the marshalling library. Additionally, it also shows the simulation stage, which would couple user simulation code with the simulator. Below the marshalling library are all of the common components that do no belong to one particular stage of the synthesis toolchain.

        The color scheme used in the same as the one used in @fig_responsibilities: blue represents the responsibility of the chip designer, orange the responsibility of the ecosystem developer, green the responsibility of the user, and purple are external tools.
    ]
)[
    #image(
        "../figures/drawio/programming.png",
        width: 100%,
        alt: "Shows the different components of the ecosystem, including the simulation, all interconnected using the marshalling library."
    )
] <fig_marshalling>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Overview*]
}
In @fig_marshalling, one can see the overview of the entire toolchain proposed in this thesis, it shows all of the different components that have been discussed so far, all interconnected using the marshalling library. It shows that all components are interconnected through this library, and that the marshalling library is the only component that is aware of all of the other components. Additionally, the marshalling library provides all of the data required by a given component to perform its task, this means that the user should easily be able to intercept the data, and modify it to their needs. This is the primary advantage of the marshalling library: providing an easy way of communicating, configuring, and tuning the synthesis process.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Choice of language*]
}
During the discussion on ecosystems, in @sec_programming_photonic_processors, _Python_ was shown to be a good candidate as a language to create libraries in, and as such, _Python_ is a good candidate for writing the marshalling library in. As the marshalling library is not a performance critical section, nor expected to be particularly complex, it can be written in _Python_ such that the user can easily script the synthesis toolchain, using a common academic language.

#pagebreak(weak: true)
=== Example <sec_modularity>

#info-box(kind: "info")[
    The marshalling library does not exist yet, therefore this example is a mockup of what the final library may look like, and how it may be used.
]

Due to its length, the code of this example is shown in @anx_marshalling_library_example, where the @phos code being simulated is shown in @lst_marshalling_phos, the code to build the modulate into a programmable form is in @lst_marshalling_comp, and the code to simulate the modulator is in @lst_marshalling_sim. In this example, a simple @phos circuit is being built, it consists of a splitter of which one of its outputs is modulated by a @prbs 12-bit sequence. In @fig_marshalling_sim, one can see the result of the simulation code, showing the modulate output in blue, and the unmodulated output in orange. One can see that the noise source is applied to both signals, but that the modulated signal is modulated by the @prbs sequence. Additionally, the circuit can be seen in @fig_marshalling_circ, showing the generated mesh on a rather large chip, showing the ports, the modulator, and the splitter. On that figure, one can also see that the place-and-route engine may utilize the two modes of the waveguides to perform more efficient routing. In practice, when looking @fig_marshalling_circ, one may notice that the losses experienced by the modulated signals, which should be significantly higher, are not modeled in the simulation shown.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Synthesis*]
}
One can see in @lst_marshalling_comp, that the user starts by importing the marshalling library `phos` (line $#2$), and their device support package `prg_device` (line $#5$) -- a fictitious device from the @prg. A device instant is then created from the `phos` library and the device support package (line $#8$). From this, the module can be loaded from its `phos` file. Moving on to the creation of the inputs and outputs (I/O) of the device (lines $#14-#17$), the electrical input is created, with its device-specific identifier being $0$. Then, each of the three optical ports are created, depending on whether they are used as inputs, outputs, their remaining port is discarded. Here as well, the device-specific ID is being used. The reason why device-specific IDs are being used is to assign the ports of the device to the logical ports of the module. Then, the module is instantiated, given a name, and all of its inputs and outputs are assigned. It can then finally be synthesized. In a real design, one would likely specify more parameters and more than one module, indeed, the marshalling library can be used to compose modules together, and to synthesize more than one module. In this example, the synthesis stage has only one parameter set, the optimization of the design set to area optimization. Finally, from the synthesized design, the user @hal and programming files cna be generated.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Simulation*]
}
This example shows that a @prbs sequence is generated in a _Numpy_ array, it shows one of the core goals of the marshalling library: broad compatibility with the existing _Python_ ecosystem. A simulator is then created from the device, a noise source and a laser source are created, from which the design can be simulated using the previously instantiated module. This runs the simulation, and the result can be plotted using libraries such as _Matplotlib_, giving the result seen in @fig_marshalling_sim.

#figurex(
    title: [ Simulation results of the marshalling layer example.],
    caption: [ Simulation results of the marshalling layer example, showing the output of the modulator, and the output directly from the splitter. The output of the modulator is the same as the output of the splitter, but with the PRBS sequence modulated onto it. ]
)[
    #image(
        "../figures/simu_marshalling_ex.svg",
        width: 100%,
        alt: ""
    )
] <fig_marshalling_sim>

#info-box(kind: "conclusion")[
    The marshalling library aims at provide an easy to use, productive interface for configuring, synthesizing, and simulating @phos circuits. Through the use of a _Python_ @api, it makes it easy for people with relatively little programming knowledge to get started. Finally, its ability to reuse existing libraries from the _Python_ ecosystem makes it easy to integrate into *existing workflows*.
]