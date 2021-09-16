class Vote < ApplicationRecord
  belongs_to :model
  belongs_to :editor

  validates :comment, presence: true

  VOTE_KINDS = [
    "in-scope",
    "out-of-scope",
    "comment"
  ].freeze

  default_scope  { order(created_at: :desc) }
  scope :in_scope, lambda { where('kind = ?', 'in-scope') }
  scope :out_of_scope, lambda { where('kind = ?', 'out-of-scope') }
  scope :comment_only, lambda { where('kind = ?', 'comment') }

  def in_scope?
    kind == "in-scope"
  end

  def out_of_scope?
    kind == "out-of-scope"
  end

  def comment?
    kind == "comment"
  end

  def self.has_vote_for?(model, editor)
    find_by_model_id_and_editor_id(model, editor)
  end

  validates :kind, inclusion: { in: VOTE_KINDS }, allow_nil: false
end
