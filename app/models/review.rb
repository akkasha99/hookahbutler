class Review < ActiveRecord::Base
  belongs_to :shop
  belongs_to :user
  validates_presence_of :shop_id, :user_id, :rating
end
