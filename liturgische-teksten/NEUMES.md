# From Byzantine neumes to pitch marks

How the pitch marks on the Ode 8 and Ode 9 irmoi in `kanon-ro-markings.typ`
were derived from a psaltic (Byzantine neume) score. Use it to check that
work, or to mark another hymn the same way.

**Source:** the Small Paraclis as sung at Stavropoleos Monastery,
Bucharest, pp. 17–19 of
<https://www.stavropoleos.ro/wp-content/uploads/Psaltica/Rugaciuni/paraclis_primul.pdf>
(see `SOURCES.md`). In this score only the irmoi of Odes 8 and 9 are
notated in full. The other odes give just the first words of the irmos,
because there only the troparia are sung.

## The idea

Byzantine notation (the Chrysanthine system used in Romanian and Greek
books) records **steps, not pitches**. Each neume says "same note", "one
step up", "two steps down", and so on, relative to the previous note. That
is what this repo's pitch marks say too, so the conversion is mostly one
neume per syllable, read straight across:

| Neume | Looks like (in this score) | Step | Mark |
|---|---|---|---|
| ison | short bar with a hook at its left end | 0 | *(none)* |
| oligon | plain straight bar | +1 | `rise` |
| petasti | cup (◡) with a curl | +1 | `rise` |
| kentimata | two short ticks (ıı) | +1 | `rise` |
| kentima | one short tick, on or next to an oligon | +2 | `risetwo` |
| apostrophos | small curve, like ")" | −1 | `fall` |
| elaphron | arch (◠) with a hook at its left end | −2 | `falltwo` |
| elaphron + apostrophos | the arch with a curl inside it | −3 | `fallthree` |

- **Ison gets no mark.** That follows `makrina.typ` and the other meneon/
  files, where an unmarked syllable stays on the same note.
- **The number of strokes is the number of steps,** stacked
  (`risetwo`, `falltwo`, `fallthree`). Three is the most `pitch-marks.typ`
  draws. Chamili (−4) would need more, but it doesn't occur in these two
  irmoi.

## Combined neumes

A neume written above, below or beside an oligon changes what the oligon
means:

- **Kentima on an oligon** (a tick on top, or just to its right): the
  oligon itself is silent and the kentima gives the step, +2 in total,
  marked `risetwo`. Examples: *și* (Ode 8) and *Dum* (Ode 9).
- **Kentimata below or above an oligon:** two notes on one syllable, each
  a step up, marked `risetwice` (two strokes side by side). Examples: *-a*
  in "Împăra-a-atul", and *zeu* and *veș* (Ode 9).
- **An oligon with a stroke underneath** (a flat hook, the antikenoma, or
  a long swoosh) is still just +1, marked `rise`. These under-strokes say
  how to sing the note, not where it goes. At first I read the swoosh as a
  second, falling note, and the martyria check (below) showed that was
  wrong.

## Signs that don't become marks

- **Klasma, apli, dipli:** a small arc (˘) or dots below or above a neume.
  They lengthen the note, so the syllable gets `hold`, the red underline.
  The step is still that of the neume they're attached to.
- **Vareia, psifiston:** small strokes that give a note emphasis. Ignored.
- **Phthorae:** red signs inside the line (for example ⚦ under *ves* and
  *nic* in Ode 9). They change the scale's intervals from that point on,
  but not which way the melody goes, so they're ignored.
- **Martyriae:** the red signs after a phrase, made of a letter and a sign
  below it. They're checkpoints, described next.

## Checking the reading against the martyriae

A martyria names the note the melody has reached, so it lets you check
your reading. Number the scale degrees by their Byzantine names:

| Ni | Pa | Vou | Ga | Di | Ke | Zo | Ni′ | Pa′ |
|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |

Start from the martyria at the heading (Ga: a Γ over its sign) and add up
the steps syllable by syllable. At each red martyria the total must equal
that note. In this score:

- **Γ** over its sign is Ga, **Δ** is Di, **ν** is Ni.
- **χ** over a λ-like sign is Ke. I couldn't recognize this letter on its
  own; I identified it because the first phrases of both irmoi add up to
  Ke there.
