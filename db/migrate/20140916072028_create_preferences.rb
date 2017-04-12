class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.float :tax_percentage

      t.timestamps
    end
  end
end
