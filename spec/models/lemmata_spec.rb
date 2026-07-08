require 'rails_helper'

RSpec.describe Lemma, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:lemma)).to be_valid
  end

  it "is invalid without a language tag" do
    expect(FactoryBot.build(:lemma, language_tag: nil)).not_to be_valid
  end

  it "is invalid if language tag is bogus" do
    expect(FactoryBot.build(:lemma, language_tag: 'XXX')).not_to be_valid
  end

  it "is invalid without a part of speech tag" do
    expect(FactoryBot.build(:lemma, part_of_speech_tag: nil)).not_to be_valid
  end

  it "is invalid if part of speech tag is bogus" do
    expect(FactoryBot.build(:lemma, part_of_speech_tag: 'XX')).not_to be_valid
  end

  it "is invalid without a lemma" do
    expect(FactoryBot.build(:lemma, lemma: nil)).not_to be_valid
  end

  it "is valid if the variant number is an integer" do
    expect(FactoryBot.build(:lemma, variant: 0)).to be_valid
    expect(FactoryBot.build(:lemma, variant: 1)).to be_valid
    expect(FactoryBot.build(:lemma, variant: -1)).to be_valid
    expect(FactoryBot.build(:lemma, variant: 12345)).to be_valid
    expect(FactoryBot.build(:lemma, variant: '1')).to be_valid
    expect(FactoryBot.build(:lemma, variant: '0')).to be_valid
  end

