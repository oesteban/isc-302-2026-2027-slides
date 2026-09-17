// ---------------------------------------------------------------------------
// ulab1-driver-worksheet.typ — one A4 sheet per group, for µLab 1 of day 2.
//
// The referee's grid records how the group worked. This records what the driver
// produced, and it carries the four steps from the deck so that the answer to
// "what were we supposed to do again?" is on the table rather than on a slide
// that has moved on.
//
// The GitHub handle in box 1 is the only link between a published image and the
// group that built it. Illegible, and there is no way to recover it afterwards,
// which is why it is written one character per box.
//
// Committed BLANK and it must stay that way: a filled sheet carries a GitHub
// handle and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
//
//   typst compile ulab1-driver-worksheet.typ
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
  title: "µLab worksheet · a cow of your own",
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

// One character per box: the only way a handle survives being read by someone
// who was not standing there when it was written.
#let charbox = box(width: 6.4mm, height: 8mm, stroke: 0.5pt + luma(150), radius: 1pt)
#let charboxes(n) = grid(
  columns: (auto,) * n, column-gutter: 1.2mm,
  ..range(n).map(_ => charbox)
)

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
  text(size: 8pt)[Driver #text(fill: luma(140))[(writes)]], rule(100%),
  text(size: 8pt)[Mapper #text(fill: luma(140))[(does not write)]], rule(100%),
)
#v(5pt)
#text(size: 7.5pt, fill: luma(140), style: "italic")[Hand this to the teacher when the round ends.]
#v(7pt)

// ── 1. the handle ─────────────────────────────────────────────────────────
#panel("1 · Whose account is this on?")[
  #text(size: 8.5pt)[
    The driver's GitHub handle, *one character per box*. Everything you publish
    today lands under this name, and this sheet is the only thing that connects
    it back to your group. If we cannot read it, we cannot find your work.
  ]
  #v(5pt)
  #charboxes(20)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    The repository you create in step 1 #rule(45%)
  ]
]

#v(7pt)

// ── 2. the steps ──────────────────────────────────────────────────────────
#panel("2 · The first half, in four steps")[
  #step("1", "Take the template")[
    Open #raw("github.com/oesteban/whalesay") and press *Use this template* →
    *Create a new repository*, under *your own* account. Not a fork.
  ]
  #v(5pt)
  #step("2", "Branch, and add your cow")[
    #raw("git checkout -b group-N") · write #raw("group-N.cow") · commit · push.
    Cows to steal: #raw("github.com/paulkaefer/cowsay-files")
  ]
  #v(5pt)
  #step("3", "Build it and make it talk")[
    #raw("docker build -t my_whale .") then
    #raw("docker run --rm my_whale -f group-N \"hi from group N\"")
  ]
  #v(5pt)
  #step("4", "Open the pull request")[
    Against the default branch, *in your own repository*. Then watch the
    *Actions* tab.
  ]
]

#v(7pt)

// ── 3. docker images ──────────────────────────────────────────────────────
// The sum-of-sizes question is the one worth the paper: `docker images` reports
// each image's full size including its base, so the two numbers add up to more
// than the disk actually holds. Nobody guesses this; everybody can check it.
#panel("3 · What you built")[
  #text(size: 8.5pt)[After step 3, run `docker images`.]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[Size of `my_whale`], rule(100%),
    text(size: 8pt)[Size of `alpine`], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    You added one small text file to `alpine` and got a much larger image.
    What else went in, and which line of the `Dockerfile` put it there?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Add the two sizes together. Now check how much disk Docker is really using
    with `docker system df`. The numbers disagree — why?
  ]
  #writing(2)
]

#pagebreak()

// ── 4. --rm ───────────────────────────────────────────────────────────────
#panel("4 · What `--rm` was for")[
  #text(size: 8.5pt)[Run the same cow twice, then look at what is left behind.]
  #v(4pt)
  #text(size: 8pt)[
    #raw("docker run --rm my_whale -f group-N \"one\"") \
    #raw("docker run my_whale -f group-N \"two\"") #text(fill: luma(140))[← no `--rm`]
  ]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[`docker ps` shows], rule(100%),
    text(size: 8pt)[`docker ps -a` shows], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    Both printed a cow and both finished. One of them is still on your machine.
    What is still there, and what is it still holding?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Run the no-`--rm` version three more times. How many entries in `docker ps -a`
    now? #rule(18mm) #h(4pt) Clear them, and write the command you used.
  ]
  #writing(1)
]

#v(7pt)

