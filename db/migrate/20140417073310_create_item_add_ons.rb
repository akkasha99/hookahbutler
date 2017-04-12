class CreateItemAddOns < ActiveRecord::Migration
  def change
    create_table :item_add_ons do |t|
      t.integer :add_on_id
      t.integer :item_id
      t.integer :item_size_id

      t.timestamps
    end
  end
end
