#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/tablex.typ": *

= Programming of photonic processors

The primary objective of this section is to explore the different aspects of programming photonic processors. This section will start by looking at different traditional programming ecosystems and how different languages approach common problems when programming. Then an analysis of the existing software solutions and their limitations will be done. Finally, an analysis of relevant programming paradigms will be done.

The secondary objective of this section is to make the reader familiar with concepts and terminology that will be used in the rest of the thesis. This section will also introduce the reader to different programming paradigms that are relevant for the research at hand, as well as programming language concept and components.

As this section also serves as an introduction to programming language concepts, it is written in a more general way, exploring components of programming ecosystems -- in @sec_components -- before looking at specificities that are relevant for the programming of photonic processors.

== Programming languages as a tool

#info-box(kind: "definition")[
    *Imperativeness* refers to whether the program specifies the expected results of the computation or the steps needed to perform this computation @noauthor_imperative_2020. These differences may be understood as the difference between _what_ and _how_, or what the program should do and how it should do it.
]

Programming languages, in the most traditional sense, are tools used to express _what_ and, depending on its imperativeness and paradigm, _how_ a computer should perform a task. A computer in this context, means any device that is capable of performing sequential operations, such as a processor, a microcontroller or another device.

However, programming languages are not limited to programming computers, but are increasingly used for other tasks. So-called #gloss("dsl", long: true, suffix: [s]) are languages designed for specific purposes that may intersect with traditional computing or describe traditional computing tasks, but can also extend beyond traditional computing. @dsl[s] can be used to program digital devices such as @fpga[s], but also to program and simulate analog system such as @verilog-ams or @spice.

Additionally, programming languages can be used as a tool to build strong abstractions over traditional computing tasks. Such as @sql is a language designed to describe database queries, by describing the _what_ and not the _how_, making it easier to reason about the queries being executed. Other examples include _Typst_, the language used to create this document.

As such, programming languages can be seen, in a more generic way, as tools that can be used to build abstractions over complex systems. And therefore, the ecosystem surrounding a language can be seen as a toolbox providing many amenities to the user of the language. Is it therefore important to understand these components and reason about their importance, relevance and how they can best be used for a photonic processor.

Finally, some languages are designed to describe digital hardware, so-called @rtl #gloss("hdl", long: true, suffix: [s]). These languages are used to describe the hardware in a way that is closer to the actual hardware, and therefore, they are not used to describe the _what_ but the _how_. These languages are not the focus of this thesis, but they are important to understand the context of the research at hand. And they will be further examined in <sec_existing_eco> where they applicability to the research at hand will be discussed.

== Components of a programming ecosystem <sec_components>

An important part of programming any kind of programmable device is the ecosystem that surrounds that device. The most basic ecosystem that is necessary for the use of the device are the following:
- a language specification: whether this language is visual or textual ;
- a compiler or interpreter: to translate the code into a form that can be executed by the device ;
- a hardware programmer or runtime: to physically program and execute the code on the device.

These components are the core elements of any programming ecosystem since they allow the user to translate their code into a form the device can execute. And then to use the device, therefore, without these components, the device is useless. However, these components are not sufficient to create a user-friendly ecosystem. Indeed, the following components are also nice to have:
- a debugger: to aid in the development and debugging of the code;
- a code editor: to write the code, for visual languages, this is key, but for textual languages, it can be an existing editor with support for the language;
- a formatter: to format the code in a consistent way;
- a linter: a tool used to check the code for common mistakes and to enforce a coding style;
- a testing framework: to test and verify the code;
- a simulator: to simulate the execution of the code;
- a package manager: to manage dependencies between different parts of the code;
- a documentation generator: to generate documentation for the code;
- a build system: to easily build the code into a form that can be executed by the device.

