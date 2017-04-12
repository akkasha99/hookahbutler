class ShopHour < ActiveRecord::Base
  has_many :shop_daily_slots
  accepts_nested_attributes_for :shop_daily_slots
end
