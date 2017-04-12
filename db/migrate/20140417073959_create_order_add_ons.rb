class CreateOrderAddOns < ActiveRecord::Migration
  def change
    create_table :order_add_ons do |t|
      t.integer :item_add_on_id
      t.integer :order_line_item_id
      t.integer :quantity

      t.timestamps
    end
  end
end