This shows that any endeavour to create such an ecosystem is a large undertaking. Such a large undertaking needs to be carefully planned and executed. And to do so, it is important to look at existing ecosystems and analyse them. This section will analyse the ecosystems of the following languages:
- #emph[C]: a low-level language that is mostly used for embedded systems and operating systems;
- #emph[Rust]: a modern systems language mostly used for embedded systems and high performance applications;
- #emph[Python]: a high-level language that is mostly used for scripting and data science;
- #emph[Java]: a high-level language that is mostly used for enterprise applications.

Each of these ecosystems come with a certain set of tools in addition to the aforementioned core components. Some of these languages come with tooling directly built by the maintainers of the languages, while others leave the development of these tools to the community. However, it should be noted, that, in general, tools maintained by the language maintainers directly tend to have a higher quality and broader usage than community-maintained tools.

Additionally, the analysis done in this section will give pointers towards the language choice used in the development of the language that will be presented in @sec_phos, which will be a custom @dsl language for photonic processors. As this language will not be self-hosted -- its compiler will not be written in itself -- it will need to use an existing language to create its ecosystem.

=== Language specification

#info-box(kind: "definition")[
    A *programming language specification* is a document that formally defines a programming language, such that there is an understanding of what programs in that language means @jones_forms_2007.
]

From this definition, one can conclude that, for languages that are expected to have more than one implementation, it is essential to have a strict specification. Indeed, code that is written following this specification should therefore be able to be executed by any implementation of the language. However, this is not always the case, several languages with proprietary implementations, such as #emph[VHDL] and #emph[SystemC] -- two languages used for hardware description of digital electronics -- have issues with vendored versions of the language @Chacko2019CaseSO.

This previous point is particularly interesting for the application at hand: assuming that the goal is to reuse an existing specification for the creation of a new photonic @hdl, then it is important to select a language that has a specification. However, if the design calls for an @api implemented in a given language instead, then it does not matter. Indeed, in the latter case, the specification is the implementation itself.

Additionally, when reusing an existing specification for a different purpose than the intended one, it is important to check that the specification is not too restrictive. Indeed, as has been previously shown in @photonic_processor, the programming of photonic processors is different from the programming of electronic processors. Therefore, special care has to be taken that the specification allows for the expression of the necessary concepts. This is particularly important for languages that are not designed for hardware description, such as #emph[C] and #emph[Python]. 

Given that photonics has a different target application and different semantics, most notably the fact that photonic processors are continuous analog systems -- rather than digital processes -- these languages may lack the needed constructs to express the necessary concepts, they may not be suitable for the development of a photonic @hdl. Given the effort required to modify the specification of an existing language, it may be better to create a new language from dedicated for photonic programming.

Furthermore, the language specification is only an important part of the ecosystem being designed when reusing an existing language. However, if creating a new language or an @api, then the specification is irrelevant. It is however desirable to create a specification when creating a new language, as it can be used a thread guiding development. With the special consideration that a specification is only useful when the language is mature, immature languages change often and may break their own specification. And maintaining a changing specification as the language evolve, may lower the speed at which work may be done. Looking at #emph[Rust], it is widely used despite lacking a formal specification @the_rust_reference.

=== Compiler

#info-box(kind: "definition")[
    A *compiler* is a program that translates code written in a higher level programming language into a lower level programming language or format, so that it can be executed by a computer or programmed onto a device @aho2006compilers.
]

The compiler has an important task, they translate the user's code from a higher level language, which can still remain quite low-level, as in the case of #emph[C], into a low-level representation that can be executed. The type of language used determines the complexity of the compiler, in general, the higher the level of abstraction, the more work the compiler must perform to create executable artefacts.

An alternative to compilers are interpreters which perform this translation on the fly, such is the case for #emph[Python]. However, @hdl[s] tend to produce programming artefacts for the device, a compiler is more appropriate for the task at hand. This therefore means that #emph[Python] is not a suitable language for the development of a photonic @hdl. Or at least, it would require the development of a dedicated compiler for the language.

