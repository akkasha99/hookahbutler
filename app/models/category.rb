class Category < ActiveRecord::Base
  has_many :sub_categories, :as => :parent, :class_name => "Category", :dependent => :destroy
  validates :name, :presence => true
  belongs_to :parent, :polymorphic => true
  has_many :items
  has_many :add_ons

  has_many :meta_categories


  def get_category(c, shop, request)
    {:id => c.id,
     :name => c.name,
     :subcategories => c.sub_categories.map { |sc| sc.get_sub_category(sc) },
     :items => c.get_items(c.sub_categories, shop, request),
     :add_ons => c.get_add_ons(c.sub_categories, shop)
    }
  end

  def get_sub_category(sc)
    {:id => sc.id,
     :name => sc.name,
     :meta_categories => sc.meta_categories.map { |i| {:id => i.id, :name => i.name}}
    }
  end

  def get_items(sub_categories, shop, request)
    items = []
    sub_categories.each do |sub_category|
      puts "SSS", sub_category.inspect
      items += shop.items.includes(:category).select { |i| i.category.id == sub_category.id  and i.is_deleted == false}
    end
    unless items.blank?
      items = items.sort_by { |item| item.id }.reverse
    end
    items.map { |i| {:id => i.id,
                     :name => i.name,
                     :description => i.description,
                     :is_shot => i.is_shot,
                     :shot_price => i.shot_price,
                     :base_price => i.base_price,
                     :category_id => i.category_id,
                     :is_sugar => i.is_sugar,
                     :asset_id => i.asset.blank? ? nil : i.asset.id,
                     :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
                     :asset_original_url => i.asset.blank? ? nil : i.asset.avatar.url(:original),
                     :item_sizes => i.item_sizes.map { |is| {
                         :id => is.id, :size_id => is.size_id,
                         :price => is.price, :name => is.size.size
                     } },
                     :item_add_ons => i.item_add_ons.where(:is_archived =>false).map { |i_add_ons| {:id => i_add_ons.id, :add_on_id => i_add_ons.add_on_id, :item_id => i_add_ons.item.id, :name => i_add_ons.add_on.blank? ? nil : i_add_ons.add_on.name,:category_id => i_add_ons.add_on.blank? ? nil : i_add_ons.add_on.category_id,:cost_per_unit => i_add_ons.add_on.blank? ? nil : i_add_ons.add_on.cost_per_unit,:number_of_units => i_add_ons.add_on.blank? ? nil : i_add_ons.add_on.number_of_units} },
    } }
  end

  def get_add_ons(sub_categories, shop)
    add_ons = []
    add_ons += shop.add_ons
    sub_categories.each do |sub_category|
      #add_ons += shop.add_ons.includes(:category).select { |a| a.category.id == sub_category.id and a.is_deleted == false}

    end
    add_ons.map { |a| {:id => a.id,
                       :name => a.name,
                       :category_id => a.category_id,
                       :cost_per_unit => a.cost_per_unit,
                       :number_of_units => a.number_of_units,
                       :description => a.description
    } }
  end


end