# FIXME? We can really test this because Active Record's connection adapter
# will coerce the value of an integer column to an integer or nil.
#  it "is invalid if the variant number is not an integer, nil or a blank string" do
#    FactoryBot.build(:lemma, variant: 'foobar').should_not be_valid
#    FactoryBot.build(:lemma, variant: Hash.new).should_not be_valid
#    FactoryBot.build(:lemma, variant: :foobar).should_not be_valid
#  end

  it "returns a language tag and a language object" do
    lemma = FactoryBot.create(:lemma)
    expect(lemma.language_tag).to eq 'lat'
    expect(lemma.language).to eq LanguageTag.new('lat')
    # FIXME: ideally these objects should also be identical
    #lemma.language.should be LanguageTag.new('lat')
  end

  it "returns a part of speech tag and a part of speech object" do
    lemma = FactoryBot.create(:lemma)
    expect(lemma.part_of_speech_tag).to eq 'V-'
    expect(lemma.part_of_speech).to eq PartOfSpeechTag.new('V-')
    # FIXME: ideally these objects should also be identical
    #lemma.part_of_speech.should be PartOfSpeechTag.new('V-')
  end

  it "returns a part of speech tag and a part of speech object" do
    lemma = FactoryBot.create(:lemma)
    expect(lemma.lemma).to eq 'sum'
  end

  it "returns all represented languages" do
    languages = %w(lat grc chu)

    languages.each do |l|
      FactoryBot.create(:lemma, language_tag: l)
    end

    language_tags = languages.map { |l| LanguageTag.new(l) }

    expect(Lemma.represented_languages.sort_by(&:tag)).to eq language_tags.sort_by(&:tag)
  end

  it "returns all represented languages in correct order" do
    languages = %w(lat grc chu)

    languages.each do |l|
      FactoryBot.create(:lemma, language_tag: l)
    end

    language_tags = languages.map { |l| LanguageTag.new(l) }

    expect(Lemma.represented_languages).to eq language_tags.sort_by(&:to_label)
  end

  it "returns all represented parts of speech" do
    parts_of_speech = %w(C- V- Df Nb Ne R-)

    parts_of_speech.each do |p|
      FactoryBot.create(:lemma, part_of_speech_tag: p)
    end

    part_of_speech_tags = parts_of_speech.map { |p| PartOfSpeechTag.new(p) }

    expect(Lemma.represented_parts_of_speech.sort_by(&:tag)).to eq part_of_speech_tags.sort_by(&:tag)
  end

  it "returns all represented parts of speech in correct order" do
    parts_of_speech = %w(C- V- Df Nb Ne R-)

    parts_of_speech.each do |p|
      FactoryBot.create(:lemma, part_of_speech_tag: p)
    end

    part_of_speech_tags = parts_of_speech.map { |p| PartOfSpeech.new(p) }

    expect(Lemma.represented_parts_of_speech).to eq part_of_speech_tags.sort_by(&:to_label)
  end

  describe '#possible_completions' do
    it "returns completions given a prefix" do
      FactoryBot.create(:lemma, lemma: 'diligo')
      FactoryBot.create(:lemma, lemma: 'dirigo')
      FactoryBot.create(:lemma, lemma: 'credo')
      FactoryBot.create(:lemma, lemma: 'credo', variant: 1)
      FactoryBot.create(:lemma, lemma: 'credo', variant: 2)

      expect(Lemma.
        possible_completions('lat', 'dir').
        map(&:export_form).
        sort).
        to eq %w(dirigo)
    end

    it "returns completions given multiple prefixes" do
      FactoryBot.create(:lemma, lemma: 'diligo')
      FactoryBot.create(:lemma, lemma: 'dirigo')
      FactoryBot.create(:lemma, lemma: 'credo')
      FactoryBot.create(:lemma, lemma: 'credo', variant: 1)
      FactoryBot.create(:lemma, lemma: 'credo', variant: 2)

      expect(Lemma.
        possible_completions('lat', %w{apo dir cred}).
        map(&:export_form).
        sort).
        to eq %w(credo credo#1 credo#2 dirigo)
    end

    it "respects a variant number when provided" do
      FactoryBot.create(:lemma, lemma: 'credo')
      FactoryBot.create(:lemma, lemma: 'credo', variant: 1)
      FactoryBot.create(:lemma, lemma: 'credo', variant: 2)

      expect(Lemma.
        possible_completions('lat', %w{cred#1}).
        map(&:export_form).
        sort).
        to eq %w(credo#1)
    end

    it "applies a restriction only on prefixes with a variant number" do
      FactoryBot.create(:lemma, lemma: 'dirigo')
      FactoryBot.create(:lemma, lemma: 'credo')
      FactoryBot.create(:lemma, lemma: 'credo', variant: 1)
      FactoryBot.create(:lemma, lemma: 'credo', variant: 2)

      expect(Lemma.
        possible_completions('lat', %w{dir cred#1}).
        map(&:export_form).
        sort).
        to eq %w(credo#1 dirigo)
    end

    it "ignores a blank variant number" do
      FactoryBot.create(:lemma, lemma: 'credo')
      FactoryBot.create(:lemma, lemma: 'credo', variant: 1)
      FactoryBot.create(:lemma, lemma: 'credo', variant: 2)

      expect(Lemma.
        possible_completions('lat', 'cred#').
        map(&:export_form).
        sort).
        to eq %w(credo credo#1 credo#2)
    end
  end

  it "is mergeable if other lemmata have the same lemma, language tag and part of speech tag" do
    l1 = FactoryBot.create(:lemma, variant: 1)
    l2 = FactoryBot.create(:lemma, variant: 2)

    expect(l1.mergeable?(l2)).to be_truthy
    expect(l2.mergeable?(l1)).to be_truthy
  end

  it "is not mergeable if other lemmata have a different lemma" do
    l1 = FactoryBot.create(:lemma, variant: 1, lemma: 'sum')
    l2 = FactoryBot.create(:lemma, variant: 2, lemma: 'fio')

    expect(l1.mergeable?(l2)).to be_falsey
    expect(l2.mergeable?(l1)).to be_falsey
  end

  it "is not mergeable if other lemmata have a different language tag" do
    l1 = FactoryBot.create(:lemma, variant: 1, language_tag: 'got')
    l2 = FactoryBot.create(:lemma, variant: 2, language_tag: 'lat')

    expect(l1.mergeable?(l2)).to be_falsey
    expect(l2.mergeable?(l1)).to be_falsey
  end

  it "is not mergeable if other lemmata have a different part of speech tag" do
    l1 = FactoryBot.create(:lemma, variant: 1, part_of_speech_tag: 'V-')
    l2 = FactoryBot.create(:lemma, variant: 2, part_of_speech_tag: 'R-')

    expect(l1.mergeable?(l2)).to be_falsey
    expect(l2.mergeable?(l1)).to be_falsey
  end

  it "returns all mergeable lemmata" do
    l1 = FactoryBot.create(:lemma, variant: 1)
    l2 = FactoryBot.create(:lemma, variant: 2)
    l3 = FactoryBot.create(:lemma, variant: nil)
    l4 = FactoryBot.create(:lemma, lemma: 'fio')

    expect(l1.mergeable_lemmata.map(&:export_form).sort).to eq %w(sum sum#2)
    expect(l2.mergeable_lemmata.map(&:export_form).sort).to eq %w(sum sum#1)
    expect(l3.mergeable_lemmata.map(&:export_form).sort).to eq %w(sum#1 sum#2)
    expect(l4.mergeable_lemmata.map(&:export_form).sort).to eq %w()
  end

  it "can be merged with a mergeable lemma" do
    l1 = FactoryBot.create(:lemma, variant: 1)
    l2 = FactoryBot.create(:lemma, variant: 2)

    l1.merge! l2
  end

  it "cannot be merged with an unmergeable lemma" do
    l1 = FactoryBot.create(:lemma, lemma: 'sum')
    l2 = FactoryBot.create(:lemma, lemma: 'fio')

    expect { l1.merge! l2 }.to raise_error(ArgumentError)
  end
end
