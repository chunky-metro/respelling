# frozen_string_literal: true

module Respelling
  # Converts an IPA string into a respelled American-English-orthography form.
  #
  # The IPA input may include the primary-stress marker ˈ, the secondary-stress
  # marker ˌ (treated like primary for v1), and the syllable-break marker `.`.
  # Stress is rendered by uppercasing the entire stressed syllable; syllable
  # boundaries become the language's `syllable_separator`.
  class Converter
    PRIMARY_STRESS = "ˈ"
    SECONDARY_STRESS = "ˌ"
    SYLLABLE_BREAK = "."
    SPACE = " "

    attr_reader :language, :warnings

    def initialize(language)
      @language = language
      @warnings = []
    end

    # Respell an IPA sequence. Returns a String. Unknown phonemes pass through
    # unchanged and append a warning to `#warnings`. Combining diacritics
    # (e.g. the lowered-vowel mark in `o̞`) are stripped before lookup so the
    # base phoneme can match the table.
    def respell(ipa)
      @warnings = []
      strip_combining(ipa).split(SPACE).map { |word| respell_word(word) }.join(SPACE)
    end

    def strip_combining(str)
      str.unicode_normalize(:nfd).gsub(/\p{M}/, "")
    end

    private

    def respell_word(word)
      syllables = split_syllables(word)
      syllables.map { |s| render_syllable(s) }.join(language.syllable_separator)
    end

    # Returns an array of [stress_flag, body] pairs split on `.` boundaries.
    # Stress flags propagate to whichever syllable the marker preceded.
    def split_syllables(word)
      tokens = tokenize_stress(word)
      group_into_syllables(tokens)
    end

    def tokenize_stress(word)
      word.chars.map { |ch| [token_kind(ch), ch] }
    end

    def token_kind(ch)
      return :stress if [PRIMARY_STRESS, SECONDARY_STRESS].include?(ch)
      return :break  if ch == SYLLABLE_BREAK

      :char
    end

    def group_into_syllables(tokens)
      syllables = [{ stressed: false, body: +"" }]
      tokens.each { |kind, ch| consume_token(syllables, kind, ch) }
      syllables.reject { |s| s[:body].empty? }
    end

    def consume_token(syllables, kind, ch)
      case kind
      when :stress then start_syllable(syllables, stressed: true)
      when :break  then start_syllable(syllables, stressed: false)
      when :char   then syllables.last[:body] << ch
      end
    end

    def start_syllable(syllables, stressed:)
      if syllables.last[:body].empty?
        syllables.last[:stressed] ||= stressed
      else
        syllables << { stressed: stressed, body: +"" }
      end
    end

    def render_syllable(syllable)
      respelled = transliterate(syllable[:body])
      syllable[:stressed] ? respelled.upcase : respelled
    end

    # Longest-match-first walk over the IPA characters, looking up each
    # window in the language table. Unknown chars pass through and warn.
    def transliterate(body)
      walk_matches(body).join
    end

    def walk_matches(body)
      parts = []
      i = 0
      i += step_match(body, i, parts) while i < body.length
      parts
    end

    def step_match(body, i, parts)
      len, value = longest_match(body, i)
      parts << value
      len
    end

    def longest_match(body, start)
      max = [language.max_key_length, body.length - start].min
      max.downto(1) do |len|
        slice = body[start, len]
        return [len, language.table[slice]] if language.table.key?(slice)
      end
      record_unknown(body[start])
      [1, body[start]]
    end

    def record_unknown(char)
      @warnings << "unknown phoneme: #{char.inspect}"
    end
  end
end
