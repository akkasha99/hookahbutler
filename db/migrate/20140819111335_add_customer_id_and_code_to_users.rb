class AddCustomerIdAndCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :customer_id, :string
    add_column :users, :code, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :address, :string
    add_column :users, :country, :string
    add_column :users, :phone, :string
    add_column :users, :date_of_birth, :datetime
    add_column :users, :zip, :string

  end
end