One of the key aspects of the compiler, excluding the translation itself, is the quality of errors it produces. The easier the errors are to understand and reason about, the easier the user can fix them. Therefore, when designing a compiler, extreme care must be taken to ensure that the errors are as clear as possible. Language like #emph[C++] are notorious for having frustrating errors @becker_compiler_2019, while languages like #emph[Rust] are praised for the quality of their errors. This is an important aspect to consider when designing a language, as it can make or break the user experience. Following guidelines such as the ones in @becker_compiler_2019 can help in the design of a compiler and greatly improve user experience.

==== Components

Compilers vary widely in their implementation, however, they all perform the same basic actions that may be separated into three distinct components:
- the frontend: which parses the code and performs semantic analysis;
- the middle-end: which performs optimisations on the code;
- the backend: which generates the executable artefacts.

The frontend checks whether the program is correct in terms of its usage of the syntax and semantics. It produces errors that should be helpful for the user @becker_compiler_2019. Additionally, in statically typed languages, it performs type checking to ensure that types are correct and operations are valid. In general, such as in the case of #emph[Rust], it is the frontend that produces a simplified, more descriptive, version of the code to be used in further stages @rust_compiler.

The middle-end performs multiple functions, but generally, it performs optimisations on the code. These optimisations can be of various types, and are generally used to improve the performance of the final executable. As will se discussed in @sec_phos, while performance is important, it is not the main focus of the proposed language. Therefore, the middle-end can be simplified.

Finally, the backend, has the task of producing the final executable. This is a complex topic in and off itself, as it requires the generation of code for the target architecture. In the case of #emph[Rust], this is done by the LLVM compiler framework @rust_compiler. However, as with the middle-end, the final solution suggested in this work will not require the generation of traditional executable artefacts. However, some of the tasks that one may group under the backend, such as place-and-route, will still be required and are complex enough to warrant their own research.

=== Hardware-programmer & runtime

#info-box(kind: "definition")[
    The *hardware-programmer* is a tool that allows the user to write their compilation artefacts to the device @czerwinski2013finite. It is generally a piece of software that communicates with the device through a dedicated interface, such as a USB port. Most often, it is provided by the manufacturer of the device.
]

The hardware-programmer is an important part of the ecosystem, as it is required to program the physical hardware. Usually it is also involved in debugging the device, such as with interfaces like @jtag. However, as this may be considered part of the hardware itself, it will not be further discussed in this section. However, it must be considered as the software must be able to communicate with the device.

#info-box(kind: "definition")[
    The *runtime* is a program that runs on the device to provide the base functions of the device, such as initialization, memory management, and other low-level functions @aho2006compilers. It is generally provided by the manufacturer of the device.
]

In the case of a photonic processor, while it may be of interest to think of what the runtime might look like and what functions it must perform for the rest of the ecosystem to work, it is therefore not the focus of this work. The runtime is a device-specific component, and as such, it is not possible to design it as a generic, reusable, component. Therefore, it is mentioned as a necessary component, and will be discussed in further details in @sec_phos but will not be further considered in this section.

In general, the hardware-programmer and the runtime work hand-in-hand to provide the full programmability of the device. As the hardware-programmer is the interface between the user and the device, and the runtime is the interface between the device and the user's code compiled artefacts. Therefore, these two components are what allow the user's code to be, not only executed on the device, but also to have access to the device's resources.

=== Debugger

#info-box(kind: "definition")[
    A *debugger* is a program that allows the user to inspect the state of the program as it is being executed @aho2006compilers. In the case of a hardware debugger, it generally works in conjunction with the hardware-programmer to allow the user to inspect the state of the device, pause execution and step through the code.
]

The typical features of debuggers include the ability to place break-points -- point in the code where the execution is automatically paused upon reaching it -- step through the code, inspect the state of the program, then resume the execution of the program. Another common feature is the ability to pause on exception, essentially, when an error occurs, the debugger will pause the execution of the program and let the user inspect what caused this error and observe the list of function calls that lead to the error.

