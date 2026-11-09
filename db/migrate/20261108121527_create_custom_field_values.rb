class CreateCustomFieldValues < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_field_values do |t|
      t.references :item, null: false, foreign_key: true
      t.references :custom_field, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end

    add_index :custom_field_values, [:item_id, :custom_field_id], unique: true,
              name: "index_custom_field_values_on_item_and_field"
  end
end