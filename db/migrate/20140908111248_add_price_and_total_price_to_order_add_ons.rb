class AddPriceAndTotalPriceToOrderAddOns < ActiveRecord::Migration
  def change
    add_column :order_add_ons, :price, :float
    add_column :order_add_ons, :total_price, :float
  end
end