Some of the functions of a debugging interface are hard to apply to analog circuitry such as in the case of photonic processors. And it is evident that traditional step-by-step debugging is not possible due to the realtime, continuous nature of analog circuitry. However, it may be possible to provide mechanisms for inspecting the state of the processor by sampling the analog signals present within the device.

Due to the aforementioned limitations of existing, digital debuggers, no existing tool can work for photonic processors. Instead, traditional analog electronic debugging techniques, such as the use of an oscilloscope are preferable. However, traditional tools only allow the user to inspect the state at the edge of the device, therefore, inspecting issues inside of the device require routing signals to the outside of the chip, which may not always be possible. However, it is interesting to note that this is an active area of research #cite("szczesny_hdl_based_2017", "Felgueiras2007ABD", "Motel2014SimulationAD"), for analog electronics at least, and it would be interesting to see what future research yields and how much introspection will be possible with "analog debuggers".

=== Code formatter

#info-box(kind: "definition")[
    A *code formatter* is a program that takes code as input and outputs the same code, but formatted according to a set of rules @bsd_style. It is generally used to enforce a consistent style across a codebase such as in the case of the _BSD project_ @bsd_style and _GNU style_ @gnu_style.
]

Most languages have code formatters such as _rustfmt_ for _Rust_ and _ClangFormat_ for the _C_ family of languages. These tools are used to enforce rules on styling of code, they play an important role in keeping code bases readable and consistent. Although not being strictly necessary, they can enhance the programmer's experience. Additionally, some of these tools have the ability to fix certain issues they detect, such as _rustfmt_.

Most commonly, these tools rely on _Wadler-style_ formatting @wadler_style. Due to the prominence of this formatting architecture, it is likely that, when developing a language, a library for formatting code will be available. This makes the development of a formatting code much easier as it is only necessary to implement the rules of the language.

=== Linting

#info-box(kind: "definition")[
    A *linter* is a program that looks for common errors and stylistic issues in code. It is used in conjunction with a formatter to enforce a consistent style across a codebase. They also help mitigate the risk of common errors and bugs that might occur in code.
]

As with formatting, most languages have linters made available either through officially maintained tools or with community maintained initiatives. As these tools provide means to mitigate common errors and bugs, they are an important part of the ecosystem. They can be built as part of the compiler directly, or as a separate tool that can be run on the codebase. Additionally, linters often lack support for finding common errors in the usage of external libraries. Therefore, when developing an @api, linters cannot check for proper usage of the @api itself and care must be done to ensure that the @api is used correctly, such as making the library less error-prone through strong typing.

However, linters are limited in their ability to detect only common errors and stylistic issues, as they can only check errors and issues for which they have pre-made rules. They cannot check for more complex issues such as logic errors. However, the value of catching common errors and issues cannot be understated. Therefore, whether selecting a language to build an @api or creating a custom language, it is important to consider the availability and quality of linters.

As for implementation of linters, they generally rely on a similar architecture than formatters, using existing components of the compiler to read code. However, they differ by matching a set of rules on the code to find common errors. Creating a good linter is therefore more challenging than creating a good formatter as the number of rules required to catch common errors may be quite high. As en example _Clippy_, _Rust_'s linter, has 627 rules @clippy_rules.

Interestingly, as in the case of _Clippy_, some rules can also be used to suggest better, more readable ways of writing code. For example, _Clippy_ has a rule that suggests lowering cognitive load using the rule `clippy::cognitive_complexity` @clippy_rules. This rules suggests that functions that are too complex as defined in the literature @cognitive_load should be either reworked or split into smaller, more readable code units.

=== Code editor

#info-box(kind: "definition")[
    A *code editor* is a program that allows the editing of text files. It generally provides features that are aimed at software development such as syntax highlighting, code completion, and code navigation.
]

