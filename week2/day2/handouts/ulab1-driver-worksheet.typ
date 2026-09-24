// ---------------------------------------------------------------------------
// ulab1-driver-worksheet.typ — one A4 sheet per group, for µLab 1 of week 2 day 2.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the three steps so that the answer to "what were we
// supposed to do again?" is on the table rather than on a slide that has moved on.
//
// The roles rotate between rounds: whoever drove the previous round is not
// driving this one.
//
// This round changes exactly one thing about Monday's µLab 3: the shape of the
// input. Same cluster, same script, same arguments. 18 846 small files became
// one compressed stream, and the execution plan says so. Keeping everything
// else fixed is the whole design; resist adding a second variable.
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
  title: "µLab 1 · Week 2 / Day 2 · Driver's handout\nCounting words in Spark on a larger dataset",
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
#panelb("Step 1 · Update the lab folder, bring the cluster back, re-run Monday's count")[
  #text(size: 8.5pt)[
    Pull today's scripts into `lab`, start Monday's cluster, put the new corpus where
    it can read it, and set the cluster to one worker. The corpus is for step 3; this
    step re-runs the count you already know, unchanged, so that steps 2 and 3 have
    something to be different from.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    The corpus is on *ISC Learn*, filed under *Simple English Wikipedia dataset*:
    one file, `simplewiki.txt.bz2`, about 80 MB. Download it now if you have not
    already. Only step 3 reads it, so it can finish downloading while you work.
  ]
  #v(4pt)
  #lbl("on your laptop", fill: luma(110))
  #v(2pt)
  #raw("git -C lab pull\ndocker start k8s\ncp ~/Downloads/simplewiki.txt.bz2 lab/data/", lang: "bash", block: true)
  #v(4pt)
  #text(size: 7.8pt, fill: luma(110))[
    All three run in the folder that holds `lab`, the one you cloned into on 21.09.
    Starting in a fresh folder, or `lab` is gone? Clone it again, and unpack into it
    the same `20news.zip` from ISC Learn that 21.09 used:
  ]
  #v(2pt)
  #raw("git clone https://github.com/oesteban/isc-302-2026-2027-spark-lab lab\nunzip ~/Downloads/20news.zip -d lab/data", lang: "bash", block: true)
  #v(2pt)
  #text(size: 7.8pt, fill: luma(110))[
    A clone carries the scripts and `stopwords.txt`, not the 18 846 newsgroup files,
    which is why the second line is there. A clone made today is already current, so
    skip the pull and run the other two lines.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    raw("git -C lab pull"),
    text(size: 7.8pt)[Brings today's scripts into that clone. `-C lab` runs git inside `lab` without moving you out of this folder, which the next two lines need. If you already pulled at 8h45 it answers `Already up to date.` and costs a second. If it refuses, use panel 7.],

    raw("docker start k8s"),
    text(size: 7.8pt)[Starts the stopped container that holds the cluster. If it answers `No such container`, use panel 7.],

    raw("cp ... lab/data/"),
    text(size: 7.8pt)[Puts the downloaded corpus where the cluster can reach it: `lab` is mounted into the cluster at `/lab`, so a file dropped here is visible to every pod. The path is where a browser saves by default; if yours saved the file somewhere else, type that path instead.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    That pull is not housekeeping. Steps 2 and 3 pass a second argument to
    `wordcount_df.py`, and Monday's copy of that script has no second argument: it
    reads the 18 846 files whatever you hand it, and says nothing. You would write
    step 1's answer down three times and never see an error. Check the pull landed:
  ]
  #v(3pt)
  #raw("grep INPUT lab/wordcount_df.py", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8.5pt)[
    Four lines is today's script. No output at all is Monday's, and the pull has to
    happen before you go on.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    Now open a *kubectl client*. You did this on 21.09 and the command has not
    changed: µLab 1, panel 1, *Start the cluster, then get a client*. Look it up on
    that sheet. Everything below runs in the shell it gives you.
  ]
  #v(4pt)
  #lbl("in the kubectl client", fill: luma(110))
  #v(2pt)
  #raw("kubectl scale deployment spark-worker --replicas=1\nkubectl get pods", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8.5pt)[
    Wait for *one* `spark-worker`, `Running`. Then run Monday's count, exactly as
    Monday ran it:
  ]
  #v(3pt)
  #raw("kubectl exec deploy/spark-master -- \\\n  /opt/spark/bin/spark-submit --master spark://spark-master:7077 \\\n  /lab/wordcount_df.py /lab/data '/lab/data/20news/*.txt'", lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    raw("kubectl exec deploy/spark-master --"),
    text(size: 7.8pt)[Runs the command inside the master pod. Everything after `--` is that command.],

    raw("--master spark://spark-master:7077"),
    text(size: 7.8pt)[Where to submit. `spark-master` is a cluster DNS name, 7077 the port the Service publishes.],

    raw("/lab/data"),
    text(size: 7.8pt)[First argument: the folder holding `stopwords.txt`. It is not what gets counted.],

    raw("'/lab/data/20news/*.txt'"),
    text(size: 7.8pt)[Second argument: what gets read. A pattern, not a folder.],
  )
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[`input partitions`], rule(100%),
    text(size: 8pt)[`elapsed`], rule(100%),
  )
  #v(5pt)
  #text(size: 8.5pt)[
    The run prints fifteen words with their counts. Copy the *first three* and the
    *last three*, word and number both. Six lines is enough to recognise this answer
    again, and step 2 asks you to.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, 14pt, auto, 1fr), column-gutter: 6pt, row-gutter: 6pt, align: bottom,
    lbl("first three", fill: luma(120)), [], [], lbl("last three", fill: luma(120)), [],
    text(size: 8pt)[1], rule(100%), [], text(size: 8pt)[13], rule(100%),
    text(size: 8pt)[2], rule(100%), [], text(size: 8pt)[14], rule(100%),
    text(size: 8pt)[3], rule(100%), [], text(size: 8pt)[15], rule(100%),
  )
  #v(5pt)
  #text(size: 8.5pt)[
    The quotes around #raw("'/lab/data/20news/*.txt'") are not decoration. From the
    shell you just typed that command in, run:
  ]
  #v(3pt)
  #raw("ls /lab/data", lang: "bash", block: true)
  #v(3pt)
  #text(size: 8.5pt)[
    It almost certainly does not exist there: the client container was started
    without mounting `/lab`, so that path means nothing to the shell. The run works
    without the quotes anyway. *Say why the quotes are important even so.*
  ]
  #v(2pt)
  #writing(3)
]

