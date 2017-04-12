class AddConveninceAndRewardToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :convenience_fee, :float
    add_column :orders, :reward_used, :float
  end
end