// ── 5. detach and exec ────────────────────────────────────────────────────
// --entrypoint is the point of this box: cowsay says its piece and exits, so
// there is nothing to detach from until you replace it. Discovering *why* the
// override is needed is the lesson; the override itself is just syntax.
#panel("5 · A container you can walk back into")[
  #text(size: 8.5pt)[
    `docker run -d` detaches. Try it on `my_whale` as it is, first, and see what
    `docker ps` says a few seconds later.
  ]
  #writing(1)
  #v(5pt)
  #text(size: 8.5pt)[Now give it something that does not finish immediately:]
  #v(3pt)
  #text(size: 8pt)[
    #raw("docker run -d --name cow --entrypoint sleep my_whale 600") \
    #raw("docker exec cow ls /usr/local/share/cows/") \
    #raw("docker exec cow cowsay -f group-N \"from inside\"")
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Why did the first attempt need no `--entrypoint` and this one does?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Compare `docker exec cow whoami` with `whoami` in your own terminal, and
    `docker exec cow ls /` with `ls /`. Same machine or not? Say how you know.
  ]
  #writing(2)
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    Stop it and remove it. Commands used: #rule(55%)
  ]
]

#pagebreak()

// ── 6. history and the cache ──────────────────────────────────────────────
// Observation only. Topic 2 on Monday explains the cache; a group that has
// already watched CACHED appear has something to hang that talk on.
#panel("6 · What the image remembers")[
  #text(size: 8.5pt)[Run `docker image history my_whale`.]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[Lines your `Dockerfile` added], rule(100%),
    text(size: 8pt)[Largest single line], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    Most lines are `0B`. What does a line of `0B` mean actually happened?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 8.5pt)[
    Add a second cow file and rebuild with the same command. Watch the output.
  ]
  #v(4pt)
  #text(size: 7.5pt, fill: luma(130))[
    Which steps re-ran, and which said `CACHED`? Write the first step that
    re-ran. #rule(40%)
  ]
  #v(4pt)
  #text(size: 7.5pt, fill: luma(130))[
    You changed one file. Why did that step, and not an earlier one, have to run
    again? Guess, and say what would test your guess.
  ]
  #writing(2)
]

#v(7pt)

// ── 7. the pull request ───────────────────────────────────────────────────
#panel("7 · Something else built it")[
  #text(size: 8.5pt)[After step 4, open the *Actions* tab on your repository.]
  #v(5pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[The run took], rule(100%),
    text(size: 8pt)[It ran on], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    That machine has never seen your laptop. What did it need from you to build
    your image, and where did it get it?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    The run finished green, and nothing was published. Say where you looked to
    be sure of that.
  ]
  #writing(2)
]

#pagebreak()

// ── 8. the compose stack ──────────────────────────────────────────────────
// The file is printed in full on purpose. The exercise is not to invent YAML
// from nothing in forty minutes; it is to see two containers cooperate without
// ever addressing each other, and to be able to say how.
#panel("8 · A web front end and a cow back end")[
  #text(size: 8.5pt)[
    Two containers. `cow` writes a page and stops. `web` serves it and stays up.
    They never talk to each other: they share one *named volume*, mounted at a
    different path in each. Put this in `compose.yaml`:
  ]
  #v(4pt)
  #block(inset: (x: 5pt, y: 4pt), fill: luma(245), radius: 2pt, width: 100%)[
    #text(size: 7.5pt)[
      ```yaml
      services:
        cow:
          image: my_whale
          entrypoint: ["/bin/sh", "-c"]
          command: ["{ echo '<pre>'; cowsay -f group-N 'your words'; echo '</pre>'; } > /srv/index.html"]
          volumes:
            - site:/srv

        web:
          image: nginx:alpine
          depends_on:
            cow:
              condition: service_completed_successfully
          ports: ["8080:80"]
          volumes:
            - site:/usr/share/nginx/html:ro

      volumes:
        site:
      ```
    ]
  ]
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    Four things in there are worth knowing rather than copying. `nginx` serves
    whatever is in `/usr/share/nginx/html`. `cowsay` writes to the screen, not to
    a file, so it needs a shell to redirect it — that is what overriding the
    entrypoint buys. The `<pre>` stops a browser collapsing the artwork. And
    `service_completed_successfully` is what stops `web` starting before there is
    anything to serve.
  ]
  #v(6pt)
  #text(size: 8.5pt)[
    #raw("docker compose up -d") then #raw("curl localhost:8080")
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    `docker compose ps` does not list `cow`. Where did it go, and which flag from
    box 4 finds it? #rule(38%)
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    `cow` exited. Is that a failure? Say what would make it one.
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    `web` never asks `cow` for anything. Trace how the words get from one
    container to the other, naming each thing they pass through.
  ]
  #writing(3)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Change the words, and run `docker compose up -d` again. Compose recreated one
    container and left the other alone. Which, and why that one?
  ]
  #writing(2)
]

#v(7pt)
#align(center)[
  #text(size: 7.5pt, fill: luma(140), style: "italic")[
    Done when `curl localhost:8080` prints your cow, `cow` has exited 0, and `web`
    is still up.
  ]
]
