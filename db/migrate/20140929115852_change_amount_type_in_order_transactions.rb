class ChangeAmountTypeInOrderTransactions < ActiveRecord::Migration
  def up
    change_column :order_transactions, :amount, :float #'float USING CAST(amount AS float)'
  end
end
