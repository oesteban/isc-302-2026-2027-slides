# 302 slides and handouts, 2026-2027

Seven remark decks and six Typst instruments for the data-pipelines block of HES-SO module
302. Published from this repository to GitHub Pages.

> **Governance lives one level up.** `course-302/CLAUDE.md` loads with this file and owns
> the push policy (ask before every push), commit etiquette (conventional commits, no
> Claude attribution, body at most two lines) and the PII doctrine. None of it is repeated
> here.

---

## Before writing anything

**Read [`AUTHORING.md`](AUTHORING.md).** It is the numbered rule catalogue for slides and
printed instruments, with the case that produced each rule. Cite rules by id in review.

The short form, for a draft in progress:

- **A1/A2** A title names its content and carries a verb. No slogans, no riddles, no
  `… , and the reason`.
- **B1** State the aim of a step before the command that performs it.
- **B2** **Every argument of every command line is explained**, in a flag table. Flags,
  positional arguments, `--`, `&&`, pipes, everything.
- **B3** Every command says where it runs: which machine, which shell, which container.
- **B4** Before an exercise, give the **need** and the reason, never the outcome. Not the
  finding, not in the title. Suspense only inside a panel marked **Extra mile**.
- **C1** Every question names the command, panel or output that answers it. No path, no
  question.
- **C2/C3** Never ask about an undefined term, and define every word the reader will see
  **on screen**, not only the ones written on the page.
- **C4** The instruction to record data sits where the data is produced.
- **D1** Define what a thing is and does. No metaphor, no simile.
- **E1** Impersonal for facts (flag tables, definitions, expected output, titles); second
  person only for actions and questions.
- **F1** **Run every command on the real system before printing it**, and quote the output
  observed, not the output expected.
- **F2** Render the PDF or slide to an image and read it back. Compiling is not evidence.
- **G1** µLab core sized for ten minutes, checkpoint bar, then marked extensions.
- **G3** **Never remove or move an existing slide without warning the user first.**

## Before committing

```bash
python3 tools/lint-decks.py      # deck structure
python3 tools/check-topics.py    # topic menu and briefs against flipped-topics.yml
python3 tools/reyear.py --check  # dates and URLs against course.yml
python3 tools/lint-handouts.py   # handout structure, cross-references, stale PDFs
```

All four must pass. They cover the mechanical half only; rules A, B4, C1, D and E are read,
not run.

Handout PDFs are **committed built**, so that printing needs no toolchain. Recompile with
`typst compile <file>.typ` and stage the PDF with the source.

## Sources of truth

| what | where |
|---|---|
| Anything year-bound | `course.yml`, propagated by `tools/reyear.py`. Never hand-edit a date, seed, countdown or deck URL. |
| Flipped-class topics | `week1/day1/handouts/flipped-topics.yml`, read by the deck and the briefs. |
| Real class roster | `roster.local.yml`, git-ignored. `roster.yml` is a synthetic placeholder and is published. |

Cohort strategy, per-session redesign notes and anything about individual students stay in
the **private** wrapper repository, in `../planning/` and `../../intel/`. This repository
is public; nothing here may assume otherwise.
