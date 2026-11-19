class CreateDiscussionPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :discussion_posts do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
