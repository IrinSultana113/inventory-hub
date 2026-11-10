class AddCustomIdFormatToInventories < ActiveRecord::Migration[8.1]
  def change
    add_column :inventories, :custom_id_format, :jsonb
  end
end
