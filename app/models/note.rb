class Note < ApplicationRecord
  belongs_to :model
  belongs_to :editor

  validates :comment, presence: true

  default_scope  { order(created_at: :asc) }
end
