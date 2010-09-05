require File.dirname(__FILE__) + '/../test_helper'

class MorphologyTestCase < ActiveSupport::TestCase
  def setup
    @tag1 = '3srip-----i'
    @tag2 = '-s---mg---i'
    @tag3 = '-----------'
    @m1 = Morphology.new(@tag1)
    @m2 = Morphology.new(@tag2)
    @m3 = Morphology.new(@tag3)
  end

  def test_tag_reader
    assert_equal @tag1, @m1.morphology
    assert_equal @tag2, @m2.morphology
    assert_equal @tag3, @m3.morphology
  end

  def test_to_s
    assert_equal @tag1, @m1.to_s
    assert_equal @tag2, @m2.to_s
    assert_equal @tag3, @m3.to_s
  end

  def test_field_access
    assert_equal :'3', @m1.person
    assert_equal :'3', @m1[:person]

    assert_equal "-", @m2.person
    assert_equal "-", @m2[:person]
  end

  def test_token_access
    s = Sentence.first
    t = s.tokens.new :lemma => Lemma.first, :form => 'foo'
    t.morphology = @m1
    t.save

    assert_equal @m1, t.morphology
    assert_equal @tag1, t.read_attribute(:morphology)
    assert_equal @m1, t.morph_features.morphology
    assert_equal @tag1, t.morph_features.morphology.to_s
    assert_equal @tag1, t.morph_features.morphology_s

    t.morphology = @tag2
    t.save

    assert_equal @m2, t.morphology
    assert_equal @tag2, t.read_attribute(:morphology)
    assert_equal @m2, t.morph_features.morphology
    assert_equal @tag2, t.morph_features.morphology.to_s
    assert_equal @tag2, t.morph_features.morphology_s
  end

  def test_inflection_access
    t = Inflection.new :lemma => 'cum,R-', :form => 'foo', :language => 'lat'
    t.morphology = @m1
    t.save

    assert_equal @m1, t.morphology
    assert_equal @tag1, t.read_attribute(:morphology)
    assert_equal @m1, t.morph_features.morphology
    assert_equal @tag1, t.morph_features.morphology.to_s
    assert_equal @tag1, t.morph_features.morphology_s

    t.morphology = @tag2
    t.save

    assert_equal @m2, t.morphology
    assert_equal @tag2, t.read_attribute(:morphology)
    assert_equal @m2, t.morph_features.morphology
    assert_equal @tag2, t.morph_features.morphology.to_s
    assert_equal @tag2, t.morph_features.morphology_s
  end
end
