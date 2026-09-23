# Authoring the 302 material

Rules for writing a slide or a printed instrument in this repository. They are numbered so
that a review can cite one instead of re-arguing it.

Every rule below was paid for. On 2026-09-20 the µLab 1 worksheet for week 2 day 1 took
**26 commits in a single day**, and almost none of them added content: they corrected the
same handful of faults, one round trip at a time. Each rule carries the test that detects
the violation and the case that produced it.

This file covers **what to write**. How much to write is a separate rule and lives
elsewhere: on a slide, less is better, and one idea per slide.

---

## A · Titles and headings

### A1 · A title names its content

No slogans, no quoted phrases, no riddles. A title tells the reader what is inside so they
can find it again; it is not an invitation to read on.

> **Test:** could this title sit on a different panel or slide without looking wrong? Then
> it names nothing.

| rejected | replacement |
|---|---|
| A Deployment is a wish that never expires | Deployment and Job |
| The controller's own account | Read the cluster's event log |
| Two image stores, one name | The cluster has its own image store |
| A wish is not a command | Scale the Deployment, then delete a pod |
| What the logs will tell you | Reading logs |
| What you started | *(deleted; the questions moved to where they belonged)* |

### A2 · Every heading carries a verb

A heading states what is to be done or what is to be known. A bare noun phrase states
neither, and the reader has to guess the objective from the body.

| rejected | replacement |
|---|---|
| Two lines from the watch, and the reason | Why the Deployment kept restarting |
| Now the question this round is about | Now **answer** the question this round is about |
| First, where those pods are running | First, **find out** where those pods are actually running |

The ` … , and the reason` / ` … , and what it bought` construction is the recurring form.
It reads as a contents list for an essay, not as an instruction.

### A3 · The line under a heading adds information

It never restates the heading in other words.

> Rejected: **Two lines from the watch in step 4.** / *One copied in the first seconds, one
> copied about a minute later.*
>
> The second line repeats the first and hedges it. The replacement states the objective and
> then gives the commands that produce the data.

---

## B · Before the command

### B1 · State the aim of a step before the command that performs it

The reader has to know what the step is for while typing it, not after.

> Rejected: *Ask the cluster to keep a whale running.*
>
> Replacement: *The aim of this round is to watch what a cluster does when a container
> stops. So the object to create is a Deployment: a stored request for three pods that
> should be running. Three rather than one, only so that there is more to watch.*

### B2 · Every argument of every command line is explained

No exceptions. This includes flags, positional arguments, the image name, the separator
`--`, shell operators (`&&`, `|`, `>`), and anything after the image name that is not a
Docker flag at all.

The device is the two-column table: `#raw("<the argument>")` on the left, one sentence on
the right. It is already the idiom in every handout here.

```typst
#grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
  raw("--rm"),
  text(size: 7.8pt)[Delete this container the moment you leave it. …],
  raw("--network container:k8s"),
  text(size: 7.8pt)[Do not give this container its own network — *join the one the
    cluster container already has*. …],
)
```

Three separate commits on 2026-09-20 went back and added tables that should have been
there from the first draft: for the `docker run` flags, then for the kubectl client
command, then for every `kubectl` line in the body.

### B3 · Every command states where it runs

Which machine, which shell, which container. A command typed in the wrong place fails in a
way the reader cannot diagnose, because the sheet has told them it should work.

> Rejected: *Inside the cluster: `crictl images`.* The reader is holding a `kubectl` that
> runs **outside** the cluster, so this sends them to type it in the one place it does not
> exist.
>
> Replacement: *Both lines below are typed **on the laptop**, in a terminal that is not the
> kubectl one:* `docker exec k8s crictl images`, followed by a note that `crictl` exists
> only inside that container.

A claim about location must also be **provable by something the reader can run**. Proving
a client is not the cluster with `command -v k3s` proves nothing to someone who does not
already know the answer; `docker ps` showing two containers does.

### B4 · Say what the exercise is meant to show, before it is done

Withholding the point does not make an exercise interesting, it makes it unattemptable. A
reader who does not know what they are looking for cannot look.

