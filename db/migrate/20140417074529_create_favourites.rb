class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.integer :shop_id
      t.integer :item_size_id
      t.integer :user_id

      t.timestamps
    end
  end
end
