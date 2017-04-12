class OrderAddOn < ActiveRecord::Base
  belongs_to :item_add_on
  belongs_to :order
  belongs_to :order_line_item
  validates_presence_of :item_add_on_id
  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  validates_format_of :item_add_on_id, :with => GREATOR_ZERO

end