Suspense is permitted in exactly one place: a panel or slide marked **Extra mile**. There,
the lever is still handed over; only the answer is withheld.

> *"If you explain what you are trying to show instead of writing a hitchcock novel of
> mistery, it is more likely they will actually get to do what they are asked. Keep the
> mistery for the extra-mile extension, you can get artistic there. Here we are teaching."*
> (2026-09-20)

---

## C · Questions

A question is the most expensive thing on a sheet. It is also the easiest to get wrong,
because a question that cannot be attempted looks exactly like one that can.

### C1 · Every question names the command, the panel or the output that answers it

> **Test:** trace the path from the question to its answer using nothing but this sheet and
> the terminal. No path, no question.

| hedged | with a path |
|---|---|
| Does it pick the same pod both times, and is that what you would want? | Run it twice: the same pod answers both times. *Now suppose only one of the three pods is misbehaving. What is the risk in letting kubectl choose for you?* |
| Which architecture is this laptop? | Ask Docker, not the shell … `docker version --format '{{.Server.Arch}}'` |
| What had to be true of your package for that to work? | Open your package's page on GitHub, your profile, then *Packages*. One setting there is the answer. |
| Where did the cluster's copy come from? | One line of the event log in panel 7 says it outright, with a duration. |

### C2 · Never ask about a term the material has not defined

`restartPolicy` was the entire answer to *"why does the cluster start it again?"* and the
word appeared nowhere on the sheet. The fix was not a better question: it was a definition,
plus the two commands that print the field's value on a pod of each kind.

> *"This is definitely not something someone using k8s for first time can know. Not even in
> the 100th time."* (2026-09-20)

### C3 · Define every word the reader will see on screen

Not only the words written on the sheet. Tool output introduces vocabulary too, and an
undefined word in a terminal is worse than one on paper, because there is nothing to look
it up against.

`kubectl describe pod` prints an `Events` block whose `From` column reads `kubelet` and
`default-scheduler`. Neither was defined. Both are now.

### C4 · The instruction to record data sits where the data is produced

Not in the panel that later consumes it. A reader who was not told to write something down
at the time does not have it afterwards, and will not re-run the step to get it.

Two forms of this fault, both found on the same sheet:

- The node figures from `kubectl get nodes` were requested four panels after the command
  that printed them. The fields moved to sit directly under the command.
- Panel 4 asked for *"two lines from the watch in step 4"*, where step 4 had said nothing
  about writing anything down. The panel now deletes the Deployment, recreates it, and says
  when to write each line.

### C5 · A value printed next to a field is masked, or it is not printed

A field exists so the reader produces the value. Printing the answer beside it turns
producing into copying, and a copied field proves nothing at the checkpoint.

Three cases, three treatments:

| what the value is for | treatment |
|---|---|
| **Checking** that a prerequisite is intact | Mask the middle: `79 8·· ··1`. Enough to catch a truncated download, not enough to fill the field without looking. |
| **Calibrating** how long something should take | State the order of magnitude, never the measurement: *"under two minutes"*, not *"110 s"*. Clocks differ by laptop anyway, so an exact figure is both an answer and a lie. |
| **Revealing** what the round was about | Print it exactly, and put it **below the checkpoint bar**, in the panel that explains it. That is the reward for having written your own number first. |

> The fault that produced this: `Size it reports, in bytes: ______  expected: 79 874 161`.
> A reader who copies that has not checked their download, which is the one thing the
> field was there to do.

---

## D · Definitions

### D1 · Define what a thing is and does

Not what it resembles, not what it signifies. An analogy explains a known thing in terms of
another known thing; it cannot introduce an unknown one.

| rejected | why |
|---|---|
| The smallest thing the cluster runs… | *"It's like defining an egg as 'An egg is most female-ish part of reproductory biology…'"* |
| Given a Deployment asking for three copies… | *"So deployments are beggars asking for copies? What is a copy?"* |
| It records what should be true. | True of a log, a schema, a contract, a promise. A sentence true of anything says nothing. |
| It compares what you wrote down against what actually exists, and acts on the difference. | *"Only you understands this (maybe not even you)."* |

The replacement for the last one states the mechanism with this lab's own numbers:

