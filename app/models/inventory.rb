class Inventory < ApplicationRecord
  belongs_to :user
  has_many :custom_fields, dependent: :destroy
  validates :title, presence: true
  validates :category, presence: true

  scope :public_inventories, -> { where(is_public: true) }
  scope :private_inventories, -> { where(is_public: false) }

  def can_write_items?(user)
    return false unless user

    user.admin? || user_id == user.id || is_public?
  end
end
