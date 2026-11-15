class Inventory < ApplicationRecord
  belongs_to :user
  has_many :custom_fields, dependent: :destroy
  has_many :items, dependent: :destroy

  has_many :inventory_accesses, dependent: :destroy
  has_many :authorized_users, through: :inventory_accesses, source: :user
  validates :title, presence: true
  validates :category, presence: true

  scope :public_inventories, -> { where(is_public: true) }
  scope :private_inventories, -> { where(is_public: false) }

  DEFAULT_CUSTOM_ID_FORMAT = [
    { "type" => "fixed_text", "value" => "ITEM-" },
    { "type" => "sequence", "format" => "D4" }
  ].freeze

  attribute :custom_id_format, default: -> {
    DEFAULT_CUSTOM_ID_FORMAT.map(&:dup)
  }

  def effective_custom_id_format
    custom_id_format.presence || DEFAULT_CUSTOM_ID_FORMAT.map(&:dup)
  end

  def can_write_items?(user)
    return false unless user

    user.admin? || user_id == user.id || is_public? || inventory_accesses.exists?(user_id: user.id)
  end
end
