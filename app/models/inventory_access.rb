
class InventoryAccess < ApplicationRecord
  belongs_to :inventory
  belongs_to :user

  validates :user_id, uniqueness: { scope: :inventory_id }
end
