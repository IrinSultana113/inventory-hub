class UpdateCustomFields < ActiveRecord::Migration[8.1]
  def change
    rename_column :custom_fields, :name, :title

    add_column :custom_fields, :description, :text
    add_column :custom_fields, :show_in_table, :boolean,
               default: false, null: false
  end
end