// ---------------------------------------------------------------------------
// ulab3-driver-worksheet.typ — one A4 sheet per group, for µLab 3 of week 2 day 1.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the four steps so that the answer to "what were we
// supposed to do again?" is on the table rather than on a slide that has moved on.
//
// The roles rotate between rounds: whoever drove µLab 1 or µLab 2 is not driving
// this one.
//
// This round runs on the cluster µLab 2 built, which is why µLab 2 exists. Every
// command here is a submission to spark://spark-master:7077, and the extensions
// change the cluster's size rather than a --master flag, so the partition sweep
// and the scaling are the same exercise.
//
// Two rulings worth not re-opening. First, D2 wants definitions collected before
// first use and C3 wants every word seen on screen defined; seventeen plan tokens
// in panel 2 would be unreadable and would arrive four pages early, so concepts
// used across panels are in panel 2 and the tokens of one specific output are
// glossed in the panel that produces it. Second, the execution plan is reprinted
// here with the 203-stopword dump elided, and the elision is announced, because
// the real line is unreadable on a laptop and impossible to point at.
//
// The sheet is cut in two by a checkpoint bar. AUTHORING.md rule G1 sizes a core
// at ten minutes; this one is sized for fifteen to twenty, because the RDD count
// in step 3 takes minutes and the reader is not the clock.
//
// Every number quoted below was observed on a real run on 2026-09-21, on a
// four-worker cluster, not reasoned out.
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
  title: "µLab worksheet · Counting words with DataFrames and with RDDs",
  subtitle: [302 Data infrastructures · week 2, day 1],
  authors: ("",),
  date: datetime(year: 2026, month: 9, day: 21),
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
#text(size: 7.5pt, fill: luma(140), style: "italic")[
  Hand this in at the end of the round. The referee presents this work in 90 seconds
  at the caucus, so the referee has to follow it, not just watch it.
]
#v(5pt)

