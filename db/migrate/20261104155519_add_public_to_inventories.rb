class AddPublicToInventories < ActiveRecord::Migration[8.1]
  def change
    add_column :inventories, :is_public, :boolean, default: false, null: false
  end
end
