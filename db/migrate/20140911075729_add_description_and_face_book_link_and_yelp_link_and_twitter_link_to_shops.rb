class AddDescriptionAndFaceBookLinkAndYelpLinkAndTwitterLinkToShops < ActiveRecord::Migration
  def change
    add_column :shops, :description, :text
    add_column :shops, :facebook_link, :string
    add_column :shops, :twitter_link, :string
    add_column :shops, :yelp_link, :string
  end
end
