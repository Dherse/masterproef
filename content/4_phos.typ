#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *
#import "../elems/tablex.typ": *

= The PHÔS programming language <sec_phos>

Based on all of the information that has been presented so far regarding translation of intent and requirements (@sec_intent), programming paradigms (@sec_paradigms), and with the inadequacies of existing languages (@sec_language_summary), it is now apparent that it may be interesting to create a new language which would benefit from dedicated semantics, syntax, and integrates elements from fitting programming paradigms for the programming of photonic processors. This language should be designed in such a way that it is able to easily and clearly express the intent of the circuit designer, while also being able to translate this code into a programmable format for the hardware. Additionally, this language should be similar enough to languages that are common within the scientific community such that it is easy to learn for engineers, and leverage existing tools. Finally, this language should be created in such a way that it provides both the level of control needed for circuit design, and the level of abstraction needed to clearly express complex ideas. Indeed, the language that is presented in this thesis, @phos, is designed to fulfill these goals.

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
@phos is an imperative language with functional elements.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constraints*]
}

== PHÔS: an initial specification <sec_spec>

This section serves as an initial specification or reference to the @phos programming language. It contains the elements and semantics that have already been well defined and are unlikely to change. Therefore, this section is not a complete specification as that would require that the language be more mature, however it serves as an in-depth introduction into the concepts, paradigms, and semantics of the language. Most parts of the specification are companied by a short example to illustrate the syntax and the semantics of the language. Additionally, some elements are further explored in subsequent section of this chapter, with only the basics being presented here.

=== Execution model <sec_exec_model>

@phos is a photonic hardware description language, due to its unique requirements, it is not designed in a traditional way and instead separates the compilation to hardware into three distinct steps: compilation, evaluation, and synthesis. The compilation step is responsible for taking the source code, written in human-readable text, and turning it into an executable form called the bytecode, see @sec_mir_to_bytecode. Followed by the evaluation, the evaluation interprets the bytecode, performs several tasks discussed in @sec_vm, and produces a tree of intrinsic operations, constraints and collected stacks. This tree is then synthesized into the output artefacts of the language, namely, the user @hal and a programming file for programming the photonic processor. The execution model is shown graphically in @fig_exec_model, showing all of the major components of the language and how they interact with each other. Further on, more details will be added as more components are discussed.

#figurex(
    title: [ Execution model of the @phos programming language ],
    caption: [
        Execution model of the @phos programming language, showing the three distinct stages: compilation, evaluation and synthesis. The compilation stage takes the user's source code along with the source code of the standard library, the platform support package -- that contains device-specific constraints and component implementations -- and produces bytecode. The evaluation stage takes the bytecode and produces a tree of intrinsic operations, constraints on those operations, and collected stacks. The evaluation uses the constraints solver and the _Z3_ prover to check for constraint satisfiability @z3. Finally, the synthesis stage takes the output of the evaluation stage, along with the @hal generator for the platform and the place-and-route implementation to produce the user @hal and the programming file for the photonic processor.

        This figure uses the same color scheme as @fig_responsibilities, showing the ecosystem components in orange, the user's code in green, the platform specific code in blue, and the third party code in purple.
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

=== Signal types and semantics

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
} Electrical signals do not allow any operations on them apart from being used in `modulate` and `demodulate` intrinsic operators. The reasoning behind this limitation is that, as present, there are no plans for analog processing in the electrical domain. Therefore, electrical signals are only ever used to modulate optical signals, or are produced as the result of demodulating optical signals. It is possible that, in the future, some analog processing features may be added, such as gain, but as it is currently not planned, electrical signals are not allowed to be used in any other way. Electrical signals follow the same semantics as optical signals: _drive-once_, _read-one_.


=== Primitive types and primitive values

@phos aims at providing primitive types that are useful for the domain of optical signal processing. As such, it provides a limited set of primitive types, not all of which are synthesizable. To understand how primitive types are synthesizable, see @sec_stack_collection. In @tab_primitive_types, the primitive types are listed, along with a short description. Primitive types are all denoted by their lowercase identifiers, this is a convention to make a distinction between composite types and primitive types. These primitive types are very similar to those found in other high-level programming languages such as _Python_ @python_reference.

