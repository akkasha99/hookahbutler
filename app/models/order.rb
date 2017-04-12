class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop
  has_many :order_line_items
  has_many :order_add_ons
  accepts_nested_attributes_for :order_line_items
  before_create :set_order_number
  has_one :order_transaction

  validates_presence_of :shop_id, :user_id#, :card_id ## card_id  is no more required because order can also be placed in cash.

  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  validates_format_of :shop_id, :with => GREATOR_ZERO
  validates_format_of :user_id, :with => GREATOR_ZERO

  has_many :CouponCodeUser
  has_one :promotion_code, :class_name => "CouponCode", :as => :promotion_code_user
  #belongs_to :item_size
  #belongs_to :item_add_on
  #has_many :order_add_ons


  def set_order_number
    self.order_number = Order.generate_order_number
  end

  def self.generate_order_number
    record = Object.new
    while record
      random = rand(999999999)
      record = where(:order_number => random.to_s).first
    end
    return random
  end

end
