class AddTotalPriceToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :total_price, :float
  end
end