#figurex(
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

#info-box(kind: "definition", footer : [ Adapter from @algebraic_data_type ])[
    *#gloss("adt", long: true)* is a type composed of other types, there exists two categories of @adt: *sum types* and *product types*. Product types are commonly tuples and structures. Sum types are usually enums, also referred to as *tagged unions*.
]

@phos has the ability of expressing @adt in the forms of enums, enums are enumeration of $n$ variants, each variant can be one of three types: a unit variant, that does not contain any other data, a tuple variant, that contains $m$ values of different types, or a struct variant that also contains $m$ values of different types, but supports named fields. Enums are defined using the `enum` keyword followed by an identifier and the list of variants. In @lst_ex_enum, one can see an example of an enum definition, showing the syntax for the creation of such an enum. Enums are a sum type, as they are a collection of variants, each variant being a product type. Enums are a very powerful tool for expressing @adt, and are used extensively in @phos and languages that support sum types.

#block(breakable: false)[
    #figurex(caption: [ Example in @phos of an @adt type, showing all three variant kinds: `A` a unit variant, `B` a tuple variant, and `C` a struct variant.  ])[
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

#info-box(kind: "definition", footer: [ Adapter from @aggregate_type ])[
    *Composite types* are types that are composed of other types, whether they be primitive types or other composite types. They are also called *aggregate types* or *structured types*. They are a subset of @adt.
]

Additionally, @phos also supports product types and more generally composite types. Composite types are any type that is made of one or more other type. They can be one of five types: a unit structure, a tuple structure, a record structure with fields, a tuple, and an array of $n$ items of the same type. The syntax of these five types can be see in @lst_ex_composite. This variety in typing allows for precise control of values and their representation. It allows the user to chose the best type for their current situation, such as anonymous tuples for temporary values, or named records for more complex structures.

#block(breakable: false)[
    #figurex(
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
a = 1 mW;
b = 0 dBm;

// 1 degree
c = 1 deg;
d = 0.01745 rad;
e = 1°;

// 1 kilohertz
f = 1 kHz
g = 1e3 Hz
        ```
    ] <lst_ex_units>
]

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Unit semantic*]
}
Instead of implementing a complete unit conversion system, at present, @phos is not intended to support conversion of units of different types, meaning that power is always power and that multiplying a power with time is invalid. To do so would require a complete unit conversion system, which is not planned for @phos. Units are the same regardless of prefixes, which are converted by the compiler into the base, unprefixed, unit before execution begins.


=== Tuples, iterable types, and iterator semantics

Tuples are a kind of product type that links one or more values together within a nameless container. They are often used as output values for functions, as they allow for multiple values to be returned. In @phos, tuples have two different semantics: one the one hand they can be used as storages for values, as in most modern languages, but on the other hand, they can be used as iterable values, which is a feature that is not present in many languages. Rather than having the concept of a list or collection, typst supports unsized tuples. The general form of tuples as container can be seen in @lst_ex_tuple_container.

#block(breakable: false)[
    #figurex(
        caption: [ 
            Example in @phos of tuples as containers.
        ]
    )[
        ```phos
/// A tuple container
a = (a, b, c)

/// A tuple as a type
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
/// A simple unsized tuple
type E = (B...)

/// A more complex unsized tuple
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
for a in (1, 2, 3) {
    print(a)
}
        ```
    ] <lst_ex_iterable_tuple>
]


=== Patterns <sec_patterns>

Patters are used for pattern matching and destructuring, and are a core part of the language. They are used for matching values, tuples, and other types. They are also used to destructure complex values into its constituents. Patterns are used in many statements, such as the `match` statement, the `let` variable assignment statement, the `for` loop statement, and function argument declarations. The general form of pattern can be see in @lst_ex_pattern
.
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


=== Branching and reconfigurability

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

@phos separates functions into three categories: functions denoted by the keyword `fn`, and synthesizable blocks denoted by the keyword `syn`. They are designated in such a way to create clearer separation between the concerns of the user, and to allow the compiler to better separate the different functions of the code. All functions in @phos, regardless of their type, are subject to constraints and the constraint-solver, whether these constraints be expressed on values, or on signals.

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
        caption: [ 
            Example in @phos of a synthesizable block.
        ]
    )[
        ```phos
