class Item < ApplicationRecord
  belongs_to :inventory
  belongs_to :user

  has_many :custom_field_values, dependent: :destroy
  has_many :custom_fields, through: :custom_field_values

  accepts_nested_attributes_for :custom_field_values

  validates :custom_id, presence: true
  validates :custom_id, uniqueness: { scope: :inventory_id }
  validate :custom_id_matches_inventory_format

  private

  def custom_id_matches_inventory_format
    return unless new_record? || will_save_change_to_custom_id?

    return if custom_id.blank? || inventory.nil?

    validator = CustomIdValidator.new(inventory, custom_id)

    unless validator.valid?
      errors.add(:custom_id, "does not match this inventory's format")
    end
  end
end