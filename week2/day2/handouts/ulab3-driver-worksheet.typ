// ---------------------------------------------------------------------------
// ulab3-driver-worksheet.typ — one A4 sheet per group, for µLab 3 of week 2 day 2.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the three steps so that the answer to "what were we
// supposed to do again?" is on the table rather than on a slide that has moved on.
//
// The roles rotate between rounds: whoever drove µLab 1 or µLab 2 is not driving
// this one.
//
// This round ends the morning's thread. µLab 1 and µLab 2 asked where the time
// goes inside one job; this one asks what stops you paying it a second time.
// That is why the extension is the cache and not something else.
//
// AUTHORING.md rule G1, as amended on 2026-09-23: the core is THREE panels, and
// the definitions sit below the checkpoint bar rather than above it. The 21.09
// sheets put five and six panels above the bar and groups ran out of clock
// reading rather than working. tools/lint-handouts.py check 9 enforces the cap.
//
// Two rulings worth not re-opening. First, the Flyte sandbox and the Spark
// cluster from µLab 1 and µLab 2 BOTH bind port 6443 and cannot run at the same
// time; step 1 therefore stops the Spark cluster, and says why, rather than
// leaving the group to decode "port is already allocated". Second, flytectl and
// uv are installed the evening before, not in the round: the image pull alone is
// several GB and would consume the whole thirty minutes.
//
// Every number quoted below was observed on a real run on 2026-09-23:
// flytectl v0.9.8, Flyte sandbox v1.16.8, flytekit 1.16.28 on Python 3.12.
// A warm sandbox start took 110 s; the two-task workflow succeeded in 36.8 s;
// the same workflow with cache=True and unchanged inputs succeeded in 0.085 s
// and created no pods at all.
//
// Committed BLANK and it must stay that way: a filled sheet carries a GitHub
// handle and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
//
//   typst compile ulab3-driver-worksheet.typ
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
  title: "µLab 3 · Week 2 / Day 2 · Driver's handout\nDeploying Flyte and running a pipeline on it",
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
#panelb("Step 1 · Check your two tools, then start the Flyte cluster")[
  #text(size: 8.5pt)[
    The round needs two small tools on your laptop. Check for them first, because
    everything below depends on both.
  ]
  #v(3pt)
  #raw("flytectl version\nuv --version", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8.5pt)[
    Either one missing? Install it here and now. This is seconds and a few MB, not
    the image download, and the third line is what puts them on your path in the
    terminal you are already in.
  ]
  #v(3pt)
  #raw("curl -LsSf https://astral.sh/uv/install.sh | sh\ncurl -sL https://ctl.flyte.org/install | bash -s -- -b $HOME/.local/bin\nexport PATH=\"$HOME/.local/bin:$PATH\"", lang: "bash", block: true)
  #v(4pt)
  #text(size: 8.5pt)[
    Now free the port. The Spark cluster and the Flyte one both publish *6443*, and
    two programs cannot hold one port. Nothing is lost: `docker start k8s` brings
    Spark back later with its data.
  ]
  #v(3pt)
  #raw("docker rm -f ui\ndocker stop k8s\nflytectl demo start", lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`docker rm -f ui`],
    text(size: 7.8pt)[Removes the port-forward container from µLab 2. Nothing needs it now.],

    text(size: 7.8pt, weight: "bold")[`docker stop k8s`],
    text(size: 7.8pt)[Stops the container running the Spark cluster and releases port 6443. It does not delete it.],

    text(size: 7.8pt, weight: "bold")[`flytectl demo start`],
    text(size: 7.8pt)[Creates a container named #raw("flyte-sandbox") holding a Kubernetes cluster with Flyte installed on it. It publishes 6443 for the cluster and *30080* for the web console.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    If it asks #raw("delete existing sandbox cluster [y/n]"), answer *n*. That
    question appears only when you already have a sandbox, and *n* keeps it: it
    replies #raw("Existing details of your sandbox") and carries on.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    The last thing it prints is one line. *Run it*, in the terminal you will use for
    step 2. Your own home directory appears where `$HOME` is here:
  ]
  #v(3pt)
  #raw("export FLYTECTL_CONFIG=$HOME/.flyte/config-sandbox.yaml", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8pt)[Without it, step 2 does not know where your cluster is.]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[Time it took to start], rule(100%),
  )
  #v(2pt)
  #text(size: 7.8pt, fill: luma(120))[
    With the image already on your laptop this is about two minutes. Much longer
    means it is still pulling, and panel 7 says what to do.
  ]
]

