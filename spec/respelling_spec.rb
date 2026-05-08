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

  def test_pair_constructor
    assert_kind_of Respelling::Converter, Respelling.pair(source: "es", target: "en")
  end

  def test_for_unknown_language_raises
    assert_raises(ArgumentError) { Respelling.for("klingon") }
  end

  def test_pair_unknown_source_raises
    assert_raises(ArgumentError) { Respelling.pair(source: "klingon", target: "en") }
  end

  def test_canonical_buenos_dias
    # ˈbwe.nos ˈði.as → BWAY-nohss DEE-ahss in the v0.2 English-orthography
    # table. Reader-perception-driven: an English speaker reading this aloud
    # produces a passable approximation of "buenos días".
    assert_equal "BWAY-nohs DEE-ahs", @converter.respell("ˈbwe.nos ˈði.as")
  end

  def test_buenos_dias_with_combining_lowered_o
    # Real IPA often writes Spanish /o/ as the lowered variant /o̞/. The
    # converter must strip the combining diacritic and still match `o`.
    assert_equal "BWAY-nohs DEE-ahs", @converter.respell("ˈbwe.no̞s ˈði.as")
    assert_empty @converter.warnings
  end

  def test_simple_word_cafe
    assert_equal "KAH-fay", @converter.respell("ˈka.fe")
  end

  def test_single_syllable_si
    assert_equal "SEE", @converter.respell("ˈsi")
  end

  def test_single_syllable_no
    assert_equal "NOH", @converter.respell("ˈno")
  end

  def test_three_syllable_fabricado
    # /fa.bɾi.ˈka.do/ → fah-bree-KAH-doh
    assert_equal "fah-bree-KAH-doh", @converter.respell("fa.bɾi.ˈka.do")
  end

  def test_gracias
    # /ˈgɾa.sjas/ → GRAH-syahss
    assert_equal "GRAH-syahs", @converter.respell("ˈgɾa.sjas")
  end

  def test_por_favor
    # /poɾ fa.ˈβoɾ/ → por fah-VOR
    assert_equal "por fah-BOR", @converter.respell("poɾ fa.ˈβoɾ")
  end
end
