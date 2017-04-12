class Item < ActiveRecord::Base
  belongs_to :shop
  belongs_to :category
  has_many :item_sizes, :dependent => :destroy

  accepts_nested_attributes_for :item_sizes, allow_destroy: true
  has_many :item_add_ons
  # accepts_nested_attributes_for :item_add_ons
  has_many :sizes, :through => :item_sizes
  has_one :asset, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :asset, :allow_destroy => true
  validates_presence_of :name, :shop_id, :category_id ,:base_price
  validates_uniqueness_of :name, scope: [:shop_id, :is_deleted]
  # validates_presence_of :shot_price, :if => lambda { self.is_shot == true }
  #PRICE_REGEX = /\A[0-9]+\z/
  GREATOR_ZERO = /\A[1-9][0-9]*\z/
  validates_format_of :category_id, :with => GREATOR_ZERO
  validates_format_of :shop_id, :with => GREATOR_ZERO


  def item_add_ons_group_by(i)
    cat_json_array = []
    i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.each do |category, item_add_ons|
      category = category
      item_add_ons = item_add_ons.select{|iao| iao.is_archived == false}
      cat_json = {:id => category.id,
                  :name => category.name,
                  :item_add_ons => item_add_ons.blank? ? [] : item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }
      }
      cat_json_array << cat_json
    end
    return cat_json_array
  end

end
