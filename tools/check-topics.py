#!/usr/bin/env python3
"""Fail if a deck and ``flipped-topics.yml`` have drifted apart.

The 25-26 flipped-class list lived only in a slide and rotted there. The 26-27
list lives in ``week1/day1/handouts/flipped-topics.yml``: the printed worksheets
are generated from it, and the decks quote it. Nothing regenerates a slide, so
this check is what keeps the copies honest.

    python3 tools/check-topics.py        report, exit 1 on any mismatch

Two decks quote the YAML and both are checked.

**The menu**, on day 0: one slide, three dated cards, the ``short:`` label of
every topic. Found by its content rather than its title, and checked for the
labels, their order, and the presentation date on each card.

**The briefs**, on day 1: one slide per topic, walked through before the draw.
Each carries the ``id``, the ``title``, the ``question`` and the ``demo``.
Sixteen separate slides defeat the menu's "most labels wins" heuristic, so they
are found by their heading instead.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
TOPICS = ROOT / "week1/day1/handouts/flipped-topics.yml"
DECK = ROOT / "week1/day0/index.html"        # the menu: one slide, three cards
BRIEFS = ROOT / "week1/day1/index.html"      # the briefs: one slide per topic

MONTHS = ("january february march april may june july "
          "august september october november december").split()


def norm_date(text: str) -> tuple[int, int] | None:
    """'Mon 21 Sept' and 'Monday 21 September' both -> (21, 9)."""
    m = re.search(r"(\d{1,2})\s+([A-Za-z]+)", text)
    if not m:
        return None
    day, month = int(m.group(1)), m.group(2).lower()
    for i, name in enumerate(MONTHS, start=1):
        if name.startswith(month[:3]):
            return day, i
    return None


def card_date(card: str) -> tuple[int, int] | None:
    """The date sits in a .kicker[...] or an h3, whichever the card uses."""
    m = re.search(r"^\.kicker\[(.+?)\]", card, re.M) or re.search(r"^#{2,3} (.+)$", card, re.M)
    return norm_date(m.group(1)) if m else None


# A label line is one of: "* Label", "- Label", "7 Label", "7. Label",
# "**7** Label" -- optionally closed by a <br />. The slide's presentation is
# Oscar's to change; this check is about the words, not the markup.
CARD = re.compile(r"\n\.card(?=[.\[])")
NUMBERED = re.compile(r"^\*{0,2}\d+\*{0,2}\.?\s+(.+)$")
BULLETED = re.compile(r"^[*-]\s+(.+)$")


def card_labels(card: str) -> list[str]:
    out = []
    for line in card.splitlines():
        line = re.sub(r"<br\s*/?>\s*$", "", line.strip())
        m = NUMBERED.match(line) or BULLETED.match(line)
        if m:
            out.append(m.group(1).strip())
    return out


def slide_source() -> str:
    """The topic slide, found by what it contains rather than by its title.

    Titles are the author's to change; a checker that pins one just breaks the
    next time the slide is renamed. The topic slide is simply the slide whose
    cards yield the most topic labels.
    """
    slides = DECK.read_text().split("\n---")
    best = max(slides, key=lambda sl: sum(len(l) for _, l in topic_cards(sl)))
    if not any(l for _, l in topic_cards(best)):
        raise SystemExit(f"no topic slide found in {DECK.relative_to(ROOT)}: "
                         "no slide has dated cards with labels in them")
    return best


def topic_cards(slide: str) -> list[tuple[tuple[int, int], list[str]]]:
    """The dated cards of a slide, in order, as (date, labels).

    A card without a date is not a topic card: the slide may also carry a
    caption card, a callout, anything the author wants beside the three.
    """
    out = []
    for card in CARD.split(slide)[1:]:
        date = card_date(card)
        if date is not None:
            out.append((date, card_labels(card)))
    return out


MARKUP = re.compile(r"\.[a-z0-9-]+(?:\.[a-z0-9-]+)*\[")
TAG = re.compile(r"<[^>]+>")
HEADING = re.compile(r"^# (.+)$", re.M)


def plain(text: str) -> str:
    """The words, with the content-class markup and inline HTML taken off.

    So that a heading written `# .gray-text[6] Kafka: ...` compares equal to
    the YAML's `6` and `title`, and reformatting the slide does not fail this.
    """
    text = MARKUP.sub("", text).replace("]", "")
    return " ".join(TAG.sub(" ", text).split())


def brief_problems(topics: list[dict]) -> list[str]:
    """One slide per topic on day 1, carrying id, title, question and demo."""
    by_heading = {}
    for slide in BRIEFS.read_text().split("\n---"):
        m = HEADING.search(slide)
        if m:
            by_heading[plain(m.group(1))] = plain(slide)

    problems = []
    for t in topics:
        want = plain("%s %s" % (t["id"], t["title"]))
        if want not in by_heading:
            problems.append("topic %s: no slide headed %r" % (t["id"], want))
            continue
        body = by_heading[want]
        for field in ("question", "demo"):
            said = plain(" ".join(t[field].split()))
            if said not in body:
                problems.append("topic %s: the slide does not carry the YAML's %s"
                                % (t["id"], field))
    return problems


def main() -> int:
    data = yaml.safe_load(TOPICS.read_text())
    slots = {s["id"]: s for s in data["slots"]}

    expected = []  # [(slot, date, [labels...])]
    for slot_id in sorted(slots):
        labels = [t["short"] for t in data["topics"] if t["slot"] == slot_id]
        expected.append((slot_id, norm_date(slots[slot_id]["presents"]), labels))

    found = topic_cards(slide_source())

    problems = []
    if len(found) != len(expected):
        problems.append(f"slide has {len(found)} dated cards, the YAML has {len(expected)} slots")
    for (slot_id, date, labels), (got_date, got_labels) in zip(expected, found):
        if date != got_date:
            problems.append(f"slot {slot_id}: card says {got_date}, YAML says {date}")
        if labels != got_labels:
            for missing in [x for x in labels if x not in got_labels]:
                problems.append(f"slot {slot_id}: YAML has {missing!r}, the slide does not")
            for extra in [x for x in got_labels if x not in labels]:
                problems.append(f"slot {slot_id}: slide has {extra!r}, the YAML does not")
            if sorted(labels) == sorted(got_labels):
                problems.append(f"slot {slot_id}: same labels, different order")

    total = sum(len(l) for _, _, l in expected)
    briefs = brief_problems(data["topics"])

    if problems or briefs:
        for deck, found_problems in ((DECK, problems), (BRIEFS, briefs)):
            if not found_problems:
                continue
            print(f"{deck.relative_to(ROOT)} has drifted from "
                  f"{TOPICS.relative_to(ROOT)}:", file=sys.stderr)
            for p in found_problems:
                print(f"  {p}", file=sys.stderr)
        return 1
    print(f"ok: {total} topics, {len(expected)} slots; "
          f"the menu and all {total} briefs match the YAML")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
