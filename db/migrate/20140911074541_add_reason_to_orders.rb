class AddReasonToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :reason, :string
  end
end
