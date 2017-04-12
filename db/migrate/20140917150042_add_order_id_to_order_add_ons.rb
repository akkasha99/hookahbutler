class AddOrderIdToOrderAddOns < ActiveRecord::Migration
  def change
    add_column :order_add_ons, :order_id, :integer
  end
end
