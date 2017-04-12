class AddItemIdToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :item_id, :integer
  end
end
