class AddIsLikeToFavourites < ActiveRecord::Migration
  def change
    add_column :favourites, :is_like, :boolean, :default => false
  end
end
