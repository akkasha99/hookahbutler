class CreateCouponCodeUsers < ActiveRecord::Migration
  def change
    create_table :coupon_code_users do |t|
      t.integer :user_id
      t.integer :coupon_code_id
      t.integer :generated_by_user
      t.integer :consumer_id
      t.boolean :is_consumed, :default => false
      t.boolean :is_applied, :default => false
      t.boolean :is_send, :default => false

      t.timestamps
    end
  end
end
