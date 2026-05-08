# respelling

> Phonetic respelling that spells foreign words like English words.

`respelling` writes Spanish phrases the way an English reader would naturally pronounce them — no hyphens marking syllable boundaries, no uppercase marking stress. The respelling looks like an English word; the reader pronounces it; what comes out approximates the Spanish.

## What's novel (v0.3)

The dictionary-style transliteration `mah-NYAH-nah` has existed forever — every Merriam-Webster entry has one. **That's not what this is.** This library writes `manyana`. English orthography does the work.

| Spanish     | Dictionary style       | This library (v0.3) |
| :---------- | :--------------------- | :------------------ |
| Buenos días | `BWAY-nohs DEE-ahs`    | `bwaynose deeyus`   |
| Mañana      | `mah-NYAH-nah`         | `manyana`           |
| Gracias     | `GRAH-syahs`           | `grasseeus`         |
| Por favor   | `por fah-VOHR`         | `porfavore`         |
| Hola        | `OH-lah`               | `ohla`              |

## Install

Once published:

```ruby
gem install respelling
```

For now, install from GitHub:

```ruby
# Gemfile
gem "respelling", github: "chunky-metro/respelling"
```

## Usage

```ruby
require "respelling"

converter = Respelling.spanish
converter.respell("ˈbwe.nos ˈði.as")
# => "BWEH-nohs THEE-ahs"

converter.respell("ˈka.fe")
# => "KAH-feh"

converter.respell("fa.bɾi.ˈka.do")
# => "fah-bree-KAH-doh"
```

Combining diacritics (e.g. the lowered-vowel mark in `o̞`) are stripped before lookup so real-world IPA copy-pastes still match the table.

Unknown phonemes pass through unchanged and are recorded on `converter.warnings`:

```ruby
converter.respell("z")  # /z/ not in LatAm Spanish
# => "z"
converter.warnings
# => ["unknown phoneme: \"z\""]
```

### CLI

```
$ bin/respell --lang es "ˈbwe.nos ˈði.as"
BWEH-nohs THEE-ahs
```

## Adding a new language

A "language" is any Ruby module that exposes:

- `#table` — `Hash[String -> String]` mapping IPA keys to respelling strings
- `#stress_marker` — currently informational; v1 always renders stress as uppercase
- `#syllable_separator` — string inserted between syllables in output
- `#max_key_length` — longest IPA key in the table (for the longest-match-first walk)

The simplest pattern is to mirror `lib/respelling/spanish.rb` and ship a JSON table under `lib/respelling/data/`. Then wire it up in `Respelling.for`:

```ruby
def self.for(lang_code)
  case lang_code.to_s
  when "es", "spanish"  then spanish
  when "fr", "french"   then french
  else raise ArgumentError, "unknown language: #{lang_code.inspect}"
  end
end
```

## Cross-language parity

This gem is the **canonical** implementation. A Python port lives in [`parrot-lab/serverless`](https://github.com/chunky-metro/parrot-lab) — the data table at `parrot-lab/data/respelling_es.json` is the single source of truth and is snapshotted into this gem at release time.

A future parity test will run both implementations against the same fixtures and assert identical output. Until then, treat divergence as a bug to be reported against this repo.

## Two layers (v0.3)

**Hand-curated corpus** (`lib/respelling/data/spanish-en-corpus.json`) — 50 phrases respelled with the novel English-word-shape style. This is the v1 craft layer that the parrot-lab demo serves.

**Algorithmic IPA fallback** (`lib/respelling/data/spanish-en.json`) — IPA→respelling table for arbitrary inputs not in the corpus. Currently emits the dictionary style (`BWAY-nohs DEE-ahs`); v0.4 will retrain it to emit corpus style by default.

## IPA → table caveats

The IPA table currently reflects the dictionary style; the corpus has the novel style. The two layers will be reconciled in v0.4.

## Attribution

Derived from the [parrot-lab](https://github.com/chunky-metro/parrot-lab) project. Data tables and code are MIT-licensed (see `LICENSE`).
