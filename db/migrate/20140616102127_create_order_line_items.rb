class CreateOrderLineItems < ActiveRecord::Migration
  def change
    create_table :order_line_items do |t|
      t.integer :item_size_id
      t.integer :order_id
      t.float :price
      t.integer :quantity

      t.timestamps
    end
  end
end
