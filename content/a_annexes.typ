#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *
#import "../elems/hexagonal.typ": hexagonal_interconnect

#set heading(numbering: "A", supplement: [ Annex ])
#set figure(numbering: (x) => [ A.#x ])
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)

#set page(flipped: true)
= AST data structure: overview <anx_ast_overview>
#figure(caption: [
    UML diagram of parts of the @ast relevant for @sec_ast. It is incomplete since phos contains 120 data structures to fully represent the @ast.
])[
    #image("../figures/drawio/ex_ast.png", width: 88%)
]

#set page(flipped: true)
= Bytecode execution <anx_bytecode_execution>
#figurex(
    title: [
        Execution diagram of the stack of @sec_ex_bytecode_exec.
    ],
    caption: [
        Execution diagram of the stack of @sec_ex_bytecode_exec, showing the stack before and after the execution of each of the bytecode instructions.
    ]
)[
    #image("../figures/drawio/execution.png", width: 85%)
] <fig_annex_execution>

#set page(flipped: true)
= Graph representation of a mesh <anx_bytecode_instruction_set>

#figurex(
    title: [ Graph representation of a mesh. ],
    caption: [
        Graph representation of a mesh, showing the direction that light is travelling in, and all of the possible connections. Based on the work of Xiangfeng Chen, et al. @chen_graph_2020. This visualization was created with the collaboration of Léo Masson, as mentioned in #link(<sec_ack>)[the acknowledgements].
    ],
)[
    #hexagonal_interconnect(side: 14cm, hex-side: 1.5cm, 10, 14)
]<fig_graph_representation_mesh>

#set page(flipped: false)
= Test