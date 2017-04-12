class AddNoOfShotsAndShotPriceAndShotTotalPriceToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :no_of_shots, :integer
    add_column :order_line_items, :shot_price, :float
    add_column :order_line_items, :shot_total_price, :float
  end
end
