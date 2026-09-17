# 302 · Data pipelines · 2026-2027

Slide decks for the **data pipelines** block of HES-SO Valais-Wallis module
*302 Data Computation*: six sessions over three weeks, taught by Oscar Esteban.
Published from this repository at
<https://oesteban.github.io/isc-302-2026-2027-slides/>.

Built on [remark.js](https://remarkjs.com/) through the shared
[remark-engine](https://github.com/oesteban/remark-engine) submodule. Every
deck is a single self-contained HTML file with its Markdown source inside a
`<textarea>`, so it is readable and diffable as text.

---

## 🚨 Never commit a real class roster

**This repository is public, and the roster is served with the decks.**
`roulette.js` fetches a roster file at run time to pick names, so whatever is
committed is published to the open web.

| file | contains | in git |
|---|---|---|
| `roster.yml` | synthetic placeholder names | **tracked**, published |
| `roster.local.yml` | the real class list | **never**, ignored at any depth |

Real names go in `roster.local.yml`, which `.gitignore` refuses to stage:

```console
$ git add roster.local.yml
The following paths are ignored by one of your .gitignore files:
roster.local.yml
hint: Use -f if you really want to add them.
```

`git add -A` and `git add .` skip it silently, and it never shows in
`git status`. Create it with:

```bash
tools/roster-local.sh      # copies the placeholder, links it into each deck
$EDITOR roster.local.yml   # put the real names in
```

**`git add -f` defeats this, and nothing local can stop it.** That is the one
deliberate act to never perform on this file. If it happens, the names are
public the moment the commit is pushed, and rewriting history does not recall
them: treat it as a disclosure, not a mistake to quietly fix.

The same rule covers every other classroom artefact. Filled referee grids and
graded worksheets carry student names and stay out of git entirely; the
handouts here are committed **blank**.

---

## The decks

In delivery order. Dates and titles come from
[`course.yml`](course.yml), which is the single source of truth for everything
year-bound; `tools/reyear.py` propagates it into the decks.

| Session | Date | Directory |
|---|---|---|
| [Data computing — module overview](https://oesteban.github.io/isc-302-2026-2027-slides/week1/day0/index.html) | Mon 14 Sep 2026 | `week1/day0/` |
| [Introduction to data pipelines](https://oesteban.github.io/isc-302-2026-2027-slides/week1/day1/index.html) | Mon 14 Sep 2026 | `week1/day1/` |
| [DevOps and Docker](https://oesteban.github.io/isc-302-2026-2027-slides/week1/day2/index.html) | Fri 18 Sep 2026 | `week1/day2/` |
| [Container orchestration at scale: Kubernetes and Slurm](https://oesteban.github.io/isc-302-2026-2027-slides/week2/day2/index.html) | Mon 21 Sep 2026 | `week2/day2/` |
| [Specifying pipelines with Flyte](https://oesteban.github.io/isc-302-2026-2027-slides/week2/day1/index.html) | Thu 24 Sep 2026 | `week2/day1/` |
| [MapReduce and Apache Spark](https://oesteban.github.io/isc-302-2026-2027-slides/week3/day1/index.html) | Mon 28 Sep 2026 | `week3/day1/` |
| [Wrap-up and section test](https://oesteban.github.io/isc-302-2026-2027-slides/week3/day2/index.html) | Thu 01 Oct 2026 | `week3/day2/` |

Navigation: arrow keys, `P` for presenter view, `C` to clone the window onto a
second screen, `?` for the full list.

## Checking a deck

```bash
python3 tools/lint-decks.py     # all seven, or pass one: week1/day0
python3 tools/check-topics.py   # the flipped-class topic slide against its YAML
python3 tools/reyear.py --check # dates and URLs against course.yml
```

`lint-decks.py` catches the mistakes that leave a deck looking correct on
screen and wrong somewhere else: a slide separator with a trailing space, which
silently merges two slides; an unbalanced content-class bracket, which swallows
the rest of a slide; a `class:` line that is not opening a slide, so it does
nothing; and a referenced file that is missing, or present but uncommitted and
therefore a 404 once published.

## Running locally

```bash
git clone https://github.com/oesteban/isc-302-2026-2027-slides.git
cd isc-302-2026-2027-slides
git submodule update --init remark      # the slide engine, public
python3 -m http.server 8000
```

Then open <http://localhost:8000/week1/day0/index.html>.

Serve over HTTP rather than opening the files directly: over `file://` the
browser blocks the `fetch` calls that load the roster and the inline SVGs, so
the roulette comes up empty and some figures do not render.

**Do not clone with `--recursive`.** Three submodules are private lab
repositories and the clone will fail on them. They hold the lab code, not the
slides: no deck loads anything from them, which is why the Pages build
initialises only `remark`.

| submodule | visibility | needed for the slides |
|---|---|---|
| `remark` | public | **yes**, the engine |
| `week1/day2/302-whalesay` | public | no |
| `week1/day1/neuro-lab` | private | no |
| `week2/day1/flyte-newsgroup` | private | no |
| `week2/day1/flyte-neuro` | private | no |

## Printed handouts

Two instruments are typeset with [Typst](https://typst.app/) against the ISC
template [`isc-hei-document`](https://github.com/ISC-HEI/isc-hei-typst-templates),
and the built PDFs are committed so that printing needs no toolchain:

| source | output |
|---|---|
| `week1/day0/handouts/referee-grid.typ` | 1 page, the mini-lab referee's grid |
| `week1/day1/handouts/docker-primer-worksheet.typ` | 2 pages, the pair's sheet for the first µLab |
| `week1/day1/handouts/flipped-worksheets.typ` | 16 pages, one brief per flipped-class topic |

Rebuild with `typst compile <file>.typ`. The topics are data, not prose: they
live in `week1/day1/handouts/flipped-topics.yml` and the document reads them,
so the worksheets and the deck cannot drift apart. The template renders a
"fonts not installed" page rather than failing, so check the output has the
page count above before printing.

## Publishing

Pushing to `main` runs [`.github/workflows/pages.yml`](.github/workflows/pages.yml),
which checks out the engine submodule, uploads the tree and deploys to Pages.
GitHub's automatic branch-based build cannot be used here: it always checks out
submodules recursively with a token scoped to this repository alone, so it fails
on the private lab repositories before it ever builds.

## License

Slide content is [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
The engine submodule is MIT.
