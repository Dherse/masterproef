#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

#set heading(numbering: "A.1")

#set page(flipped: true)
= AST data structure: overview <anx_ast_overview>
#figure(caption: [
    UML diagram of parts of the @ast relevant for @sec_ast. It is incomplete since phos contains 120 data structures to fully represent the @ast.
])[
    #image("../figures/drawio/ex_ast.png", width: 88%)
]

#set page(flipped: false)
= Test