#import "@preview/polylux:0.3.1": *
#import "@preview/codly:0.1.0": *
#import "ugent-theme.typ": *

// Get the current date, you can also replace it with your
// presentation's date:
// #let date = datetime(year: 2023, month: 06, day: 29)
#let date = datetime.today()

// Configure the slides:
#show: ugent-theme.with(
  // The authors of the presentation
  authors: "<your full name>",

  // The short version of your name (e.g. for the footer)
  short-authors: "<shortened version of your name>",

  // The role you have in the University
  role: [ Student ],

  // The title of the presentation
  title: [ \<full thesis title\> ],

  // The subtitle of the presentation
  subtitle: [
      Master's thesis defence - \<full name\> - \<presentation date\>
      #linebreak()
      Promoters: \<promoters names & titles\>
  ],

  // The short title of the presentation (e.g. for the footer)
  short-title: [ Defence of Master's thesis ],

  // The date of the presentation
  date: date,

  // The email address you want to display on the slides (or `none`)
  email: "<your email address>@ugent.be",

  // The mobile number you want to display on the slides (or `none`)
  mobile: "<your mobile number>",

  // The department you are part of
  dept: "<your department>",

  // The research group you are part of
  research-group: "<your research group>",

  // The link to your LinkedIn profile
  linkedin: "<your linkedin profile>",

  // Set this to true to generate a handout version of the slides.
  handout: false,

  // Whether to display a small progress bar at the bottom of the slides.
  progress-bar: false,
)

// Configure codly
#show: codly-init.with()
#codly()

// UGent logo
#corporate-logo()

// Global title slide
#title-slide()

// Print a nice outline of the presentation
#outline-slide()

// Start of the first section
#section-slide("Introduction")

// We create a simple slide.
#slide(title: "Hello, world!")[
  - Welcome to this demo
  - Of the UGent theme for Typst
  - Made with Polylux
][
  - It can even span two columns!
  - Just like this
  - How awesome is that?
]

#slide(title: "Codly")[
  ```rs
  fn main() {
    println!("Hello, world!");
  }
  ```
]

#slide(title: "One by one")[
  #line-by-line[
    - This
    - Slide
    - Is
    - Awesome
  ]
]

#slide(title: "And a pretty image", kind: "image")[
  #image("assets/programmable-pic-hierarchy.png")
]

#image-slide(title: "And a pretty image", kind: "content,image")[
  And a caption!
][
  #image("assets/big_circuit.png", width: 100%)
]

#slide(title: "Two contents size by side!", colwidths: (auto, 1fr))[
  - A list
  - With a picture
  - On the side,
  - Wrapped in a figure!
][
  #figure(
    caption: [
      A hierarchy of programmable PICs courtesy  of Prof. dr. ir. Wim Bogaerts
    ],
    image("assets/programmable-pic-hierarchy.png")
  )
]

// Final end slide
#end-slide()