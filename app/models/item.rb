class Item < ApplicationRecord
  belongs_to :inventory
  belongs_to :user

  has_many :custom_field_values, dependent: :destroy
  has_many :custom_fields, through: :custom_field_values

  accepts_nested_attributes_for :custom_field_values

  validates :custom_id,
            uniqueness: { scope: :inventory_id },
            allow_nil: true
end