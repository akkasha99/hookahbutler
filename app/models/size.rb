class Size < ActiveRecord::Base
  has_many :item_sizes
  has_many :items, :through => :item_sizes
  validates_presence_of :size
end
