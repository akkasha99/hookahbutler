class CreateMetaCategories < ActiveRecord::Migration
  def change
    create_table :meta_categories do |t|
      t.string :name
      t.integer :parent_id
      t.integer :category_id
      t.string :parent_type

      t.timestamps
    end
  end
end
