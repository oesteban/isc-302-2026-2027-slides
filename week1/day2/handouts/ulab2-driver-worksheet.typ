// ---------------------------------------------------------------------------
// ulab2-driver-worksheet.typ — one A4 sheet per group, for µLab 2 of day 2.
//
// The referee's grid records how the group worked. This records what the driver
// produced, and it carries the four steps from the deck so that the answer to
// "what were we supposed to do again?" is on the table.
//
// The roles rotate between rounds: whoever drove µLab 1 is not driving this one.
//
// Box 4 is a failure on purpose. The bind mount is the mistake every group makes
// with the Docker socket, it produces no error, and being made to do it once
// deliberately is cheaper than losing twenty minutes to it by accident.
//
// Committed BLANK and it must stay that way: a filled sheet is handed to the
// teacher at the end of the round, never returned, never photographed, and never
// enters git. See the PII doctrine in the repository CLAUDE.md.
//
//   typst compile ulab2-driver-worksheet.typ
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
  title: "µLab worksheet · one image, two jobs",
  subtitle: [302 Data infrastructures · week 1, day 2],
  authors: ("",),
  date: datetime(year: 2026, month: 9, day: 18),
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
  width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, breakable: false,
  stroke: (top: 1.4pt + accent, rest: hair),
)[
  #lbl(title)
  #v(3pt)
  #body
]

#let writing(n) = {
  for _ in range(n) {
    block(width: 100%, height: 15pt, above: 3pt, below: 0pt, stroke: (bottom: hair))[]
  }
}

#let tick = box(width: 8pt, height: 8pt, stroke: 0.6pt + luma(140), radius: 1pt)

#let step(n, title, body) = grid(
  columns: (auto, 1fr), column-gutter: 6pt, align: (top, top),
  text(size: 8pt, weight: "bold", fill: accent)[#n#h(3pt)#tick],
  [#text(size: 8.5pt, weight: "bold")[#title] \ #text(size: 8pt)[#body]],
)

// ── header ────────────────────────────────────────────────────────────────
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Group], rule(100%),
  text(size: 8pt)[Date #rule(20mm) #h(6pt) Time], rule(24mm),
)
#v(6pt)
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Driver #text(fill: luma(140))[(not the one who drove round 1)]], rule(100%),
  text(size: 8pt)[Mapper], rule(100%),
)
#v(5pt)
#text(size: 7.5pt, fill: luma(140), style: "italic")[Hand this to the teacher when the round ends.]
#v(7pt)

// ── 1. the steps ──────────────────────────────────────────────────────────
#panel("1 · The round, in four steps")[
  #step("1", "Measure what you were given")[
    #raw("docker image ls oesteban/neuropipeline-302") — write the number down.
  ]
  #v(5pt)
  #step("2", "Build the notebook half")[
    Jupyter and the viewer, plus `docker-cli`, and *none* of the neuroimaging
    stack. Measure that one too.
  ]
  #v(5pt)
  #step("3", "Give it the socket and a volume")[
    #raw("docker volume create project") then run the notebook with both
    #raw("-v project:...") and #raw("-v /var/run/docker.sock:/var/run/docker.sock")
  ]
  #v(5pt)
  #step("4", "Drive the tools from a cell")[
    The notebook holds no tools. It starts a container that does.
  ]
]

#v(7pt)

// ── 2. the monolith ───────────────────────────────────────────────────────
#panel("2 · What you were given")[
  #text(size: 8.5pt)[
    The image carries its own recipe. Read it without unpacking anything:
  ]
  #v(3pt)
  #text(size: 8pt)[#raw("docker run --rm oesteban/neuropipeline-302 cat /opt/302/Dockerfile")]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[Size], rule(100%),
    text(size: 8pt)[Layers #text(fill: luma(140))[(`image history`)]], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    Name two things in that `Dockerfile` that a person *running* the notebook
    never needs, and say who does need them.
  ]
  #writing(2)
]

#v(7pt)

