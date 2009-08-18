class Language < ActiveRecord::Base
  has_many :lemmata
  has_many :sources
  has_many :inflections

  validates_presence_of :iso_code
  validates_length_of :iso_code, :is => 3
  validates_uniqueness_of :iso_code
  validates_presence_of :name
  validates_uniqueness_of :name

  # Returns the language code as a string. Equivalent to
  # +language.iso_code+.
  def to_s
    iso_code
  end

  # Returns inferred morphology for a word form in the language.
  #
  # ==== Options
  # <tt>:ignore_instances</tt> -- If set, ignores all instance matches.
  # <tt>:force_method</tt> -- If set, forces the tagger to use a specific tagging method,
  #                          e.g. <tt>:manual_rules</tt> for manual rules. All other
  #                          methods are disabled.
  def guess_morphology(form, existing_tags, options = {})
    TAGGER.tag_token(iso_code.to_sym, form, existing_tags)
  rescue Exception => e
    logger.error { "Tagger failed: #{e}" }
    [:failed, nil]
  end

  # Returns a transliterator for the language or +nil+ if none exists.
  def transliterator
    t = TRANSLITERATORS[iso_code.to_sym]
    t ? TransliteratorFactory::get_transliterator(t) : nil
  end

  # Returns potential lemma completions based on query string on the
  # form +foo+ or +foo#1+. +foo+ should be the prefix of the lemmata
  # to be returned and may be transliterated. The result is returned
  # as two arrays: one with the transliterations of the query and one
  # with completions.
  def find_lemma_completions(query)
    if t = transliterator
      results = t.transliterate_string(query)
      completion_candidates = results
    else
      results = []
      completion_candidates = query
    end

    completions = lemmata.by_completions(completion_candidates)

    [results.sort.uniq, completions]
  end

  # Returns potential lemma completions based on query string on the
  # form +foo+ or +foo#1+. +foo+ should be the prefix of the lemmata
  # to be returned and may be transliterated. The result is returned
  # as two arrays: one with the transliterations of the query and one
  # with completions.
  def self.find_lemma_completions(language_code, query)
    language = Language.find_by_iso_code(language_code)
    language ? language.find_lemma_completions(query) : [[query], []]
  end

  protected

  def self.search(query, options)
    options[:conditions] ||= ["name LIKE ?", "%#{query}%"]
    options[:order] ||= "name ASC"

    paginate options
  end
end
