# frozen_string_literal: true

require "json"

module Respelling
  # Latin American Spanish IPA → American-English orthography table.
  #
  # Data lives in `lib/respelling/data/spanish.json` and is a verbatim snapshot
  # of parrot-lab/data/respelling_es.json at gem-release time. The Python
  # serverless function in parrot-lab is the parity reference.
  module Spanish
    DATA_PATH = File.expand_path("data/spanish.json", __dir__)

    module_function

    def data
      @data ||= JSON.parse(File.read(DATA_PATH))
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

    # Longest IPA key length present in the table. The converter uses this
    # to bound its longest-match-first lookup window.
    def max_key_length
      @max_key_length ||= table.keys.map(&:length).max
    end
  end
end
