class CreateItemSizes < ActiveRecord::Migration
  def change
    create_table :item_sizes do |t|
      t.integer :item_id
      t.integer :size_id
      t.float :price

      t.timestamps
    end
  end
end
