class AddOn < ActiveRecord::Base
  belongs_to :category
  belongs_to :shop
  validates_presence_of :name, :cost_per_unit, :number_of_units, :shop_id, :category_id
  validates_uniqueness_of :name, scope: [:shop_id, :is_deleted]
  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  PRICE_REGEX = /\A[1-9][0-9]+\z/
  validates_format_of :category_id, :with => GREATOR_ZERO
  validates_format_of :shop_id, :with => GREATOR_ZERO
end
