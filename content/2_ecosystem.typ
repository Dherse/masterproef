#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/tablex.typ": *
#import "../elems/template.typ": *

= Programming of photonic processors <sec_programming_photonic_processors>

The primary objective of this chapter is to explore the different aspects of programming photonic processors. This chapter will start by looking at different traditional programming ecosystems and how different languages approach common problems when programming. Then, the existing software solutions and their limitations will be analysed. Finally, an analysis of relevant programming paradigms will be done. This chapter's secondary objective is to familiarise the reader with the concepts and terminology used in the rest of the thesis. This chapter will also introduce the reader to different programming paradigms relevant to the research at hand, as well as programming language concepts and components. As this chapter also serves as an introduction to programming language concepts, it is written in a more general way, exploring components of programming ecosystems -- in @sec_components -- before looking at specificities relevant to the programming of photonic processors.

== Programming languages as a tool <sec_language_tool>

#info-box(kind: "definition", footer: [ Adapted from @noauthor_imperative_2020 ])[
    *Imperativeness* refers to whether the program specifies the expected results of the computation (declarative) or the steps needed to perform this computation (imperative). These differences may be understood as the difference between _what_ the program should do and _how_ it should do it.
]

Programming languages, in the most traditional sense, are tools used to express _what_ and, depending on its imperativeness and paradigm, _how_ a device should perform a task. A device, in this context, means any device that is capable of performing sequential operations, such as a processor, a microcontroller or another device. However, programming languages are not limited to programming computers but are increasingly used for other tasks. So-called #gloss("dsl", long: true, suffix: [s]) are languages designed for specific purposes that may intersect with traditional computing or describe traditional computing tasks but can also extend beyond traditional computing. @dsl[s] can be used to program digital devices such as @fpga[s] but also to program and simulate analog systems such as @verilog-ams or @spice.

Additionally, programming languages can be used to build strong abstractions over traditional computing tasks. For example, @sql is a language designed to describe database queries by describing the _what_ and not the _how_, making it easier to reason about the queries being executed. Other examples include _Typst_, the language used to create this document.

Furthermore, some languages are designed to describe digital hardware, so-called @rtl #gloss("hdl", long: true, suffix: [s]). These languages are used to describe the hardware in a way closer to the actual hardware; therefore, they are not used to describe the _what_ but the _how_. These languages are not the focus of this thesis, but they are essential to understand the context of the research at hand, and they will be further examined in @sec_ecosystem_components_summary, where their applicability to the research at hand will be discussed.

As such, programming languages can be seen, in a more generic way, as tools that can be used to build abstractions over complex systems, whether software systems or hardware systems, and therefore, the ecosystem surrounding a language can be seen as a toolbox providing many amenities to the user of the language. Is it, therefore, important to understand these components and reason about their importance, relevance and how they can best be used for a photonic processor.

== Typing in programming languages <sec_typing>

#info-box(kind: "definition", footer: [ Adapted from @cardelli_understanding_1985 ])[
    A *type system* is a system made of rules that assign a property called a type to values in a program. It dictates how to create them, what kind of operations can be done on those values, and how they can be combined.
]

#info-box(kind: "definition", footer: [ Adapted from @cardelli_understanding_1985 ])[
    *Static or dynamic typing* refers to whether the type of arguments, variables and fields is known at compile time or at runtime. In statically typed languages, the type of values must be known at compile time, while in dynamically typed languages, the type of values is computed at runtime.
]

All languages have a type system; it provides the basis for the language to reason about values. It can be of two types: static or dynamic. Static typing allows the compiler to know ahead of executing the code what each value is and means. This allows the compiler to provide features such as type verification that a value has the correct type for an operation and to optimise the code to improve performance. On the contrary, dynamic typing does not determine the type of values ahead of time, instead forcing the burden of type verification on the user. This practice makes development easier at the cost of increased overhead during execution and the loss of some optimisations @dot_analysis_2015. Additionally, dynamic typing is a common source of runtime errors for programs written in a dynamically typed language, something that is caught during the compilation process in statically typed languages.

Therefore, static typing is generally preferred for applications where speed is a concern, as is the case in _C_ and _Rust_. However, dynamic typing is preferred for applications where iteration speed is more important, such as in _Python_. However, some languages exist at the intersection of these two paradigms, such as _Rust_, which can infer parts of the type system at compile time, allowing the user to write their code with fewer type annotations while still providing the benefits of static typing. This is achieved through a process called type inference, where the compiler generally uses the de facto standard algorithm called _Hindley-Milner_ algorithm #cite("milner_theory_1978", "rust_compiler"), which will be discussed further in @sec_phos.

#info-box(kind: "definition", footer: [ Adapted from @cardelli_understanding_1985 ])[
    *Polymorphism* refers to the ability of a language to allow the same code to be used with different types.
]

Polymorphism allows code to be re-used with different types; a typical example is a list. For a list to work, it does not matter what type of value is contained within the list. Therefore one can make the list polymorphic over the item type such that the list is defined at the type `List<V>` where `V` is a type argument defining the contents of the list. Additionally, polymorphic languages often offer a way to define types that meet specific criteria, such as a type that is comparable or a type that is copyable. This is called a _trait_ in _Rust_ and an _interface_ in _Java_ and _C\#_. On the other hand, _C_ does not have polymorphism nor interfaces or traits. Then, polymorphic types and functions can request that their type argument meet these requirements. This is called _bounded polymorphism_ and is a common feature in modern programming languages @cardelli_understanding_1985. 

== Explicitness in programming languages <sec_explicitness>

In language design, one of the most important aspects to consider is the explicitness of the language, that is, how many details the user must manually specify and how much can be inferred. This is a trade-off between the expressiveness of the language and the complexity of the language. A language that is too explicit is both difficult to write and to read, while a language that is too implicit is difficult to understand and reason about, while also generally being more complex to implement. Therefore, it is essential to find a balance between these two extremes. Another factor to take into account is that too much "magic", that is, operations being done implicitly, can lead to difficult-to-understand code, unexpected results and bugs that are difficult to track down.

Therefore, it is in the interest of the language designer and users to find a balance where the language is sufficiently expressive while also being sufficiently explicit. This is, generally, a difficult balance to find and can take several iterations to achieve. This balance is not the same for every programming language either. The target audience of the language tends to govern, at least to some extent, which priorities are put in place. For example, performance-focused systems, such as @hpc solutions, tend to be very explicit, with fine-grained control to eke out the most performance, while on the contrary, systems designed for beginners might want to be more implicit, sacrificing complexity and fine-grained control for ease of use.

== Components of a programming ecosystem <sec_components>

An important part of programming any kind of programmable device is the ecosystem that surrounds that device. The most basic ecosystem components that are necessary for the use of the device are the following:
- a language reference or specification: the syntax and semantics of the language;
- a compiler or interpreter: to translate the code into a form that can be executed by the device;
- a hardware programmer or runtime: to physically program and execute the code on the device.

These components are the core elements of any programming ecosystem since they allow the user to translate their code into a form the device can execute. And then to use the device. Therefore, without these components, the device is useless. However, these components are not sufficient to create a user-friendly ecosystem. Indeed, the following component list can also be desirable:
- a debugger: to aid in the development and debugging of the code;
- a code editor: to write the code in, it can be an existing editor with support for the language;
- a formatter: to format the code consistently;
- a linter: a tool used to check the code for common mistakes and to enforce a coding style;
- a testing framework: to test and verify the code;
- a simulator: to simulate the execution of the code;
- a package manager: to manage dependencies between different parts of the code;
- a documentation generator: to generate documentation for the code;
- a build system: to easily build the code into a form that the device can execute.

With the number of components desired, one can conclude that any endeavour to create such an ecosystem is a large undertaking. Such a large undertaking needs to be carefully planned and executed. And to do so, it is important to look at existing ecosystems and analyse them. This section will analyse the ecosystems of the following languages, when relevant:
- #emph[C]: a low-level language that is mainly used for embedded systems and operating systems;
- #emph[Rust]: a modern systems language primarily used for embedded systems and high-performance applications;
- #emph[Python]: a high-level language that is used chiefly for scripting and data science;
- #emph[@vhdl]: an #gloss("hdl", long: true) that is used to describe digital hardware;
- #emph[@verilog-ams]: an analog simulation language that has been used to describe photonic circuits @ansys_lumerical;

Each of these ecosystems comes with a particular set of tools in addition to the aforementioned core components. Some of these languages come with tooling directly built by the maintainers of the languages, while others leave the development of these tools to the community. However, it should be noted that, generally, tools maintained by the language maintainers tend to have a higher quality and broader usage than community-maintained tools.

Additionally, the analysis done in this section will give pointers towards the language choice used in developing the language that will be presented in @sec_phos, a custom @dsl language for photonic processors. As this language will not be self-hosted -- its compiler will not be written in itself -- it will need to use an existing language to create its ecosystem.

=== Language specification & reference

