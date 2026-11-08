class CustomField < ApplicationRecord
  belongs_to :inventory

  FIELD_TYPES = %w[string text number link boolean].freeze

  validates :title, presence: true,
            uniqueness: {
              scope: :inventory_id,
              case_sensitive: false
            }

  validates :field_type, presence: true,
            inclusion: { in: FIELD_TYPES }

  validate :maximum_three_fields_per_type

  private

  def maximum_three_fields_per_type
    return unless inventory && FIELD_TYPES.include?(field_type)

    existing_fields = inventory.custom_fields.where(field_type: field_type)
    existing_fields = existing_fields.where.not(id: id) if persisted?

    if existing_fields.count >= 3
      errors.add(:field_type, "can have at most 3 fields of this type")
    end
  end
end