class AddDescriptionToItems < ActiveRecord::Migration
  def change
    add_column :items, :description, :string
    add_column :items, :is_shot, :boolean, :default => false
    add_column :items, :shot_price, :float
  end
end