// ══ CORE — fifteen to twenty minutes ══════════════════════════════════════
#panelb("1 · Fill the lab folder, then hand the cluster a file · step 1")[
  #text(size: 8.5pt)[
    µLab 2 built the Spark cluster by typing three commands, and it works. Two things
    those commands cannot do are now needed: give the pods the folder holding the corpus,
    and give the master a name of its own in cluster DNS. Neither is an option on
    #raw("kubectl create"). Both are lines in a file.
  ]
  #v(3pt)
  #step("1", "Put the scripts and the corpus into lab, then apply the file.")[
    The first three lines run on the laptop, in the folder holding #raw("kube") and
    #raw("lab"). The corpus is the 20 MB #raw("20news.zip") from ISC Learn.
  ]
  #v(2pt)
  #raw("git clone https://github.com/oesteban/isc-302-2026-2027-spark-lab lab\nunzip ~/Downloads/20news.zip -d lab/data\nls lab/data/20news | wc -l", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("clone … lab"),
    text(size: 7.8pt)[The last argument says where to put it, and it must be the #raw("lab") µLab 2 created, because that is the folder the cluster was given. Cloning into it works only while it is *empty*; if this refuses, something is already there.],
    raw("unzip -d lab/data"),
    text(size: 7.8pt)[Unpack into that folder. The zip contains a directory called #raw("20news"), so this produces #raw("lab/data/20news") beside the #raw("stopwords.txt") that came with the clone.],
    raw("| wc -l"),
    text(size: 7.8pt)[Count the lines, which here means count the files. It must read *18846*. Anything else means the zip landed somewhere other than #raw("lab/data").],
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now describe the cluster in a file, and apply it.]
  #v(1pt)
  #text(size: 8pt)[
    The same Service and two Deployments as µLab 2, written down instead of typed, plus
    the two things that could not be typed. In the #raw("kubectl") shell:
  ]
  #v(2pt)
  #raw("kubectl apply -f https://raw.githubusercontent.com/oesteban/\\\n  isc-302-2026-2027-spark-lab/main/spark-standalone.yaml", lang: "console")
  #v(2pt)
  #text(size: 7.8pt, fill: luma(120))[
    The address is one line, broken here only to fit the page. Type it without the
    backslash and without the line break.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("apply"),
    text(size: 7.8pt)[Make the cluster match the description: create what is missing, change what differs, leave the rest alone. Safe to run twice.],
    raw("-f https://…"),
    text(size: 7.8pt)[#raw("-f") is for #emph[file], and a URL counts as one. #raw("raw.githubusercontent.com") serves a file's contents rather than the web page around it.],
    raw("volumeMounts: /lab"),
    text(size: 7.8pt)[In the file, on both Deployments: hand each pod the folder the cluster container sees at #raw("/lab").],
    raw("hostname: spark-master"),
    text(size: 7.8pt)[In the file, on the master: give the pod a name cluster DNS answers for, so #raw("--conf spark.driver.host") is never needed again.],
  )
  #v(3pt)
  #text(size: 8pt)[
    It prints three warnings saying these objects were created by hand and it has nothing
    to compare against. That is true and harmless: it patches them anyway, and each pod is
    replaced by one that has the folder.
  ]
  #v(4pt)
  #text(size: 8pt)[
    Once the new pods read #raw("1/1 Running"), ask one of them to count the same files.
    It has never been told anything about your laptop:
  ]
  #v(2pt)
  #raw("kubectl get pods\nkubectl exec deploy/spark-worker -- ls /lab/data/20news | wc -l", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[files on the laptop], rule(100%),
    text(size: 8pt)[files inside the pod], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Then set the cluster to four workers.]
  #v(1pt)
  #text(size: 8pt)[
    Every command in this round is a submission to that cluster, and nothing runs on your
    laptop's own cores. Each worker was given one core, so the cluster's size is its
    worker count. Four, so that every group runs the same experiment.
  ]
  #v(2pt)
  #raw("kubectl scale deployment spark-worker --replicas=4\nkubectl logs deploy/spark-master | grep -c \"Registering worker\"", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("scale … --replicas=4"),
    text(size: 7.8pt)[Edit one field of a Deployment that already exists. Give it fifteen seconds and re-run #raw("kubectl get pods").],
    raw("grep -c \"Registering worker\""),
    text(size: 7.8pt)[Count the lines in which a worker announced itself. The master restarted when the file was applied, so this counts only what has reported in since.],
  )
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[worker pods Running], rule(100%),
    text(size: 8pt)[cores available], rule(100%),
  )
]