// ── 3. the notebook half ──────────────────────────────────────────────────
#panel("3 · The half you build")[
  #text(size: 8.5pt)[
    A Jupyter image with `docker-cli` in it and no neuroimaging software at all.
  ]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[Its size], rule(100%),
    text(size: 8pt)[Times smaller], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    You added a tool to this image (`docker-cli`) in order to *remove* tools from
    it. Say in one sentence why that is not a contradiction.
  ]
  #writing(2)
]

#pagebreak()

// ── 4. the trap, on purpose ───────────────────────────────────────────────
// -v <path> inside a container is resolved by the DAEMON, on the host. A path
// that exists only in the notebook arrives empty, with no error and no clue.
// Every group meets this. Meeting it deliberately costs two minutes.
#panel("4 · Get it wrong first, on purpose")[
  #text(size: 8.5pt)[
    From inside the notebook, make a directory and put a file in it. Then start a
    container mounting *that path* and look at what arrived:
  ]
  #v(3pt)
  #text(size: 8pt)[
    #raw("mkdir -p /tmp/mine && echo hello > /tmp/mine/file") \
    #raw("docker run --rm -v /tmp/mine:/mnt alpine ls -A /mnt")
  ]
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    What did it list? #rule(30%) #h(4pt) Was there an error? #rule(20%)
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    The path exists. You just made it. So who went looking for it, and where did
    *they* look?
  ]
  #writing(3)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Now do it again with a *named volume* instead of a path, and say why that
    one works.
  ]
  #writing(2)
]

#v(7pt)

// ── 5. the pipeline ───────────────────────────────────────────────────────
#panel("5 · Driving the tools from a cell")[
  #text(size: 8.5pt)[
    Put the data in the volume first, then one container per step. Every line
    below starts a container, and every container is gone before the next begins.
  ]
  #v(4pt)
  #block(inset: (x: 5pt, y: 4pt), fill: luma(245), radius: 2pt, width: 100%)[
    #text(size: 7.5pt)[
      ```sh
      W=/home/databot/work
      T=oesteban/neuropipeline-302

      # seed the volume, and its ownership, from the image itself
      !docker run --rm -v project:$W $T sh -c "cp \$HOME/data/ds000005/sub-01/anat/sub-01_T1w.nii.gz $W/"

      !docker run --rm -v project:$W $T mri_synthstrip -i $W/sub-01_T1w.nii.gz -o $W/brain.nii.gz
      !docker run --rm -v project:$W $T niimath $W/brain.nii.gz -unifize $W/uni.nii.gz
      !docker run --rm -v project:$W $T tissue_segment $W/uni.nii.gz $W/dseg.nii.gz
      !docker run --rm -v project:$W $T tissue_volumes $W/dseg.nii.gz $W/volumes.tsv
      ```
    ]
  ]
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    Write the three tissue volumes it reports.
    CSF #rule(20mm) #h(3pt) GM #rule(20mm) #h(3pt) WM #rule(20mm)
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    There is no neuroimaging software in your notebook image. So how did a brain
    get segmented? Answer in terms of *who ran what, where*.
  ]
  #writing(3)
]

#pagebreak()

// ── 6. what it cost ───────────────────────────────────────────────────────
#panel("6 · What the split cost, and what it bought")[
  #text(size: 7.5pt, fill: luma(130))[
    Run `docker ps` in another terminal while a step is running, and again two
    seconds later. What is different, and what does that tell you about where
    the work happens?
  ]
  #writing(3)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Both containers mounted `project`. Neither could see the other's filesystem.
    So where does the brain image actually live between two steps?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Samira's replacement wants to change the segmentation tool next month.
    With the monolith, what would have to be rebuilt? With the split?
  ]
  #writing(3)
]

#v(7pt)

// ── 7. the socket, again ──────────────────────────────────────────────────
#panel("7 · The thing you handed over")[
  #text(size: 8.5pt)[
    You gave a notebook `/var/run/docker.sock`. A notebook that runs whatever
    anyone types into it.
  ]
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    Name one thing a cell could now do that has nothing to do with neuroimaging.
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    This is fine on your own laptop this afternoon. Say the condition that would
    make it not fine.
  ]
  #writing(2)
]

#v(7pt)
#align(center)[
  #text(size: 7.5pt, fill: luma(140), style: "italic")[
    Done when the notebook renders a brain it did not compute, and you can state
    both image sizes.
  ]
]
