// ---------------------------------------------------------------------------
// flipped-worksheets.typ — one A4 brief per flipped-class topic.
//
// Handed out at the lottery on day 1: the student draws a folded sheet and
// walks away holding the brief. That is why every sheet is self-contained,
// carries its own deadlines, and never says "see the schedule".
//
// Content comes from flipped-topics.yml — the single source of truth. Do not
// edit topics here; edit the YAML and recompile.
//
//   typst compile flipped-worksheets.typ
//
// Requires the ISC fonts:  source src/fonts/install_fonts.sh
// from https://github.com/ISC-HEI/isc-hei-typst-templates
// ---------------------------------------------------------------------------

#import "@preview/isc-hei-document:0.8.1": *

#let data = yaml("flipped-topics.yml")

// slot id -> slot record, so a sheet can print its own dates
#let slot-of = {
  let m = (:)
  for s in data.slots { m.insert(str(s.id), s) }
  m
}

#show: project.with(
  doc-type: "document",
  show-cover: false,
  show-toc: false,
  fancy-line: true,
  title: "Flipped class — topic briefs",
  subtitle: [#data.section],
  authors: (data.teacher,),
  date: datetime(year: 2026, month: 9, day: 14),
  revision: "1.0",
  language: "en",
  logo: auto,
)

#set heading(numbering: none)

#let accent = rgb("#dc0069")

// A small uppercase section label.
#let lbl(it) = block(above: 1.0em, below: 0.35em)[
  #text(size: 7.5pt, weight: "bold", tracking: 0.09em, fill: accent, upper(it))
]

// A reference's link, shown as something typeable off paper: a DOI reads as
// doi:10.xxxx/yyyy, anything else as the URL without its scheme. The text is
// also the link target, so the PDF works both printed and on screen.
#let doi-label(u) = {
  if u.starts-with("https://doi.org/") { "doi:" + u.slice(16) }
  else if "/doi/" in u { "doi:" + u.split("/doi/").at(1) }
  else { u.replace("https://", "") }
}

// The question the talk has to answer: the one thing on the sheet in a box.
#let question-box(it) = block(
  width: 100%, inset: (x: 10pt, y: 8pt), radius: 4pt,
  stroke: 0.6pt + accent,
)[#text(size: 10.5pt, style: "italic")[#it]]

#let worksheet(t) = {
  let s = slot-of.at(str(t.slot))

  text(size: 8pt, fill: luma(110))[
    Flipped class · #data.course · topic #t.id of #data.topics.len()
    #h(1fr) presents *#s.presents*
  ]
  v(-2pt)
  line(length: 100%, stroke: 0.6pt + luma(180))

  heading(level: 1)[#t.title]

  question-box(t.question)

  lbl("Your presentation (15 minutes + 10 min Q&A)")
  text(size: 9.5pt)[This could be the structure of your talk. Nonetheless, you are free to improve or modify to ensure the topic will be more accessible.]
  v(2pt)
  for (i, beat) in t.shape.enumerate() {
    block(above: 2.5pt, below: 2.5pt)[
      #text(size: 9.5pt, fill: luma(140))[#(i + 1).] #h(4pt) #text(size: 9.5pt)[#beat]
    ]
  }

  lbl("Your demo (aim at 2 min, but flexible if you blend it nicely with the presentation)")
  text(size: 9.5pt)[#t.demo]
  v(3pt)
  text(size: 8.5pt, fill: luma(110))[
    Demo should run in about 2 minutes, and should be a demo unless a teacher allows you to bring pre-baked results.
  ]

  lbl("Your three deliverables")
  table(
    columns: (auto, 1fr, auto),
    stroke: none,
    inset: (x: 0pt, y: 3.5pt),
    column-gutter: (8pt, 10pt),
    align: (left, left, right),
    text(size: 9pt, weight: "bold")[C1], text(size: 9pt)[*Angle* — one slide: the topic in your own words, the question you answer, what your demo will show], text(size: 9pt)[#s.c1],
    text(size: 9pt, weight: "bold")[C2], text(size: 9pt)[*Demo runs* — the code, a README, one command], text(size: 9pt)[#s.c2],
    text(size: 9pt, weight: "bold")[C3], text(size: 9pt)[*Deck* — complete slides, demo embedded], text(size: 9pt)[#s.c3],
  )
  v(2pt)
  text(size: 8.5pt, fill: luma(110))[
    All three interim materials must be uploaded into ISC Learn by 18:00; the demo as a repository link.
    These deliverables are mandatory, and the teacher will provide feedback to improve your work.
  ]

  if t.refs.len() > 0 {
    lbl("Reading")
    for r in t.refs {
      block(above: 2pt, below: 0pt, text(size: 9.5pt)[
        #r.cite
        #if "url" in r [
          #h(5pt) #text(size: 8.5pt, fill: accent)[#link(r.url)[#doi-label(r.url)]]
        ]
      ])
    }
  }

  // Room to think on the sheet itself: it is a working document, not a poster.
  // The 1fr comes first so the notes sit in whatever gap the topic leaves,
  // rather than adding height and pushing a long topic onto a second page.
  v(1fr)
  lbl("Notes")
  v(1pt)
  for _ in range(5) {
    line(length: 100%, stroke: 0.4pt + luma(215))
    v(9pt)
  }

  v(6pt)
  line(length: 100%, stroke: 0.4pt + luma(200))
  v(2pt)
  text(size: 9pt, fill: luma(110))[Drawn by #box(width: 6cm, repeat[.]) #h(1fr) #data.lottery]
}

// ── cover page ────────────────────────────────────────────────────────────
// The template's header belongs to a cover, not to topic 1. So the menu goes
// here and every brief, the first included, starts on a page of its own.
#text(size: 10pt)[
  Sixteen topics, one each. You draw yours on #data.lottery and teach it on the
  date its slot shows below.
]

#v(10pt)

#for s in data.slots [
  #lbl("Presents " + s.presents)
  #for t in data.topics.filter(x => x.slot == s.id) [
    #block(above: 2.5pt, below: 2.5pt)[
      #box(width: 7mm)[#text(size: 9.5pt, fill: luma(150))[#t.id]]#text(size: 9.5pt)[#t.title]
    ]
  ]
  #v(7pt)
]

#for t in data.topics {
  pagebreak()
  worksheet(t)
}