// Synthesizable block that performs the filtering of an input signal using an MZI
syn filter(in: optical) -> optical {
    a |> split((0.5, 0.5))
      |> constrain(d_phase: 30 deg)
      |> interfere()
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
        Example in @phos of a `Fn` closure (a), a `Syn` closure (b), and a `SynOnce` closure (c).
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
    ```,
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
    It has been discussed that the syntax of constraints should be changed to be declutter function/synthesizable block signatures. This would allow constraints to be cleaner, and would ideally be expressed as its own part of the signature, rather than being defined with the arguments. However, this has not yet been designed, and is therefore not discussed further in this document.
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
    ```,
] <lst_ex_constraint>


=== Unconstrained <sec_unconstrained>

As mentioned in @sec_constraints, constraints only work for non-cyclic constraints, however this limitations removes the advantage of having a recirculating mesh inside of the photonic processor. Therefore, as was previously mentioned, @phos must provide a way to express blocks where the constraints are not automatically inferred, but must be manually specified. This is done by using the `unconstrained` keyword, which allows the user to specify the constraints manually at the boundary of a synthesizable block. An example of an unconstrained block can be seen in @lst_ex_unconstrained.

Additionally, unconstrained block allow the user to create their own signal, without needing to use a source intrinsic. This semantic is useful for creating recirculating elements in the photonic processor, as it allows the user to create temporary variables containing signals.

#figure(
    kind: raw,
    caption: [ 
        Example in @phos of a constrained synthesizable block.
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
    ```,
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
syn gain(in: optical) -> optical {
    a |> std::intrinsic::gain(10 dB)
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
A {a: 1, b: 2} B(1, 2) MyEnum::A C
        ```,
    )
] <tab_exprs>

== Standard library <sec_stdlib>

In addition to the language itself, @phos will come with a standard library: a library of functions and synthesizable blocks that come with the language. The standard library will be written in a mixture of @phos for synthesizable blocks and functions, and some native _Rust_ code for either performance critical sections, or areas where external libraries are required. The standard library will be organized as logically as possible, providing the necessary building blocks for new users to be productive with the language. However, the standard library will be limited in scope such that it does not become a burden to maintain. Relying instead on third-party libraries and @ip[s] for more complex functionality. A notable goal of the standard library is to provide synthesizable blocks for all common functions, like modulators, filters, and so on. But not for more complex functionality like larger components, or even entire systems.

Most intrinsic operations discussed in @sec_intrinsic_operations are more complex than they first appear. As previously mentioned in @sec_programmable_photonics, most photonic components are actually reciprocal, meaning that they are the same whether light is travelling forwards or backwards. Additionally, waveguides support two modes, one in each direction, meaning that each device may be used for two purposes. Removing the user's ability to exploit these properties would be greatly limiting, and as such, the standard library must provide ways of accessing these fully-featured intrinsic operations. However, the user cannot be expected to only program using these low level primitives, Furthermore, as they are mostly unconstrained and would require constrained blocks to be used to their full extent, due to the limitation on constraints regarding cyclic dependencies. Therefore, one of the main goals of the standard library is to provide higher-level primitives that wrap these unconstrained intrinsic operations into constrained block following the feedforward approximation (@feedforward_approx).

The standard library should also decouple synthesizable blocks from computational methods. For example, a filter block may need other functions to compute the coupling coefficient, or the length of a ring resonator. These functions will need to be part of the standard library to offer filter synthesis, but they should be accessible separately, such that if a user wishes to implement some function themselves, they can rely on the existing code present in the standard library to make their work easier. This also means that the standard library should be as modular as possible, perhaps even in the future allowing users to replace default behaviour in the standard library with their own implementations. This modularity also helps in the development of the platform support packages, as these need to be able to support the standard library, something that may be done by replacing parts of the standard library with platform specific implementations, while keeping the exposed @api the same.

