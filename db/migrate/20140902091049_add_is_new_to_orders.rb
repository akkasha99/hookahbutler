class AddIsNewToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_new, :boolean, :default => true
  end
end
