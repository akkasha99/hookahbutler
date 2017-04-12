class CreateOrderTransactions < ActiveRecord::Migration
  def change
    create_table :order_transactions do |t|
      t.integer :shop_id
      t.integer :user_id
      t.integer :order_id
      t.string :transaction_id
      t.string :transaction_type
      t.string :status
      t.string :amount

      t.timestamps
    end
  end
end
