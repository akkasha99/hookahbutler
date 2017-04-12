class AddStatusToShops < ActiveRecord::Migration
  def change
    add_column :shops, :status, :boolean, :default => false
  end
end
