class AddIsSugarToItems < ActiveRecord::Migration
  def change
    add_column :items, :is_sugar, :boolean, :default => false
  end
end
