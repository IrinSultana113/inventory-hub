class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories do |t|
      t.string :title, null: false
      t.text :description
      t.string :category, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