As previously mentioned, most code editors also provide features aimed at software development. Features such as syntax highlighting: which provides the user with visual cues about the structure of the code, code completion: which suggest possible completions for the code the user is currently writing, and code navigation: allows the user to jump to the definition or user of a function, variable, or type. These features help the user be more productive and navigate codebases more easily.

In general, it is not the responsibility of the programming language to make a code editor available. Fully features programming editors are generally called @ide[s]. Indeed, most users have a preferred choice of editor with the most popular being _Visual Studio Code_, _Visual Studio_ -- both from _Microsoft_ -- and _IntelliJ_ -- a Java-centric @ide from _JetBrains_ @stackoverflow_survey. Additionally, most editors have support for more than one language, either officially or through community maintained plugins -- additional software that extends the functionality of the editor.

Therefore, when creating a new language, effort should not go towards creating a new editor as much as supporting existing editors. This is usually done by creating plugins for common editors, however this approach leads to repetition has editors use different language for plugin development. Over the past few years, a new standard, @lsp, has established itself as a de-facto standard for editor support @kjaer_rask_specification_2021. Allowing language creators to provide an @lsp implementation and small wrapper plugins for multiple editors greatly reducing the effort required to support multiple editors. @lsp was originally introduced by _Microsoft_ for _Visual Studio Code_, but has since been adopted by most editors @kjaer_rask_specification_2021.

=== Testing & simulation

#info-box(kind: "definition")[
    *Testing* is the process of checking that a program produces the correct output for a given input. It is generally done by writing a separate programs that runs parts -- or the entirety -- of the tested program and checks that it produces an output, and that the produced output is correct.
]

Testing can generally be seen as a way of checking that a program works as intended. Checking for logical errors rather than syntactic errors, as the compiler would. Tests can be written ahead of the writing of the program, this is then called @tdd @McDonough2021TestDrivenD. Additionally, external software can provide metrics such as _code coverage_ that inform the user of how much of their code is being tested @ivankovic_code_2019.

Testing also comes in several forms, one may write _unit tests_ that test a single function, _integration tests_ that test the interaction between functions or module, _regression tests_ that test that a bug was fixed and does not reappear in newer versions, _performance tests_ -- also called _benchmarks_ -- which test the performance of the programs or parts of the program, and _end-to-end tests_ which test the program as a whole.

Additionally, there also exists an entirely different kind of tests called _constrained random_ which produces random, but correct, input to a program and checks that, in no conditions, does the program crash. This is generally utilized to find edge cases that are not properly handled as well as testing the robustness of the program -- especially areas concerning security and memory management.

Most modern programming language such as _Rust_ provide a testing framework as part of the language ecosystem. However, these testing framework may need to be expanded to provide library-specific features to test more advanced usage. As an example, one may look at libraries like _Mockito_ which provides features for @http testing in rust @mockito_github.

Therefore, when developing an @api, it is important to consider how the @api itself will be tested, but also how the user is expected to test their usage of the @api. Additionally, when creating a language, it is important to consider how the language will be tested, and what facilities will be provided to the user for testing of their code.

#info-box(kind: "definition")[
    *Simulation* is the process of running a program that simulates the behavior of a physical device. It is used to test that @hdl[s] produce the correct state for a given input and starting state, while also checking that the program does so in the correct timing, power consumption limits, etc.
]

Simulation is more specific to @hdl[s] and embedded development than traditional computer development, where the user might want to programmatically test their code on the target platform without needing the physical device to be attached to a computer. For this reason, the hardware providers make simulators available to their users. These simulators are used to run the user's code as if it was running on real hardware, providing the user with tools for introspection of the device and checking that the program behaves as expected.

As an example, _Xilinx_ provides a simulator for their @fpga[s] called _Vivado Simulator_. This simulator allows the user to run their code on a simulated @fpga and check that the output is correct. This is an important tools for the users of @hdl[s] as it allows them to test their code without needed access to the physical devices. Furthermore, it allows programmers working on @asic[s] to simulate their code, and therefore their design before manufacturing of a prototype.

