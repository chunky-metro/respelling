# frozen_string_literal: true

require_relative "../spec_helper"

# Spanish module + table-driven converter tests covering vowels, single
# consonants, clusters, word-final patterns, error handling.
class SpanishTest < Minitest::Test
  def setup
    @converter = Respelling::Converter.new(Respelling::Spanish)
  end

  def test_table_loaded
    assert_equal 220, Respelling::Spanish.table.size
  end

  def test_stress_marker_metadata
    assert_equal "uppercase", Respelling::Spanish.stress_marker
    assert_equal "-", Respelling::Spanish.syllable_separator
  end

  def test_simple_vowels
    assert_equal "ah", @converter.respell("a")
    assert_equal "eh", @converter.respell("e")
    assert_equal "ee", @converter.respell("i")
    assert_equal "oh", @converter.respell("o")
    assert_equal "oo", @converter.respell("u")
  end

  def test_single_consonants
    # Whole "word" inputs without stress / break markers — exercises the
    # plain transliterate path.
    assert_equal "kahsah", @converter.respell("kasa")
    assert_equal "pehroh", @converter.respell("peɾo")
  end

  def test_cluster_diphthongs
    assert_equal "EYE", @converter.respell("ˈai")
    assert_equal "OY", @converter.respell("ˈoi")
    assert_equal "OW", @converter.respell("ˈau")
  end

  def test_palatal_clusters
    assert_equal "NYAH-nyah", @converter.respell("ˈɲa.ɲa")
    assert_equal "ehs-pah-NYOHL", @converter.respell("es.pa.ˈɲol")
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
    assert_equal "HEHN-teh", @converter.respell("ˈxen.te")
  end

  def test_unknown_phoneme_passes_through_with_warning
    out = @converter.respell("ˈz")  # /z/ not in LatAm Spanish table
    assert_equal "Z", out  # base char passes through, then upcased by stress
    refute_empty @converter.warnings
    assert_match(/unknown phoneme/, @converter.warnings.first)
  end

  def test_warnings_reset_between_calls
    @converter.respell("z")
    refute_empty @converter.warnings
    @converter.respell("ˈka.sa")
    assert_empty @converter.warnings
  end

  def test_multi_word_input_preserves_space
    assert_equal "ah eh", @converter.respell("a e")
  end

  def test_secondary_stress_treated_like_primary
    # ˌsekundary marker should also uppercase its syllable.
    assert_equal "SEH", @converter.respell("ˌse")
  end

  def test_longest_match_prefers_clusters
    # "bwe" should match the 3-char cluster, not b+w+e.
    # (Plus the explicit single-syllable case from the canonical example.)
    assert_equal "BWEH", @converter.respell("ˈbwe")
  end
end
