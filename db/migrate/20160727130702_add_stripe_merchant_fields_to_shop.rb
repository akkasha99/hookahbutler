class AddStripeMerchantFieldsToShop < ActiveRecord::Migration
  def up
    add_column :shops, :bank_account_id, :string
    add_column :shops, :stripe_account_id, :string
  end

  def down
    remove_column :shops, :bank_account_id, :string
    remove_column :shops, :stripe_account_id, :string
  end
end
