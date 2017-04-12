class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.float :base_price
      t.integer :shop_id
      t.integer :category_id

      t.timestamps
    end
  end
end


