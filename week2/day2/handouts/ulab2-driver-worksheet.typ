// ---------------------------------------------------------------------------
// ulab2-driver-worksheet.typ — one A4 sheet per group, for µLab 2 of week 2 day 2.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the three steps so that the answer to "what were we
// supposed to do again?" is on the table rather than on a slide that has moved on.
//
// The roles rotate between rounds: whoever drove the previous round is not
// driving this one.
//
// This round changes exactly one thing about µLab 1: the number of workers.
// The measured answer is that four workers bought a factor of two, not four,
// and the extension shows where a further five seconds is hiding. Amdahl's law
// was taught on day 1, slide 45; this is that slide with a stopwatch.
//
// AUTHORING.md rule G1, as amended on 2026-09-23: the core is THREE panels, and
// the definitions sit below the checkpoint bar rather than above it. The 21.09
// sheets put five and six panels above the bar and groups ran out of clock
// reading rather than working. tools/lint-handouts.py check 9 enforces the cap.
//
// Every number quoted below was observed on a real run on 2026-09-23, on the
// k3s cluster built on 21.09, against simplewiki.txt.bz2 (212 354 articles,
// 76 MB compressed, 259 MB of text). Not reasoned out.
//
// Committed BLANK and it must stay that way: a filled sheet carries a GitHub
// handle and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
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
  title: "µLab 2 · Week 2 / Day 2 · Driver's handout\nMeasuring the speed-up from one worker to four",
  subtitle: [302 Data infrastructures · week 2, day 2],
  authors: ("",),
  date: datetime(year: 2026, month: 9, day: 24),
  revision: "1.0",
  language: "en",
  logo: auto,
)

#set text(size: 9pt)
#set heading(numbering: none)
// Fira Code ligatures redraw ">=" as "≥" and "!=" as "≠". A reader who
// copies what is printed would type a character Python does not accept.
#show raw: set text(ligatures: false, features: ("calt": 0))

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

#let panelb(title, body) = block(
  width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, breakable: true,
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

// The one thing on the sheet that must not be missed.
#let checkpoint = block(
  width: 100%, inset: (x: 8pt, y: 7pt), radius: 3pt, breakable: false,
  fill: accent,
)[
  #grid(columns: (auto, 1fr), column-gutter: 9pt, align: (horizon, top),
    box(width: 15pt, height: 15pt, radius: 2pt, fill: white, stroke: 1pt + white),
    [
      #text(size: 9.5pt, weight: "bold", fill: white)[
        Reached this line? Then you have solved the challenge.
      ]
      #v(2pt)
      #text(size: 8.5pt, fill: white)[
        *Referee: tick the box on the left now*, and write the time. Do not wait
        for the caucus. \
        Then carry on below — the extensions are not optional, they are the rest
        of the round.
      ]
      #v(3pt)
      #text(size: 8pt, fill: white)[
        Solved at #box(width: 22mm, stroke: (bottom: 0.6pt + white), height: 9pt)
        #h(10pt) Referee's initials #box(width: 22mm, stroke: (bottom: 0.6pt + white), height: 9pt)
      ]
    ])
]

