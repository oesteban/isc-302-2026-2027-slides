// ---------------------------------------------------------------------------
// referee-grid.typ — one A4 sheet per referee per microLab.
//
// Sixteen students run as four teams of four: driver, mapper and TWO
// independent referees. The two referees do not confer and do not read each
// other's notes, so each one fills their own copy of this sheet.
//
// Committed BLANK and it must stay that way: a filled sheet carries student
// names and is personally identifying. It is handed to the teacher at the
// caucus, never returned, never photographed, and never enters git. See the
// PII doctrine in the repository CLAUDE.md.
//
//   typst compile referee-grid.typ
//
// Requires the ISC fonts:  source src/fonts/install_fonts.sh
// from https://github.com/ISC-HEI/isc-hei-typst-templates
//
// Ported from the earlier hand-written HTML version, which fitted one page but
// was our own look rather than the ISC one.
// ---------------------------------------------------------------------------

#import "@preview/isc-hei-document:0.8.1": *

#show: project.with(
  doc-type: "document",
  show-cover: false,
  show-toc: false,
  fancy-line: true,
  title: "µLab referee log",
  subtitle: [302 Data infrastructures · microLabs],
  authors: ("",),
  date: datetime(year: 2026, month: 9, day: 14),
  revision: "1.0",
  language: "en",
  logo: auto,
)

// Portrait, because the ISC template hard-sets `paper: "a4"` inside project()
// and a page rule in the body cannot override it. The form was reflowed to
// suit: lanes full width, the two tallies side by side, criteria in a pair.
#set text(size: 8pt)
#set heading(numbering: none)

#let accent = rgb("#dc0069")
#let hair = 0.4pt + luma(190)

#let lbl(it, fill: accent) = text(size: 6.5pt, weight: "bold", tracking: 0.08em, fill: fill, upper(it))

// A rule to write on, and the same with a label in front of it.
#let rule(w) = box(width: w, stroke: (bottom: 0.5pt + luma(120)), height: 8pt)
#let fld(name, w) = box[#text(size: 7.5pt)[#name] #rule(w)]

// A panel with the accent top rule the ISC look uses.
#let panel(title, body, title-fill: accent) = block(
  width: 100%, inset: (x: 5pt, y: 3pt), radius: 2pt,
  stroke: (top: 1.4pt + title-fill, rest: hair),
)[
  #lbl(title, fill: title-fill)
  #v(2pt)
  #body
]

// One tally row: description, dotted leader, a box to mark in.
#let tally(desc) = block(above: 0.8pt, below: 0.8pt)[
  #box(width: 1fr)[#text(size: 7pt)[#desc]]
  #box(width: 14mm, stroke: (bottom: 0.5pt + luma(140)), height: 7pt)
]

// A tally row carrying its sign. The sign is boxed to a fixed width so every
// row's text starts on the same edge, and "+" has to be escaped or Typst reads
// it as the start of an enumerated list.
#let tpos(desc) = tally[#box(width: 3.4mm)[#text(weight: "bold")[\+]] #desc]
#let tneg(desc) = tally[#box(width: 3.4mm)[#text(weight: "bold")[−]] #desc]

// ── header ────────────────────────────────────────────────────────────────
// No border: these read as fields already, and a box around them is clutter.
// The µLab rule takes the slack so Date and Time sit flush right.
#grid(columns: (auto, 1fr, auto), column-gutter: 6pt, align: bottom,
  text(size: 7.5pt)[µLab name:],
  rule(100%),
  text(size: 7.5pt)[Date #rule(22mm) #h(8pt) Time #rule(13mm) → #rule(13mm)],
)
#v(7pt)
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 7.5pt)[Driver], rule(100%),
  text(size: 7.5pt)[Mapper], rule(100%),
)
#v(7pt)
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 7.5pt)[Name:], rule(100%),
  text(size: 7.5pt)[Other referee (or n/a):], rule(100%),
)
#v(7pt)

// ── session notes ─────────────────────────────────────────────────────────
// The instrument. Everything the four removed panels used to occupy goes here.
#let LANES = 11
#let LANE = 8.6mm
#panel("Session notes")[
  #table(
    columns: (13mm, 1fr), stroke: none, inset: (x: 2pt, y: 0pt),
    ..range(LANES).map(_ => (
      block(height: LANE)[#v(1fr) #text(size: 7pt, fill: luma(130))[\_\_:\_\_]],
      block(height: LANE, width: 100%, stroke: (bottom: hair))[],
    )).flatten()
  )
  #v(5pt)
  #grid(columns: (auto, 1fr), column-gutter: 10pt, align: bottom,
    text(size: 7.5pt)[*SOLUTION REACHED* #h(5pt) #box(width: 3.2mm, height: 3.2mm, stroke: 0.6pt, baseline: 0.5mm) #h(6pt) at #rule(16mm)],
    text(size: 7pt)[if not reached, what was missing #box(width: 1fr, stroke: (bottom: hair), height: 8pt)],
  )
  #block(above: 5pt)[#text(size: 7pt)[Most positive aspect/event in lab:] #box(width: 1fr, stroke: (bottom: hair), height: 8pt)]
  #block(above: 3pt)[#text(size: 7pt)[Negative aspects/events to remark:] #box(width: 1fr, stroke: (bottom: hair), height: 8pt)]
]

#v(3pt)

// ── one column per role ───────────────────────────────────────────────────
// Sorted by role, not by valence: the driver and the mapper are graded
// separately, so the sheet has to add up separately for each of them.
#grid(columns: (1fr, 1fr), column-gutter: 5pt,
  panel("Driver · one mark per occurrence")[
    #tpos[states intent before typing]
    #tpos[asks in their own words]
    #tpos[reads the error before reacting]
    #tpos[restates the mapper's answer]
    #tneg[types, cannot say what for]
    #tneg[“ask the LLM to…”]
    #tneg[doesn't carefully read the error]
    #tneg[types a dictated line verbatim]
    #tneg[operates uncritically or not understanding]
  ],
  panel("Mapper · one mark per occurrence")[
    #tpos[names a source]
    #tpos[checks the driver understood]
    #tpos[waits, lets the driver try]
    #tpos[re-prompts LLMs to understand the answer]
    #tneg[answer with no named source]
    #tneg[fails to listen carefully]
    #tneg[pre-empts, does not let the driver try]
    #tneg[provides feedback from dubious sources or raw LLM outputs]
  ],
)

#v(3pt)

// ── the only grading on the sheet ─────────────────────────────────────────
#panel("Grade")[
  #grid(columns: (16mm, 20mm, 20mm, auto), column-gutter: 10pt, row-gutter: 5pt, align: bottom,
    [],
    text(size: 7pt, fill: luma(120))[marks +],
    text(size: 7pt, fill: luma(120))[marks −],
    text(size: 7pt, fill: luma(120))[grade],
    text(size: 7.5pt)[*Driver*], rule(100%), rule(100%), rule(18mm),
    text(size: 7.5pt)[*Mapper*], rule(100%), rule(100%), rule(18mm),
  )
]
