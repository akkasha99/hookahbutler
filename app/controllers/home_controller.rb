class HomeController < ApplicationController
  layout "super_admin_non_login"

  #def index
  #
  #
  #  #Shop.all.each do |shop|
  #  #
  #  #  puts "CC", custom.user_id
  #  #end
  #
  #  #@user = User.find(3)
  #  #favourite_shop_ids = @user.favourites.map { |favourite| favourite.shop if favourite.shop }
  #  #render :json => {:success => "true",
  #  #                 :data => {
  #  #                     :customer => "s",
  #  #                     :shops => favourite_shop_ids.blank? ? [] : favourite_shop_ids.map { |shop| {:id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :hours => shop.hours, :status => shop.status, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false} }
  #  #                     #:favourite_shops => @user.favourites.map { |favourite| {:id => favourite.id, :shop_id => favourite.shop.id, :name => favourite.shop.name, :phone => favourite.shop.phone, :address => favourite.shop.address, :latitude => favourite.shop.latitude, :longitude => favourite.shop.longitude, :hours => favourite.shop.hours, :status => favourite.shop.status, :reviews_count => favourite.shop.reviews.size, :average_rating => favourite.shop.average_rating} if favourite.shop }
  #  #                 }
  #  #}
  #  #puts "CC", favourite_shop_ids.inspect
  #  #  ss
  #  if current_user.present?
  #    redirect_to super_admin_merchants_path
  #  end
  #end

  def index
    @user =User.new
    if current_user.present?
      redirect_to super_admin_merchants_path
    end
  end


end
