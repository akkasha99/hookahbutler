class Sugar < ActiveRecord::Base
  validates_numericality_of :price, :greater_than => 0, :less_than => 1000000
  has_many :items
end
