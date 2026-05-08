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

  # LLM-backed respelling for ANY phrase. Spells the source phrase using
  # target-orthography conventions so a target-language reader naturally
  # approximates the source pronunciation.
  #
  #   Respelling.via_llm(phrase: "Estoy bien", source: :es, target: :en)
  #   # => "estoy beeayn"
  #
  # Requires OPENROUTER_API_KEY (env or api_key:). Uses google/gemma-4-26b-a4b-it
  # by default — small, fast, follows the few-shot orthography rules well.
  def self.via_llm(phrase:, source: :es, target: :en,
                   model: "google/gemma-4-26b-a4b-it",
                   api_key: ENV["OPENROUTER_API_KEY"],
                   endpoint: "https://openrouter.ai/api/v1/chat/completions",
                   temperature: 0.2)
    require "net/http"
    require "json"
    require "uri"

    raise ArgumentError, "via_llm requires OPENROUTER_API_KEY (env or api_key:)" if api_key.nil? || api_key.empty?
    raise ArgumentError, "via_llm requires a phrase" if phrase.nil? || phrase.to_s.empty?

    names = { es: "Spanish", en: "English", fr: "French", pt: "Portuguese" }
    source_name = names[source.to_sym] || source.to_s
    target_name = names[target.to_sym] || target.to_s

    fewshot = [
      ["Hola",        "ohla"],
      ["mañana",      "manyana"],
      ["buenos días", "bwaynose deeyus"],
      ["gracias",     "grasseeus"],
      ["por favor",   "porfavore"],
      ["adiós",       "ahdyose"],
      ["hasta luego", "asta lwaygo"],
      ["mucho gusto", "moocho goosto"]
    ].map { |a, b| "- \"#{a}\" → \"#{b}\"" }.join("\n")

    prompt = <<~PROMPT
      Respell the #{source_name} phrase using #{target_name} orthography conventions so a native #{target_name} reader, reading naturally with no special instructions, produces an approximation of the source-language pronunciation.

      NO hyphens. NO capitalized syllables. NO transliteration markers. Output should look like a plausible #{target_name} word.

      Examples:
      #{fewshot}

      Respell: "#{phrase}"

      Output ONLY the respelling, nothing else. No quotes, no explanation.
    PROMPT

    uri  = URI(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(
      uri.request_uri,
      "Authorization" => "Bearer #{api_key}",
      "content-type"  => "application/json"
    )
    req.body = JSON.generate(
      model:       model,
      messages:    [{ role: "user", content: prompt }],
      max_tokens:  80,
      temperature: temperature
    )
    res = http.request(req)
    raise "OpenRouter #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    raw  = data.dig("choices", 0, "message", "content").to_s.strip
    raw.sub(/\A["']|["']\z/, "").strip
  end
end