#v(5pt)

#panelb("Step 2 · Run the two-task workflow on that cluster")[
  #text(size: 8.5pt)[
    `hello.py` lives in the lab repository, and it was added this week. Go into `lab`
    and look: if `ls hello.py` comes up empty, `git pull` and look again. It has two tasks and one workflow: `split` turns a sentence into a list of
    words, `tally` counts them. The point is not the count. It is that the list of
    words leaves one task and arrives in another, and that Flyte checked the two
    types agreed before anything ran.
  ]
  #v(4pt)
  #raw("cd lab\nls hello.py || git pull", lang: "bash", block: true)
  #v(3pt)
  #raw("uv run --python 3.12 --with flytekit==1.16.28 \\\n  pyflyte run --remote hello.py count_words --sentence \"the quick brown fox jumps\"",
       lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`uv run --python 3.12`],
    text(size: 7.8pt)[Runs the command in a throwaway environment on Python 3.12. `flytekit` refuses to install on 3.9 or on 3.13 and later, and your laptop has whichever it has; this sidesteps the question entirely.],
  )
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`--with flytekit==1.16.28`],
    text(size: 7.8pt)[The Flyte SDK, pinned. Flyte 2 exists and is different; everything here is the 1.x line.],
  )
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`pyflyte run --remote`],
    text(size: 7.8pt)[Sends the file to the cluster and runs it *there*. Without `--remote` it would run in this terminal and no cluster would be involved.],
  )
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`count_words`],
    text(size: 7.8pt)[Which of the things in the file to run. A file may hold several workflows.],
  )
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`--sentence "..."`],
    text(size: 7.8pt)[An input of the workflow. `pyflyte` built this flag from the function's signature, which is why a typed signature is worth having.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    It returns in about four seconds and prints a URL. Those seconds are the
    *submission*, not the run: the run is only starting.
  ]
  #v(3pt)
  #text(size: 8pt)[The URL it printed ends in an execution id. Write that id here: #rule(45mm)]
]

#v(5pt)

#panelb("Step 3 · Find the run in the console")[
  #text(size: 8.5pt)[
    Open #raw("http://localhost:30080/console") and find your execution. Wait until
    it says *SUCCEEDED*. Expect tens of seconds, nearly all of it spent starting a
    container for each task.
  ]
  #v(4pt)
  #text(size: 8.5pt)[Write down, from the console:]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[How many tasks ran], rule(100%),
    text(size: 8pt)[How long the whole execution took], rule(100%),
  )
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[What value `tally` received from `split`], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    #text(weight: "bold")[Then answer this, in one sentence.] A shell script running
    the same two steps would have printed the same number. Name one thing the
    console is showing you that the shell script could not have told you.
  ]
  #v(2pt)
  #writing(2)
]

#v(6pt)

#text(size: 8pt, style: "italic", fill: luma(110))[
  Solved means panels 1 to 3 are done: the console shows one execution of
  `count_words` in phase SUCCEEDED, with two tasks. The referee ticks the bar
  below at that moment, not at the caucus.
]
#v(3pt)

#checkpoint

