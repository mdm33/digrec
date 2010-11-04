# Slash edges are directed, labelled edges in the dependency
# graph. They are intended to be used as indicators of various forms
# of coindexing. The `slasher' is generally the element that has a `gap',
# and the `slashee' is the element that would fill the `gap'.
class SlashEdge < ActiveRecord::Base
  belongs_to :slasher, :class_name => 'Token', :foreign_key => 'slasher_id'
  belongs_to :slashee, :class_name => 'Token', :foreign_key => 'slashee_id'
  belongs_to :relation

  validates_uniqueness_of :slasher_id, :scope => :slashee_id,
    :message => 'Slash edge already exists in dependency structure'
  validates_presence_of :relation

  acts_as_audited

  # Returns +true+ if the slash points to the slasher's head.
  def points_to_head?
    slashee == slasher.head
  end

  def cyclic?
    slashee.subgraph_set.include?(slasher)
  end
end
