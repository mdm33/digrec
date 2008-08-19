# Model for a lemma. Each lemma has a base (non-inflected) form, a language code
# and may additionally be differentiated from other lemmata in the same language
# with the same base form using a integer variant identifier.
class Lemma < ActiveRecord::Base
  has_many :tokens
  has_many :dictionary_references
  has_many :notes, :as => :notable, :dependent => :destroy

  validates_presence_of :lemma
  validates_unicode_normalization_of :lemma, :form => UNICODE_NORMALIZATION_FORM

  # Returns the Perseus lemma for this lemma or +nil+ if unknown.
  def perseus_lemma
    if variant && m = variant.match(/^perseus=(\d+)$/)
      lemma + m[1]
    else
      nil
    end
  end

  # Returns +true+ if a Perseus lemme is known for this lemma, +false+ otherwise.
  def perseus_lemma?
    (!perseus_lemma.nil?)
  end

  # Returns the human-readable presentation for for the lemma.
  def to_s
    self.variant ? "#{self.lemma}##{self.variant}" : self.lemma 
  end

  def presentation_form
    if self.variant
      [self.lemma, self.variant].join('#')
    else
      self.lemma
    end
  end

  def Lemma.find_or_create_by_morph_and_lemma_tag_and_language(ml_tag, language)
    pos = ml_tag.morphtag.pos_to_s
    find_or_create_by_lemma_and_variant_and_pos_and_language(ml_tag.lemma, ml_tag.variant, pos, language)
  end

  # Merges another lemma into this lemma and saves the results. The two lemmata
  # must have the same base form, the same morphology and be for the same language.
  # All tokens belonging to the lemma to be merged will have their lemma references
  # changed.
  def merge!(other_lemma)
    raise "Different base forms" unless self.lemma == other_lemma.lemma
    raise "Different languages" unless self.language == other_lemma.language
    raise "Different morphology" unless self.pos == other_lemma.pos

    Token.transaction do
      other_lemma.tokens.each do |t|
        t.lemma_id = self.id
        t.save!
      end
    end
  end

  protected

  def self.search(query, options = {})
    conditions = []
    clauses = []

    unless query.blank?
      lemma, variant = query.split('#')

      if variant
        options[:conditions] ||= ['lemma LIKE ? AND variant = ?', "%#{lemma}%", variant]
      else
        options[:conditions] ||= ['lemma LIKE ?', "%#{lemma}%"]
      end
    end

    options[:order] ||= 'language ASC, sort_key ASC, lemma ASC, variant ASC, pos ASC'

    paginate options
  end

  # Returns lemmata that are possible completions of the lemma +q+ in the language
  # +language+. The lemma should be given on presentation form, i.e. "lemma" or
  # "lemma#variant". If no variant is given, both completion with and without
  # variant numbers will be returned.
  def self.find_completions(q, language)
    lemma, variant = q.split(/#/)
    unless variant.blank?
      Lemma.find(:all, :conditions => ["language = ? AND lemma LIKE ? AND variant = ?", language, "#{lemma}%", variant])
    else
      Lemma.find(:all, :conditions => ["language = ? AND lemma LIKE ?", language, "#{lemma}%"])
    end
  end
end
