class Shop < ActiveRecord::Base
  #attr_accessible :user_id, :name, :phone, :latitude, :longitude, :address
  belongs_to :user
  has_many :items
  has_many :favourites
  has_many :order_transactions


  has_many :shop_hours, -> { order 'created_at asc' }, :dependent => :destroy
  accepts_nested_attributes_for :shop_hours

  #has_one :asset, :as => :owner, :dependent => :destroy

  has_one :asset, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :asset, :allow_destroy => true

  has_many :reviews

  #has_many :orders
  has_many :orders, -> { order 'created_at desc' }, :dependent => :destroy

  has_many :add_ons

  has_many :shop_hours

  has_many :shop_sugars


  validates_presence_of :name, :phone, :address
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip_code

  geocoded_by :complete_address

  after_validation :geocode

  def complete_address
    "#{self.address}, #{self.city}, #{self.state}"
  end

  def user_rating(user, shop)
    review = Review.find_by_user_id_and_shop_id(user.id, shop.id)
    return review.blank? ? 0 : review.rating
  end

  def average_rating
    average_rate = 0
    reviews.each do |review|
      unless review.rating.blank?
        average_rate += review.rating
      end
    end
    if reviews.size > 0
      average_rate = average_rate / reviews.size
    end
    return average_rate
  end

  def self.top_rated_shops
    shops = []
    Shop.where("latitude is not NULL").all.each do |shop|
      puts "Top rated shops"
      if shop.user.status != 'inactive'
        shops << shop
      end
    end
    shops = shops.sort_by { |shop| shop.average_rating }.reverse
    return shops
  end

  def self.distance_shops(user, latitude, longitude)
    shops = {}
    shops_hash = {}
    Shop.where("latitude is not NULL").each do |shop|
      puts "Distance shops"
      if shop.user.status != 'inactive'
        distance = shop.distance_from([latitude, longitude])
        shops[shop.id] = distance.blank? ? 0 : distance.nan? ? 0 : distance.round(2)

        shops_hash[shop.id] = shop
      end
    end
    shops = shops.sort_by { |k, v| v }
    return shops, shops_hash
  end

  def shop_timings(shop)
    # shop.shop_hours.sort_by { |s| s.id }.map { |shop_hour| {:id => shop_hour.id, :name => shop_hour.name, :start_time => shop_hour.start_time.utc, :end_time => shop_hour.end_time.utc, :status => shop_hour.is_open} }
    shop.shop_hours.sort_by { |s| s.id }.map { |shop_hour| shop_hour.shop_daily_slots.sort_by { |slot| slot.id }.map { |slot|
      {:is_open => shop_hour.is_open, :id => slot.id,
       :start_time => slot.start_time.utc,
       :end_time => slot.end_time.utc,
       :name => slot.name, :day_id => slot.shop_hour_id}
    } }
  end

  def shop_distance(shop, latitude, longitude)
    distance = shop.distance_from([latitude, longitude])
    return distance.blank? ? 0 : distance
  end


  # def shop_status(shop, user_time)
  #   status = 0
  #   if shop.status == true
  #     time = Time.now.strftime("%A")
  #     time_obj = shop.shop_hours.where("lower(name) = ? and shop_id = ?", time.downcase, shop.id).first
  #     status= 1 if user_time.to_time >= (time_obj.start_time.strftime("%I:%M%p").to_time.utc) && user_time.to_time <= (time_obj.end_time.strftime("%I:%M%p").to_time.utc) # converted user_time to time and then compared
  #   else
  #     status = 0
  #   end
  #   return status
  # end

  def shop_status(shop, user_time)
    status = 0
    if shop.status == true
      time = Time.now.strftime("%A")
      time_obj = shop.shop_hours.where("lower(name) = ? and shop_id = ?", time.downcase, shop.id).first.shop_daily_slots
      time_obj.each do |slot|
        if user_time.to_time >= (slot.start_time.strftime("%I:%M%p").to_time.utc) && user_time.to_time <= (slot.end_time.strftime("%I:%M%p").to_time.utc) # converted user_time to time and then compared
          status = 1
        end
        if status == 1
          return status
        end
      end
    else
      status = 0
    end
    return status
  end

  #def shop_status(shop)
  #  status = 0
  #  if shop.status == true
  #  time = Time.now.strftime("%A")
  #  time_obj = shop.shop_hours.where("lower(name) = ? and shop_id = ?", time.downcase, shop.id).first
  #  if (Time.now.utc - 4.hour) >= (time_obj.start_time.strftime("%I:%M%p").to_time.utc) and (Time.now.utc - 4.hour) <= (time_obj.end_time.strftime("%I:%M%p").to_time.utc)
  #    status= 1
  #    puts "VVVV111", (Time.now.utc - 4.hour) >= (time_obj.start_time.strftime("%I:%M%p").to_time.utc)
  #    puts "VVVV22",  (Time.now.utc - 4.hour) <= (time_obj.end_time.strftime("%I:%M%p").to_time.utc)
  #  else
  #    puts "VVVV111", (Time.now.utc - 4.hour) >= (time_obj.start_time.strftime("%I:%M%p").to_time.utc)
  #    puts "VVVV22",  (Time.now.utc - 4.hour) <= (time_obj.end_time.strftime("%I:%M%p").to_time.utc)
  #  end
  #  puts "OOOOOOOOOOOO", Time.now.utc - 4.hour , time_obj.start_time.strftime("%I:%M%p").to_time.utc
  #  puts "OOOOOOOOOOOO", Time.now.utc - 4.hour, time_obj.end_time.strftime("%I:%M%p").to_time.utc
  #  else
  #    status = 0
  #  end
  #  return status
  #end

  def shop_json(shop)
    {
        :id => shop.id,
        :name => shop.name,
        :phone => shop.phone,
        :status => shop.status,
        :city => shop.city,
        :state => shop.state,
        :zip_code => shop.zip_code,
        :address => shop.address,
        :description => shop.description,
        :facebook_link => shop.facebook_link,
        :twitter_link => shop.twitter_link,
        :yelp_link => shop.yelp_link,
        :instagram_link => shop.instagram_link,
        :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:original),
        :picture_id => shop.asset.blank? ? nil : shop.asset.id,
        :logo_url => shop.user.asset.blank? ? nil : shop.user.asset.avatar.url(:thumb),
        :logo_id => shop.user.asset.blank? ? nil : shop.user.asset.id,
        :today_customer_count => Order.where("Date(created_at) = ? and shop_id= ?", Date.today, shop.id).all.group_by { |order| order.user_id }.size,
        :yesterday_customer_count => Order.where("Date(created_at) = ? and shop_id= ?", Date.today - 1.day, shop.id).all.group_by { |order| order.user_id }.size,
        :today_order_count => Order.where("Date(created_at) = ? and shop_id= ?", Date.today, shop.id).size,
        :yesterday_order_count => Order.where("Date(created_at) = ? and shop_id= ?", Date.today - 1.day, shop.id).size,
        :today_sale => Order.where("Date(created_at) = ? and status IN (?)  and shop_id= ?", Date.today, ['accepted', 'closed'], shop.id).sum('total_amount'),
        :yesterday_sale => Order.where("Date(created_at) = ? and status IN (?) and shop_id= ?", Date.today - 1.day, ['accepted','closed'], shop.id).sum('total_amount'),
        :shop_hours => shop.shop_timings(shop)
    }
  end

  def complete_address
    [name, address, city, state].compact.join(', ')
  end


end
