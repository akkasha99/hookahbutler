class MetaCategory < ActiveRecord::Base
  has_many :sub_meta_categories, :as => :parent, :class_name => "MetaCategory", :dependent => :destroy
  belongs_to :parent, :polymorphic => true
  validates :name, :presence => true
  validates :category_id, :presence => true

  belongs_to :category


end
