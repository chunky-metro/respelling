# frozen_string_literal: true

require_relative "../spec_helper"

# Spanish module + table-driven converter tests covering vowels, single
# consonants, clusters, word-final patterns, error handling.
class SpanishTest < Minitest::Test
  def setup
    @converter = Respelling::Converter.new(Respelling::Spanish.for_target("en"))
  end

  def test_table_loaded
    refute_empty Respelling::Spanish.table
    assert Respelling::Spanish.table.size > 200
  end

  def test_stress_marker_metadata
    assert_equal "uppercase", Respelling::Spanish.stress_marker
    assert_equal "-", Respelling::Spanish.syllable_separator
  end

  def test_simple_vowels
    assert_equal "ah", @converter.respell("a")
    assert_equal "ay", @converter.respell("e")
    assert_equal "ee", @converter.respell("i")
    assert_equal "oh", @converter.respell("o")
    assert_equal "oo", @converter.respell("u")
  end

  def test_single_consonants
    # Whole "word" inputs without stress / break markers — exercises the
    # plain transliterate path.
    # IPA convention: words include syllable separators. Without them,
    # the longest-match-first walker can over-match across syllables
    # (e.g. medial 'eɾ' grabs the word-final '-eɾ'→'air' rule).
    assert_equal "kah-sah", @converter.respell("ka.sa")
    assert_equal "PAY-roh", @converter.respell("ˈpe.ɾo")
  end

  def test_cluster_diphthongs
    assert_equal "EYE", @converter.respell("ˈai")
    assert_equal "OY", @converter.respell("ˈoi")
    assert_equal "OW", @converter.respell("ˈau")
  end

  def test_palatal_clusters
    assert_equal "NYAH-nyah", @converter.respell("ˈɲa.ɲa")
    assert_equal "ays-pah-NYOHL", @converter.respell("es.pa.ˈɲol")
  end

  def test_affricate_ch
    assert_equal "CHEE-koh", @converter.respell("ˈtʃi.ko")
  end

  def test_word_final_patterns
    # Word-final -as, -os, -es exist as their own table entries so the
    # longest-match-first path picks them up over single `s`.
    assert_equal "KAH-sahs", @converter.respell("ˈka.sas")
    assert_equal "KOH-mohs", @converter.respell("ˈko.mos")
  end

  def test_jota_x_to_h
    # The /x/ jota maps to American "h" (gente, jefe).
    assert_equal "HAYN-tay", @converter.respell("ˈxen.te")
  end

  def test_unknown_phoneme_passes_through_with_warning
    out = @converter.respell("ˈq")  # /q/ not in Spanish table
    assert_equal "Q", out
    refute_empty @converter.warnings
    assert_match(/unknown phoneme/, @converter.warnings.first)
  end

  def test_warnings_reset_between_calls
    @converter.respell("q")
    refute_empty @converter.warnings
    @converter.respell("ˈka.sa")
    assert_empty @converter.warnings
  end

  def test_multi_word_input_preserves_space
    assert_equal "ah ay", @converter.respell("a e")
  end

  def test_secondary_stress_treated_like_primary
    assert_equal "SAY", @converter.respell("ˌse")
  end

  def test_longest_match_prefers_clusters
    # "bwe" should match the 3-char cluster, not b+w+e.
    assert_equal "BWAY", @converter.respell("ˈbwe")
  end

  def test_th_phoneme_renders_as_d
    # English readers don't naturally produce intervocalic 'th' — render as 'd'.
    # /ði/ → "dee", /naða/ → "NAH-dah".
    assert_equal "NAH-dah", @converter.respell("ˈna.ða")
  end

  def test_final_s_renders_as_double_s
    # English convention: 'boss' not 'bos'. -os/-as/-es/-is/-us all double.
    assert_equal "ah-MEE-gohs", @converter.respell("a.ˈmi.gos")
  end
end