#v(5pt)

#panelb("Step 2 · Store the same text as one file, and run it again")[
  #text(size: 8.5pt)[
    Step 1 read 18 846 files. Now glue exactly those bytes into one compressed file
    and read that instead, so that the only difference between the two runs is how the
    text is stored on disk. Holding everything else fixed is what makes the two sets of
    numbers worth comparing.
  ]
  #v(4pt)
  #lbl("on your laptop", fill: luma(110))
  #v(2pt)
  #raw("cd lab/data\nfind 20news -name '*.txt' -exec cat {} + | bzip2 > 20news.txt.bz2\nls -lh 20news.txt.bz2\ncd ../..", lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    raw("find ... -exec cat {} +"),
    text(size: 7.8pt)[Prints every file, one after another, into one stream. The `+` hands `cat` many files per call instead of one, which is the difference between three seconds and a minute. Every message already ends in a newline, so nothing is glued to the end of the line before it.],

    raw("| bzip2 >"),
    text(size: 7.8pt)[Compresses that stream into one file. `bzip2` is used rather than `gzip` for a reason you will meet in µLab 2.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    It takes a few seconds and makes one file of about 11 MB. Then run the same count
    on it, from the client:
  ]
  #v(3pt)
  #raw("kubectl exec deploy/spark-master -- \\\n  /opt/spark/bin/spark-submit --master spark://spark-master:7077 \\\n  /lab/wordcount_df.py /lab/data /lab/data/20news.txt.bz2", lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    raw("/lab/data/20news.txt.bz2"),
    text(size: 7.8pt)[The only argument that differs from step 1: one file in place of a pattern matching 18 846 of them.],
  )
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[`input partitions`], rule(100%),
    text(size: 8pt)[`elapsed`], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    #text(weight: "bold")[Now check the thing that matters.] Compare the first three
    and last three lines with the six you copied in step 1.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[Same six lines, or not?], rule(100%),
  )
]

#v(5pt)

#panelb("Step 3 · Now run it on the larger corpus")[
  #text(size: 8.5pt)[
    Same kind of file as step 2, but eight times as much text: one compressed file of
    212 354 Wikipedia articles.
  ]
  #v(3pt)
  #raw("kubectl exec deploy/spark-master -- \\\n  /opt/spark/bin/spark-submit --master spark://spark-master:7077 \\\n  /lab/wordcount_df.py /lab/data /lab/data/simplewiki.txt.bz2", lang: "bash", block: true)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    raw("/lab/data/simplewiki.txt.bz2"),
    text(size: 7.8pt)[Again the only argument that differs. Three runs, one command, one changing word.],
  )
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[`input partitions`], rule(100%),
    text(size: 8pt)[`elapsed`], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    Step 2 held the text fixed and changed how it was stored. Step 3 held the storage
    fixed and used eight times as much text. One of those changed the partition count
    and one changed the clock. Write one sentence saying which did which.
  ]
  #v(2pt)
  #writing(2)
]

