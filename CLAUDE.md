# respelling

Ruby gem for native-tongue phonetic respelling — IPA → American-English orthography. Maps `/ˈbwe.nos ˈði.as/` → `BWEH-nohs THEE-ahs` so an English speaker can read the result aloud and approximate the source language. Latin American Spanish ships in v1; the lookup engine is language-agnostic. Extracted from parrot-lab.

## Stack
- Ruby >= 3.0
- Minitest (`~> 5.20`), Rake (`~> 13.0`), ruby-lsp
- CLI binary: `bin/respell`

## Commands
- install: `bundle install`
- test: `bundle exec rake test`
- run: `bin/respell "ˈbwe.nos ˈði.as"`

## Conventions
- Sandi Metz (classes ≤100 LOC, methods ≤5 LOC, ≤4 params)
- Mappings live in `lib/respelling/spanish.rb`-shaped data files
- Cross-language parity with `respelling-js` is a goal — keep the API surface symmetric

## Linked context
- Linear: https://linear.app/fleetvoxes/project/respelling-3766854af487
- GitHub: https://github.com/chunky-metro/respelling
- Sister repo (JS port): https://github.com/chunky-metro/respelling-js

## Active branches / WIP
- main: `13d4709 v0.3.2: absorb 4 guiding principles + asta lawaygo / grassious`
- Cross-language parity test (gem vs python serverless) deferred per MEMORY.md