- Notes a fourth apart share the same lower sign. For example Ni and Ga
  share theirs, which is how the ν martyria (Ni) was confirmed.

Results:

| Irmos | Phrase | From → to | Adds up? |
|---|---|---|---|
| Ode 8 | "Pe Împăra-a-atul" | Ga → Ke | yes |
| Ode 8 | "Ceresc … îngereștile cete, cântați-L" | Ke → Ni | yes |
| Ode 8 | "și preaînălțați-L, noroade, totdeauna" | Ni → Ga | **no**, one step short |
| Ode 9 | "Mântuiți prin ti-i-ne" | Ga → Ke | yes |
| Ode 9 | "fiind, Fecioară … toți" | Ke → Ga | yes |
| Ode 9 | "de Dumnezeu … mărindu-te" | Ga → Ga | yes |

The one gap is in the last phrase of the Ode 8 irmos. Two neumes there
aren't in the table above:
- on *ța*, a petasti with a small stroke beneath it;
- on *roa*, an oligon over a petasti.

Marked as one rise and two rises, the phrase ends one step below its
martyria, so one of them rises one step more than marked. A chanter who
knows these combinations can settle it. Every other syllable has been
checked this way.

## Start and end notes

Like `meneon/7/makrina.typ`, each irmos begins and ends with an em dash
(`---`). The mark over the dash gives the first or last note relative to
DO, counted in a major scale on DO: no mark is DO, one rising stroke is
RE, one falling stroke is SI below, and so on.

So DO is the base note of the melody's major scale. These irmoi are in
the "triphonic" form of plagal glas IV: the melody is built on Ga, and
from Ga upwards the scale is major (Ga, Di, Ke, Zo flat, Ni′ …). Ga is
therefore DO. Note that this is not Byzantine Ni, which is the usual
Ni = Do of Byzantine solfège; that would only apply to a melody built on
Ni.

The score gives both notes:

- **First note:** the martyria next to the ode heading.
- **Last note:** the martyria after the final syllable.

For both irmoi these are Ga, i.e. DO, so all four dashes carry no mark.
For a melody that starts or ends elsewhere, count its scale degrees from
the base note: e.g. starting on Di in a melody built on Ga gives
`risetwo`, starting on Vou gives `fall`.

## What the marks leave out

- **Step size.** A step is one scale degree, not a fixed interval. How big
  it sounds depends on the mode, and on the phthorae.
- **Rhythm and ornament,** except holds. The score has much more of this,
  e.g. gorgon (quicken), antikenoma and vareia.
- **Absolute pitch.** The marks say up or down, never which note.

## The words follow the score

The marks belong to the syllables Stavropoleos sings, which differ from
the Râmnic text used in the rest of `kanon-ro.typ`:

- **Ode 8:** "Pe Împăratul ceresc, pe Care Îl laudă îngereștile cete,
  cântați-L și preaînălțați-L, noroade, totdeauna" (Râmnic: "…oștile
  îngerești, lăudați-L și-L preaînălțați întru toți vecii").
- **Ode 9:** "Mântuiți prin tine fiind, Fecioară, pe tine vestimu-te toți
  de Dumnezeu Născătoare, veșnic mărindu-te" (Râmnic: "Cu adevărat,
  Născătoare de Dumnezeu, te mărturisim pe tine Fecioară curată, noi cei
  izbăviți prin tine, slăvindu-te cu cetele fără de trup").

Where the score stretches a vowel over extra notes, the text spells it the
way the score does, and the extra vowel carries its own mark:
"Împăra-a-atul", "ce-e-te", "ti-i-ne", "vesti-i-mu-te".

## Marking another hymn

1. Find a score with every syllable notated, and the text it uses.
2. Write each syllable's neume and step next to it, as in the comments
   above the two irmoi in `kanon-ro-markings.typ`.
3. Add up the steps and check them at every martyria. Recheck any phrase
   that doesn't come out.
4. Turn steps into marks with the tables above. Add `hold` for klasma,
   apli or dipli.
5. Typeset the result and look at it:
   - stacked marks may need a little more `clearance:` (around 0.25em for
     two strokes and 0.4em for three, at 12pt);
   - wrap a word in `#box[…]` if a line break splits it.
