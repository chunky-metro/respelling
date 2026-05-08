# frozen_string_literal: true

require "json"

module Respelling
  # Latin American Spanish source language. v2 schema: each language can
  # publish multiple target-orthography tables. Default target is "en"
  # (American English orthography per Matt's "spelled in English" brief).
  #
  # Data lives in `lib/respelling/data/spanish-{target}.json`. To add a new
  # target orthography (es→pt, es→fr, es→ko, ...) drop a new file alongside.
  module Spanish
    DEFAULT_TARGET = "en"
    DATA_DIR = File.expand_path("data", __dir__)

    module_function

    def for_target(target = DEFAULT_TARGET)
      Target.new(target)
    end

    # Backwards-compatible default — Spanish.table, Spanish.stress_marker, etc.
    # delegate to the default English-target table so existing callers keep
    # working.
    def data
      for_target(DEFAULT_TARGET).data
    end

    def table
      for_target(DEFAULT_TARGET).table
    end

    def stress_marker
      for_target(DEFAULT_TARGET).stress_marker
    end

    def syllable_separator
      for_target(DEFAULT_TARGET).syllable_separator
    end

    def max_key_length
      for_target(DEFAULT_TARGET).max_key_length
    end

    # A loaded source→target pairing. Implements the Language interface
    # the Converter expects: #table, #stress_marker, #syllable_separator,
    # #max_key_length.
    class Target
      attr_reader :target

      def initialize(target)
        @target = target.to_s
        @path = File.join(DATA_DIR, "spanish-#{@target}.json")
        raise ArgumentError, "no Spanish→#{@target} table at #{@path}" unless File.exist?(@path)
      end

      def data
        @data ||= JSON.parse(File.read(@path))
      end

      def table
        @table ||= data.fetch("entries").to_h { |e| [e.fetch("ipa"), e.fetch("respelling")] }
      end

      def stress_marker
        data.fetch("stress_marker", "uppercase")
      end

      def syllable_separator
        data.fetch("syllable_separator", "-")
      end

      def max_key_length
        @max_key_length ||= table.keys.map(&:length).max
      end
    end
  end
end
