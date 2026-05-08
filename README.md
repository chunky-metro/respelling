# respelling

> Hear what you actually sounded like.

`respelling` maps IPA phonemes to American-English-orthography hints so an English speaker can read the result aloud and approximate the source language. Latin American Spanish ships in v1; the lookup engine is language-agnostic.

```
ˈbwe.nos ˈði.as  →  BWEH-nohs THEE-ahs
```

Stressed syllables are uppercased; syllable boundaries become `-`.

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

## IPA → table caveats

The table reflects how the table maps IPA, not how a dictionary might idealize the result. Two examples:

- `bwe` → `bweh` (not `bway`). The vowel `/e/` in Spanish is closer to "bed" than "bay"; the table preserves that distinction.
- `ð` → `th`. Spanish intervocalic `/d/` becomes the voiced dental fricative `[ð]`, and English speakers approximate it as `th` (as in "this") more cleanly than `d`.

If your use case wants the dictionary-style hint instead, ship a sibling table or filter the output post-respell.

## Attribution

Derived from the [parrot-lab](https://github.com/chunky-metro/parrot-lab) project. Data tables and code are MIT-licensed (see `LICENSE`).