#panelb("2 · Some definitions")[
  #text(size: 8pt)[
    Everything this round asks you to explain can be answered from this block. The words
    for the cluster itself, *driver*, *executor*, *master* and *worker*, were defined in
    µLab 2 and are not repeated.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 5pt, align: (top, top),

    text(size: 8.5pt, weight: "bold")[partition],
    text(size: 8pt)[
      *The piece of a dataset that one core works on at a time.* Splitting the data is
      what lets several cores work at once, so nothing is parallel until it is
      partitioned. Both scripts print how many partitions the *read* produced, under
      #raw("input partitions"). That is not the same number as the #raw("200") that
      appears later in the plan, which is how many the *shuffle* produces.
    ],

    text(size: 8.5pt, weight: "bold")[task],
    text(size: 8pt)[
      *The work of one partition, run on one core.* Spark schedules it, ships it to an
      executor and collects the result, and it pays that cost once per task whether the
      partition holds a gigabyte or four kilobytes. Partitions are therefore not free,
      and the number of them is the single most important thing about a Spark job.
    ],

    text(size: 8.5pt, weight: "bold")[transformation],
    text(size: 8pt)[
      *An instruction that describes a new dataset without producing one.*
      #raw("select"), #raw("filter"), #raw("groupBy"), #raw("map") return immediately
      and read nothing. They build a description, and that is all they do.
    ],

    text(size: 8.5pt, weight: "bold")[action],
    text(size: 8pt)[
      *An instruction that demands an answer, and therefore runs everything described so
      far.* The two in these scripts are #raw("take") and #raw("takeOrdered"). Until one
      of them is reached, no file has been opened.
    ],

    text(size: 8.5pt, weight: "bold")[shuffle],
    text(size: 8pt)[
      *Moving rows between partitions so that rows belonging together end up together.*
      Counting a word needs every copy of that word in one place, and they start
      scattered across every file, so every partition has to send something to every
      other. It is the most expensive thing a Spark job does, and on a real cluster it
      crosses the network. In a plan it is printed as #raw("Exchange").
    ],

    text(size: 8.5pt, weight: "bold")[DataFrame],
    text(size: 8pt)[
      *Rows in named columns, described by expressions Spark can read.* Because Spark can
      read the description, it can rewrite it before running: choose the order, choose
      how to group, decide how many partitions. The rewritten result is the *plan*.
    ],

    text(size: 8.5pt, weight: "bold")[RDD],
    text(size: 8pt)[
      *A collection of Python objects with no columns and no types, transformed by
      functions Spark cannot look inside.* Spark's original API, from before DataFrames
      were built on top of it. Because a lambda is opaque, nothing can be rewritten:
      what is written is what runs, in the order it was written.
    ],

    text(size: 8.5pt, weight: "bold")[plan, and lineage],
    text(size: 8pt)[
      *The plan is what the optimiser decided; the lineage is the chain as it was
      written.* #raw("explain()") prints the first and #raw("toDebugString()") prints the
      second. An RDD has no plan to print because there is no optimiser to print one.
    ],

    text(size: 8.5pt, weight: "bold")[stopword],
    text(size: 8pt)[
      *A word dropped before counting because its frequency says nothing.* This corpus
      has 203 of them, ordinary English plus the names of mail header fields. They
      matter twice here: they are why #raw("university") finishes fifth, from the
      #raw("Organization:") lines rather than from anyone discussing universities, and
      they are why one line of the plan in panel 5 is enormous.
    ],
  )
]

#panelb("3 · Count the words with the DataFrame API · step 2")[
  #text(size: 8.5pt)[
    The script below counts every word in 18'846 Usenet messages and prints the fifteen
    most common. What this step is for is not the word list: it is that the *plan comes
    out above the words*. Nothing before the last line reads a single file, so Spark can
    print what it intends to do before it has done any of it.
  ]
  #v(3pt)
  #text(size: 8pt)[The script, with the noise removed, is eight lines:]
  #v(2pt)
  #raw("lines  = spark.read.text(\"…/20news/*.txt\")                      # a transformation
