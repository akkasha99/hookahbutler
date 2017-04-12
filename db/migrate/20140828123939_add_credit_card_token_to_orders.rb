class AddCreditCardTokenToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :card_id, :string
    add_column :orders, :estimated_time, :integer
  end
end