#info-box(kind: "definition", footer: [ Adapted from @jones_forms_2007 ])[
    A *programming language specification* is a document that formally defines a programming language, such that there is an understanding of what programs in that language mean. This document can be used to ensure that all implementations of the language are compatible with one another.
]

#info-box(kind: "definition", footer: [ Adapted from @jones_forms_2007 ])[
    A *programming language reference* is a document that outlines the syntax, features and usage of a programming language. It serves as a simplified version of the specification and is usually written during the development of the language.
]

A programming specification is useful for languages that are expected to have more than one implementation, as it outlines what a program in that language is expected to do. Indeed, code that is written following this specification should therefore be able to be executed by any language implementation and produce the same output. However, this is not always the case. Several languages with proprietary implementations, such as #emph[VHDL] and #emph[SystemC] -- two languages used for hardware description of digital electronics -- have issues with vendored versions of the language @Chacko2019CaseSO.

This previous point is particularly interesting for the application at hand: assuming that the goal is to reuse an existing specification for the creation of a new photonic @hdl, then it is crucial to select a language that has a specification. However, if the design calls for an @api implemented in a given language instead, then it does not matter. Indeed, in the latter case, the specification is the implementation itself.

Additionally, when reusing an existing specification for a different purpose than the intended one, it is essential to check that the specification is not too restrictive. Indeed, as previously shown in @photonic_processor, the programming of photonic processors is different from that of electronic processors. Therefore, special care has to be taken that the specification allows for the expression of the necessary concepts. This is particularly important for languages that are not designed for hardware description, such as #emph[C] and #emph[Python]. Given that photonics has a different target application and different semantics, most notably the fact that photonic processors are continuous analog systems -- rather than digital processes -- these languages may lack the needed constructs to express the necessary concepts, they may not be suitable for the development of a photonic @hdl. Given the effort required to modify the specification of an existing language, it may be better to create a new language dedicated for photonic programming.

Furthermore, the language specification is only an important part of the ecosystem being designed when reusing an existing language. However, if creating a new language or an @api, then the specification is irrelevant. It is desirable to create a specification when creating a new language, as it can be used as a thread guiding development. With the special consideration that a specification is only useful when the language is mature, immature languages change often and may break their own specification. And maintaining a changing specification as the language evolves may lower the speed at which work is done. For example, #emph[Rust] is widely used despite lacking a formal specification @rust-reference.

=== Compiler

#info-box(kind: "definition", footer: [ Adapted from @aho2006compilers ])[
    A *compiler* is a program that translates code written in a higher-level programming language into a lower-level programming language or format so that it can be executed by a computer or programmed onto a device.
]

The compiler has an important task; they translate the user's code from a higher-level language, which can still remain quite low-level, as in the case of #emph[C], into a low-level representation that can be executed. The type of language used determines the complexity of the compiler. In general, the higher the level of abstraction, the more work the compiler must perform to create executable artefacts.

An alternative to compilers are interpreters who perform this translation on the fly; such is the case for #emph[Python]. However, @hdl[s] tend to produce programming artefacts for the device. However, a compiler is more appropriate for the task at hand. This, therefore, means that #emph[Python] is not a suitable language for the development of a photonic @hdl. Or, at least, it would require the development of a dedicated compiler for the language.

One of the key aspects of the compiler, excluding the translation itself, is the quality of errors it produces. The easier the errors are to understand and reason about, the easier the user can fix them. Therefore, when designing a compiler, extreme care must be taken to ensure that the errors are as clear as possible. Languages like #emph[C++] are notorious for having frustrating errors @becker_compiler_2019, while languages like #emph[Rust] are praised for the quality of their errors. This is important to consider when designing a language, as it can make or break the user experience. Following guidelines such as the ones in @becker_compiler_2019 can help in the design of a compiler and greatly improve user experience.

==== Components

Compilers vary widely in their implementation. However, they all perform the same basic actions that may be separated into three distinct components:
- the frontend: which parses the code and performs semantic analysis;
- the middle-end: which performs optimisations on the code;
- the backend: which generates the executable artefacts.

The frontend checks whether the program is correct in terms of its usage of syntax and semantics. It produces errors that should be helpful for the user @becker_compiler_2019. Additionally, in statically typed languages, it performs type checking to ensure that types are correct and operations are valid. In general, the frontend produces a simplified, more descriptive version of the code to be used in further stages @rust_compiler. The middle-end performs multiple functions but generally performs optimisations on the code. These optimisations can be of various types, and are generally used to improve the performance of the final executable. As will se discussed in @sec_phos, while performance is important, it is not the main focus of the proposed language. Therefore, the middle-end can be simplified. Finally, the backend, has the task of producing the final executable. This is a complex topic in and off itself, as it requires the generation of code for the target architecture. In the case of #emph[C] using #emph[Clang] -- a common compiler for _C_-- this is done by the LLVM compiler framework @clang_internals. However, as with the middle-end, the final solution suggested in this work will not require the generation of traditional executable artefacts. Instead, some of the tasks that one may group under the backend, such as place-and-route, will still be required and are complex enough to warrant their own research.

=== Hardware-programmer & runtime

#info-box(kind: "definition", footer: [ Adapted from @czerwinski2013finite])[
    The *hardware-programmer* is a tool that allows the user to write their compilation artefacts to the device. It is generally a piece of software that communicates with the device through a dedicated interface, such as a USB port. Most often, it is provided by the manufacturer of the device.
]

The hardware-programmer is an important part of the ecosystem, as it is required to program the physical hardware. Usually it is also involved in debugging the device, such as with interfaces like @jtag. However, as this may be considered part of the hardware itself, it will not be further discussed in this section. However, it must be considered as the software must be able to communicate with the device.

#info-box(kind: "definition", footer: [ Adapted from @czerwinski2013finite])[
    The *runtime* is a program that runs on the device to provide the base functions of the device, such as initialization, memory management, and other low-level functions @aho2006compilers. It is generally provided by the manufacturer of the device.
]

In the case of a photonic processor, it is as of yet unclear what tasks and functions it will perform for the rest of the ecosystem, and warrants its own research and work. The runtime is a device-specific component, and as such, it is not possible to design it as a generic, reusable, component. Therefore, it is mentioned as a necessary component, and will be discussed in further details in @sec_phos but will not be further considered in this section.

In general, the hardware-programmer and the runtime work hand-in-hand to provide the full programmability of the device. As the hardware-programmer is the interface between the user and the device, and the runtime is the interface between the device and the user's code compiled artefacts. Therefore, these two components are what allows the user's code to not only be executed on the device, but also to have access to the device's resources.

=== Debugger

#info-box(kind: "definition", footer: [Adapted from @aho2006compilers])[
    A *debugger* is a program that allows the user to inspect the state of the program as it is being executed. In the case of a hardware debugger, it generally works in conjunction with the hardware-programmer to allow the user to inspect the state of the device, pause execution and step through the code.
]

The typical features of debuggers include the ability to place break-points -- point in the code where the execution is automatically paused upon reaching it -- step through the code, inspect the state of the program, then resume the execution of the program. Another common feature is the ability to pause on exception, essentially, when an error occurs, the debugger will pause the execution of the program and let the user inspect what caused this error and observe the list of function calls that lead to the error.

Some of the functions of a debugging interface are hard to apply to analog circuitry such as in the case of photonic processors. And it is evident that traditional step-by-step debugging is not possible due to the real-time, continuous nature of analog circuitry. However, it may be possible to provide mechanisms for inspecting the state of the processor by sampling the analog signals present within the device.

Due to the aforementioned limitations of existing digital debuggers, no existing tool can work for photonic processors. Instead, traditional analog electronic debugging techniques, such as the use of an oscilloscope are preferable. However, traditional tools only allow the user to inspect the state at the edge of the device, therefore, inspecting issues inside of the device require routing signals to the outside of the chip, which may not always be possible. However, it is interesting to note that this is an active area of research #cite("szczesny_hdl_based_2017", "Felgueiras2007ABD", "Motel2014SimulationAD"), for analog electronics at least, and it would be interesting to see what future research yields and how much introspection will be possible with "analog debuggers".

=== Code formatter

#info-box(kind: "definition", footer: [Adapted from @nonoma_formatter])[
    A *code formatter* is a program that takes code as input and outputs the same code, but formatted according to a set of rules. It is generally used to enforce a consistent style across a codebase such as in the case of the _BSD project_ @bsd_style and _GNU style_ @gnu_style.
]

Most languages have code formatters such as _rustfmt_ for _Rust_ and _ClangFormat_ for the _C_ family of languages. These tools are used to enforce rules on styling of code, they play an important role in keeping code bases readable and consistent. Although not being strictly necessary, they can enhance the programmer's experience. Additionally, some of these tools have the ability to fix certain issues they detect, such as _rustfmt_.

Most commonly, these tools rely on _Wadler-style_ formatting @wadler_style. Due to the prominence of this formatting architecture, it is likely that, when developing a language, a library for formatting code will be available. This makes the development of a formatting code much easier as it is only necessary to implement the rules of the language.

=== Linting