// ── header ────────────────────────────────────────────────────────────────
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Group], rule(100%),
  text(size: 8pt)[Date #rule(20mm) #h(6pt) Time], rule(24mm),
)
#v(6pt)
#grid(columns: (auto, 1fr, auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Driver #text(fill: luma(140))[(types)]], rule(100%),
  text(size: 8pt)[Mapper #text(fill: luma(140))[(looks up)]], rule(100%),
  text(size: 8pt)[Referee #text(fill: luma(140))[(demos)]], rule(100%),
)
#v(5pt)
// ══ CORE — three panels, ten minutes ══════════════════════════════════════
#panelb("Step 1 · Take the one-worker clock again")[
  #text(size: 8.5pt)[
    Four workers have four times the cores of one, so a job that divided cleanly
    would finish in a quarter of the time. Whether it does, and by how much it misses
    if it does not, is a thing to measure rather than to reason about. This round
    measures it: the same job at one worker, then at four.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    Start from one worker, so the two clocks compare. If µLab 1's number is still on
    your sheet and nobody has touched the cluster since, copy it and go to step 2.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    All of this round happens in the *kubectl client*, the one µLab 1 sent you to
    look up. If you closed it, open it again the same way.
  ]
  #v(4pt)
  #lbl("in the kubectl client", fill: luma(110))
  #v(2pt)
  #raw("kubectl scale deployment spark-worker --replicas=1\nkubectl get pods", lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`scale ... --replicas=1`],
    text(size: 7.8pt)[States how many workers you want. It returns immediately; the cluster then removes pods until it agrees. `get pods` is how you find out that it has.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    The master publishes a web page of its own, the *Spark master UI*, listing the
    workers that have registered and the cores they bring. Start it once and leave
    it running.
  ]
  #v(3pt)
  #lbl("on your laptop", fill: luma(110))
  #v(2pt)
  #raw("docker run -d --name ui -p 8080:8080 -v \"$PWD/kube:/kube:ro\" \\\n  --add-host host.docker.internal:host-gateway \\\n  -e KUBECONFIG=/kube/config alpine/kubectl \\\n  --server https://host.docker.internal:6443 --insecure-skip-tls-verify \\\n  port-forward --address 0.0.0.0 deploy/spark-master 8080:8080", lang: "bash", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    raw("-p 8080:8080"),
    text(size: 7.8pt)[Publishes the UI on your laptop. This is the argument that makes it reachable from a browser.],

    raw("--add-host host.docker.internal:host-gateway"),
    text(size: 7.8pt)[Defines that name inside the container as the machine Docker itself runs on. Docker Desktop, on macOS and Windows, supplies the name on its own; Docker Engine on Linux does not, and the container then exits straight away. The line is harmless where the name already exists, so it is printed for everybody.],

    raw("--server ... host.docker.internal"),
    text(size: 7.8pt)[From inside a container, your laptop is called `host.docker.internal`, not `127.0.0.1`, which would be the container itself.],

    raw("port-forward ... 8080:8080"),
    text(size: 7.8pt)[Tunnels the UI out through the API server, the one port the cluster already publishes. Nothing about the cluster changes.],
  )
  #v(3pt)
  #text(size: 8.5pt)[
    Open #raw("http://127.0.0.1:8080/"), with the `http://` typed out. The summary
    at the top lists *Alive Workers* on one line and *Cores in use* on the next;
    every number this round asks for is read from those two lines. Wait until
    *Alive Workers* reads 1 before you start the job.
  ]
  #v(2pt)
  #text(size: 8pt, fill: luma(110))[
    Page does not open? Panel 7. Remove it at the end of the round with `docker rm -f ui`.
  ]
  #v(4pt)
  #raw("kubectl exec deploy/spark-master -- \\\n  /opt/spark/bin/spark-submit --master spark://spark-master:7077 \\\n  /lab/wordcount_df.py /lab/data /lab/data/simplewiki.txt.bz2", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8.5pt)[
    Submit it *twice*, and write down the second number. A first run pays to pull
    the file off the disk; a second finds it already in memory, and that gap has
    nothing to do with workers. Step 2 asks for a second run too, so the two
    numbers you compare are measured the same way.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[`elapsed` A, second run, one worker], rule(100%),
    text(size: 8pt)[`input partitions`], rule(100%),
  )
]

#v(5pt)

#panelb("Step 2 · Grow the cluster to four, and run the identical job")[
  #text(size: 8.5pt)[
    Before you touch anything, read *Cores in use* off the Spark master UI. It is
    written `N Total, M Used`; write down the *Total*. You cannot get this number
    back once the cluster has grown.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[Cores in use, one worker], rule(100%),
  )
  #v(4pt)
  #lbl("in the kubectl client", fill: luma(110))
  #v(2pt)
  #raw("kubectl scale deployment spark-worker --replicas=4\nkubectl get pods", lang: "bash", block: true)
  #v(4pt)
  #text(size: 8.5pt)[
    Now reload the Spark master UI. *Alive Workers* and *Cores in use* both climb as
    the new workers register. Once *Alive Workers* reads 4, take the second reading
    and run the same submission as step 1, unchanged. Twice again, and write down
    the second number, for the reason step 1 gave.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[Cores in use, four workers], rule(100%),
  )
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[`elapsed` B, second run, four workers], rule(100%),
    text(size: 8pt)[`input partitions`], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    Spark cut the same input into 2 chunks the first time and 4 the second. The
    number of chunks follows the number of cores it has to keep busy, not the size
    of what it is reading.
  ]
]

#v(5pt)

#panelb("Step 3 · Write the speed-up, and explain the number you get")[
  #text(size: 8.5pt)[
    Four workers have four times the cores of one. Divide A by B, and see how much
    of that four you actually got.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[A ÷ B], rule(100%),
  )
  #v(5pt)
  #text(size: 8.5pt)[
    Whatever you wrote, it is not four. Part of a Spark job does not divide at all:
    starting it costs the same on one worker as on forty, and no number of workers
    makes that part shorter.
  ]
  #v(3pt)
  #text(size: 8.5pt)[
    Write one sentence: what does that mean for a team whose answer to a slow job
    is always to add machines?
  ]
  #v(2pt)
  #writing(3)
]

#v(6pt)

#text(size: 8pt, style: "italic", fill: luma(110))[
  Solved means panels 1 to 3 are done: two timings, the speed-up, and one sentence
  on the part that does not divide.
  The referee ticks the bar below at that moment, not at the caucus.
]
#v(3pt)

#checkpoint

#v(8pt)

