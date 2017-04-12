class AddIsDeletedToItems < ActiveRecord::Migration
  def change
    add_column :items, :is_deleted, :boolean, :default => false
  end
end