#v(6pt)

#lbl("your three runs, side by side")
#v(3pt)
  #grid(columns: (1fr, auto, auto, 1fr, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (left, right, right, bottom, bottom),
    text(size: 8pt, weight: "bold")[run], text(size: 8pt, weight: "bold")[text],
    text(size: 8pt, weight: "bold")[disk], text(size: 8pt, weight: "bold")[partitions],
    text(size: 8pt, weight: "bold")[run time],

    text(size: 8pt)[step 1 · 18 846 files], text(size: 8pt)[34.2 MB],
    text(size: 8pt)[87.9 MB], rule(100%), rule(100%),

    text(size: 8pt)[step 2 · the same text, one `.bz2`], text(size: 8pt)[34.2 MB],
    text(size: 8pt)[11.3 MB], rule(100%), rule(100%),

    text(size: 8pt)[step 3 · Wikipedia, one `.bz2`], text(size: 8pt)[272.8 MB],
    text(size: 8pt)[79.9 MB], rule(100%), rule(100%),
  )
  #v(3pt)
  #text(size: 7.8pt, fill: luma(120))[
    *text* is how much text there is; *disk* is what it occupies, measured with
    `du`. Fill in the last two columns from your own three runs.
  ]

#v(6pt)

#text(size: 8pt, style: "italic", fill: luma(110))[
  Solved means steps 1 to 3 are done and the table above is filled in. The referee
  ticks the bar below at that moment, not at the caucus.
]
#v(3pt)

#checkpoint

#v(8pt)

#panelb("4 · The script you have been running")[
  #v(4pt)
  #text(size: 8.5pt)[
    The comments have been taken out. Put them back: write on the right, beside
    each part, what that part of the script is doing.
  ]
  #v(5pt)
  #grid(columns: (auto, 1fr), column-gutter: 12pt, align: (top, top),
    text(size: 6.8pt)[#raw("\"\"\"Count the words in a text corpus, with the DataFrame API.\"\"\"\nimport sys\nimport time\nfrom pathlib import Path\n\nfrom pyspark.sql import SparkSession\nfrom pyspark.sql import functions as F\n\nDATA = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(\"data\")\nINPUT = sys.argv[2] if len(sys.argv) > 2 else str(DATA / \"20news\" / \"*.txt\")\nTOP_N = 15\n\nstopwords = {\n    line.strip().lower()\n    for line in (DATA / \"stopwords.txt\").read_text().splitlines()\n    if line.strip()\n}\n\nspark = SparkSession.builder.appName(\"wordcount-df\").getOrCreate()\nspark.sparkContext.setLogLevel(\"WARN\")\n\nlines = spark.read.text(INPUT)\n\nwords = lines.select(\n    F.explode(F.split(F.lower(F.col(\"value\")), r\"\\W+\")).alias(\"word\")\n)\n\nwords = words.filter(\n    (F.length(F.col(\"word\")) >= 3)\n    & (~F.col(\"word\").rlike(r\"^[0-9]+$\"))\n    & (~F.col(\"word\").isin(list(stopwords)))\n)\n\ncounts = words.groupBy(\"word\").count().orderBy(F.desc(\"count\"))\n\nprint(\"\\n=== the plan, before a single byte has been read ===\")\ncounts.explain()\n\nprint(\"\\n=== now an action, and only now does anything run ===\")\nt0 = time.perf_counter()\nrows = counts.take(TOP_N)\nelapsed = time.perf_counter() - t0\n\nfor r in rows:\n    print(f\"{r['count']:>8}  {r['word']}\")\nprint(f\"\\ninput partitions : {lines.rdd.getNumPartitions()}\")\nprint(f\"elapsed          : {elapsed:.1f} s\")\n\nspark.stop()", lang: "python", block: true)],
    [
      #lbl("what is this part doing?", fill: luma(120))
      #v(5pt)
      #writing(22)
    ],
  )
]

#v(5pt)

