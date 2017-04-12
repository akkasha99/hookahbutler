class AddTaxAndRefundedAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tax, :float
    add_column :orders, :refunded_amount, :float
  end
end
