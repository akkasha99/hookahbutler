class AddIsOpenToShopHours < ActiveRecord::Migration
  def change
    add_column :shop_hours, :is_open, :boolean
  end
end
