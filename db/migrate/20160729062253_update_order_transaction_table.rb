class UpdateOrderTransactionTable < ActiveRecord::Migration
  def up
    rename_column :order_transactions, :transaction_type, :charge_id
  end

  def down
    rename_column :order_transactions, :charge_id, :transaction_type
  end
end
