class CreateOrderTimes < ActiveRecord::Migration
  def change
    create_table :order_times do |t|
      t.integer :time
      t.integer :user_id
      t.timestamps
    end
  end
end
