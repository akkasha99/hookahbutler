class AddIsDeletedToAddOns < ActiveRecord::Migration
  def change
    add_column :add_ons, :is_deleted, :boolean, :default => false
  end
end
