class CreateShopHours < ActiveRecord::Migration
  def change
    create_table :shop_hours do |t|
      t.integer :shop_id
      t.string :name
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end
end
