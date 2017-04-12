class ItemAddOn < ActiveRecord::Base
  belongs_to :item
  belongs_to :item_size
  belongs_to :add_on
  has_many :order_add_ons
  validates_presence_of :add_on_id
  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  validates_format_of :add_on_id, :with => GREATOR_ZERO
end