Finally, the standard library can serve as a series of examples for new users. A photonic engineer, that is knowledgeable with photonic circuit design would benefit from the standard library as a source of high quality examples onto which they may base themselves. Similarly, a software engineer, that is knowledgeable with software development, but not photonic circuit design, would benefit from the standard library as a source of high quality examples of basic building blocks of photonic circuits. The standard library should be written in a way that is easy to understand, and that is well documented, such that it can serve as a learning resource for new users.

#pagebreak(weak: true)
== Compiler architecture <sec_arch>

The design of the @phos compiler is inspired in parts by @llvm, _Rust_'s compiler, and _Java_'s compiler. As previously mentioned, the compilation of a @phos program into a circuit design that can be programmed onto a photonic processor is a three step process: compilation, evaluation, and synthesis. The compiler as it is referred in this section performs the compilation step. Therefore, as previously mentioned in @sec_exec_model, it has the task for taking the user's code as an input and producing bytecode for the #gloss("vm", long: true). The compiler is written in _Rust_, and is split into several components, each with a specific purpose. As will be discussed in subsequent sections, the @phos compiler is composed of a _lexer_, a _parser_, an _#gloss("ast", long: true)_, a _desugaring_ step, a _high-level intermediary representation_, a _medium-level intermediary representation_, and a _bytecode_ generator.

The compiler is architected in a multi-stage process, where each stage is responsible for a specific set of tasks, this is similar to the design of other compilers, such as the _Rust_ compiler @rust_compiler. Furthermore, each stage corresponds almost perfectly with each of the components of the compiler, as will be discussed in the following sections. This multi-stage process is illustrated in @fig_compiler_arch.

#figurex(
    title: [ Compiler architecture of the @phos programming language ],
    caption: [
        Compiler architecture of the @phos programming language, showing that the user code flows into the different stages of the compiler: lexing, parsing, desugaring, AST-to-HIR, HIR-to-MIR, and bytecode generation. All of these stages producing the bytecode that can be executed by the @vm.

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

Before parsing the language, one must first describe the grammar of the language. There exists many families of grammars as seen in @fig_parser_hierarchy. The more complex the grammar is, the more complex of a parser it will require. It is important to note that @fig_parser_hierarchy describes grammars not languages, languages can be expressed using multiple grammars, and some grammars for a given language can be simpler @cs143. Every grammar can be expressed with a grammar of a higher level, but the reverse is not true.

@phos has an LL(K) grammar, meaning that it can be read from #strong[L]eft-to-right with #strong[L]eftmost derivation, with $k$ token lookahead, meaning that the parser can simply move left to right, only ever applying rules to elements on the left, and needs to look up to $k$ tokens ahead of the current position to know which rule to apply. This is a fairly complex grammar to express and to parse. The parser for @phos is implemented using the _Chumsky_ library (named after _Noam Chomsky_) in _Rust_ @chumsky. _Chumsky_ is a parser combinator generator, meaning that it allows the creation of complex parsers with relatively little code. Because of the properties of _Chunmsky_, the parser for the @phos language is fairly simple 1600 lines of code, and is relatively easy to understand. It is the task of the parser to use the @phos grammar to produce an #gloss("ast", long: true), this tree represents the syntax and groups tokens into meaningful elements.

Additionally, the grammar of @phos contains the priority of operations, meaning that the resulting @ast is already correct with regards to the order of operations, something that otherwise would need to be done using @ast transformations in the next step of the compilation process. This further increases the complexity of the grammar, and the complexity of the parser, but simplifies the next steps of the compilation process.

#figurex(
    title: [ Hierarchy of grammars that can be used to describe a language. ],
    caption: [
        Hierarchy of grammars that can be used to describe a language. The grammars are ordered from the most powerful to the least powerful. The most powerful grammars are able to describe any language, whereas the least powerful grammars are only able to describe a subset of the languages @cs143. As @phos does not use an ambiguous grammar and they are very difficult to describe and parse, they are not discussed further.

        - #smallcaps[*LL*]: #strong[L]eft-to-right, #strong[L]eftmost derivation.
        - #smallcaps[*LR*]: #strong[L]eft-to-right, #strong[R]ightmost derivation.
        - #smallcaps[*SLR*]: #strong[S]imple #strong[L]eft-to-right, #strong[L]eftmost derivation.
        - #smallcaps[*LALR*]: #strong[L]ook#strong[a]head #strong[L]eft-to-right, #strong[L]eftmost derivation.
    ],
)[
    #image(
        "../figures/drawio/parser-hierarchy.png",
        width: 90%,
        alt: "Shows the hierarchy of parser, showing that for unambiguous grammars, the subsets are LR(K), LR(1), LALR(1), SLR(1), LR(0), LL(K), LL(1), LL(0). Ambiguous grammars also exists but they are not discussed further."
    )
] <fig_parser_hierarchy>

