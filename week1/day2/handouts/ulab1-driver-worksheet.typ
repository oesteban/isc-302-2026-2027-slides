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
    *Create a new repository*, under *your own* account.
  ]
  #v(5pt)
  #step("2", "Branch, and add your cow")[
    #raw("git checkout -b group-N") · write #raw("group-N.cow") · commit · push.
  ]
  #v(5pt)
  #step("3", "Build it and make it talk")[
    #raw("docker build -t my_whale .") then
    #raw("docker run --rm my_whale -f group-N \"hi from group N\"")
  ]
  #v(5pt)
  #step("4", "Open the pull request")[
    Against `main`, *in your own repository*. Then watch the
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


// ── 6. history and the cache ──────────────────────────────────────────────
// Observation only: they watch the cache behave, and are not told why yet.
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


// ── 8. the socket ─────────────────────────────────────────────────────────
// Both files are printed in full. The exercise is not to invent a CGI script in
// half an hour; it is to watch one container start another, and to be able to
// say what that cost.
#panel("8 · A web server that starts containers")[
  #text(size: 8.5pt)[
    A web server with no cowsay in it. Every request it receives, it runs
    `docker run` and a fresh cow container prints the answer and dies. Two files,
    in a `web/` directory:
  ]
  #v(4pt)
  #block(inset: (x: 5pt, y: 4pt), fill: luma(245), radius: 2pt, width: 100%)[
    #text(size: 7.5pt)[`web/Dockerfile`]
    #v(2pt)
    #text(size: 7.5pt)[
      ```docker
      FROM alpine
      RUN apk add --no-cache busybox-extras docker-cli
      COPY cgi-bin/ /www/cgi-bin/
      ENTRYPOINT ["httpd", "-f", "-p", "80", "-h", "/www"]
      ```
    ]
    #v(5pt)
    #text(size: 7.5pt)[`web/cgi-bin/cow` #text(fill: luma(130))[ — and it must be executable]]
    #v(2pt)
    #text(size: 7.5pt)[
      ```sh
      #!/bin/sh
      echo "Content-type: text/html"
      echo
      say=$(printf '%s' "$QUERY_STRING" | sed -n 's/^.*message=\([^&]*\).*$/\1/p' | sed 's/+/ /g')
      [ -z "$say" ] && say="try /?message=hello"
      echo "<pre>"
      docker run --rm my_whale -f group-N "$say"
      echo "</pre>"
      ```
    ]
  ]
  #v(5pt)
  #text(size: 8pt)[
    #raw("chmod +x web/cgi-bin/cow") \
    #raw("docker build -t cow-web ./web") \
    #raw("docker run --rm -p 8080:80 -v /var/run/docker.sock:/var/run/docker.sock cow-web")
  ]
  #v(5pt)
  #text(size: 8pt)[
    #raw("curl \"localhost:8080/cgi-bin/cow?message=hello+302\"")
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Before you run it: there is no `cowsay` anywhere in the `web` image. So where
    does the cow come from?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Open a second terminal, run `docker events`, and load the page twice. Write
    the sequence of words it prints for one request.
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    How many cow containers exist on your machine between two requests?
    #rule(20mm) #h(4pt) Which flag in the script decided that?  #rule(28%)
  ]
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    That last command handed the container `/var/run/docker.sock`. Name one thing
    this web server could now do to your laptop that has nothing to do with cows.
  ]
  #writing(2)
]

#v(7pt)

// ── 9. reading the Dockerfile ─────────────────────────────────────────────
// Four instructions, four different kinds of thing: a base to start from, a
// package install, a copy out of the build context, and the process the
// container exists to run. They have already watched all four take effect in
// boxes 3, 5 and 6; this is where they have to say what each one actually did.
#panel("9 · Four lines, four layers")[
  #text(size: 8.5pt)[
    Go back to the `web/Dockerfile` in box 8 and take its four instructions one
    at a time. In your own words: what did each one put in the image?
  ]
  #v(5pt)
  #text(size: 8pt)[#raw("FROM alpine")]
  #v(2pt)
  #text(size: 7.5pt, fill: luma(130))[
    What is in the image after this line and before the next one runs, and where
    did it come from? Then: why `alpine` rather than, say, `ubuntu`? Box 3
    measured your evidence.
  ]
  #writing(2)
  #v(6pt)
  #text(size: 8pt)[#raw("RUN apk add --no-cache busybox-extras docker-cli")]
  #v(2pt)
  #text(size: 7.5pt, fill: luma(130))[
    One of these two packages is the web server, the other is the `docker`
    command. Which is which — and is the Docker *daemon* in this image?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 8pt)[#raw("COPY cgi-bin/ /www/cgi-bin/")]
  #v(2pt)
  #text(size: 7.5pt, fill: luma(130))[
    Where does `cgi-bin/` live before this line runs, and where does it live
    afterwards? Name both places precisely enough that someone could go and look.
  ]
  #writing(2)
  #v(6pt)
  #text(size: 8pt)[#raw("ENTRYPOINT [\"httpd\", \"-f\", \"-p\", \"80\", \"-h\", \"/www\"]")]
  #v(2pt)
  #text(size: 7.5pt, fill: luma(130))[
    Three flags: `-f`, `-p 80`, `-h /www`. Which one keeps the container alive,
    and what did box 5 have to do for a command that lacked it? And `80` turns up
    again in the `docker run` line as `8080:80` — say which of those two it is.
  ]
  #writing(3)
]

