class CreateSugars < ActiveRecord::Migration
  def change
    create_table :sugars do |t|
      t.string :name
      t.float :price
      t.boolean :is_deleted , :default => false

      t.timestamps
    end
  end
end
