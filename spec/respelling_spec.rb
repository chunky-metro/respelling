# frozen_string_literal: true

require_relative "spec_helper"

# Top-level Respelling module tests — version, language lookup, the
# canonical Buenos días example.
class RespellingTest < Minitest::Test
  def setup
    @converter = Respelling.spanish
  end

  def test_version_present
    refute_nil Respelling::VERSION
    assert_match(/\A\d+\.\d+\.\d+\z/, Respelling::VERSION)
  end

  def test_for_returns_spanish_converter
    assert_kind_of Respelling::Converter, Respelling.for("es")
    assert_kind_of Respelling::Converter, Respelling.for("spanish")
  end

  def test_for_unknown_language_raises
    assert_raises(ArgumentError) { Respelling.for("klingon") }
  end

  def test_canonical_buenos_dias
    # ˈbwe.nos ˈði.as → BWEH-nohs THEE-ahs (faithful to the data table).
    # The "BWAY-nohs DEE-ahs" form some dictionaries print is the *idealized*
    # English-speaker target; this gem reflects the parrot-lab IPA→table
    # mapping where bwe→bweh and ð→th.
    assert_equal "BWEH-nohs THEE-ahs", @converter.respell("ˈbwe.nos ˈði.as")
  end

  def test_buenos_dias_with_combining_lowered_o
    # Real IPA often writes Spanish /o/ as the lowered variant /o̞/. The
    # converter must strip the combining diacritic and still match `o`.
    assert_equal "BWEH-nohs THEE-ahs", @converter.respell("ˈbwe.no̞s ˈði.as")
    assert_empty @converter.warnings
  end

  def test_simple_word_cafe
    assert_equal "KAH-feh", @converter.respell("ˈka.fe")
  end

  def test_single_syllable_si
    assert_equal "SEE", @converter.respell("ˈsi")
  end

  def test_single_syllable_no
    assert_equal "NOH", @converter.respell("ˈno")
  end

  def test_three_syllable_fabricado
    assert_equal "fah-bree-KAH-doh", @converter.respell("fa.bɾi.ˈka.do")
  end
end