There exists a plethora of simulation tools, as previously mentioned, _Vivado Simulator_ allows users to test their FPGA code, other tools such as _QEMU_ allow users to test embedded platforms. Additionally, a lot of analog simulations tools exist, most notably the @spice family of tools, which allow the simulation of analog electronics. There is also work being done to simulate photonic circuits using @spice @ye_spice-compatible_2022.

Finally, there also exist tools for physical simulation, such as _Ansys Lumerical_ which are physical simulation tools that simulate the physical interactions of light with matter. These tools are used during the creation of photonic components used when creating @pic[s]. However, they are generally slow and require large amounts of computation power #cite("bogaerts_silicon_2018", "alerstam_parallel_2008").

Therefore, when creating an @api or a language for photonic processor development, it is desirable to consider how simulation will be performed and the level of details that this simulator will provide. The higher the amount of details, the higher the computational needs.

==== Verification

As previously mentioned, when writing @hdl code, it is desirable to simulate the code to check that it behaves correctly. Therefore, it may even be desirable to automatically simulate code in a similar way that unit tests are performed. This action of automatically testing through simulation is called _verification_.

As verification is an important part of the @hdl workflow and ecosystem. It is critical that any photonic programming solution provides a way to perform verification. This would be done by providing both a simulator and a tester and then providing a way of interface both together to perform verification.

=== Package manager

#info-box(kind: "definition")[
    A *package manager* or *dependency manager* is a tool that allows users to install and manage dependencies of their projects. These dependencies are generally libraries, but they can also be tools such as testing frameworks, etc.
]

Package management is an integral part of modern language ecosystems. It allows users to easily install dependencies from the community as well as share dependencies with the community. This is done through the use of a global repository of packages. Additionally, some package managers provide a way to create private repositories for protection of intellectual property.

This last point is of particular interest for hardware description. It is common in the hardware industry to license the use of components -- generally called @ip[s]. Therefore, any package manager designed to be used with an @hdl must provide a way of protecting the intellectual property of package providers and users alike.

Additionally, package manager often offer version management, allowing the user to specify which version of a package they wish to use. As well as allowing package providers to update their packages as they get refined and improved. The same can be applied for hardware description as additional features may be added to a component, or hardware bugs may be fixed.

Finally, package managers usually handle nested dependencies, that is, they are able to resolve the dependencies of the dependencies, making the rule of a user wishing to use a specific package easier. This lets creators of dependencies themselves build on top of existing community solutions, providing for a more cohesive ecosystem. It is also important to point out that nested dependencies can cause conflicts, and therefore, package managers must provide a way to resolve these conflicts. This is usually done using _semantic versioning_ which is a way of specifying version number that allow, to some degree, automatic conflict resolution @lam_putting_2020.

=== Documentation generator

=== Build system

=== Summary

As has been showed, in order to build a complete, user friendly ecosystem, a lot of components are preferred. Official support for these components might be preferred as they lead to lower fracturing of their respective ecosystems. In @tab_ecosystem_components, an overview of components that are desirable, along with a short description and their applicability for different scenarios as mentioned.

#let not_needed = text(fill: red, size: 28pt)[#raw("\u{2718}")]
#let required = text(fill: green, size: 28pt)[#raw("\u{2714}")]
#let optional = text(fill: orange, size: 28pt)[#raw("\u{2714}")]
#let desired = text(fill: yellow.darken(20%), size: 28pt)[#raw("\u{2699}")]

