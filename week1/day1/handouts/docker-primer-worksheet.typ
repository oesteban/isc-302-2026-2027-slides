// ---------------------------------------------------------------------------
// docker-primer-worksheet.typ — one A4 sheet per pair, for the first microLab.
//
// The referee's log records how the pair worked. This records what they
// produced: the collateral that testifies the pair actually addressed the
// question rather than agreeing that they understood it.
//
// The driver holds the pen. The mapper looks things up and says them out loud
// and writes nothing, which is what makes the referee's "restates the mapper's
// answer" and "types a dictated line verbatim" rows observable on paper as
// well as on the keyboard.
//
// Committed BLANK and it must stay that way: a filled sheet carries student
// names and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
//
//   typst compile docker-primer-worksheet.typ
//
// Requires the ISC fonts:  source src/fonts/install_fonts.sh
// from https://github.com/ISC-HEI/isc-hei-typst-templates
// ---------------------------------------------------------------------------

#import "@preview/isc-hei-document:0.8.1": *

#show: project.with(
  doc-type: "document",
  show-cover: false,
  show-toc: false,
  fancy-line: true,
  title: "µLab worksheet · Docker primer",
  subtitle: [302 Data infrastructures · week 1, day 1],
  authors: ("",),
  date: datetime(year: 2026, month: 9, day: 14),
  revision: "1.0",
  language: "en",
  logo: auto,
)

#set text(size: 9pt)
#set heading(numbering: none)

#let accent = rgb("#dc0069")
#let hair = 0.4pt + luma(190)

#let lbl(it, fill: accent) = text(size: 7pt, weight: "bold", tracking: 0.09em, fill: fill, upper(it))

#let rule(w) = box(width: w, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)

#let panel(title, body) = block(
  width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt,
  stroke: (top: 1.4pt + accent, rest: hair),
)[
  #lbl(title)
  #v(3pt)
  #body
]

// n full-width lines to write on.
#let writing(n) = {
  for _ in range(n) {
    block(width: 100%, height: 15pt, above: 3pt, below: 0pt, stroke: (bottom: hair))[]
  }
}

// One numbered slot for a layer hash: the ordinal, then five characters of room.
#let slot(i) = box[
  #text(size: 6.5pt, fill: luma(150))[#i]
  #box(width: 12mm, stroke: (bottom: 0.5pt + luma(140)), height: 9pt)
]

// ── header ────────────────────────────────────────────────────────────────
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Group], rule(100%),
  text(size: 8pt)[Date #rule(20mm) #h(6pt) Time], rule(24mm),
)
#v(6pt)
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Driver #text(fill: luma(140))[(writes)]], rule(100%),
  text(size: 8pt)[Mapper #text(fill: luma(140))[(does not write)]], rule(100%),
)
#v(5pt)
#text(size: 7.5pt, fill: luma(140), style: "italic")[Hand this to the teacher when the round ends.]
#v(7pt)

// ── 1. the layers ─────────────────────────────────────────────────────────
#panel("1 · The layers of oesteban/neuropipeline-302")[
  #text(size: 8.5pt)[
    `docker pull` prints one line per layer. Write the *first five characters*
    of each, in the order they appear. Leave the rest of the boxes blank.
  ]
  #v(5pt)
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr), row-gutter: 11pt, column-gutter: 5pt,
    ..range(1, 25).map(i => slot(i))
  )
  #v(3pt)
  #text(size: 7.5pt, fill: luma(130))[How many layers in total? #rule(14mm)]
]

#v(7pt)

// ── 2. the output of the commands ─────────────────────────────────────────
#panel("2 · What the commands told you")[
  #text(size: 8.5pt)[
    Run `docker info` and copy three of the values it prints.
  ]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[Server version], rule(100%),
    text(size: 8pt)[Storage driver], rule(100%),
    text(size: 8pt)[Docker root dir], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    Every layer in box 1 is on your disk right now, under one of those three.
    Which one, and what else would you expect to find there?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    The *first* time you ran `docker run oesteban/whalesay`, it printed
    something before the cow appeared. What, and why?
  ]
  #writing(2)
]

#v(7pt)

// ── 3. what a layer is ────────────────────────────────────────────────────
#panel("3 · What is a layer?")[
  #text(size: 7.5pt, fill: luma(130))[In your own words.]
  #writing(3)
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[Where did the answer come from? #rule(60%)]
]

#pagebreak()

// ── 4. image versus container ─────────────────────────────────────────────
#panel("4 · An image and a container are not the same thing")[
  #text(size: 7.5pt, fill: luma(130))[What is the difference? A sentence each is enough.]
  #writing(3)
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[Where did the answer come from? #rule(60%)]
]

#v(9pt)

// ── 5. the two stacks ─────────────────────────────────────────────────────
// Open paper, no boxes: a drawn stack is a pile of rectangles and a frame
// around it only competes with them.
#panel("5 · The two stacks")[
  #text(size: 7.5pt, fill: luma(130))[
    Draw them side by side. What does the container *not* have?
  ]
  #v(6pt)
  #grid(columns: (1fr, 1fr), column-gutter: 10pt,
    text(size: 6.5pt, weight: "bold", tracking: 0.08em, fill: luma(150))[CONTAINERS],
    text(size: 6.5pt, weight: "bold", tracking: 0.08em, fill: luma(150))[VIRTUAL MACHINES],
  )
  #v(135mm)
]