#panel("5 · Extension · change what the script calls a word")[
  #text(size: 8.5pt)[
    The `words.filter(...)` block throws tokens away before counting: anything under three
    characters, anything that is all digits, and anything in `stopwords.txt`. Each of
    those is a decision somebody made, and each one changes the answer.
  ]
  #v(4pt)
  #text(size: 8.5pt)[Make one change at a time, re-run, and record what moves:]
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 4pt, align: (top, top),
    text(size: 8pt, weight: "bold")[drop the length filter],
    text(size: 8pt)[Remove the `F.length(...) >= 3` line. A comment beside it *in the file* predicts what you will see: the listing above is trimmed of comments, the file is not. Was it right?],

    text(size: 8pt, weight: "bold")[raise `TOP_N`],
    text(size: 8pt)[`TOP_N`, near the top. Show fifty words instead of fifteen. Does the run take longer? Should it?],

    text(size: 8pt, weight: "bold")[add one stopword],
    text(size: 8pt)[`websites` is in the top ten of the Wikipedia corpus and nobody wrote it in a sentence: it comes from the *Other websites* heading. Add it and see what takes its place.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    Then the question that matters: is editing the stopword list *cleaning the data*
    or *choosing the answer*? One sentence.
  ]
  #v(2pt)
  #writing(2)
]

#v(5pt)

#panel("6 · Extension · why 589, and where a setting lives")[
  #text(size: 8.5pt)[
    Step 1's 589 is neither one piece per file nor one in total. Spark groups small
    files, because opening a file costs time whatever its size, and it charges every
    file a flat fee to account for that. The fee is a setting with a default of 4 MiB,
    and you can change it for one run:
  ]
  #v(3pt)
  #raw("kubectl exec deploy/spark-master -- \\\n  /opt/spark/bin/spark-submit --master spark://spark-master:7077 \\\n  --conf spark.sql.files.openCostInBytes=1048576 \\\n  /lab/wordcount_df.py /lab/data '/lab/data/20news/*.txt'", lang: "bash", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, align: (top, top),
    raw("--conf spark.sql.files.openCostInBytes"),
    text(size: 7.8pt)[The fee, in bytes. 1048576 is 1 MiB, a quarter of the default. `--conf` sets it for this run only.],
  )
  #v(3pt)
  #text(size: 8.5pt)[
    A cheaper fee means more files fit in one piece. Predict the direction, then read
    it off.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[predicted: up or down], rule(100%),
    text(size: 8pt)[`input partitions`], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt)[
    The same setting can live in the script instead, where it is part of the program
    rather than part of how you happened to launch it. The line that builds the
    session takes it:
  ]
  #v(3pt)
  #raw("spark = (SparkSession.builder.appName(\"wordcount-df\")\n         .config(\"spark.sql.files.openCostInBytes\", 1048576)\n         .getOrCreate())", lang: "python", block: true)
  #v(3pt)
  #text(size: 8.5pt)[
    Copy the script to a new name, make that edit, and run it *without* `--conf`. Then
    say which of the two places you would use for something that must hold every time
    the script runs.
  ]
  #v(2pt)
  #writing(2)
  #v(3pt)
  #text(size: 8pt, style: "italic", fill: luma(90))[
    Observed 2026-09-23: 148 pieces either way, down from 589. Edit under a *new*
    filename; a file rewritten in place is sometimes still the old one inside the pod.
  ]
]

#v(5pt)

#panel("7 · Annex · troubleshooting")[
  #text(size: 8.5pt)[
    *`git pull` refuses.* If somebody in your group edited one of the lab's own
    scripts on 21.09, git stops rather than overwrite that edit, and says
    `Your local changes to the following files would be overwritten by merge`. Put the
    edit aside and pull again:
  ]
  #v(3pt)
  #raw("git -C lab stash\ngit -C lab pull", lang: "bash", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 3pt, align: (top, top),
    raw("git -C lab stash"),
    text(size: 7.8pt)[Puts your edit away and restores the file git shipped. The edit is kept, not thrown away: `git -C lab stash pop` brings it back after the round.],

    raw("git -C lab pull"),
    text(size: 7.8pt)[The same line as step 1. With nothing edited, it now goes through.],
  )
  #v(5pt)
  #text(size: 8.5pt)[
    *The cluster is gone.* `docker start k8s` answers `No such container` only if you removed the cluster
    rather than stopping it. Rebuilding it is not new work and it is not reprinted
    here: it is *µLab 3 of 21.09, panel 1, Start again from nothing*, which creates
    the container, starts a client with the manifest mounted, and applies it. Work
    through that panel, then come back to step 1 above.
  ]
  #v(4pt)
  #text(size: 8pt)[
    Tell the Lab Master before you start: it takes several minutes, and somebody in
    the room has already done it today.
  ]
]
