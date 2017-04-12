class AddCompletedTimeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :completed_time, :datetime
  end
end
