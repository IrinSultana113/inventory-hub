
class CustomFieldValue < ApplicationRecord
  belongs_to :item
  belongs_to :custom_field

  validates :custom_field_id,
            uniqueness: { scope: :item_id }

  validate :custom_field_belongs_to_same_inventory
  validate :value_matches_field_type

  private

  def custom_field_belongs_to_same_inventory
    return unless item && custom_field

    unless item.inventory_id == custom_field.inventory_id
      errors.add(:custom_field, "must belong to the item's inventory")
    end
  end

  def value_matches_field_type
    return if value.blank? || custom_field.nil?

    case custom_field.field_type
     when "string", "text"
    # Any text is allowed.
    when "number"
      unless Float(value, exception: false)
        errors.add(:value, "must be a valid number")
      end
    when "link"
      begin
        uri = URI.parse(value)
        unless uri.is_a?(URI::HTTP) && uri.host.present?
          errors.add(:value, "must be a valid URL")
        end
      rescue URI::InvalidURIError
        errors.add(:value, "must be a valid URL")
      end
    when "boolean"
      unless %w[true false].include?(value)
        errors.add(:value, "must be true or false")
      end
    end
  end
end
