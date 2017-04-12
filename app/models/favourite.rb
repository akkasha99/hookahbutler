class Favourite < ActiveRecord::Base
  belongs_to :shop
  belongs_to :user
  belongs_to :item_size
  belongs_to :item
end
