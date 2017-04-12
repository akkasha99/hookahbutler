class AddConvenienceAndrewardToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :convenience_fee, :float
    add_column :preferences, :reward, :float
  end
end
