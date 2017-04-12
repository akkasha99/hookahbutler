class AddConvenienceAndIsChargedToOrderTransactions < ActiveRecord::Migration
  def change
    add_column :order_transactions, :convenience_fee, :float
    add_column :order_transactions, :is_charged, :boolean, :default => false
    add_column :order_transactions, :transaction_type, :string
  end
end
