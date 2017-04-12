class CreateShopDailySlots < ActiveRecord::Migration
  def change
    create_table :shop_daily_slots do |t|
      t.references :shop_hour, index: true
      t.string :name
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end
end
