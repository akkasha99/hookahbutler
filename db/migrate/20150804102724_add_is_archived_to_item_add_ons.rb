class AddIsArchivedToItemAddOns < ActiveRecord::Migration
  def change
    add_column :item_add_ons, :is_archived, :boolean, :default => false
  end
end
