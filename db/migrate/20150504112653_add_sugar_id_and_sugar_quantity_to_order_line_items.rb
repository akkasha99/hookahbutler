class AddSugarIdAndSugarQuantityToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :sugar_id, :integer
    add_column :order_line_items, :sugar_quantity, :integer
    add_column :order_line_items, :sugar_total_price, :float
  end
end