=== The abstract syntax tree <sec_ast>

The #gloss("ast", long: true) is the result of the previous compilation step -- parsing -- and it is a tree-like data structure that represents the syntax of the user's code in a meaningful way. It shows the elements as bigger groups than tokens, such as expressions, synthesizable blocks, etc. The @ast is the base data structure on which all subsequent compilation steps are based. The @ast would also used by the @ide to provide code completion, syntax highlighting, and code formatting.

Just as is the case for parsing, syntax trees have a hierarchy, it generally consists of two categories: the #gloss("cst", long: true) and the #gloss("ast", long: true). The @cst aims at being a concrete representation of the grammar, being as faithful as possible, keeping as much information as possible. On the other hand, an @ast only keep the information necessary to perform the compilation, therefore, it is generally simpler and smaller than an equivalent @cst. However, while this can be seen as a hierarchy, it is more of a spectrum, as the @ast can be made more concrete and closer to a @cst depending on the needs. In fact, the @ast of @phos keeps track of all tokens, and their position in the source code, making it possible to reconstruct the original source code from the @ast. The only thing it discards are whitespaces, linebreaks, and comments. Additionally, the @ast of @phos also keeps track of spans where the code comes from, just like in the lexer, it is used to provide better error messages.

Building on top of the example shown in @lst_lexing_ex, the @ast for the function `add` would look like @lst_ast_ex. Additionally, an overview of the data structure required to understand this part of the @ast is shown in @anx_ast_overview.

#figurex(
    title: [
        Partial result of parsing @lst_lexing_ex.
    ],
    caption: [
        Partial result of parsing @lst_lexing_ex, showing the tree-like structure of nested data structures. The @ast is a tree-like data structure that represent the syntax of the user's code. In this case, it shows a function which name is an identifier `add`, and that has two arguments: `a` and `b`, both of type `it`, it has a return type of type `int`, and a body that is a block containing a single expressions, which is a call to the `+` operator, with the arguments `a` and `b`.

        This figure makes abstractions of the aforementioned spans, and only shows the relevant information. It also does some simplification over the actual data structure as these are not relevant to understand the @ast, and are rather lengthy.
    ]
)[
    #image(
        "../figures/drawio/ex_ast_out.png",
        width: 100%,
        alt: "Partial result of parsing @lst_lexing_ex, showing the tree-like structure of nested data structures. The AST is a tree-like data structure that represent the syntax of the user's code. In this case, it shows a function which name is an identifier add, and that has two arguments: a and b, both of type it, it has a return type of type int, and a body that is a block containing a single expressions, which is a call to the + operator, with the arguments a and b."
    )
] <lst_ast_ex>

=== Desugaring

=== AST to high-level intermediary representation <sec_ast_to_hir>

=== HIR to medium-level intermediary representation <sec_mir_to_mir>

=== MIR to bytecode <sec_mir_to_bytecode>

== Virtual machine <sec_vm>

== Execution artefacts <sec_artefacts>

== Marshalling library <sec_marshalling>

=== Moving data around <sec_moving_data>

=== Modularity <sec_modularity>

== Place-and-route <sec_place_and_route>
 
== Hardware abstraction library <sec_hal>

== Constraint solver <sec_constraint_solver>

== Adopting PHÔS <sec_adopting>

== State of the project <sec_state>

Due to the complexity of implementing a software ecosystem, PHÔS is still in its infancy. While some components were created and tested, such as the _parser_, the _abstract syntax tree_, and a _syntax highlighter_, the language is not currently usable. Therefore, the language is a work in progress and the syntax is subject to changes. Additionally, examples serve as a way to illustrate the language and are not necessarily valid.

== Putting it all together