class AddCustomIdSequenceToInventories < ActiveRecord::Migration[8.1]
  def change
    add_column :inventories, :custom_id_sequence,
               :integer, default: 0, null: false
  end
end