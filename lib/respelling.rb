# frozen_string_literal: true

require_relative "respelling/version"
require_relative "respelling/converter"
require_relative "respelling/spanish"

# Respelling — IPA to target-language orthography phonetic respelling.
#
# Hear what you actually sounded like. v0.2 generalizes to source→target
# language pairs: Spanish-IPA → American-English orthography is the v1
# pair, Korean→English / French→English / English→Spanish all slot in
# under the same shape (drop a new table file alongside, register a
# source-language module).
#
# Convention: a source-language module exposes `.for_target(target_code)`
# returning a Language object the Converter can consume.
module Respelling
  # Convenience constructor for the default Spanish→English pairing.
  def self.spanish(target: "en")
    Converter.new(Spanish.for_target(target))
  end

  # Generic constructor: `Respelling.pair(source: 'es', target: 'en')`.
  # Currently only Spanish source is registered; new source languages
  # plug in by adding a module under Respelling:: with a `.for_target`
  # class method and a case branch here.
  def self.pair(source:, target: "en")
    case source.to_s
    when "es", "spanish" then Converter.new(Spanish.for_target(target))
    else raise ArgumentError, "unknown source language: #{source.inspect}"
    end
  end

  # Backwards-compatible: returns the default Spanish→English converter.
  def self.for(lang_code)
    case lang_code.to_s
    when "es", "spanish" then spanish
    else raise ArgumentError, "unknown language: #{lang_code.inspect}"
    end
  end
end
