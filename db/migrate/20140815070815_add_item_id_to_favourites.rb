class AddItemIdToFavourites < ActiveRecord::Migration
  def change
    add_column :favourites, :item_id, :integer
  end
end