#info-box(kind: "definition", footer: [Adapted from @nonoma_formatter])[
    A *linter* is a program that looks for common errors, good practices, and stylistic issues in code. It is used with a formatter to enforce a consistent style across a codebase. They also help mitigate the risk of common errors and bugs that might occur in code.
]

As with formatting, most languages have linters made available through officially maintained tools or community maintained initiatives. As these tools provide means to mitigate common errors and bugs, they are an important part of the ecosystem. They can be built as part of the compiler, or as a separate tool that can be run on the codebase. Additionally, linters often lack support for finding common errors in the usage of external libraries. Therefore, when developing an @api, linters are limited in checking for proper usage of the @api itself. Care must be done to ensure that the @api is used correctly, such as making the library less error-prone through strong typing.

Nonetheless, linters are limited in their ability to detect only common errors and stylistic issues, as they can only check errors and issues for which they have pre-made rules. They cannot check for more complex issues such as logic errors. However, the value of catching common errors and issues cannot be understated. Therefore, whether selecting a language to build an @api or creating a custom language, it is important to consider the availability and quality of linters.

As for the implementation of linters, they generally rely on a similar architecture to formatters, using existing compiler components to read code. However, they differ by matching a set of rules on the code to find common errors. Creating a good linter is, therefore, more challenging than creating a good formatter as the number of rules required to catch common errors may be quite high. For example, _Clippy_, _Rust_'s linter, has 627 rules @clippy_rules.

Interestingly, as in the case of _Clippy_, some rules can also be used to suggest better, more readable ways of writing code, colloquially called good practices. For example, _Clippy_ has a rule that suggests lowering cognitive load using the rule `clippy::cognitive_complexity` @clippy_rules. This rule suggests that functions that are too complex, as defined in the literature @cognitive_load, should be either reworked or split into smaller, more readable code units.

=== Code editor

#info-box(kind: "definition", footer: [ Adapted from @source-code-editor ])[
    A *code editor* is a program that allows the editing of text files. It generally provides features aimed at software development, such as syntax highlighting, code completion, and code navigation.
]

As previously mentioned, most code editors also provide features aimed at software development. Features such as syntax highlighting: which provides the user with visual cues about the structure of the code, code completion: which suggest possible completions for the code the user is currently writing. And code navigation: allows the user to jump to the definition or user of a function, variable, or type. These features help the user be more productive and navigate codebases more easily.

In general, it is not the responsibility of the programming language to make a code editor available. Fully featured programming editors are generally called @ide[s]. Indeed, most users have a preferred choice of editor, with the most popular being _Visual Studio Code_, _Visual Studio_ -- both from _Microsoft_ -- and _IntelliJ_ -- a _Java_-centric @ide from _JetBrains_ @stackoverflow_survey. Additionally, most editors have support for more than one language, either officially or through community-maintained plugins -- additional software that extends the editor's functionality.

When creating a new language, effort should not go towards creating a new editor as much as supporting existing ones. This is usually done by creating plugins for common editors. However, this approach leads to repetition, has editors use different languages for plugin development. Over the past few years, a new standard, @lsp, has established itself as a de-facto standard for editor support @kjaer_rask_specification_2021. Allowing language creators to provide an @lsp implementation and small wrapper plugins for multiple editors greatly reducing the effort required to support multiple editors. @lsp was originally introduced by _Microsoft_ for _Visual Studio Code_, but has since been adopted by most editors @kjaer_rask_specification_2021.

=== Testing & simulation

#info-box(kind: "definition", footer: [ Adapted from #cite("unit-test", "simulation")])[
    *Testing* is the process of checking that a program produces the correct output for a given input. It is generally done by writing a separate program that runs parts -- or the entirety -- of the tested program and checks that it produces an output and that the produced output is correct.
]

Testing can generally be seen as checking that a program works as intended. They check for logical errors rather than syntactic errors, as the compiler would. Tests can be written ahead of the writing of the program. This is then called @tdd @McDonough2021TestDrivenD. Additionally, external software can provide metrics such as _code coverage_ that inform the user of the proportion of their code being tested @ivankovic_code_2019.

Testing also comes in several forms; one may write _unit tests_ that test a single function, _integration tests_ that test the interaction between functions or modules, _regression tests_ that test that a bug was fixed and does not reappear in newer versions, _performance tests_ -- also called _benchmarks_ -- which test the performance of the programs or parts of the program, and _end-to-end tests_ which test the program as a whole.

Additionally, there also exists an entirely different kind of test called _constrained random_ which produces random but correct input to a program and checks that, under no conditions, the program crashes. This is generally utilised to find edge cases that are not correctly handled and test the program's robustness, especially in areas concerning security and memory management.

Most modern programming languages, such as _Rust_ provide a testing framework as part of the language ecosystem. However, these testing frameworks may need to be expanded to provide library-specific features to test more advanced usage. As an example, one may look at libraries like _Mockito_, which provides features for @http testing in _Rust_ @mockito_github.

Therefore, when developing an @api, it is important to consider how the @api itself will be tested and how the user is expected to test their usage of the @api. Additionally, when creating a language, it is important to consider how the language will be tested and what facilities will be provided to the user to test their code.

#info-box(kind: "definition", footer: [ Adapted from #cite("unit-test", "simulation")])[
    *Simulation* is the process of running a program that simulates the behaviour of a physical device. It is used to test that @hdl[s] produce the correct state for a given input and starting state while also checking that the program does so in the correct timing or power consumption limits.
]

Simulation is more specific to @hdl[s] and embedded development than traditional computer development, where the user might want to programmatically test their code on the target platform without needing the physical device to be attached to a computer. For this reason, the hardware providers make simulators available to their users. These simulators run the user's code as if it was running on real hardware, providing the user with tools for introspection of the device and checking that the program behaves as expected. As an example, _Xilinx_ provides a simulator for their @fpga[s] called _Vivado Simulator_. This simulator allows the user to run their code on a simulated @fpga and check that the output is correct. This is an essential tool for the users of @hdl[s] as it allows them to test their code without needed access to physical devices. Furthermore, it allows programmers working on @asic[s] to simulate their code and design before manufacturing a prototype.

There are many simulation tools, such as _Vivado Simulator_, which allows users to test their FPGA code, other tools, such as _QEMU_ which allow users to test embedded platforms. Additionally, many analog simulation tools exist, most notably the @spice family of tools, which allow the simulation of analog electronics. There is also work being done to simulate photonic circuits using @spice @ye_spice-compatible_2022.

Finally, there also exist tools for physical simulation, such as _Ansys Lumerical_ which are physical simulation tools that simulate the physical interactions of light with matter. These tools are used during the creation of photonic components used when creating @pic[s]. However, they are generally slow and require large amounts of computation power #cite("bogaerts_silicon_2018", "alerstam_parallel_2008"). Therefore, when creating an @api or a language for photonic processor development, it is desirable to consider how simulations will be performed and the level of details that this simulator will provide. The higher the amount of details, the higher the computational needs.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Verification*]
}
As previously mentioned, when writing @hdl code, it is desirable to simulate the code to check that it behaves correctly. Therefore, it may even be desirable to automatically simulate code in a similar way that unit tests are performed. This action of automatically testing through simulation is called _verification_, as verification is an integral part of the @hdl workflow and ecosystem. Any photonic programming solution must provide a way to perform verification. This would be done by providing both a simulator and a tester and then providing a way of interfacing both together to perform verification.

=== Package manager

#info-box(kind: "definition", footer: [ Adapted from @package-manager ])[
    A *package manager* or *dependency manager* is a tool that allows users to install and manage dependencies of their projects. These dependencies are generally libraries but can also be tools such as testing frameworks, etc.
]

Package management is an integral part of modern language ecosystems. It allows users to easily install dependencies from the community and share new ones with the community. This is done through the use of a global repository of packages. Additionally, some package managers provide a way to create private repositories to protect intellectual property.

This last point is of particular interest for hardware description. It is common in the hardware industry to license the use of components -- generally called @ip[s]. Therefore, any package manager designed to be used with an @hdl must provide a way of protecting the intellectual property of package providers and users alike.

Additionally, package managers often offer version management, allowing the user to specify which version of a package they wish to use. As well as allowing package providers to update their packages as they get refined and improved. The same can be applied to hardware description as additional features may be added to a component, or hardware bugs may be fixed.

Finally, package managers usually handle nested dependencies, that is, they are able to resolve the dependencies of the dependencies, making the experience of a user wishing to use a specific package easier. This lets creators of dependencies build on top of existing community solutions, providing a more cohesive ecosystem. It is also important to point out that nested dependencies can cause conflicts, so package managers must provide a way to resolve these conflicts. This is usually done using _semantic versioning_ which is a way of specifying version number that allow, to some degree, automatic conflict resolution @lam_putting_2020.

=== Documentation generator

#info-box(kind: "definition", footer: [ Adapted from @sai_zhang_automated_2011])[
    A *documentation generator* is a tool that allows users to generate documentation for their code using their code. This is usually done using special comments in the code that are extracted and interpreted as documentation.
]

