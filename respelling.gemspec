# frozen_string_literal: true

require_relative "lib/respelling/version"

Gem::Specification.new do |spec|
  spec.name = "respelling"
  spec.version = Respelling::VERSION
  spec.authors = ["Matt Culpepper", "Vox"]
  spec.email = ["matt@culpepper.co"]

  spec.summary = "IPA → American-English orthography respelling. Hear what you actually sounded like."
  spec.description = <<~DESC
    Native-tongue phonetic respelling for pronunciation feedback. Maps IPA phonemes
    to American-English-orthography hints (e.g. /ˈbwe.nos ˈði.as/ → BWEH-nohs THEE-ahs)
    so an English speaker can read the result aloud and approximate the source language.
    Latin American Spanish ships in v1; the lookup engine is language-agnostic.
  DESC
  spec.homepage = "https://github.com/chunky-metro/respelling"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "respelling.gemspec"]
  end
  spec.bindir = "bin"
  spec.executables = ["respell"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "rake", "~> 13.0"
end
