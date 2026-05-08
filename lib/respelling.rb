# frozen_string_literal: true

require_relative "respelling/version"
require_relative "respelling/converter"
require_relative "respelling/spanish"

# Respelling — IPA to American-English-orthography phonetic respelling.
#
# Hear what you actually sounded like. The gem ships with a Latin American
# Spanish table; new languages are added by writing a module that exposes
# `#table`, `#stress_marker`, and `#syllable_separator`.
module Respelling
  # Convenience constructor: returns a Converter wired to the Spanish table.
  def self.spanish
    Converter.new(Spanish)
  end

  # Look up a language module by short code. Raises ArgumentError for
  # unknown codes so the CLI can report a clean error.
  def self.for(lang_code)
    case lang_code.to_s
    when "es", "spanish" then spanish
    else raise ArgumentError, "unknown language: #{lang_code.inspect}"
    end
  end
end
