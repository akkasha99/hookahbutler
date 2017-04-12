class AddInstagramLinkToShops < ActiveRecord::Migration
  def change
    add_column :shops, :instagram_link, :string
  end
end
