class AddConvenienceFeeToUser < ActiveRecord::Migration
  def change
    add_column :users, :convenience_fee, :float
  end
end
