class OrderLineItem < ActiveRecord::Base
  belongs_to :sugar
  belongs_to :order
  has_many :order_add_ons, :dependent => :destroy
  belongs_to :item
  belongs_to :item_size
  accepts_nested_attributes_for :order_add_ons, :reject_if => proc { |a| a['item_add_on_id'].blank? }
  validates_presence_of :quantity
  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  #validates_format_of :item_size_id, :with => GREATOR_ZERO
  validates_format_of :quantity, :with => GREATOR_ZERO
end