#v(8pt)
#panelb("4 · Some definitions")[
  #text(size: 8.5pt)[
    These are the words the console puts on screen. They are here, below the bar,
    because none of them is needed to finish the core.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    text(size: 8pt, weight: "bold")[task],
    text(size: 8pt)[A Python function marked #raw("@task"). It runs in its own container, on its own, and its arguments and return type are declared. Flyte will not connect two tasks whose types disagree.],

    text(size: 8pt, weight: "bold")[workflow],
    text(size: 8pt)[A Python function marked #raw("@workflow") that calls tasks. It does *not* run them: calling a task inside a workflow records that the output of one becomes the input of another. The graph is built from those recordings, then executed elsewhere.],

    text(size: 8pt, weight: "bold")[execution],
    text(size: 8pt)[One run of a workflow, with an id such as #raw("an4w2r8ql4pw6sf9tkw9"). Every execution is kept, with its inputs, its outputs and its logs. This is the thing a shell script does not have.],

    text(size: 8pt, weight: "bold")[launch plan],
    text(size: 8pt)[A workflow plus a set of input values, saved under a name. The console labels your run #raw("LAUNCH_PLAN") because #raw("pyflyte run") made one for you.],

    text(size: 8pt, weight: "bold")[sandbox],
    text(size: 8pt)[The single container #raw("flytectl demo start") creates. It holds a Kubernetes cluster, the Flyte services, a database, an object store and an image registry. It is the laptop deployment of Flyte, not the production one, and everything you do here would be done the same way against a real cluster.],
  )
]

#v(5pt)

#panel("5 · Extension · make the second run cost nothing")[
  #text(size: 8.5pt)[
    #text(weight: "bold")[What this shows, before you do it.] Both tasks ran in
    containers and took about 37 s. Nothing about `split` depends on anything but
    its input. If the input has not changed, running it again is waste. Flyte can
    be told that.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    Copy `hello.py` to `hello_cached.py` and change *both* `@task` lines to:
  ]
  #v(3pt)
  #raw("@task(cache=True, cache_version=\"1.0\")", lang: "python", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    text(size: 7.8pt, weight: "bold")[`cache_version`],
    text(size: 7.8pt)[Your label for "the code inside this task". Change the body of the task and you must change this string, or Flyte will hand back the old answer.],
  )
  #v(4pt)
  #v(3pt)
  #raw("uv run --python 3.12 --with flytekit==1.16.28 \\\n  pyflyte run --remote hello_cached.py count_words --sentence \"the quick brown fox jumps\"",
       lang: "bash", block: true)
  #v(4pt)
  #text(size: 8.5pt)[
    Run it, *wait for it to reach SUCCEEDED*, then run the identical command again.
    Waiting matters: a task's result only enters the cache when it finishes, so two
    runs fired back to back both miss.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[First run, elapsed], rule(100%),
    text(size: 8pt)[Second run, elapsed], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    Then open the second run in the console and look at its two tasks. Write down
    what the console says about them that it did not say about the first run.
  ]
  #v(2pt)
  #writing(1)
  #v(4pt)
  #text(size: 8.5pt, style: "italic", fill: luma(90))[
    Observed on 2026-09-24: 39.1 s, then 0.085 s, and zero pods. The second run did
    not do the work faster. It did not do it at all: Flyte handed back the result it
    had already stored.
  ]
]

#v(5pt)

#panel("6 · Extra mile · break the types on purpose")[
  #text(size: 8.5pt)[
    Change `tally` to take a `str` instead of a `List[str]`, leaving everything else
    alone, and run it again. Write down *when* the failure happens: before the
    cluster is contacted, after submission but before a task starts, or inside a
    running task.
  ]
  #v(3pt)
  #writing(2)
  #v(3pt)
  #text(size: 8.5pt)[
    Then say which of those three a shell script chaining two commands would have
    given you.
  ]
  #v(2pt)
  #writing(1)
]

#v(5pt)

#panel("7 · Annex · getting past three things that go wrong")[
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 4pt, align: (top, top),
    text(size: 8pt, weight: "bold")[`Bind for 0.0.0.0:6443 failed: port is already allocated`],
    text(size: 8pt)[The Spark cluster is still running. `docker stop k8s`, then start the sandbox again. This is panel 1 and it is the most common failure of the round.],

    text(size: 8pt, weight: "bold")[`connection refused` on port 30080],
    text(size: 8pt)[The sandbox is up but Flyte inside it is not ready yet. `flytectl demo status` reports whether it is. A warm start took 110 s on 2026-09-23.],

    text(size: 8pt, weight: "bold")[`flytekit` will not install],
    text(size: 8pt)[Your Python is older than 3.10 or newer than 3.12. That is what `uv run --python 3.12` in panel 2 is for; do not drop it.],

    text(size: 8pt, weight: "bold")[The image never arrived, and the sandbox will not start],
    text(size: 8pt)[Take the image off the USB stick: #raw("gunzip -c flyte-sandbox.tar.gz | docker load"), then start again. If even that is not an option, drop `--remote` from the step 2 command: #raw("pyflyte run hello.py count_words --sentence \"...\"") runs the same workflow in this terminal, with no cluster and no image. You lose the console, the execution history and panel 5, and you keep the part where the types are checked and the output of one task becomes the input of the next.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    #text(weight: "bold")[Leave the sandbox installed when you go.] Monday's session
    starts from it. Tearing it down costs the 700 MB download again to get back.
  ]
]
