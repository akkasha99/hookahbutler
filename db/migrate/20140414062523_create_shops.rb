class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.integer :user_id
      t.string :name
      t.string :phone
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :hours

      t.timestamps
    end
  end
end
