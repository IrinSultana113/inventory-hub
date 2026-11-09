class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :custom_id

      t.timestamps
    end

    add_index :items, [:inventory_id, :custom_id], unique: true
  end
end