The most common document generators are _Doxygen_ used by the _C_ and _C++_ communities and _Javadoc_ used by the _Java_ community. Generally, documentation generators produce documentation in the form of a website, where all the documentation and components are linked together automatically. This makes navigating the documentation easier for the user. Additionally, some documentation generators, such as _Rustdoc_ for the _Rust_ ecosystem, provide a way to include and test examples directly in the documentation. This makes it easier for users to understand and use new libraries they might be unfamiliar with. For this reason, when developing an @api, having a documentation generator built into the language is highly desirable as the documentation can serve as a way for users to learn the @api but also for maintainers to understand the implementation of the @api itself. Additionally, when creating a new language, care might be given to documentation generators, as they can provide a way for users to document their code and maintainers to document the language and its standard library. Finally, as technical documentation is the primary source of information for developers @stackoverflow_survey, it is essential to consider this need from users. 

=== Build system

#info-box(kind: "definition", footer: [ Adapted from @aho2006compilers ])[
    A *build system* is a tool that allows users to build their projects.
]

Build systems play an essential role in building complex software. Modern software is generally composed of many files that are compiled together, along with dependencies, configuration and many other resources, so it is challenging to compile modern software projects by hand. For these reasons, build systems are available. They provide a way to specify how a project should be built, this can be done in an explicit way: where the user specifies the steps that should be taken, the dependencies and how to build them. This approach would be similar to the popular _CMake_ build system for the _C_ family of languages. Other build systems like _Cargo_ for _Rust_ provide a mostly implicit way of building projects, where the user only specifies the dependencies and, by using a standardised file structure, the build system is able to infer how to build the project. This approach is easier to use and leads to a more uniform project structure. This means that, in combination with other tools such as formatters and linters, projects built using tools like _Cargo_ all _look_ alike, making them easy to navigate for beginners and experienced users alike. Additionally, not having to create _CMake_ files for every new project follows the @dry principle, which is a common mantra in programming.

Additionally, build systems can provide advanced features that are of particular interest to hardware description languages. Features such as _feature flags_ are particularly useful. A feature flag is a property that can be enabled during building that is additive. It adds additional features to the program. As a simple example, consider the program in @prog_hello: it will print `"Hello, world!"` when it is called. A feature flag called `custom_hello` may be used to add the function in @prog_hello_custom, which allows the user to specify a name to greet. It is purely additive: adding functionality to the previous library and using the `custom_hello` feature flag to enable the additional feature conditionally. This example is trivial, but this idea can be expanded.

Another example might be a feature flag that enables an additional type of modulator in a library of reusable photonic components. Some libraries even take a step further, where almost all of their features are gated, which allows them to be very lean and fast to compile. However, this is not a common occurrence.

#figure(caption: [ Simple function that prints `"Hello, world!"`, in _Rust_.])[
    #raw(read("../code/hello_world/0.rs"), lang: "rust", block: true)
] <prog_hello>

#figure(caption: [ Function that prints `"Hello, {name}!"` with a custom name, in _Rust_.])[
    #raw(read("../code/hello_world/1.rs"), lang: "rust", block: true)
] <prog_hello_custom>

Whether providing the user with an @api or creating a new language, it is essential to consider how the user's program must be built, as this task can quickly become quite complex. Enforcing a fixed folder structure and providing a ready-made build system that handles all common building tasks can significantly improve the user experience. And especially the experience of newcomers as it might prevent them from having to do obscure tasks such as writing their own _CMake_ files.

=== Summary <sec_ecosystem_components_summary>

As has been shown, many components are necessary or desirable to build a complete, user-friendly ecosystem. Official support for these components might be preferred as they lead to lower fracturing of their respective ecosystems. In @tab_ecosystem_components, an overview of required components, desirable or not needed, along with a short description and their applicability for different scenarios are mentioned. Some components are more critical than others and are required to build the ecosystem. Most notably, the compiler, hardware-programmer, and testing and simulation tools are critical to be able to utilise the hardware platform. Without these components, the ecosystem is not usable for hardware development. However, while the other components are not strictly needed, several of them are desirable: having proper debugging facilities makes the ecosystem easier to use. Similarly, having a build system can help the users get started with their projects faster.

In @tab_ecosystem_components, there is a distinction made on the type of design that is pursued, as will be discussed in @sec_phos, this thesis will create a new hardware description language, but the possibility of creating an @api was also discussed. And while an @api is not the retained solution, one can use this information for the choice of the language in which this new language, called @phos, will be implemented. Indeed, the same components that make @api designing easy also make language implementation easier. As will be discussed in @sec_language_summary, @phos will be implemented in _Rust_. The language meets all requirements by having first-party support for all of the required and desired components for an @api design. Its high performance and safety features make it a good candidate for a reliable implementation of the @phos ecosystem.

