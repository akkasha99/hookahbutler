class Users::RegistrationsController < Devise::RegistrationsController

  skip_before_filter :verify_authenticity_token

  def change_password
    @user = current_user
    render :layout => false
  end


  def edit
    add_breadcrumb "#{current_user.role.humanize.upcase}", "/#{current_user.role}s"
    add_breadcrumb "ACCOUNT"
  end

  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
                             @user.update_with_password(sign_up_params)
                           else
                             # remove the virtual current_password attribute update_without_password
                             # doesn't know how to ignore it
                             params[:user].delete(:current_password)
                             @user.update_without_password(sign_up_params)
                           end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to super_admin_categories_path
      #redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end


  def new
    build_resource({})
    #respond_with self.resource

    render :layout => false
  end

  # all user sign up method (customer, merchant)
  def create
    if params[:role] == "merchant"
      create_merchant #creating merchant in this method  and sending response.
    elsif params[:role] == "customer"
      create_customer #creating customer in this method  and sending response.
    end
  end


  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    #user.email != params[:user][:email] ||
    #    params[:user][:password].present?
    params[:user][:password].present?
  end


  protected

  def seed_shop_hours(shop)
    start_time = Time.zone.parse("8:00 am").in_time_zone("UTC")
    end_time = Time.zone.parse("07:00 pm").in_time_zone("UTC")

    ShopHour.create!(:shop_id => shop.id, :name => 'MONDAY',
                     :start_time => start_time, :end_time => end_time, :status => true)
    ShopHour.create!(:shop_id => shop.id, :name => 'TUESDAY',
                     :start_time => start_time, :end_time => end_time, :status => true)
    ShopHour.create!(:shop_id => shop.id, :name => 'WEDNESDAY',
                     :start_time => start_time, :end_time => end_time, :status => true)
    ShopHour.create!(:shop_id => shop.id, :name => 'THURSDAY',
                     :start_time => start_time, :end_time => end_time, :status => true)
    ShopHour.create!(:shop_id => shop.id, :name => 'FRIDAY',
                     :start_time => start_time, :end_time => end_time, :status => true)
    ShopHour.create!(:shop_id => shop.id, :name => 'SATURDAY',
                     :start_time => start_time, :end_time => end_time, :status => true)
    ShopHour.create!(:shop_id => shop.id, :name => 'SUNDAY',
                     :start_time => start_time, :end_time => end_time, :status => false)
    puts "SSSSSSSSSSSSSSSOPPPPPPPPPPPPPPPPPPP"
  end

  def create_merchant
    build_resource(sign_up_params)
    resource.roles << Role.find_by_name("merchant")
    if resource.save
      UserMailer.welcome(resource).deliver
      @user = resource
      @shop = @user.shop
      seed_shop_hours(@shop)
      create_merchant_success_response #   protected method for success response
    else
      create_merchant_failure_response # if resource id not saved in any case response
    end
  end

  def create_merchant_success_response
    render :json => {:success => "true",
                     :data => {
                         :categories => Category.where(:parent_id => nil)
                                            .map { |c| c.get_category(c, @shop, request) },
                         :sizes => Size.all.map { |s| {:id => s.id, :name => s.size} },
                         :merchant => merchant_json,
                         :shop => @shop.shop_json(@shop)
                     }
           }
  end

  def create_merchant_failure_response
    error_string = ""
    resource.errors.full_messages.each do |msg| #Concatinating the error message into one string.
      error_string += msg
    end
    render :json => {:success => "false",
                     :message => "Something went wrong. Please try again later. #{error_string}"}
  end

  # def create_customer
  #   if (Date.today.strftime("%Y/%m/%day").to_date - params[:user][:date_of_birth].to_date).to_i/365 >= 18 #condition for under_age customer
  #     build_resource(sign_up_params)
  #     resource.roles << Role.find_by_name("customer")
  #     if params[:lat].present? and params[:long].present?
  #       @latitude = params[:lat]
  #       @longitude = params[:long]
  #       result = Braintree::Customer.create(
  #           :first_name => params[:user][:name],
  #           :email => params[:user][:email]
  #       )
  #       if result.success?
  #         braintree_create_success_response(result)
  #       else
  #         braintree_create_failure_response(result) #customer could not be created on braintree
  #       end
  #     else
  #       render :json => {:success => "false", :message => "lat, long missing"}
  #     end
  #   else
  #     render :json => {:success => "false", :message => "You should be 18+ for using this app."}
  #   end
  # end

  def create_customer
    if (Date.today.strftime("%Y/%m/%day").to_date - params[:user][:date_of_birth].to_date).to_i/365 >= 21 #condition for under_age customer
      build_resource(sign_up_params)
      resource.roles << Role.find_by_name("customer")
      if params[:lat].present? and params[:long].present?
        @latitude = params[:lat]
        @longitude = params[:long]
        begin
          result = Stripe::Customer.create(
              :description => "Customer for #{User.last.email}",
              :email => params[:user][:email],
          )
          stripe_create_success_response(result)
        rescue Stripe::StripeError => e
          stripe_create_failure_response(e)
        end
      else
        render :json => {:success => "false", :message => "lat, long missing"}
      end
    else
      render :json => {:success => "false", :message => "You should be 21+ for using this app."}
    end
  end

  #after customer successfully created on braintree
  # def braintree_create_success_response(result)
  #   resource.customer_id = result.customer.id
  #   if resource.save
  #     @user = resource
  #     if params[:device_type].blank?
  #       unless params[:registration_id].blank?
  #         @user.update_attributes(:registration_id => params[:registration_id],
  #                                 :device_type => nil)
  #         after_sign_in_data_customer
  #       else
  #         render :json => {:success => "false", :errors => "GCM id is missing"}
  #       end
  #     elsif params[:device_type] == 'iphone'
  #       iphone_create_response # if hit request from iphone
  #     end
  #   else
  #     resource_save_failure_response
  #   end
  # end

  def stripe_create_success_response(result)
    resource.customer_id = result.id
    resource.convenience_fee = Preferences.last.reward
    if resource.save
      @user = resource
      if params[:device_type].blank?
        unless params[:registration_id].blank?
          @user.update_attributes(:registration_id => params[:registration_id],
                                  :device_type => nil)
          after_sign_in_data_customer
        else
          render :json => {:success => "false", :errors => "GCM id is missing"}
        end
      elsif params[:device_type] == 'iphone'
        iphone_create_response # if hit request from iphone
      end
    else
      resource_save_failure_response
    end
  end

  #if customer is not created on braintree
  # def braintree_create_failure_response(result)
  #   codes = []
  #   result.errors.each { |a| codes << a.code }
  #   @user.errors.add("Braintree:", codes.join(","))
  #   error_string = ""
  #   resource.errors.full_messages.each do |msg|
  #     error_string += msg
  #   end
  #   render :json => {:success => "false",
  #                    :message => "Something went wrong. Please try again later. #{error_string}"}
  # end

  def stripe_create_failure_response(exception)
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAA", exception.inspect
    body = exception.json_body
    puts "Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", body.inspect
    err = body[:error]
    puts "wwwwwwwwwwwwwwwwwwwwwwwwwwwww", err.inspect
    @user.errors.add("", err[:message])
    error_string = ""
    resource.errors.full_messages.each do |msg|
      error_string += msg
    end
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", error_string.inspect
    render :json => {:success => "false",
                     :message => "Something went wrong. Please try again later. #{error_string}"}
  end

  # if resource is not saved successfully
  def resource_save_failure_response
    error_string = ""
    resource.errors.full_messages.each do |msg| #Concatinating error message into 1 string.
      error_string += msg
    end
    render :json => {:success => "false",
                     :message => "Something went wrong. Please try again later. #{error_string}"}
  end

  def iphone_create_response
    unless params[:device_id].blank?
      @user.update_attributes(:device_id => params[:device_id],
                              :device_type => params[:device_type])
      after_sign_in_data_customer
    else
      render :json => {:success => "false", :errors => "device_id is missing"}
    end
  end

  #def after_sign_in_data_customer
  #  favourite_shop_ids = @user.favourites.map { |favourite| favourite.shop.id if favourite.shop and not favourite.shop.latitude.blank? }
  #  shops = Shop.where("latitude is not NULL")
  #  @latitude = params[:lat]
  #  @longitude = params[:long]
  #  distance_shops, shops_hash = Shop.distance_shops(@user, @latitude, @longitude)
  #  render :json => {:success => "true",
  #                   :data => {
  #                       :customer => @user.customer_json,
  #                       :shops => shops.blank? ? [] : shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :hours => shop.hours, :status => shop.status, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
  #                       :favourite_shops => @user.favourite_shops.blank? ? [] : @user.favourite_shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :hours => shop.hours, :status => shop.status, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
  #                       :top_rated_shops => Shop.top_rated_shops.blank? ? [] : Shop.top_rated_shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :hours => shop.hours, :status => shop.status, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
  #                       :distance_shops => distance_shops.blank? ? [] : distance_shops.map { |key, val| {:distance => val, :id => shops_hash[key].id, :name => shops_hash[key].name, :phone => shops_hash[key].phone, :address => shops_hash[key].address, :latitude => shops_hash[key].latitude, :longitude => shops_hash[key].longitude, :hours => shops_hash[key].hours, :status => shops_hash[key].status, :reviews_count => shops_hash[key].reviews.size, :average_rating => shops_hash[key].average_rating, :is_favourite => favourite_shop_ids.include?(shops_hash[key].id) ? true : false, :shop_hours => shops_hash[key].shop_timings(shops_hash[key])} }
  #                   }
  #  }
  #end

  def after_sign_in_data_customer
    if params[:time].blank?
      params[:time] = Time.now.utc - 5.hour
    end
    favourite_shop_ids = @user.favourites.map { |favourite| favourite.shop.id if favourite.shop and favourite.item.blank? and not favourite.shop.latitude.blank? }
    #shops = Shop.where("latitude is not NULL")
    shops = Shop.includes(:user).where("users.status !=? and latitude is not NULL", 'inactive')
    distance_shops, shops_hash = Shop.distance_shops(@user, @latitude, @longitude)
    @customer = nil
    unless @user.customer_id.blank?
      @credit_cards = Stripe::Customer.retrieve(@user.customer_id).sources.all(:object => "card")
    end
    UserMailer.welcome(@user).deliver
    render :json => {:success => "true",
                     :data => {
                         :customer => @user.customer_json,
                         :shops => shops.blank? ? [] : shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :hours => shop.hours, :status => shop.status == true ? shop.shop_status(shop, params[:time]) == 1 ? true : false : false, :reviews_count => shop.reviews.size, :user_rating => shop.user_rating(@user, shop), :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop), :estimated_time => OrderTime.last.time, :description => shop.description, :facebook_link => shop.facebook_link, :twitter_link => shop.twitter_link, :yelp_link => shop.yelp_link, :instagram_link => shop.instagram_link, :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:original)} },
                         :favourite_shops => @user.favourite_shops.blank? ? [] : @user.favourite_shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:medium), :hours => shop.hours, :status => shop.status == true ? shop.shop_status(shop, params[:time]) == 1 ? true : false : false, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
                         :top_rated_shops => Shop.top_rated_shops.blank? ? [] : Shop.top_rated_shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:medium), :hours => shop.hours, :status => shop.status == true ? shop.shop_status(shop, params[:time]) == 1 ? true : false : false, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
                         :distance_shops => distance_shops.blank? ? [] : distance_shops.map { |key, val| {:distance => val, :id => shops_hash[key].id, :name => shops_hash[key].name, :phone => shops_hash[key].phone, :address => shops_hash[key].address, :latitude => shops_hash[key].latitude, :longitude => shops_hash[key].longitude, :picture_url => shops_hash[key].asset.blank? ? nil : shops_hash[key].asset.avatar.url(:medium), :hours => shops_hash[key].hours, :status => shops_hash[key].status == true ? shops_hash[key].shop_status(shops_hash[key], params[:time]) == 1 ? true : false : false, :reviews_count => shops_hash[key].reviews.size, :average_rating => shops_hash[key].average_rating, :is_favourite => favourite_shop_ids.include?(shops_hash[key].id) ? true : false, :shop_hours => shops_hash[key].shop_timings(shops_hash[key])} },
                         :credit_cards => @credit_cards.blank? ? [] : @credit_cards.map { |f| {:id => f.id, :number => f.last4, :label => @user.name,
                                                                                               :expiry_date => "#{f.exp_month}/#{f.exp_year}",
                                                                                               :postal_code => (f.address_zip.present? ? f.address_zip : ""), :card_type => f.brand} }
                     }
           }
  end

  def sign_up_params
    params.require(:user).permit(:registration_id, :customer_id, :name, :email, :password,
                                 :phone, :password_confirmation, :convenience_fee, :date_of_birth, # added phone and convenience_fee in strong params for customer
                                 :shop_attributes => [:id, :user_id, :name, :phone, :address])
  end

  def shop_json(shop)
    {
        :id => shop.id,
        :name => shop.name,
        :phone => shop.phone,
        :status => shop.status,
        :today_customer_count => 10,
        :yesterday_customer_count => 20,
        :today_order_count => 100,
        :yesterday_order_count => 200,
        :today_sale => 1000,
        :yesterday_sale => 500,
        :shop_hours => shop_hours(shop)
    }
  end

  def merchant_json
    {
        :token => @user.authentication_token,
        :id => @user.id,
        :email => @user.email,
        :name => @user.name
    }
  end

end