words  = lines.select(explode(split(lower(col(\"value\")), r\"\\W+\")))  # a transformation
words  = words.filter(length >= 3 and not numeric and not a stopword)
counts = words.groupBy(\"word\").count().orderBy(desc(\"count\"))       # still nothing ran
counts.explain()                                                    # prints the plan
rows   = counts.take(15)                                            # THIS one runs it
print(rows)
print(lines.rdd.getNumPartitions())", block: true)
  #v(4pt)
  #step("2", "Submit it to the cluster, in the kubectl shell.")[
    The driver runs inside the master pod, for the reason µLab 2 panel 9 gives.
  ]
  #v(2pt)
  #raw("kubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  /lab/wordcount_df.py /lab/data", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("exec deploy/spark-master"),
    text(size: 7.8pt)[Run a command inside the master's pod. KIND#raw("/")NAME again, so the pod's own name is not needed.],
    raw("--"),
    text(size: 7.8pt)[End of #raw("kubectl")'s arguments. Everything after belongs to the command being run, so #raw("--master") is read by Spark.],
    raw("spark-submit"),
    text(size: 7.8pt)[Spark's launcher: start a driver, ask a master for cores, run the code, print, exit.],
    raw("--master spark://…:7077"),
    text(size: 7.8pt)[Which cluster to ask. The Service name and submit port from µLab 2. Change nothing here and the same line works on a cluster of any size.],
    raw("/lab/wordcount_df.py"),
    text(size: 7.8pt)[The program to run. This path is *inside the pods*, where µLab 2 attached the repository, and it is the same path for the driver and for every executor.],
    raw("/lab/data"),
    text(size: 7.8pt)[The script's own argument: which folder to read. Without it the script looks for #raw("data") beside itself, which is not where it is from inside a pod.],
  )
  #v(3pt)
  #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
    #text(size: 8pt)[
      Several hundred lines of Spark's own logging come first. The output that belongs to
      this exercise begins at the first banner line, a row of equals signs reading
      #emph[the plan, before a single byte has been read]. Everything above it can be
      ignored.
    ]
  ]
  #v(3pt)
  #text(size: 8pt)[
    *Write these down now.* They are printed once, at the end of this run, and panel 6
    needs them after the next run has scrolled them away. On a four-worker cluster this
    took *11.7 seconds* and reported *589* input partitions, with #raw("one") on top at
    14'620.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[elapsed], rule(100%),
    text(size: 8pt)[input partitions], rule(100%),
    text(size: 8pt)[top word], rule(100%),
    text(size: 8pt)[its count], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now answer the first question.]
  #v(1pt)
  #text(size: 8pt)[
    Which line of the script above made work actually happen? The eight-line skeleton is
    at the top of this panel, and panel 2 separates the two kinds of instruction. Your own
    output brackets the answer: everything printed above the second banner line, the one
    reading #emph[now an action, and only now does anything run], happened without
    reading anything.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[the line], rule(100%),
  )
]

#panelb("4 · Start the RDD count, then leave it running · step 3")[
  #text(size: 8.5pt)[
    The second script gets the same fifteen words by different machinery: no columns, no
    optimiser, just functions applied one after another. It takes *minutes* rather than
    seconds: on a four-worker cluster it took *555 seconds*, which is nine minutes. Why
    is the question panel 6 asks. Start it now and go straight to panel 5. Do not sit and
    watch it.
  ]
  #v(3pt)
  #step("3", "Open a SECOND kubectl shell, and submit the other script from there.")[
    A second #raw("docker run") line, exactly the one from µLab 2, in a second terminal.
    The first shell keeps the DataFrame output on screen, which panel 5 needs.
  ]
  #v(2pt)
  #raw("kubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  /lab/wordcount_rdd.py /lab/data", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("/lab/wordcount_rdd.py"),
    text(size: 7.8pt)[The only thing that changes. Every other argument is the one explained in panel 3.],
    raw("second shell"),
    text(size: 7.8pt)[Not a second cluster: both shells talk to the same master. Two clients, one cluster, exactly as in µLab 1.],
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Read one number off it straight away, then walk away.]
  #v(1pt)
  #text(size: 8pt)[
    This script prints its lineage within the first few seconds, and the number in
    parentheses at the head of the first line is its partition count. The
    #raw("input partitions") line at the bottom says the same thing, but only arrives
    when the whole job is over. Take it from the lineage now:
  ]
  #v(2pt)
  #raw("(18846) PythonRDD[6] at RDD at PythonRDD.scala:53 []
   |    MapPartitionsRDD[5] at mapPartitions at PythonRDD.scala:160 []
   |    ShuffledRDD[4] at partitionBy at <unknown>:0 []
   +-(18846) PairwiseRDD[3] at reduceByKey at /lab/wordcount_rdd.py:36 []
        |    PythonRDD[2] at reduceByKey at /lab/wordcount_rdd.py:36 []
        |    /lab/data/20news/*.txt MapPartitionsRDD[1] at textFile at <unknown>:0 []
        |    /lab/data/20news/*.txt HadoopRDD[0] at textFile at <unknown>:0 []", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[input partitions #text(fill: luma(140))[(now)]], rule(100%),
    text(size: 8pt)[elapsed #text(fill: luma(140))[(when it lands)]], rule(100%),
  )
]

#panelb("5 · Find the shuffles in the plan · step 4")[
  #text(size: 8.5pt)[
    The plan printed in step 2 is what Spark decided to do, written as a tree. Read it
    *bottom-up*: the bottom row happens first and the top row last. Two of its rows move
    rows between partitions, and those two are what this step is about.
  ]
  #v(3pt)
  #step("4", "Scroll back to the plan in the first shell, and find the two Exchange rows.")[
    The copy below is the same plan with one line shortened, so that it can be marked up
    on paper. Circle the two rows on this sheet; check they are in your own output too.
  ]
  #v(2pt)
  #raw("AdaptiveSparkPlan isFinalPlan=false
+- Sort [count DESC NULLS LAST], true, 0
   +- Exchange rangepartitioning(count DESC NULLS LAST, 200), ENSURE_REQUIREMENTS
      +- HashAggregate(keys=[word], functions=[count(1)])
         +- Exchange hashpartitioning(word, 200), ENSURE_REQUIREMENTS
            +- HashAggregate(keys=[word], functions=[partial_count(1)])
               +- Filter ((length(word) >= 3) AND NOT RLIKE(word, ^[0-9]+$)
                          AND NOT word INSET < 203 stopwords, ONE LINE on your screen >)
                  +- Generate explode(split(lower(value), \\W+, -1)), false, [word]
                     +- FileScan text [value] … InMemoryFileIndex(18846 paths)", block: true)
  #v(3pt)
  #text(size: 8pt)[
    The angle brackets on the eighth row are this sheet's, not Spark's: on your screen
    all 203 stopwords are printed there, on one line, which is why that row runs off the
    right of the terminal. Spark also numbers each column and each shuffle
    (#raw("word#3"), #raw("plan_id=26")); both are internal and are dropped above.
  ]
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[What each row is, bottom to top.]
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("FileScan text"),
    text(size: 7.8pt)[Open the files and produce one row per line of text. This is the first thing that happens, and the only row that touches a disk.],
    raw("InMemoryFileIndex(18846 paths)"),
    text(size: 7.8pt)[How many files Spark found. Note it, because panel 6 compares it with the two partition counts.],
    raw("Generate explode(split(…))"),
    text(size: 7.8pt)[Cut each line into words and turn one row of text into many rows of one word. #raw("split") cuts, #raw("explode") is what turns one row into many.],
    raw("\\W+"),
    text(size: 7.8pt)[The pattern to cut on: one or more characters that are not letters or digits. It is also why #raw("don't") becomes #raw("don") and #raw("t"), and therefore why short words are dropped.],
    raw("Filter"),
    text(size: 7.8pt)[Throw rows away. #raw("RLIKE") is a regular-expression match, here used to drop pure numbers; #raw("INSET") is membership of a fixed list, here the 203 stopwords.],
    raw("HashAggregate partial_count"),
    text(size: 7.8pt)[Count within each partition, without talking to any other partition. Cheap, local, and incomplete: the same word is still counted in many places.],
    raw("Exchange hashpartitioning(word, 200)"),
    text(size: 7.8pt)[*The first shuffle.* Send every row to the partition chosen by a hash of its word, so that all copies of one word land together. #raw("200") is how many partitions come out.],
    raw("HashAggregate count"),
    text(size: 7.8pt)[Now that each word is in one place, add up the partial counts. This row is the answer.],
    raw("Exchange rangepartitioning(count, 200)"),
    text(size: 7.8pt)[*The second shuffle.* Send rows to partitions by range of count, so that partition 1 holds the largest counts and partition 200 the smallest. Sorting needs that; counting did not.],
    raw("Sort"),
    text(size: 7.8pt)[Order within each partition. After the range shuffle, that is enough to have the whole thing in order.],
    raw("AdaptiveSparkPlan isFinalPlan=false"),
    text(size: 7.8pt)[This is the plan from *before* the run. Spark is allowed to change it while running, once it can see how much data there actually is, and #raw("false") says it has not done so yet.],
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now answer what the two shuffles are for.]
  #v(1pt)
  #text(size: 8pt)[
    The two #raw("Exchange") rows both move every row across the cluster, and they do it
    for different reasons. Say, in one line each, what would go wrong if each were
    removed. The two glosses above name what each one groups rows by, and the row
    immediately above each shuffle is what needed that grouping.
  ]
  #writing(2)
  #v(3pt)
  #text(size: 8pt)[
    One more number to be careful with: the #raw("200") in both shuffle rows is neither
    589 nor 18'846. Say which of the three the reader produced, and which the shuffle
    produced. Panel 2, under *partition*, distinguishes them.
  ]
  #writing(2)
]

#v(6pt)

#text(size: 8pt, style: "italic", fill: luma(110))[
  Solved means panels 1 to 5 are done: the DataFrame count finished and its four numbers
  written down, the RDD count started and its partition count taken from the lineage, and
  the two #raw("Exchange") rows found and explained. The RDD clock may still be empty
  here, and goes in at panel 6.
]
#v(3pt)

#checkpoint

#v(8pt)

// ══ EXTENSIONS — up to twenty minutes ═════════════════════════════════════
#panelb("6 · Compare the two partition counts and the two clocks")[
  #text(size: 8.5pt)[
    Both scripts printed the same fifteen words with the same counts, on the same
    cluster, from the same files. Everything that differs between them is machinery.
    Copy the four numbers you wrote down in panels 3 and 4 into one place.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[DataFrame partitions], rule(100%),
    text(size: 8pt)[DataFrame elapsed], rule(100%),
    text(size: 8pt)[RDD partitions], rule(100%),
    text(size: 8pt)[RDD elapsed], rule(100%),
  )
  #v(4pt)
  #text(size: 8pt)[
    One fact you need and cannot work out from the output: #raw("sc.textFile"), which the
    RDD script uses, gives *at least one partition per file*. The DataFrame reader packs
    small files together instead, until the bucket it is filling reaches a size limit.
  ]
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Two questions, and both are arithmetic before they are opinion.]
  #v(2pt)
  #text(size: 8pt)[
    One of the two partition counts is exactly the number of files, which panel 5's
    #raw("InMemoryFileIndex") row also printed. Divide the larger partition count by the
    smaller one and write the result down. Then say what that number is counting.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[the quotient], rule(60mm),
  )
  #writing(2)
  #v(3pt)
  #text(size: 8pt)[
    Now the clocks. The two runs did identical arithmetic on identical data and one took
    far longer. Say what the extra time was spent on, using the definition of *task* in
    panel 2 and the two partition counts above. The answer is not that one API is
    written better than the other.
  ]
  #writing(2)
]

#v(5pt)

#panelb("7 · Split the same job three ways and time each one")[
  #text(size: 8.5pt)[
    Panel 6 compared two partition counts that the two readers happened to choose. This
    one chooses them on purpose. #raw("slowdown.py") runs the same count three times over
    the same 34 MB, at 8 partitions, then 800, then 8000, and prints a wall clock for
    each. The number of distinct words it finds is printed beside each clock and it never
    changes, which is the point: the answer is identical all three times, so the only
    thing being measured is what it costs to administer the work.
  ]
  #v(3pt)
  #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
    #text(size: 8pt)[
      *Wait until the RDD count from step 3 has finished before submitting this.* A
      standalone master gives every core it has to the first application that asks, so a
      second submission does not share: it waits, printing
      #raw("Initial job has not accepted any resources") until the first one is over.
    ]
  ]
  #v(3pt)
  #raw("kubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  /lab/slowdown.py /lab/data", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("/lab/slowdown.py"),
    text(size: 7.8pt)[The only argument that differs from panel 3. The script sets the partition counts itself, with #raw("repartition(n)"), which is a transformation that says nothing except #emph[redistribute into n pieces].],
  )
  #v(3pt)
  #text(size: 8pt)[
    It prints the master, the partitions the read chose, then one row per split. Record
    the three clocks: expect the middle to be roughly twice the first, and the last
    several times the middle again. Ignore the #raw("cores Spark will use") line, which
    is Spark's default parallelism with a floor of two, read before the executors have
    reported in. Panel 1 has the cluster's real core count.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr, auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[8], rule(100%),
    text(size: 8pt)[800], rule(100%),
    text(size: 8pt)[8000], rule(100%),
  )
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[distinct words, all three], rule(50mm),
  )
]

#v(5pt)

#panelb("8 · Shrink the cluster to one core and run it again")[
  #text(size: 8.5pt)[
    Panel 7 varied the partitions and held the cores fixed. Now hold the partitions fixed
    and vary the cores. Every worker offers one core, so the cluster's size is a field in
    a Deployment, and changing it is the command µLab 1 used on the whale. This is the longest
    run on the sheet, about six minutes on one core against two on four, so start it and
    read the question below while it works.
  ]
  #v(3pt)
  #raw("kubectl scale deployment spark-worker --replicas=1\nkubectl get pods\nkubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  /lab/slowdown.py /lab/data", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("--replicas=1"),
    text(size: 7.8pt)[One worker, one core. Wait until #raw("kubectl get pods") shows a single #raw("spark-worker") before submitting, or the job will start with cores that are about to disappear.],
    raw("the wait"),
    text(size: 7.8pt)[This is the longest run on the sheet: about *six minutes* on one core, against two on four. Start it, then read the question below while it works.],
  )
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[8], rule(100%),
    text(size: 8pt)[800], rule(100%),
    text(size: 8pt)[8000], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Six clocks, one sentence.]
  #v(1pt)
  #text(size: 8pt)[
    Read the six numbers as a table: cores across, partitions down. Every column rises as
    the partitions go up, and every row falls as the cores go up. Say in one sentence why
    8000 partitions over 34 MB is slower than 8, *on both cluster sizes*. Panel 2 defines
    *task*, and 34 MB divided by 8000 is the size of one of them.
  ]
  #writing(2)
  #v(3pt)
  #text(size: 8pt)[
    Put the cluster back before you leave: #raw("kubectl scale deployment spark-worker --replicas=4").
  ]
]

#v(6pt)

#panel("9 · Extra mile · make the reader choose a different number of partitions")[
  #text(size: 8.5pt)[
    589 was not a guess. The reader charges a fixed cost per file, then fills each
    partition until the total reaches a limit. Both are settings. Predict the new
    partition count before you look.
  ]
  #v(2pt)
  #raw("kubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  --conf spark.sql.files.maxPartitionBytes=32m \\\n  /lab/wordcount_df.py /lab/data", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("--conf"),
    text(size: 7.8pt)[Set one Spark setting for this submission only. Nothing on the cluster is changed and the next job is unaffected.],
    raw("spark.sql.files.maxPartitionBytes"),
    text(size: 7.8pt)[How much a single input partition may hold before the reader starts another one. The default is #raw("128m"), and this asks for a quarter of that.],
  )
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[partitions predicted], rule(100%),
    text(size: 8pt)[partitions measured], rule(100%),
    text(size: 8pt)[elapsed], rule(100%),
    text(size: 8pt)[elapsed at the default], rule(100%),
  )
  #v(3pt)
  #text(size: 8pt)[
    The other setting is #raw("spark.sql.files.openCostInBytes"), the fixed charge per
    file, which defaults to #raw("4m"). With 18'846 files, those two numbers are enough
    to work out 589 exactly. Do the arithmetic, then say what the best partition count
    depends on: the size of the data, or the size of the cluster.
  ]
  #writing(1)
]

#v(8pt)

#panel("10 · Annex · getting past two things that go wrong")[
  #text(size: 8pt)[
    The #raw("Filter") row is unreadable because #raw("explain()") prints every value of
    an #raw("INSET") test, and there are 203 of them. #raw("explain(\"formatted\")")
    prints the tree first and the conditions afterwards, one per row, which fits on a
    screen. Using it means editing the script, which is why the core does not.
  ]
  #v(3pt)
  #text(size: 8pt)[
    *If a submission never starts.* The driver waits, printing
    #raw("Initial job has not accepted any resources") every fifteen seconds. It means no
    executor could be started, and the usual cause here is that there are no workers:
    panel 8 scales them to one. #raw("kubectl get pods") settles it in one line. The
    other two causes are a submission queued behind one that already holds every core,
    which panel 7 warns about, and a driver with no name, which µLab 2 panel 9 covers.
  ]
]

#v(4pt)
#align(center)[
  #text(size: 8pt, fill: luma(130), style: "italic")[
    Done when the referee can point at the two shuffles in the plan, and say why the same
    count took nine minutes one way and twelve seconds the other.
  ]
]
