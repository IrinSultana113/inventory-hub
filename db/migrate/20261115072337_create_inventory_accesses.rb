class CreateInventoryAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_accesses do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.index [:inventory_id, :user_id], unique: true
      t.timestamps
    end
  end
end
