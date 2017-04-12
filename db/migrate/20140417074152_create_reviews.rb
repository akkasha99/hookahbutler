class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.float :rating
      t.integer :shop_id
      t.integer :user_id

      t.timestamps
    end
  end
end
