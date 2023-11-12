#import "../ugent-template.typ": *
#show: ugent-preface

= Remark on the master's dissertation and the oral presentation
This master's dissertation is part of an exam. Any comments formulated by the
assessment committee during the oral presentation of the master's dissertation
are not included in this text.

= Acknowledgements <sec_ack>

I would like to express my deepest gratitude to Prof. dr. ir. Wim Bogaerts and
Prof. dr. ir. Dirk Stroobandt for their time, guidance, patience, and trust in
applying for an #emph[FWO] proposal to extend this Master Thesis. Through their
advice and guidance, I have gained a breadth of knowledge and understanding that
I have done my best to share in this thesis. It is with great pleasure that I
write this document to share these findings and insights with them and others
within the scientific community.

I would also like to give my most heartfelt thanks to the best friend one could
ever ask for: ir. Thomas Heuschling, for his patience, friendship, guidance and
all of the amazing moments we spent throughout our studies. I would also like to
thank him for his help in proofreading this thesis and his advice on the PHÔS
programming language. I also would like to thank Alexandre Bourbeillon for his
help and advice for the creation of the formal grammar of the PHÔS programming
language and being a great friend for over a decade.

I must also thank the incredible people that helped me proofread and improve my
thesis: Daniel Csillag and Mossa Merhi Reimert for their time, advice and
support. And Léo Masson for his help on programmatic visualisation of hexagonal
lattices and his advice regarding typesetting.

Finally, my parents, Evelyne Dekens and Baudouin d'Herbais de Thun, were also
there for me every step of the way and I deeply thank them for their support and
listening to my endless rambling about photonics and programming.

#align(right)[
  -- Sébastien d'Herbais de Thun #linebreak()
  Wavre BE, 16th of June 2023
]

= Permission of use on loan

The author gives permission to make this master dissertation available for
consultation and to copy parts of this master dissertation for personal use. In
the case of any other use, the copyright terms have to be respected, in
particular with regard to the obligation to state expressly the source when
quoting results from this master dissertation.

#align(right)[
  -- Sébastien d'Herbais de Thun #linebreak()
  Wavre BE, 16th of June 2023
]

= Abstract
In this thesis, a novel way of programmatically designing photonic circuits is
introduced, using a new programming language called PHÔS. This thesis' primary
goal is to research which paradigms, techniques, and languages are best suited
for the programmatic description of photonic circuits, with a special emphasis
on programmable photonics as it is being researched at Ghent University. This
involves an in-depth analysis of existing programming languages and paradigms,
followed by a careful analysis of the functional requirements of photonic
circuit design. This analysis highlights the need for a new language dedicated
to photonic circuit design that is able to concisely and effectively express
photonic circuits.

The design of this language is then shown, with all of the steps for its
implementation carefully detailed. Parts of this language are implemented in a
prototype compiler. One of its components, the constraint-solver, was the
primary focus of this development effort, which has shown to be capable of
simulating many photonic circuits based on simple constraints and operations. 

Finally, meaningful demonstrations of the capabilities of the language and the
constraint-solver are shown.

== Keywords

Programmable photonic, photonic circuit design, programming language, photonic
circuit simulation.

#ugent-outlines(
  // Whether to include a table of contents.
  heading: true,
  // Whether to include a list of acronyms.
  acronyms: true,
  // Whether to include a list of figures.
  figures: true,
  // Whether to include a list of tables.
  tables: true,
  // Whether to include a list of equations.
  equations: false,
  // Whether to include a list of listings (code).
  listings: true,
)