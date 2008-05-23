class Source < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title

  has_many :books, :class_name => 'Book', :finder_sql => 'SELECT books.* FROM books AS books LEFT JOIN sentences AS sentences ON book_id = books.id WHERE source_id = #{id} GROUP BY book_id'
  has_many :sentences
  has_many :tokens, :class_name => 'Token', :finder_sql => 'SELECT * FROM tokens LEFT JOIN sentences ON sentence_id = sentences.id WHERE source_id = #{id}', :counter_sql => 'SELECT count(*) FROM tokens LEFT JOIN sentences ON sentence_id = sentences.id WHERE source_id = #{id}' 

  has_many :unannotated_sentences, :class_name => 'Sentence', :foreign_key => 'source_id', :conditions => 'annotated_by is null'
  has_many :annotated_sentences, :class_name => 'Sentence', :foreign_key => 'source_id', :conditions => 'annotated_by is not null'
  has_many :reviewed_sentences, :class_name => 'Sentence', :foreign_key => 'source_id', :conditions => 'reviewed_by is not null'

  belongs_to :aligned_with, :class_name => 'Source', :foreign_key => 'alignment_id' 
  has_many :bookmarks

  # FIXME: These don't really belong here, do they? But where should
  # they go instead?
  class << self
    # Returns information about the level of activity. The information is returned
    # per day, and for freshly annotated sentences. Does not include the present
    # day, since activity may not yet have ceased.
    def activity
      Sentence.count(:all, :conditions => "annotated_at is not null AND annotated_at < DATE_FORMAT(NOW(), '%Y-%m-%d')", :group => "DATE_FORMAT(annotated_at, '%Y-%m-%d')", :order =>"annotated_at ASC")
   end

    # Returns completion information. If +source+ is given, then information is returned
    # only for this particular source.
    def completion(source = nil)
      sources = Source.find(source || :all)
      sources = [sources] unless sources.is_a?(Array)
      r = {}
      r[:reviewed] = sources.sum { |s| s.reviewed_sentences.count }
      r[:annotated] = sources.sum { |s| s.annotated_sentences.count }
      r[:unannotated] = sources.sum { |s| s.unannotated_sentences.count }
      r
    end
  end

  # Invokes the PROIEL morphology tagger. Takes any already set morphology
  # as well as any source morph+lemma tag into account.
  def invoke_tagger(form, sort, existing_morph_lemma_tag = nil, options = {})
    TAGGER.logger = logger
    TAGGER.tag_token(self.language, form, sort, existing_morph_lemma_tag, options)
  end

  # Returns the human-readable presentation form of the name of the source.
  def presentation_form
    self.title
  end

  protected

  def self.search(search, page)
    search ||= {}
    conditions = [] 
    clauses = [] 
    includes = []

    paginate(:page => page, :per_page => 50, :conditions => conditions, 
             :include => includes)
  end
end
