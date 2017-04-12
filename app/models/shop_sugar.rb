class ShopSugar < ActiveRecord::Base
  validates_presence_of :sugar_id, :shop_id
  belongs_to :sugar
end