#v(7pt)

// ── 10. the build context ─────────────────────────────────────────────────
// The file is one line; the lesson is that `docker build .` ships the whole
// directory to the daemon before it reads a single instruction. The junk file
// is there because the honest difference on this project is a few hundred
// bytes, which nobody would notice. The last question is the one they get
// wrong: ignoring web/ at the root does not touch the frontend build, because
// that build's context IS web/.
#panel("10 · Hiding contents from the build context")[
  #text(size: 8.5pt)[
    At the root of your repository, next to the `Dockerfile` and *not* inside
    `web/`, create a file called `.dockerignore` holding one line:
  ]
  #v(3pt)
  #text(size: 8pt)[#raw("web/")]
  #v(5pt)
  #text(size: 8.5pt)[
    Two small files make a difference nobody can see, so put something heavy in
    there first, then build the cow image twice: once as it is, once with the
    `web/` line commented out (`#` starts a comment).
  ]
  #v(3pt)
  #text(size: 8pt)[
    #raw("dd if=/dev/urandom of=web/junk bs=1024 count=20000") \
    #raw("docker build -t my_whale .") #text(fill: luma(140))[← read the line about the build context]
  ]
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    Read that first command before you run it, because you are about to quote its
    result as a measurement. `dd` copies blocks: `bs` is the size of one block in
    bytes, `count` is how many of them.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[So `web/junk` will be], rule(100%),
    text(size: 8pt)[and `ls -l` says], rule(100%),
  )
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    And what is in it? `/dev/urandom` is not a file sitting on your disk. Say what
    it is and what you therefore just wrote into `web/`.
  ]
  #writing(2)
  #v(6pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 5pt, align: bottom,
    text(size: 8pt)[Context with `web/` ignored], rule(100%),
    text(size: 8pt)[and without], rule(100%),
  )
  #v(7pt)
  #text(size: 7.5pt, fill: luma(130))[
    Your `Dockerfile` copies `cowsay`, `*.cow` and `docker.cow` by name, so
    nothing in `web/` was ever going to end up inside `my_whale`. What did
    carrying it cost you, then, and who was it being carried to?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Put the line back and delete `web/junk`, or the frontend build would carry it. Which is the question: you just told Docker to ignore `web/`, so
    why does #raw("docker build -t cow-web ./web") still work at all?
  ]
  #writing(2)
]

#v(7pt)

// ── 11. the extra mile ─────────────────────────────────────────────────────
// No solution printed: the script already parses one parameter, and the second
// one is that same line written twice. What the box is really for is the
// question underneath it — the request now picks an argument to `docker run`,
// and only one of the two parameters can make that command fail.
#panel("11 · Extra mile · let the request pick the cow")[
  #text(size: 8.5pt)[
    Same server, one more parameter: the cow comes from the URL instead of being
    fixed in the script.
  ]
  #v(4pt)
  #text(size: 8pt)[
    #raw("curl \"localhost:8080/cgi-bin/cow?message=hello+302&cow=group-N\"")
  ]
  #v(5pt)
  #text(size: 7.5pt, fill: luma(130))[
    One line of the script already does this for `message`. Write the line you
    added for `cow`, and what it falls back to when nobody asks for one.
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Ask for a cow the image does not have (`&cow=nonesuch`). What does the page
    show, and which of the two containers produced that text?
  ]
  #writing(2)
  #v(6pt)
  #text(size: 7.5pt, fill: luma(130))[
    Both values now come from the request, but only one of them can make
    `docker run` fail. Which one, and what does that say about the difference
    between them?
  ]
  #writing(2)
]

#v(7pt)
#align(center)[
  #text(size: 7.5pt, fill: luma(140), style: "italic")[
    Done when `?message=hello` makes your cow say hello, and `docker events` shows
    a container created and destroyed on every request.
  ]
]
