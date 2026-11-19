class DiscussionPost < ApplicationRecord
  belongs_to :inventory
  belongs_to :user

  validates :body, presence: true, length: { maximum: 10_000 }
end