#figure(
    caption: [
        This table shows the different components that are needed (#required), desired (#desired) or not needed (#not_needed) for an ecosystem. It compares they applicability for different scenarios, namely whether developing an API that is used to program photonic processors or whether creating a new language for photonic processor development.
    ],
    kind: table,
)[
    #tablex(
        columns: (auto, 1fr, 0.25fr, 0.25fr),
        align: center + horizon,
        auto-vlines: false,
        repeat-header: true,
        rowspanx(2)[#smallcaps[ *Component* ]], rowspanx(2)[#smallcaps[ *Description* ]], colspanx(2)[#smallcaps[ *Applicability* ]], (), (),
        (), (), smallcaps[ *API design* ], smallcaps[ *language #linebreak() design* ],

        // Language specification
        smallcaps[ *Language specification* ], 
        align(left)[Defines the syntax and semantics of the language.], 
        optional, 
        optional,

        // Compiler
        smallcaps[ *Compiler* ], 
        align(left)[Converts code written in a high-level language to a low-level language.], 
        required, 
        [ #optional #linebreak() (interpreted#super[1]) ],

        // Hardware programmer & runtime
        smallcaps[ *Hardware-programmer#linebreak()& runtime* ], 
        align(left)[ Allows the execution of code on the hardware.], 
        required, 
        required,

        // Debugger
        smallcaps[ *Debugger* ],
        align(left)[Allows the user to inspect the state of the program at runtime.],
        optional,
        optional,

        // Code formatter
        smallcaps[ *Code formatter* ],
        align(left)[Allows the user to format their code in a consistent way.],
        desired,
        required,

        // Linter
        smallcaps[ *Linter* ],
        align(left)[Allows the user to check their code for common mistakes.],
        not_needed,
        desired,
        
        // Code editor
        rowspanx(2)[#smallcaps[ *Code editor* ]],
        rowspanx(2)[#align(left)[Allows the user to write code in a user-friendly way.]],
        not_needed,
        not_needed,
        hlinex(start: 2, end: 3, stroke: 0pt),
        (), (), cellx(colspan: 2)[(provided by the#linebreak()ecosystem#super[2])], (),

        // Testing & simulation
        smallcaps[ *Testing#linebreak()& simulation* ],
        align(left)[Allows the user to test their code.],
        required,
        required,

        // Package management
        smallcaps[ *Package management* ],
        align(left)[Allows the user to install and manage dependencies.],
        desired,
        desired,

        // Documentation generator
        smallcaps[ *Documentation generator* ],
        align(left)[Allows the user to generate documentation for their code.],
        [#required],
        desired,

        // Build system
        smallcaps[ *Build system* ],
        align(left)[Allows the user to build their code.],
        required,
        required,
    )
] <tab_ecosystem_components>

== Overview of syntaxes

== Comparison of existing programming ecosystems <sec_existing_eco>

#info-box(kind: "conclusion")[
    With the previous sections, it can be seen that creating a user-friendly ecosystem revolves around the creation of tools to aid in development. The compiler and language cannot be created in isolation, and the ecosystem as a whole has to be considered to achieve the broadest possible adoption.

    Depending on the choice of implementation, the components of the ecosystem will change. However, whether the language already exists or whether it is created for the purpose of programming photonic processor, special care needs to be taken to ensure high usability and productivity through the creation of tools to aid in development.

    As will be discussed in @sec_phos, the chosen solution will be the creation of a custom @dsl for photonic processors. This will be done due to the unique needs of photonic processors, and the lack of existing languages that can be used for the development of such devices. And this ecosystem will need to be created from scratch. However, the analysis done in this section will be used to guide the development of this ecosystem.
]

== Analysis of programming paradigms <sec_paradigms>

=== Imperative programming

=== Functional programming

=== Object-oriented programming

=== Logic programming

=== Dataflow programming

== Existing framework

== Summary

After comparing existing ecosystems as well as the existing framework used to program photonic processors, further discussion on ...

#info-box(kind: "question")[
    Should a new programming language be created for photonic processors?
    - What type of programming paradigm should be used?
    - What features should be included in the language?
    - What tools should be created to aid in the development?
    - What existing programming languages, if any, should be used as a base?
]