> **controller**: *A program inside the cluster that reads the stored requests and changes
> the cluster until they are met. Take a Deployment that says three pods. The controller
> counts the pods that exist. Two, so it starts one. Four, and it would stop one. Then it
> counts again, and it keeps counting for as long as the request is stored.*

A definition should also answer **why the thing exists**, not only what it is. *"Deployment
misses to answer why, why kubernetes requires you to request a deployment?"*

### D2 · Definitions precede first use, collected, in dependency order

One block, before the steps that need it, ordered so that nothing is defined in terms of a
word that comes later. Scattering definitions into the steps that use them forces the
reader to read the sheet out of order.

The definitions block is also the answer bank for the questions: it is worth saying so in
the block itself, so the reader knows to come back to it.

---

## E · Register

*Settled 2026-09-20.*

### E1 · Impersonal for facts, second person for actions and questions

| impersonal | second person |
|---|---|
| Flag tables | *Write the command, then run it.* |
| Definitions | *Which did you pick, (a) or (b)?* |
| Expected output | *Pick one of the three pods and write its line down.* |
| Panel and slide titles | |

> `scale`: *Edits one field, `replicas`, of an object that already exists. It creates
> nothing.*
>
> not: *`scale` lets you change how many pods you want running.*

### E2 · No ornamental lead-ins

*"Look at the pods the controller made for you"*, *"Now here comes the interesting part"*,
*"Let us see what happens"*. Delete them and start with the instruction.

### E3 · A sentence that would be true of anything says nothing

Delete it. The test is to substitute an unrelated subject: if the sentence survives, it was
not about its subject.

---

## F · Truth

### F1 · Run every command on the real system before it is printed

Quote the output observed, not the output expected. This is the rule that catches the
errors nothing else can, because a plausible command that does not work still looks right
on the page.

Found on 2026-09-20, all by running them:

| claim on the sheet | what actually happened |
|---|---|
| `kubectl logs <pod> --previous` shows the previous run | fails roughly two times in three with `unable to retrieve container logs`; the dead container has already been cleared away |
| `Running` is never caught in the watch | at three seconds, two of three pods read `1/1 Running` |
| read `State: Waiting` for `restarting failed container` | that field is usually `Terminated / Completed`; the reliable place is the `Events` block |
| race `kubectl get pods` to see a pod start | `ContainerCreating` → `CrashLoopBackOff` in four seconds, so the race is unwinnable; `watch kubectl get pods` replaced it |
| deleting a completed Job's pod | verified it is **not** replaced, so the contrast with a Deployment holds |

Timings, versions and counts belong to the same rule. The cluster reaches `Ready` in 8.0 s
on `v1.36.4-k3s1`; a pod is replaced in 2.8 s; the client-server version skew warning
disappears only on a matched pin. None of that is guessable.

### F2 · Render it and read it back

Compile the PDF to an image, or shoot the slide, and look at it. Compilation succeeding is
not evidence that the page is right.

Caught this way on one sheet: a paragraph justified into a single stretched line because an
inline `#raw` was too long; three grey highlight artifacts where a multi-line `#raw` had no
`block: true` and the template styled it as inline; a blank page where a non-breakable
panel would not fit.

### F3 · Re-check every cross-reference after any renumbering

Renumbering compiles cleanly and leaves dangling references. After moving panels 5→4
through 12→11, both `Panel 12` and `panel 5` still pointed at panels that no longer
existed, in a file that built without a warning. `tools/lint-handouts.py` check 1 exists
for this.

---

## G · Shape

### G1 · A core sized for ten minutes, then marked extensions

µLabs stopped being micro and students stopped finishing them. The structure that fixes it:

- **Core**, sized for **10 minutes**, with a stated clock deadline.
- **The checkpoint bar**, the loudest thing on the page. A group that reaches it has solved
  the challenge, and the referee ticks it **there and then**, not at the caucus.
- **Extensions**, sized for **20 minutes**, marked as such and not optional: they are the
  rest of the round.

### G2 · Detours go to an annex

