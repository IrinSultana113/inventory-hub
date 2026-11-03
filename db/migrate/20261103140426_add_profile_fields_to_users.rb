class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :blocked, :boolean, default: false, null: false
    add_column :users, :locale, :string, default: "en", null: false
    add_column :users, :theme, :string, default: "light", null: false

    add_index :users, :username, unique: true
  end
end