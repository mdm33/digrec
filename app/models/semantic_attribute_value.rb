class SemanticAttributeValue < ActiveRecord::Base
  belongs_to :semantic_attribute
  has_many :semantic_tags

  validates_presence_of :tag
  validates_uniqueness_of :tag, :scope => :semantic_attribute_id

  def self.ransackable_attributes(auth_object = nil)
    column_names + _ransackers.keys
  end

  def self.ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end
end