Anything not needed to finish the core. The `docker buildx imagetools inspect` comparison
was genuinely interesting and genuinely in the way; it is now panel 11, referenced from a
grey note in the step that raises the question.

### G3 · Never remove an existing slide without warning

Moving a slide to an appendix is a removal from the flow and needs the same warning. A
removal that was not evident during a working session was only noticed *after* the first
theory block had been delivered.

---

## The house idiom

Six handouts exist and all follow the same shape. It has never been written down, which is
why it is reproduced by copying rather than by rule.

### The banner comment

Every `.typ` opens with a ruled comment block giving: the filename and its one-line
purpose; who holds the pen and why; the rationale for any deliberate oddity; the
`typst compile` invocation; and the ISC font install line.

Every instrument that is **collected from students** additionally carries the PII
paragraph, and it is not optional:

```
// Committed BLANK and it must stay that way: a filled sheet carries a GitHub
// handle and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
```

### The preamble

Pinned template, identical `project.with(...)` block, then the shared helpers.

```typst
#import "@preview/isc-hei-document:0.8.1": *

#show: project.with(
  doc-type: "document", show-cover: false, show-toc: false, fancy-line: true,
  title: "µLab N · Week W / Day D · Driver's handout\nWhat the round is about",
  subtitle: [302 Data infrastructures · week W, day D],
  authors: ("",), date: datetime(year: …, month: …, day: …),
  revision: "1.0", language: "en", logo: auto,
)
```

The version pin is checked across all handouts by `tools/lint-handouts.py`.

### The title is two lines, and which line is which

The first line says **which instrument this is**: the round, where it sits in the
course, and whose copy it is. The second says **what the round is about**. A reader
holding four sheets sorts them by the first line and chooses by the second.

```
µLab 1 · Week 2 / Day 2 · Driver's handout
Counting words in Spark on a larger dataset
```

The newline is literal, inside the `title` string. The template joins the two with
`–` in the running footer, so the second line is not lost on later pages.

Introduced on 2026-09-23. The single-line form it replaced
(`µLab worksheet · The same count, on Simple English Wikipedia`) named neither the
round nor the day, so a sheet on a table said nothing about which round it belonged
to.

### Panels that are steps say so

A core panel carries out a numbered step of the round and is titled
`Step N · What to do`. A panel below the checkpoint bar is not a step and is titled
`N · What it is`, continuing the same numbering. Both forms count as panel `N`, so
`panel 7` resolves whichever kind it is, and `tools/lint-handouts.py` reads both.

The form this replaced repeated itself: `1 · Bring the cluster back · step 1`.

| helper | what it draws |
|---|---|
| `lbl(it)` | small uppercase tracked label in the accent colour |
| `rule(w)` | a bottom-stroked box of width `w`, to write on |
| `panel(title, body)` | a bordered block with an accent top rule and an `lbl` title |
| `panelb(title, body)` | the same, breakable across pages |
| `writing(n)` | `n` ruled writing lines |
| `step(n, title, body)` | a numbered step with a tick box |
| `tick` | an 8pt tick box |

`accent` is `rgb("#dc0069")`, matching `remark/themes/hes-so.css`.

### Panels

Numbered from 1, contiguous, titled `"N · Title"`, in the order they are worked through.
Both numbering rules are checked by the linter, because renumbering silently breaks
cross-references.

### Multi-line code

Pass `block: true` or a `lang:`, otherwise the template styles it as inline `#raw` and
paints a highlight box across the short line. Use `lang: "console"` only where the
highlighter helps; it mis-lexes placeholders such as `<one of the three>`.

### Data, not prose

Where a YAML source exists, the document reads it and the YAML is the source of truth:
`flipped-topics.yml` for the topic briefs, `course.yml` for everything year-bound. Do not
retype the content into the `.typ`.

---

## Checking the work

```bash
python3 tools/lint-decks.py      # deck structure
python3 tools/check-topics.py    # topic menu and briefs against flipped-topics.yml
python3 tools/reyear.py --check  # dates and URLs against course.yml
python3 tools/lint-handouts.py   # handout structure, cross-references, stale PDFs
```

The linters cover the mechanical half. Rules A, B4, C1, D and E are read, not run.
