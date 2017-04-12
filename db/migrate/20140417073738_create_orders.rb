class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :shop_id
      t.integer :user_id
      t.string :order_number
      t.string :status
      t.float :total_amount

      t.timestamps
    end
  end
end