#figurex(
    caption: [
        This table shows the different components that are needed (#required_sml), desired (#desired_sml) or not needed (#not_needed_sml) for an ecosystem. It compares their importance for different scenarios, namely whether developing an API that is used to program photonic processors or whether creating a new language for photonic processor development.
        + Interpreted languages are languages that are not compiled to machine code, but rather interpreted at runtime. This means that they do not require a compiler per se, but rather an interpreter.
        + A code editor is provided as an external tool, however, support for the language must be provided by the ecosystem. That being said, it is not a requirement and is desired rather than required.
    ],
    title: [
        Comparison of programming ecosystem components and their importance.
    ],
    kind: table,
)[
    #tablex(
        columns: (auto, 1fr, 0.25fr, 0.25fr),
        align: center + horizon,
        auto-vlines: false,
        repeat-header: true,
        rowspanx(2)[#smallcaps[ *Component* ]], rowspanx(2)[#smallcaps[ *Description* ]], colspanx(2)[#smallcaps[ *Importance* ]], (), (),
        (), (), smallcaps[ *@api design* ], smallcaps[ *language #linebreak() design* ],

        // Language specification
        smallcaps[ *Language specification* ], 
        align(left)[Defines the syntax and semantics of the language.], 
        desired, 
        desired,

        // Compiler
        smallcaps[ *Compiler* ], 
        align(left)[Converts code written in a high-level language to a low-level language.], 
        required, 
        [ #desired #linebreak() (interpreted#super[1]) ],

        // Hardware programmer & runtime
        smallcaps[ *Hardware-programmer#linebreak()& runtime* ], 
        align(left)[ Allows the execution of code on the hardware.], 
        required, 
        required,

        // Debugger
        smallcaps[ *Debugger* ],
        align(left)[Allows the user to inspect the state of the program at runtime.],
        desired,
        desired,

        // Code formatter
        smallcaps[ *Code formatter* ],
        align(left)[Allows the user to format their code in a consistent way.],
        desired,
        desired,

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
        required,
        desired,

        // Build system
        smallcaps[ *Build system* ],
        align(left)[Allows the user to more easily build their codebase.],
        desired,
        desired,
    )
] <tab_ecosystem_components>

Finally, @tab_ecosystem_compare compares the ecosystem of existing programming and hardware description languages and their components. It shows that some ecosystems, like _Python_'s, have many components but that not all of them are first-party, nor is there always an agreement within the community on the best tool. However _Rust_ is a particularly interesting candidate in this regard, as it has first-party support for all of the required components except hardware-programming and debugging tools. However, as noted in @tab_ecosystem_compare, most other languages do not come with first-party support for these tools either. However, as will be discussed in @sec_overview_of_syntax, it is not easy to learn, has not seen use in hardware synthesis and is, therefore not a good fit for regular users. But its robust ecosystem makes it a good candidate for a language implementation, something for which it has a thriving ecosystem of many libraries, colloquially called _crates_, fit for this purpose.

One can also see from @tab_ecosystem_compare that simulation and hardware description ecosystems tend to be highly proprietary and incomplete. This problem can be solved by providing a common baseline for all tasks relating to photonic hardware description, where only the lowest level of the technology stack: the platform-support is vendored. Forcing platforms, through an open source license such as @gpl-3-0, to provide a standard interface for their hardware will allow a standardised ecosystem to be built on top of it. This is the approach that @phos will hopefully take.

#figurex(
    caption: [
        This table compares the ecosystems of different programming and hardware description languages. It shows whether the components are first-party (#required_sml), third-party but well-supported (#desired_sml) or third-party but not well-supported or non-existent (#not_needed_sml). Each component also lists the name of the tool that is most commonly used for that purpose.
        + _C_ has multiple, very popular, compilers, such as _GCC_ and _Clang_. However, these are third-party, and for embedded and @hls development, there is no de facto standard.
        + Traditional programming languages usually rely on programmers and runtime provided by the hardware vendor of the targetted embedded hardware.
        + #emph[@verilog-ams] is a language used for simulation, not hardware description.
        + _C_ and _Rust_ generally share debuggers due to being native languages.
        + There do seem to exist some formatters, linters, code editor support and documentation generators for #emph[@verilog-ams] and #emph[@vhdl], but they are not widely used and are sparsely maintained.
        + Due to the difficulty in handling intellectual property in hardware, there is no ubiquitous package manager for hardware description languages.
        + Python being interpreted, it does not need a build system, but some dependency and environment automation tools such as _Poetry_ are widely used.
    ],
    title: [
        This table compares the ecosystems of different programming and hardware description languages.
    ],
    kind: table,
)[
    #tablex(
        columns: (auto, 0.1fr, 0.1fr, 0.1fr, 0.1fr, 0.1fr),
        align: center + horizon,
        auto-vlines: false,
        repeat-header: true,

        rowspanx(2)[#smallcaps[ *Components* ]],
        colspanx(3)[#smallcaps[ *Traditional languages* ]],
        hlinex(start: 1, end: 4, stroke: 1pt, expand: (0pt, -5pt)),
        hlinex(start: 4, end: 6, stroke: 1pt, expand: (-5pt, 0pt)),
        (), (), 
        colspanx(2)[#smallcaps[ *Hardware description#linebreak()& simulation languages* ]], (), 
        smallcaps[ *C* ], 
        smallcaps[ *Rust* ], 
        smallcaps[ *Python* ], 
        smallcaps[ *#gloss("verilog-ams", short: true)* ],
        smallcaps[ *#gloss("vhdl", short: true)* ],

        // Language specification
        smallcaps[ *Language specification* ], 
        [ #required @ISO13586 ], 
        [ #not_needed @rust-reference],
        [ #not_needed @python_reference],
        [ #required @verilog-ams-ref],
        [ #required @vhdl-standard],

        // Compiler
        smallcaps[ *Compiler* ], 
        [#desired #super[1] #linebreak() (_Clang_ & _GCC_)], 
        [#required #linebreak() (_rustc_)],
        [#desired #linebreak() (_PyPy_ & _Numba_)],
        [#not_needed #linebreak() (simulated)],
        [#desired #linebreak() (synthesised)],

        // Hardware programmer & runtime
        smallcaps[ *Hardware-programmer#linebreak()& runtime* ], 
        [#desired #super[2] #linebreak() (vendored)],
        [#desired #super[2] #linebreak() (vendored)],
        [#desired #super[2] #linebreak() (vendored)],
        [#desired #super[3] #linebreak() (vendored)],
        [#desired #linebreak() (vendored)],

        // Debugger
        smallcaps[ *Debugger* ],
        [#desired #super[4] #linebreak() (_GDB_ & _LLDB_)],
        [#desired #super[4] #linebreak() (_GDB_ & _LLDB_)],
        [#required #linebreak() (_PDB_)],
        [#desired #linebreak() (vendored)],
        [#desired #linebreak() (vendored)],

        // Code formatter
        smallcaps[ *Code formatter* ],
        [#desired #linebreak() (_clang-format_#linebreak()& _uncrustify_)],
        [#required #linebreak() (_rustfmt_)],
        [#desired #linebreak() (_Black_)],
        [#not_needed #super[5]],
        [#not_needed #super[5]],

        // Linter
        smallcaps[ *Linter* ],
        [#desired #linebreak() (_clang-tidy_#linebreak()& _uncrustify_)],
        [#required #linebreak() (_Clippy_)],
        [#desired #linebreak() (_Black_)],
        [#not_needed #super[5]],
        [#not_needed #super[5]],
        
        // Code editor
        smallcaps[ *Code editor support* ],
        [#desired #linebreak() (_clangd_ & _ccls_)],
        [#required #linebreak() (_rust-analyzer_)],
        [#desired #linebreak() (_Pyright_)],
        [#not_needed #super[5]],
        [#not_needed #super[5]],

        // Testing & simulation
        smallcaps[ *Testing* ],
        [#desired #linebreak() (_CUnit_)],
        [#required #linebreak() (_rustc_)],
        [#desired #linebreak() (_Pytest_)],
        [#desired #linebreak() (_SVUnit_)],
        [#desired #linebreak() (_VUnit_)],

        // Testing & simulation
        smallcaps[ *Simulation* ],
        [#desired #super[2] #linebreak() (vendored)],
        [#desired #super[2] #linebreak() (vendored)],
        [#desired #super[2] #linebreak() (vendored)],
        [#desired #linebreak() (vendored)],
        [#desired #linebreak() (vendored)],

        // Package management
        smallcaps[ *Package management* ],
        not_needed,
        [#required #linebreak() (_Cargo_)],
        [#required #linebreak() (_PyPI_)],
        [#not_needed #super[6]],
        [#not_needed #super[6]],

        // Documentation generator
        smallcaps[ *Documentation generator* ],
        [#desired #linebreak() (_Doxygen_)],
        [#desired #linebreak() (_Rustdoc_)],
        [#desired #linebreak() (_Sphinx_)],
        [#not_needed #super[5]],
        [#not_needed #super[5]],

        // Build system
        smallcaps[ *Build system* ],
        [#desired #linebreak() (_CMake_)],
        [#required #linebreak() (_Cargo_)],
        [#desired #super[7] #linebreak() (_Poetry_)],
        [#desired #linebreak() (vendored)],
        [#desired #linebreak() (vendored)],
    )
] <tab_ecosystem_compare>

#info-box(kind: "conclusion")[
    With the previous sections, it can be seen that creating a user-friendly ecosystem revolves around creating tools to aid development. The compiler and language cannot be created in isolation, and the entire ecosystem has to be considered to achieve the broadest possible adoption.

    Depending on the implementation choice, the ecosystem's components will change. However, whether the language already exists or is created to program photonic processors, special care needs to be taken to ensure high usability and productivity through the availability or creation of tools to aid in development.

    As will be discussed in @sec_phos, the chosen solution will be the creation of a custom @dsl for photonic processors. This will be done due to the unique needs of photonic processors and the lack of existing languages that can be used for development targetting such devices. Moreover, this ecosystem will need to be created from scratch. However, the analysis done in this section will be used to guide the development of this ecosystem.
]

== Overview of syntaxes <sec_overview_of_syntax>

Following the analysis of programming ecosystem components, this section will analyse the syntaxes employed by various common programming languages. This section aims at building intuition on what these syntaxes look like, what they mean and how they can be applied to photonics. Additionally, this section will also analyse the syntaxes of existing @hdl[s] and other @dsl[s] that are used to program digital electronics -- most notably @fpga[s] -- and analog electronics. This analysis will also provide insight into whether these languages are suitable for programmable photonics. As programmable photonics works using different paradigms than digital and analog electronics, it is crucial to understand these differences and why they make these existing solutions unsuitable.

The first analysis, which looks at traditional programming languages, will look at the syntaxes of the following languages: _C_, _Rust_, and _Python_. These languages have been chosen as they are some of the most popular languages in the world, but also because they each bring different strengths and weaknesses with regards to the following aspects:
- _C_ is a low-level language that is used as the building block for other non-traditional computation types such as @fpga[s] by being used for @hls @schafer_high_level_2020, but is also being used for novel use cases such as quantum programming @mccaskey_extending_2021.
- _Rust_ is another low-level language, it has not seen wide use in @hls or other non-traditional computation types, but it has modern features that make it a good candidate for @api development. However, _Rust_ has a very steep learning curve, making it unsuitable for non-programmers @rust_learning_curve.
- _Python_ is a common language that is used by a vast proportion of researchers and engineers #cite("stackoverflow_survey", "python_research"), which makes it a great candidate as the starting point of any language development. It is also used for some @hdl development @villar_python_2011 and is used for the development of the existing photonic processor @api[s], as well as for other non-traditional computation types such as quantum computing. However, it is a high-level, generally slow language with a syntax generally unsuitable for hardware description, as will be further discussed later.

The second analysis will focus on different forms of #gloss("hdl", long: true, suffix: [s]) and simulation languages. Most notably, the following languages will be analysed:
- _SytemC_ is a language that has seen increased use in @hls for @fpga[s].
- _MyHDL_ is a library for _Python_ that gives it hardware description capabilities.
- _VHDL_: a common @hdl used for @fpga development and other digital electronics @my_hdl.
- #emph[@verilog-ams]: a superset of _Verilog_ that allows for the description of analog electronics. It has seen use in the development of photonic simulation, most notably in _Ansys Lumerical_ @ansys_lumerical.
- #emph[@spice]: a language that is used for the simulation of analog electronics. #emph[@spice] as seen use in the development of photonic simulation @ye_spice-compatible_2022.

The goal of the second analysis will be to see whether any of these languages can be reused or easily adapter for photonic simulation. In the end, none of these languages fit the needs of photonic development, most notably with regard to ease of use. Nonetheless, the analysis provides insight that can be useful when designing a new language. It is also important to note that two distinct families of languages are in the aforementioned list: digital @hdl[s] and analog simulation-centric languages. Therefore this comparison will be made in two parts, one for each family of languages.

=== Traditional programming languages

To compare traditional programming languages, a simple yet classical example will be used: _FizzBuzz_, which is a simple program that prints the number from one to one hundred, printing _Fizz_ when the number is divisible by three, _Buzz_ when the number is divisible by five and _FizzBuzz_ when the number is divisible by both three and five. The _C_ implementation of _FizzBuzz_ is shown in @lst_c_fizz. The _Rust_ implementation of _FizzBuzz_ is shown in @lst_rust_fizz. The _Python_ implementation of _FizzBuzz_ is shown in @lst_python_fizz. For each of those languages, many different implementations are possible. However, a simple and representative version was used. As performance is not the focus of this comparison, choosing the most optimised implementation is not necessary.

Programming languages often take inspiration from one another. As such, most modern languages are inspired by _C_, which is itself inspired by _B_, _ALGOL 68_ and _FORTRAN_ @ritchie_development_1993. _C_ has had a large influence on languages such as _Python_ @rossum1993python and _Rust_ @rust-reference -- through _C++_ and _Cyclone_ -- but also on @hdl[s] such as _Verilog_ (and therefore _Verilog-AMS_). As such, this section will start with an outlook on the syntax of _C_ and discuss some of its shortcomings regarding more modern languages. Additionally, the more difficult aspects of the language will be discussed, most notably manual memory management and pointer semantics, as these two aspects are error-prone and even considered to be the root cause for most security vulnerabilities @ms_security.

A simple _C_ implementation of _FizzBuzz_ can be found in @lst_c_fizz, it shows several important aspects of _C_:
- blocks of code are surrounded by curly braces (`{` and `}`);
- statements are terminated by a semicolon (`;`); however, curly braces can be omitted for single-line statements;
- variables are declared with a type and a name and optionally initialised with a value;
- functions are declared with a return type, a name, a list of arguments and a body;
- ternary operators are available for shorter but less readable conditional statements;
- _C_ lacks a lot of high-level constructs such as string, relying instead on arrays of characters;
- _C_ has a lot of low-level constructs, such as pointers, which are used to pass arguments by reference;
- _C_ is not whitespace or line-space sensitive, and statements can span multiple lines;
- _C_ uses a preprocessor to perform text substitution, such as importing other files;
- _C_ needs a `main` function to be defined, which is the program's entry point.

#figure(caption: [ _FizzBuzz_ implemented in _C_, based on the _Rosetta Code_ project @rosetta_code_sieve_2021.])[
    #raw(read("../code/fizzbuzz/c.c"), lang: "c", block: true)
] <lst_c_fizz>

The _Rust_ implementation of _FizzBuzz_ can be found in @lst_rust_fizz, it shows several important aspects of _Rust_:
- blocks of code are surrounded by curly braces (`{` and `}`);
- statements are terminated by a semicolon (`;`);
- loops use the range syntax (`..`) instead of manual iteration;
- printing is done using the `print` and `println` macros, which are similar to _C_'s `printf`;
- variables do not need to be declared with a type, as the compiler can infer it;
- _Rust_ is not whitespace or line-space sensitive, and statement can span multiple lines;
- _Rust_ needs a `main` function to be defined, which is the program's entry point.

#figure(caption: [ _FizzBuzz_ implemented in _Rust_, based on the _Rosetta Code_ project @rosetta_code_sieve_2021])[
    #raw(read("../code/fizzbuzz/rust.rs"), lang: "rust", block: true)
] <lst_rust_fizz>

The _Python_ implementation of _FizzBuzz_ can be found in @lst_python_fizz, it shows several important aspects of _Python_:
- blocks of code are delimited by indentation;
- a newline terminates statements;
- loops use the `range` function instead of manual iteration;
- printing is done using the `print` function;
- variables do not need to be declared with a type, as the language is dynamically typed;
- _Python_ is whitespace and line-space sensitive;
- _Python_ does not need a `main` function to be defined, as the file is the program's entry point.

#figure(caption: [ _FizzBuzz_ implemented in _Python_, based on the _Rosetta Code_ project @rosetta_code_sieve_2021.])[
    #raw(read("../code/fizzbuzz/python.py"), lang: "python", block: true)
] <lst_python_fizz>

This simple example shows some fundamental design decisions for _C_, _Rust_, and _Python_, most notably that _Python_ is whitespace and line-space sensitive, while _C_ and _Rust_ are not. This is a design feature of _Python_ that aids in making the code more readable and consistently formatted regardless of whether the user uses a formatter or not. Then, focusing on typing, _Python_ is dynamically typed, making the work of any compiler more difficult. Dynamic typing is a feature that generally makes languages easier to use at the cost of runtime performance, as type-checking has to be done as the code is running. Per contra, _Rust_ takes an intermediate approach between _Python_'s dynamic typing and _C_'s manual type annotation: _Rust_ uses type inference to infer the type of variables, which means that users still need to annotate some types. However, overall most variables do not need type annotations. This makes _Rust_ easier to use than _C_, but also more challenging to use than _Python_ from a typing point of view.

Additional features that the languages offer:
- _Python_ and _Rust_ both offer iterators, which are a high-level abstraction over loops;
- _C_ and _Rust_ both offer more control over data movement through references and pointers;
- _Python_ and _Rust_ both have an official package manager, while _C_ does not;
- _Python_ and _Rust_ are both memory safe, meaning that memory management is automatic and not prone to errors;
- _Rust_ is a thread-safe language, meaning that multithreaded programs are easier to write and less prone to errors;
- _C_ and _Rust_ are both well suited for embedded development. While _Python_ has seen use in embedded development, it is not as well suited as the other two languages due to performance constraints;
- _Rust_ does not have truthiness: only `true` and `false` are considered boolean values, while _Python_ and _C_ have truthiness, meaning several types of values can be used as boolean values.

#info-box(kind: "conclusion")[
    It was shown that traditional programming languages generally lack the features required to be used as a photonic @hdl. However, _Python_ is a strong candidate for creating an @api, and _Rust_ is a strong candidate for implementing a compiler.
]

=== Digital hardware description languages

Unlike traditional programming languages, digital @hdl[s] try and represent digital circuitry using code. This means that the code is not executed but rather synthesised into hardware that can be built. This hardware generally has one of two forms: logic gates that can be built discretely or @lut[s] programmed on an FPGA. Both processes involve "running" the code through a synthesiser that produces a netlist and a list of operations that are needed to implement the circuit. As previously discussed, in @sec_language_tool, languages can serve as the foundation to build abstractions over complex systems. However, most @hdl[s] tend to only have an abstraction over the #gloss("rtl", long: true) level, which is the level that describes the movement, and processing of data between registers. Registers are memory cells commonly used in digital logic that store the result of operations between clock cycles. This means that the abstraction level of most @hdl[s] is shallow.

This low-level of abstraction can be better understood by understanding three factors regarding digital logic programming. The first is the economic aspect: custom @ic[s] are very expensive to design and produce. As such, the larger the design, the larger the dies needed, which increases cost; and @fpga[s] are costly devices, the larger the design, the more space it physically occupies inside of the @fpga, increasing the size needed and therefore the cost. The second factor is the design complexity: the more complex the design, the more difficult it is to verify and the slower it is to simulate, which decreases productivity. The third factor is with regard to performance. Three criteria characterise the performance of a design: the speed of the algorithm being implemented, the power consumed for a given operation, and the area that the circuit occupies. These performance definitions are often referred to be the acronym @ppa. As such, the design is generally done at a lower-level of abstraction to try and meet performance targets.

==== High-level synthesis

#info-box(kind: "definition", footer: [ Adapted from #cite("schafer_high_level_2020", "meeus_overview_2012")])[
    *High-level Synthesis (HLS)* is the process of translating high-level abstractions in a programming language into #gloss("rtl", long: true) level descriptions. This process is generally done by a compiler that takes as input the high-level language and translates the code into a lower-level form. 
]

In recent years, there has been a push towards higher-level abstraction for digital @hdl[s]. It takes the form of so-called #gloss("hls", long: true) languages. These languages allow the user to build their design at a higher-level of abstraction, which is generally more straightforward and more productive @ye_scalehls_2022. Allowing the user to focus on the feature they are trying to build and not the low-level implementation of those designs. As discussed in @sec_language_tool, this can be seen as a move towards declarative programming or a less imperative programming model. Coupled with the rise of hardware accelerators in the data center and cloud markets, which are generally either @gpu[s] or @fpga[s], there has been an increased need for software developers to be able to use these #gloss("fpga")-based accelerators. Because these software developers are generally not electrical engineers, and due to the high complexity of @fpga[s], developing for such devices is not an easy skill to acquire. This has provided an industry drive towards economically viable @hls languages and tools that software developers can use to program #gloss("fpga")-based accelerators.

Another advantage of @hls is the ability to test the hardware using traditional testing frameworks, as discussed in @sec_ecosystem_components_summary, testing systems for @hdl[s] tend to be vendored and therefore difficult to port. Additionally, they are based on simulation of the behaviour, which is generally slower than running the equivalent @cpu instructions. Therefore, testing the hardware using traditional frameworks is a significant advantage of @hls languages. In the same way that it allows the use of regular testing frameworks, it also enables the reuse of well-tested algorithms that may already be implemented in a given ecosystem which can drastically lower the development time of a given design and reduce the risk of errors. In addition to being able to use existing testing frameworks, the code can be verified using provers and formal verification tools, which can prove the correctness of an implementation, something that does not exist for traditional @rtl level development.

Given that @hls development is generally easier, more productive and allows for the reuse of existing well-tested resources, it is a sensible alternative to traditional @rtl level development. However, it does come at the cost of generally higher resource usage and lower performance. This is due to the fact that the @hls abstractions are still not mature enough to meet the performance of hand-written @hdl code. However, there has been a push towards a greater level of optimisation, such as using the breadth of optimisation available in the @llvm compiler. This has allowed @hls to reach a level of performance acceptable for large swath of applications, especially when designed by non-specialists @lahti_are_2019. Other techniques, such as machine learning based optimisation techniques have been used to increase performance even further @shahzad_reinforcement_2022.

==== Modern RTL languages

In parallel to @hls development, a lot of higher-level @rtl languages and libraries have been created, such as _MyHDL_, _Chisel_, and _SpinalHDL_. These alternatives are positioned as replacements to traditional @hdl[s] such as _SystemVerilog_. They are often libraries for existing languages such as _Python_, and therefore inherit their broad ecosystems. As discussed in @sec_ecosystem_components_summary, @hdl[s], tend to be lackluster -- or highly vendor-locked -- with regard to development tools. And just as in the case of @hls, this can be an argument in favour of using alternatives, such as these @hdl[s] implemented inside of existing languages.

These @hdl[s] are generally implemented as translators, where, instead of doing synthesis down to the netlist level, they translate the user's code into a traditional @hdl. As such, they are not a replacement for traditional @hdl[s] but offer a higher-level of abstraction and better tooling through the use of more generic languages. This places these tools in an interesting place, where users can use them for their nicer ecosystems and easier development but still have the low-level control that traditional @hdl[s] offer. This is in contrast to @hls, where this control is often lost due to the higher-level of abstraction over the circuit's behaviour. Additionally, these tools often integrate well with existing package-managers which are available for the language of choice, allowing for easy reuse and sharing of existing libraries.

=== Comparison

For the comparison, three @hdl[s] of varying reach and abstraction levels will be used: #emph[@vhdl], #emph[MyHDL], and #emph[SystemC]. They each represent one of the aforementioned categories: traditional @hdl[s], modern @rtl\-level languages, and @hls languages. For this comparison, a simple example of an $n$-bit adder will be used, where $n$ is a design parameter. This will allow the demonstration of procedural generation of hardware and the use of modules and submodules to structure code.

#info-box(kind: "info")[
    Most @hdl languages come with pre-built implementations of adders. Usually, the compiler or synthesis tool chooses the best adder implementation based on the user's constraints. These constraints can relate to the area, power consumption or timing requirements.
]

In the first example, in @lst_adder_vhdl, it can be seen that the @vhdl implementation is verbose, giving details for all parameters and having to import all of the basic packages (line $#2-3$). In @vhdl, the ports and other properties are defined in the `entity`, and the logic is implemented in an `architecture` block. This leads to functionality being spread over multiple locations, generally reducing readability. Assignments are done using the `<=` operator. Unlike most modern counterparts, the language does not use indentation or braces to denote code blocks but rather the `begin` and `end` keywords, which is a dated practice. However, @vhdl does support parameterisation of the design, as can be seen on line $#6$ with the declaration of the generic `n`. This allows for the generation of hardware based on parameters, which is a useful feature for hardware design.

#figurex(
    caption: [ Example of a $n$-bit adder in @vhdl, based on @vhdl-adder. ],
)[
    #raw(lang: "vhdl", read("../code/adder/vhdl.vhdl"), block: true)
] <lst_adder_vhdl>

The second example based on _MyHDL_, in @lst_adder_my_hdl, shows a combinatorial implementation of an adder. It shows that _MyHDL_ relies on decorators to perform code transformations, something that may be useful when designing custom languages based on _Python_ @ikarashi_exocompilation_2022. Despite using decorators, the code for the _Python_ example is very short, relying on the `@always_comb` annotation to denote the combinatorial logic. The `@block` annotation is used to denote a block of code that will be translated to a module. Overall, code in _MyHDL_ is generally easy to read and has a low barrier to entry for _Python_ developers. 

#pagebreak(weak: true)

#figurex(
    caption: [ Example of a $n$-bit adder in _MyHDL_. ],
)[
    #raw(lang: "python", read("../code/adder/myhdl.py"), block: true)
] <lst_adder_my_hdl>

The final and third sample is in _SytemC_, in @lst_adder_systemc. It is verbose, using lots of macros, it does not directly support generics due to its _C_ heritage, and requires the use of defined macros to configure the number of bits. Overall, it does not provide a pleasant user experience even for a simple example. Despite being a @hls language, it is seemingly less readable and user-friendly than _MyHDL_.

#figurex(
    caption: [ Example of a $n$-bit adder in _SystemC_. ],
)[
    #raw(lang: "c", read("../code/adder/systemc.c"), block: true)
] <lst_adder_systemc>

Three languages were shown, starting with @vhdl, which is widely used in the industry and has a long history of support and use in hardware synthesis toolchains. A newer, very modern @rtl language based on _Python_ with a compelling feature set, _MyHDL_, was also shown. Finally, a @hls language, _SystemC_, was shown. It was shown that _MyHDL_ is a very user-friendly language, with a low barrier to entry and a very modern feature set. It was also shown that _SystemC_ is a very verbose language and does not provide a good user experience. It was also shown that _SystemC_ does not support generics and requires the use of macros to achieve the same functionality. This is in contrast to _MyHDL_, which supports generics and parameterisation of designs. It was also shown that _MyHDL_ is a very modern language, with a very modern feature set and a very low barrier of entry. This is in contrast to _SystemC_, a very verbose language that does not provide a good user experience. It was also shown that _SystemC_ does not support generics and requires the use of macros to achieve the same functionality. This is in contrast to _MyHDL_, which implicitly supports generics and parameterisation of designs. However, this implicitness can be error-prone, which in the case of @asic design would be very expensive.

Finally, none of the aforementioned @hdl[s] provide any facilities for analog hardware description. Some, like @vhdl, can provide analog modelling, but not analog hardware description. This is a significant limitation of all digital electronic @hdl[s]. Additionally, the signal semantics they all use of _driven-once_, _drive_many_ could lead to issues with signal splitting, as will be discussed in @sec_signal_types.

#info-box(kind: "conclusion")[
    It was shown that traditional @rtl @hdl[s] are not suitable for photonic development. They are not easily approachable for non-expert and lack the correct semantic for analog processing. However, _MyHDL_ shows a promising approach to @hdl creation based on _Python_.
]

=== Analog simulation languages

There are several analog simulation languages. However, there are very few analog hardware description languages, and they mostly seem to be research languages #cite("murayama_top-down_1996", "mitra_study_2010"). Due to this overall unavailability of analog @hdl[s], this comparison will instead rely on analog simulation languages, namely @spice and @verilog-ams. These two languages are very different, designed for different purposes and at different times. However, they are both actively used. Their uses differ significantly as @spice aims to provide a netlist description of analog electrical circuitry to be simulated, whereas @verilog-ams aims to provide models of analog systems compatible with mixed-signal simulations of digital and analog electronics.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*SPICE*]
}
@spice is not a programming language but a configuration language: the user declares a list of nets and the components that connect these nets. As such, @spice is very explicit, and little in the way of programmatic features are offered. Additionally, @spice depends on models and is not meant to describe hardware. This means it is a very low-level representation of a circuit, which goes against the goal of using a high-level language, as discussed in @initial_requirements.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Verilog-AMS*]
} @verilog-ams is a modern mixed-signal simulation. It suffers from the same issues as @spice, namely that it cannot be used for hardware description but rather hardware modelling. While @verilog-ams has been used for photonic modelling, it is not a suitable candidate for use as a photonic @hdl.

#info-box(kind: "conclusion")[
    Existing analog modelling languages are unsuitable for photonic hardware description, as they are not hardware description languages but hardware modelling languages.
]

== Analysis of programming paradigms <sec_paradigms>

#info-box(kind: "definition", footer: [ Adapted from @noauthor_programming_2020. ])[
    A *programming paradigm* is a style of programming, a way of thinking, structuring, and solving problems in a language.
]

After an overview of existing programming languages, one must now consider the available programming paradigms. When selecting or creating a language, particular care must be taken when selecting one or more paradigms. This is because the choice of paradigms will affect the language's expressiveness and ease of use. Generally, most languages, like _Python_ are imperative languages with elements from functional programming.

There are two broad categories of programming paradigms, imperative and declarative programming. As mentioned in @sec_language_tool, imperative languages are concerned with the "how" of programming, whereas declarative languages are concerned with the "what". A complete overview of all programming paradigms is available in @anx_paradigms @van_roy_classification_nodate. In this comparison, the number of paradigms will be reduced as many of them exist. Instead, focusing on the most relevant ones, namely object-oriented, functional, logic, and dataflow programming. It is important to note that object-oriented programming is a subset of imperative programming and that functional programming is a subset of declarative programming, with dataflow programming being a subset of functional programming. This means that the aforementioned paradigms are not mutually exclusive and can, for example, be combined to create an object-oriented language with functional elements @van_roy_programming_2012.

=== Object-oriented programming

Object-oriented programming is one of the most common paradigms, being part of _Java_, _Python_, _C\#_, and many others. It follows the idea that data is the most important part of an application and that it should be contained together in an object along with the methods acting upon it. For each piece of data, an instance of an object is created. In theory, this allows for the creation of complex data structures easily in a tree-like structure. Object-oriented also allows for inheritance, where one class of object inherits from another. The most typical example is shown in @lst_oop_example, it shows a super class `Student` being inherited by a subclass `Sebastien`. This allows the subclass to override methods on the super class and share its initialisation function and state.

#figurex(
    title: [ Example of object-oriented programming in _Python_. ],
    caption: [ Example of object-oriented programming in _Python_, showing inheritance and method overriding. ],
)[
```python
class Student:
    def __init__(self, name):
        self.name = name
    def print_thesis_grade(self, grade):
        print("Thesis grade of " + self.name + " is " + grade)
class Sebastien(Student):
    def __init__(self):
        super().__init__("Sébastien d'Herbais de Thun")
    def print_thesis_grade(self, grade):
        print("Thesis grade of Sébastien is A+")
```
]<lst_oop_example>

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Criticism*]
} Object-oriented programming has been criticised for its tendency to create overly complex and sometimes confusing data structures. This is because it is very easy to create complex trees of classes, all interconnected, and all inheriting from one-another in not-always obvious ways. Additionally, one of the stated goals of object-oriented programming is to make code more modularised, therefore reusable. However, in practice, this is not always the case, as it is easy to create overly specialised classes @cardelli_bad_1996.

=== Functional programming

Functional programming views programs in the opposite way of object-oriented programming, instead emphasising procedures being done on data. In purely functional programming, all data is immutable, meaning that a value cannot be changed, only ever created or destroyed. This has advantages regarding limiting the number of side-effects, making the code easier to reason about. However, it can also make implementing some programs that require side-effects very difficult, such as communicating with other programs.

=== Logic programming

Logic programming is a subset of functional programming, instead focused on logical relations. The most common example of a logic programming language is _Prolog_. In logic programming, the programmer defines a set of rules, and the program will try to find a solution to the problem. This is done by defining a set of rules and a set of facts. The program will then try to find a solution to the problem by applying the rules to the facts.  Logic programming does not find its use in common programming, but rather in proving mathematical theorems and solving mathematical problems. As such, it is not suitable for hardware description.

=== Dataflow programming

Dataflow programming is another subset of functional programming, where the program is represented as a graph of nodes, where each node performs a function, and the graph's edges are the data flowing between the nodes. Its data model is particularly interesting for hardware description, as it can represent the operations being done on a signal, with the "flow" of light being the edges of the graph. Indeed, this is the approach taken by _DFiant_, a _Scala_ based @rtl @hdl that uses dataflow programming as its paradigm @port_dfiant_2017. And as will be seen in @sec_phos, it is part of the paradigm used by @phos, the language created in this thesis.

== Existing framework

There currenrly exists a framework developed at the @prg, for the programming of photonic processors. However, its level of abstraction is low, it consists of manually setting the parameters of each photonic gate, and then manually connecting them together. This is a very low-level approach, and as such, it is not suitable for the programming of complex photonic processors. However, it is still useful for the programming of simpler photonic circuits, and as such has been used for demonstrations of routing, switching, and circuit designing.

== Hardware-software codesign

#info-box(kind: "definition", footer: [ Adapted from @darwish_trends_2005. ])[
    *Hardware-software codesign* is the process of designing a system where both the hardware and software components are designed together, with the goal of interoperating hardware components and software systems more easily. And optimising the system as a whole rather than optimising the hardware and software components separately.
]

#todo("here")


== Summary <sec_language_summary>

From the aforementioned criteria, one may give a score for each of the discussed languages based on its suitability for a given application. This is done in @tbl_language_comparison. The score is given on a scale of one to five, with one being the lowest and five being the highest. The score is given based on the following criteria: the maturity of the ecosystem and the suitability for different scenarios that were previously explored, notably: @api design, root language -- i.e. as the basis for reusing the existing ecosystem and syntax -- and the implementation of a new language -- i.e. using the language to build the ecosystem components of a new language. @rtl languages implemented on top of _Python_ are not included in the table. Neither is @spice due to its restrictive scope.

From @tbl_language_comparison, one can see that for creating a new language, the best languages to implement it are _Rust_ and _C_. And the best languages to inspire the syntax and semantics are _Python_ and #emph[@verilog-ams]. Additionally, _C_ is also a good inspiration due to its widespread use and the familiarity of its syntax. Finally, for the implementation of an @api, the best choice is _Python_ due to its maturity, simplicity and popularity in academic and engineering circles.

#figurex(
    caption: [
        Comparison of the different languages based on the criteria discussed in @sec_language_summary.
    ],
    kind: table,
)[
    #tablex(
        columns: (0.0001fr, 0.075fr, 0.1fr, 0.1fr, 0.1fr, 0.1fr),
        align: center + horizon,
        auto-vlines: false,
        repeat-header: true,

        rowspanx(2)[],
        rowspanx(2)[#smallcaps[ *Language* ]],
        colspanx(4)[#smallcaps[ *Applications* ]],

        (),
        smallcaps[ *Ecosystem* ], 
        smallcaps[ *@api design* ],
        smallcaps[ *Root language* ], 
        smallcaps[ *New language* ],

        rowspanx(2)[],
        smallcaps[ *C* ],
        score(3),
        score(2),
        score(2),
        score(4),
        hlinex(start: 1, end: 5, stroke: (thickness: 0.5pt, dash: "dashed")),
        [],
        colspanx(4)[#align(left)[
            C is a fully featured low-level language; it is performant and has a simple syntax. However, it lacks some more modern ecosystem components and is error-prone. Because of this, it is unsuitable for @api design since it would require the user to be familiar with memory management. It lacks many of the semantics of hardware description, making it unsuitable as a root language. However, its extensive array of language-implementation libraries makes it a good candidate for implementing a new language.
        ]],

        rowspanx(2)[],
        smallcaps[ *Rust* ],
        score(5),
        score(2),
        score(2),
        score(5),
        hlinex(start: 1, end: 5, stroke: (thickness: 0.5pt, dash: "dashed")),
        [],
        colspanx(4)[#align(left)[
            Rust is a modern low-level language; it is very performant, has excellent first-party tooling, is quickly growing in popularity, and is memory safe. However, it has complicated syntax and semantics that is unwelcoming for non-developers, which makes it unsuitable for either @api design or as a root language. However, its extensive array of language-implementation libraries and its memory and thread safety make it an excellent candidate for implementing a new language.
        ]],

        rowspanx(2)[],
        smallcaps[ *Python* ],
        score(4),
        score(5),
        score(4),
        score(2),
        hlinex(start: 1, end: 5, stroke: (thickness: 0.5pt, dash: "dashed")),
        [],
        colspanx(4)[#align(left)[
            Python is a mature high-level language that sees wide use within the academic community; it has great third-party tooling and is easy to learn. These factors make it an excellent candidate for @api design and as a root language. However, its slowness and error-prone dynamic typing make it an unsuitable candidate for implementing a new language.
        ]],

        rowspanx(2)[],
        smallcaps[ *Verilog-AMS* ],
        score(1),
        score(0),
        score(3),
        score(0),
        hlinex(start: 1, end: 5, stroke: (thickness: 0.5pt, dash: "dashed")),
        [],
        colspanx(4)[#align(left)[
            @verilog-ams is a mixed signal simulation software; its ecosystem is lackluster, with many proprietary tools which incur expensive licenses. It is not a generic language and is therefore not designed for an @api to be implemented in the language, nor is it suitable for implementing a new language. However, it is a mature language with a familiar syntax to electrical engineers, which may make it suitable as the root language.
        ]],

        rowspanx(2)[],
        smallcaps[ *VHDL* ],
        score(1),
        score(0),
        score(1),
        score(0),
        hlinex(start: 1, end: 5, stroke: (thickness: 0.5pt, dash: "dashed")),
        [],
        colspanx(4)[#align(left)[
            VHDL is a mature language with a large ecosystem but suffers from the same issues as @verilog-ams, most notably that most tools are proprietary and licensed. Similarly, its nature as a hardware description language makes it unsuitable for @api design or the creation of a new language. Its verbose syntax and semantics are challenging to learn and make the language difficult to read, which makes it unsuitable as a root language.
        ]],
    )
] <tbl_language_comparison>