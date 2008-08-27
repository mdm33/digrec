#!/usr/bin/env ruby 
#
# morphtag.rb - Morphological tags
#
# Written by Marius L. Jøhndal, 2007, 2008.
#
require 'proiel/tagsets'
require 'proiel/morphtag_constraints'
require 'proiel/positional_tag'

module PROIEL
  MorphLemmaTag = Struct::new(:morphtag, :lemma, :variant)

  class MorphLemmaTag
    def initialize(morphtag_or_string, lemma = nil, variant = nil)
      if morphtag_or_string.is_a?(String) and lemma.nil? and variant.nil?
        morphtag, rest = morphtag_or_string.split(':')
        lemma, variant = rest.split('#') if rest

        super(MorphTag.new(morphtag), lemma, variant ? variant.to_i : nil)
      else
        morphtag = morphtag_or_string.is_a?(String) ? MorphTag.new(morphtag_or_string) : morphtag_or_string
        lemma, variant = lemma.split('#') unless variant

        super(morphtag, lemma, variant ? variant.to_i : nil)
      end

      raise ArgumentError, "invalid variant. Must be nil or a positive integer" unless self.variant.nil? or self.variant > 0
    end

    def lemma_to_s
      v = self.variant ? "##{self.variant}" : ''
      l = self.lemma ? "#{self.lemma}" : ''
      l + v
    end

    def to_s
      l = lemma_to_s
      l != '' ? "#{self.morphtag}:#{l}" : self.morphtag.to_s
    end

    def to_abbrev_s
      l = lemma_to_s
      l != '' ? "#{self.morphtag.to_abbrev_s}:#{l}" : self.morphtag.to_abbrev_s
    end

    def eql?(o)
      o.is_a?(MorphLemmaTag) && to_s == o.to_s
    end

    def hash
      to_s.hash 
    end

    def ==(o)
      o.is_a?(MorphLemmaTag) && to_s == o.to_s
    end

    # Returns an integer, -1, 0 or 1, suitable for sorting the tag.
    def <=>(o)
      s = self.morphtag <=> o.morphtag
      s = (self.lemma || '') <=> (o.lemma || '') if s.zero?
      s = (self.variant || 0) <=> (o.variant || 0) if s.zero?
      s
    end

    def contradicts?(o)
      morphtag.contradicts?(o.morphtag) || (lemma and o.lemma and lemma != o.lemma) || (variant and o.variant and variant != o.variant)
    end
  end

  class MorphTag < Logos::PositionalTag
    PRESENTATION_SEQUENCE = [:major, :minor, :mood, :tense, :voice, :degree, :case, 
      :person, :number, :gender, :animacy, :strength]

    def initialize(values = nil)
      values = PROIEL::MorphTag.pad_s(values) if values.is_a?(String)

      super
    end

    def self.pad_s(s)
      s.ljust(MORPHOLOGY.fields.length, '-')
    end

    def self.fields
      MORPHOLOGY.fields
    end

    def fields
      MORPHOLOGY.fields
    end

    # Returns the tag as an string, abbreviated as much as possible.
    def to_abbrev_s
      to_s.sub(/-+$/, '')
    end

    # Returns the part-of-speech part of the morphtag as a string.
    def pos_to_s
      "#{self[:major]}#{self[:minor]}"
    end

    # Returns the non-part-of-speech part of the morphtag as a string.
    def non_pos_to_s
      to_s[2, fields.length - 2]
    end

    # Returns the morphtag as a pattern suitable for matching using SQL's LIKE
    # operator.
    def to_sql_pattern
      to_abbrev_s.gsub('-', '_') + '%'
    end

    # Returns descriptions for one or more fields in a tag. If
    # +inclusive+ is +true+, +fields+ is an array of fields to
    # include in the description. If +fields+ is +false+, +fields+
    # is an array of fields to exclude. The descriptions are
    # returned as an array of strings. 
    #
    # ==== Options
    # style:: If +:abbreviation+, returns the description on abbreviated form whenever possible.
    # If +:summary+, returns the description as a summary. Default is +:summary+.
    def descriptions(fields, inclusive = true, options = {})
      f = inclusive ? fields : PRESENTATION_SEQUENCE.reject { |field| fields.include?(field) }
      f.collect { |field| self[field] != '-' ?
        MORPHOLOGY.descriptions(field, options)[self[field]] : nil }.compact
    end

    def union(x)
      super(x.to_s.ljust(fields.length, '-'))
    end

    def self.expand_s(tag)
      PROIEL::MorphTag.new(tag).to_s
    end

    # DEPRECATED
    # Returns all possible values for POS-fields.
    def self.pos_values(language)
      p = []
      poses = tag_space(language).map { |tag| MorphTag.new(tag) }.map { |tag| [tag.major, tag.minor] }.uniq.each do |major, minor|
        major = MORPHOLOGY[:major][major.to_sym]
        if minor != '-'
          minor = MORPHOLOGY[:minor][minor.to_sym]
          p.push([major.code, major.summary, minor.code, minor.summary])
        else
          p.push([major.code, major.summary, nil, nil])
        end
      end
      p
    end

    # Generates all possible completions of the possibly incomplete tag.
    def completions(language)
      PROIEL::MorphtagConstraints::instance.tag_space(language.to_sym).reject { |t| contradicts?(t) }
    end

    def self.tag_space(language)
      PROIEL::MorphtagConstraints::instance.tag_space(language.to_sym)
    end

    # Returns +true+ if the tag is valid, i.e. if the subset of fields
    # with a value match the constraints on the fields.
    def is_valid?(language)
      PROIEL::MorphtagConstraints.instance.is_valid?(self.to_s, language.to_sym)
    end

    def to_features
      PROIEL::MorphtagConstraints.instance.to_features(self.to_s)
    end

    # DEPRECATED
    # Returns true if gender has value +value+ or a value that is
    # a super-tag for +value+.
    def is_gender?(value)
      raise ArgumentError.new("Invalid gender") unless [:m, :f, :n].include?(value)

      case self[:gender]
      when :m, :f, :n
        self[:gender] == value
      when :o
        value == :m or value == :n
      when :p
        value == :m or value == :f
      when :r
        value == :f or value == :n
      when :q
        value == :m or value == :f or value == :n
      else
        false
      end
    end

    OPEN_MAJOR = [:V, :A, :N]

    private

    def self.fields_with_inheritance
      [:gender]
    end

    public

    # Returns +true+ if the tag belongs to one of the `closed' parts
    # of speech.
    #
    # Examples:
    #  MorphTag.new('C').is_closed?  #-> true
    #  MorphTag.new('A').is_closed?  #-> false
    #  MorphTag.new('-').is_closed?  #-> false
    def is_closed?
      self.has_key?(:major) and not OPEN_MAJOR.include?(self[:major])
    end

    # Returns +true+ if the tag is a subtag of another tag +o+.
    #
    # Examples (assuming that the defined field in the examples
    # represents gender, and that 'q' is a supertag for 'n'):
    #
    #   MorphTag.new('-------n---').is_subtag?(MorphTag.new('-------q---'))  #-> true
    #   MorphTag.new('-------q---').is_subtag?(MorphTag.new('-------n---'))  #-> false
    #   MorphTag.new('-------n---').is_subtag?(MorphTag.new('-----------'))  #-> false
    #   MorphTag.new('-----------').is_subtag?(MorphTag.new('-------n---'))  #-> false
    def is_subtag?(o)
      # Copy the two tags in question, mask out all fields with inheritance and compare
      # the rest.
      a, b = self.dup, o.dup
      a[*MorphTag::fields_with_inheritance], b[*MorphTag::fields_with_inheritance] = nil, nil
      return false unless a == b

      # Test the inheritable fields
      [:m, :f, :n].include?(self[:gender]) ? o.is_gender?(self[:gender]) : false
    end

    # Returns +true+ if the tag is compatible with another tag +o+, i.e.
    # if the tag is a subtag of the tag +o+ or the tag is a supertag of
    # the tag +o+ or the tags are identical.
    #
    # Examples (assuming that the defined field in the examples
    # represents gender, and that 'q' is a supertag for 'n'):
    #
    #   MorphTag.new('-------n---').is_compatible?(MorphTag.new('-------q---'))  #-> true
    #   MorphTag.new('-------q---').is_compatible?(MorphTag.new('-------n---'))  #-> true
    #   MorphTag.new('-------n---').is_compatible?(MorphTag.new('-----------'))  #-> false
    #   MorphTag.new('-----------').is_compatible?(MorphTag.new('-------n---'))  #-> false
    def is_compatible?(o)
      self == o or self.is_subtag?(o) or o.is_subtag?(self)
    end
  end
end
