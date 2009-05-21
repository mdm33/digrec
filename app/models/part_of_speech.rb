class PartOfSpeech < ActiveRecord::Base
  has_many :lemmata

  has_many :tokens, :through => :lemmata
  has_many :languages, :through => :lemmata, :uniq => true, :order => 'name ASC'

  validates_presence_of :tag
  validates_length_of :tag, :is => 2
  validates_uniqueness_of :tag
  validates_presence_of :summary
  validates_uniqueness_of :summary
  validates_presence_of :abbreviated_summary
  validates_uniqueness_of :abbreviated_summary

  protected

  def self.search(query, options)
    options[:conditions] ||= ["summary LIKE ?", "%#{query}%"]
    options[:order] ||= "summary ASC"

    paginate options
  end
end
