class AddSequenceNumberToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :sequence_number, :integer
  end
end