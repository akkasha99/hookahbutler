require 'rubygems'
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")
task :seed_shop_hours do
  start_time = "8:00 am"
  end_time = "07:00 pm"
  Shop.all.each do |shop|
    if shop.shop_hours.blank?
      puts "Seeding Shop Hours"
      ShopHour.create!(:shop_id => shop.id, :name => 'MONDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
      ShopHour.create!(:shop_id => shop.id, :name => 'TUESDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
      ShopHour.create!(:shop_id => shop.id, :name => 'WEDNESDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
      ShopHour.create!(:shop_id => shop.id, :name => 'THURSDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
      ShopHour.create!(:shop_id => shop.id, :name => 'FRIDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
      ShopHour.create!(:shop_id => shop.id, :name => 'SATURDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
      ShopHour.create!(:shop_id => shop.id, :name => 'SUNDAY', :start_time => start_time, :end_time => end_time, :is_open => false)
    end
  end
end


