class CreateCustomFields < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_fields do |t|
      t.references :inventory, null: false, foreign_key: true
      t.string :name, null: false
      t.string :field_type, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end