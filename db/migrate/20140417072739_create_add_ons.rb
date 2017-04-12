class CreateAddOns < ActiveRecord::Migration
  def change
    create_table :add_ons do |t|
      t.integer :category_id
      t.string :name
      t.string :description
      t.float :cost_per_unit
      t.integer :number_of_units
      t.integer :shop_id
      t.timestamps
    end
  end
end
