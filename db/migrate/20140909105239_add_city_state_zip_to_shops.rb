class AddCityStateZipToShops < ActiveRecord::Migration
  def change
    add_column :shops, :city, :string
    add_column :shops, :state, :string
    add_column :shops, :zip_code, :string
    add_column :shops, :country, :string
  end
end
