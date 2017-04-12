class AddCashConvenienceToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :cash_convenience_fee, :float
  end
end