#panelb("4 · The numbers this was measured against")[
  #text(size: 8.5pt)[
    Observed on 2026-09-23 on a ten-core laptop, against `simplewiki.txt.bz2`
    (212 354 articles, 259 MB of text), each worker configured with one core:
  ]
  #v(4pt)
  #grid(columns: (auto, auto, auto, 1fr), column-gutter: 10pt, row-gutter: 3pt, align: (left, left, left, left),
    text(size: 8pt, weight: "bold")[input], text(size: 8pt, weight: "bold")[workers],
    text(size: 8pt, weight: "bold")[partitions], text(size: 8pt, weight: "bold")[elapsed],

    text(size: 8pt)[`.bz2`], text(size: 8pt)[1], text(size: 8pt)[2], text(size: 8pt)[27.9 s],
    text(size: 8pt)[`.bz2`], text(size: 8pt)[4], text(size: 8pt)[4], text(size: 8pt)[14.1 s],
    text(size: 8pt)[plain `.txt`], text(size: 8pt)[1], text(size: 8pt)[3], text(size: 8pt)[11.6 s],
    text(size: 8pt)[plain `.txt`], text(size: 8pt)[4], text(size: 8pt)[4], text(size: 8pt)[8.9 s],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    Four times the workers bought less than a factor of *two*, and your own run may
    have bought less than that again. It is not the cost of starting a job: the same
    script on a single line of text finishes in about two seconds whether one worker
    is running or four. So whatever refuses to divide here is work that grows with
    the data, and panel 6 sends you to find where it puts the ceiling.
  ]
  #v(3pt)
  #text(size: 8.5pt)[
    The last two rows are the ones panel 5 sends you to reproduce. Read them before
    you start it.
  ]
  #v(3pt)
  #text(size: 8pt, fill: luma(110))[
    Your numbers will be slower than these and will differ a lot from the laptop
    next to you: seventeen clusters on one wifi, and whatever else each machine is
    running. What survives that is the ratio between two of your own rows, not any
    single number.
  ]
]

#v(5pt)

#panel("5 · Extension · take the compression away")[
  #text(size: 8.5pt)[
    Every run so far has read a compressed file, and decoding it is work Spark does
    before it can count anything. This extension takes that work away and changes
    nothing else, so that the four clocks you end up with separate what the file
    format costs from what the extra workers buy.
  ]
  #v(4pt)
  #lbl("on your laptop", fill: luma(110))
  #v(2pt)
  #raw("bzcat lab/data/simplewiki.txt.bz2 > lab/data/simplewiki.txt\nls -lh lab/data/simplewiki.txt", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8pt, fill: luma(110))[It becomes 260 MB on disk. Delete it at the end of the round if you are short of space.]
  #v(4pt)
  #text(size: 8.5pt)[
    Run the same submission with the new path, at four workers and then at one.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[plain text, four workers], rule(100%),
    text(size: 8pt)[plain text, one worker], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    Now put the four clocks in one place and answer: which bought more, four times
    the workers or dropping the compression? And what did dropping the compression
    cost, in disk and in download?
  ]
  #v(2pt)
  #writing(3)
]

#v(5pt)

#panel("6 · Extra mile · find where the ceiling actually is")[
  #text(size: 8.5pt)[
    Scale to eight workers and run the plain-text job again. The laptop has ten
    cores, so eight workers of one core each still fit.
  ]
  #v(3pt)
  #text(size: 8pt)[eight workers, plain text: #rule(40mm)]
  #v(4pt)
  #text(size: 8.5pt)[
    Compare with the four-worker number and say what is now the limit. The answer is
    not "the laptop": the plan tells you how many pieces the input came in, and no
    worker can be given a ninth piece that does not exist.
  ]
  #v(2pt)
  #writing(2)
]

#v(5pt)

#panel("7 · Annex · troubleshooting")[
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 4pt, align: (top, top),
    text(size: 8pt, weight: "bold")[Why steps 1 and 2 ask for the second run],
    text(size: 8pt)[The operating system keeps recently read files in memory. The first run of a file pays for the disk, every run after it does not, and the difference is large enough to swamp what you are trying to measure. Comparing a first run against a second would tell you about the disk instead of about the workers.],

    text(size: 8pt, weight: "bold")[The page will not open],
    text(size: 8pt)[Check four things, in order. *One*, `docker ps` should list `ui`; if it exited, `docker logs ui` says why, and the two answers worth knowing are `dial tcp: lookup host.docker.internal ... no such host`, which means the `--add-host` line above was left out, and `deployments.apps "spark-master" not found`, which means the cluster you reached has no Spark on it and step 1 of µLab 1 has to be redone. *Two*, the address must begin `http://`: the UI is served over plain HTTP and Firefox will silently try `https` otherwise, which fails with no useful message. *Three*, `docker rm -f ui` before every retry: a container that exited keeps the name. *Four*, if you ran `kubectl port-forward` yourself instead of the container above, it must not be from inside the kubectl client: that container is on the *cluster's* network rather than your laptop's, so it forwards to a `localhost` your browser cannot reach.],

    text(size: 8pt, weight: "bold")[A job that waits],
    text(size: 8pt)[If a previous submission is still registered, yours gets no cores and simply waits, reporting a clock that is mostly queueing. In the client, `kubectl logs deploy/spark-master | grep "Registered app"` shows what the master thinks is running; `kubectl delete pod -l app=spark-master` clears a stuck one.],
  )
]
