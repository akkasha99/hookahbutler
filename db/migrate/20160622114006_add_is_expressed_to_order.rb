class AddIsExpressedToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :is_expressOrder, :boolean, :default => false
  end

  def down
    remove_column :orders, :is_expressOrder, :boolean, :default => false
  end
end
