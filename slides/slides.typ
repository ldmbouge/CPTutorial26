#import "@preview/touying:0.7.1": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly
#import "algo.typ": algo, i, d, comment, _algo-default-keywords
#import "@preview/fontawesome:0.6.0": *


#show: metropolis-theme.with(
    aspect-ratio: "16-9",
    //footer: self => none,
    //footer: self => self.info.institution,
    footer: self => context utils.slide-counter.display() + " / " + utils.last-slide-number,
    //footer-right: [#image("./uconn-wordmark-stacked-blue.png")],
    footer-right: [],
    header-right: [#box(height: 30pt,image("./uconn-wordmark-stacked-white.png"))],
    config-info(
        title: [CP Everywhere for Everyone All at Once],
        subtitle: [From Nothing to Scheduling with M\*\*iCP! (CP'26)],
        author: [Augustin Delecluse (UCL), Laurent Michel (UConn), Pierre Schaus (UCL)],
        date: [] , // datetime.today()
        institution: [School of Computing, University of Connecticut, Universite Catholique de Louvain],
        contact: [ldm\@engr.uconn.edu, ...],
        logo: [#box(height: 50pt,image("./uconn-wordmark-stacked-blue.png"))],
    ),
    config-colors(
        primary: rgb("#eb811b"),
        primary-light: rgb("#d6c6b7"),
        secondary: rgb("#000E2F"),
        neutral-lightest: rgb("#ffffff"),
        //neutral-lightest: rgb("#fafafa"),
        neutral-dark: rgb("#000e2f"),
        //neutral-dark: rgb("#23373b"),
        neutral-darkest: rgb("#23373b"),
    )
)

// Macros
#let DD = $D#h(-3pt)D$
#let emph(body) = text(fill: rgb("#eb811b"), weight: "regular")[#body]
#let bf(body) = text(weight: "bold", fill: rgb("#23373b"))[#body]


#show outline.entry: it => block(above: 0.8em)[
  • #link(it.element.location(), it.element.body)
]

#title-slide()

= Outline <touying:hidden>
#outline(title: none, indent: 1em, depth: 1)

= CP in a Nutshell

= Modeling with MiniCP

= Solving with MiniCP

= Scheduling / Routing with MaxiCP

= Setting up for the exercices

= Conclusion
---
- This was great!
- See you tomorrow for exercises.
- Videos for setting up your development environment.

#box(baseline: 0.1em)[#text(size: 24pt)[#fa-icon("github")]] #h(0.3em) http://www.minicp.org/

#box(baseline: 0.1em)[#text(size: 24pt)[#fa-icon("github")]] #h(0.3em) http://www.maxicp.org/

#box(baseline: 0.1em)[#text(size: 24pt)[#fa-icon("github")]] #h(0.3em) https://github.com/ldmbouge/minicpp
