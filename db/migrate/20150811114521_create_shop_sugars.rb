class CreateShopSugars < ActiveRecord::Migration
  def change
    create_table :shop_sugars do |t|
      t.integer :shop_id
      t.integer :sugar_id
      t.boolean :is_archived, :default =>false

      t.timestamps
    end
  end
end
