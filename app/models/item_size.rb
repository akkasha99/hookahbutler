class ItemSize < ActiveRecord::Base
  has_one :asset, :as => :owner, :dependent => :destroy
  belongs_to :item
  belongs_to :size
  # validates_presence_of :size_id, :price
  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  validates_format_of :size_id, :with => GREATOR_ZERO
end
