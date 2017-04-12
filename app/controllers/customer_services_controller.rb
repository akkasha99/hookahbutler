class CustomerServicesController < ApplicationController
  #include ActionView::Helpers::DateHelper
  respond_to :json
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!
  before_filter :check_session_create, :except => [:sign_in, :forgot_password]
  before_filter :check_lat_long, :only => [:sign_in, :get_shop_distance_away]
  #before_filter :check_session_create, :except => [:sign_in]

  include ApplicationHelper

  def sign_in
    if params[:email].present? and params[:password].present?
      @user = User.find_by_email(params[:email])
      if @user.blank?
        render :json => {:success => "false", :errors => "failed sign in, user cannot be found."}
      else
        if @user.customer?
          if not @user.valid_password?(params[:password])
            render :json => {:success => "false", :errors => "Invalid email or password."}
          else
            if params[:device_type].blank?
              unless params[:registration_id].blank?
                @user.update_attributes(:registration_id => params[:registration_id], :device_type => nil)
                after_sign_in_data_customer
                return
              else
                render :json => {:success => "false", :errors => "registration_id missing"}
              end
            elsif params[:device_type] == 'iphone'
              unless params[:device_id].blank?
                @user.update_attributes(:device_id => params[:device_id], :device_type => params[:device_type])
                after_sign_in_data_customer
                return
              else
                render :json => {:success => "false", :errors => "device_id is missing"}
              end
            end
          end
        else
          render :json => {:success => "false", :errors => " User is not customer "}
        end
      end
    else
      render :json => {:success => "false", :errors => " email or password missing"}
    end
  end


  # def get_menu
  #   if params[:shop_id].present?
  #     @shop = Shop.find_by_id(params[:shop_id])
  #       cat_json_array = []
  #    cat_json_array_1 = []
  #     cat_json_array_2 = []
  #     @shop.items.group_by { |item| item.category }.each do |category, items|
  #       items = items.sort_by{|i| i.created_at}.reverse
  #       unless category.parent.id == 3
  #       puts "IIII", items.first.inspect
  #       category = items.first.category
  #       favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
  #       cat_json = {:id => category.id,
  #                   :name => category.name,
  #                   :cat_parent_name => category.parent.name,
  #                   :items => items.select{|ia| ia.is_deleted == false}.map { |i| {:id => i.id,
  #                                              :name => i.name,
  #                                              :description => i.description,
  #                                              :is_shot => i.is_shot,
  #                                              :shot_price => i.shot_price,
  #                                              :is_shot => i.is_shot,
  #                                              :shot_price => i.shot_price,
  #                                              :is_sugar => i.is_sugar,
  #                                              :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map{|shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name}},
  #                                              #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
  #                                              :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
  #                                              :base_price => i.base_price,
  #                                              :category_id => i.category_id,
  #                                              :asset_id => i.asset.blank? ? nil : i.asset.id,
  #                                              :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
  #                                              :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
  #                                              #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
  #                                              :item_all_add_ons => i.item_add_ons_group_by(i)
  #                   } }
  #       }
  #       cat_json_array << cat_json
  #       unless category.parent.id == 3
  #         if category.parent.id == 1
  #           if items.select{|ia| ia.is_deleted == false}.size > 0
  #           category = items.first.category
  #           favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
  #           cat_json = {:id => category.id,
  #                       :name => category.name,
  #                       :cat_parent_name => category.parent.name,
  #                       :items => items.select{|ia| ia.is_deleted == false}.map { |i| {:id => i.id,
  #                                                  :name => i.name,
  #                                                  :description => i.description,
  #                                                  :is_shot => i.is_shot,
  #                                                  :shot_price => i.shot_price,
  #                                                  :is_shot => i.is_shot,
  #                                                  :shot_price => i.shot_price,
  #                                                  :is_sugar => i.is_sugar,
  #                                                  #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
  #                                                  :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map{|shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name}},
  #                                                  :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
  #                                                  :base_price => i.base_price,
  #                                                  :category_id => i.category_id,
  #                                                  :asset_id => i.asset.blank? ? nil : i.asset.id,
  #                                                  :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
  #                                                  :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
  #                                                  #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
  #                                                  :item_all_add_ons => i.item_add_ons_group_by(i)
  #                       } }
  #           }
  #           cat_json_array_1 << cat_json
  #           end
  #         elsif category.parent.id == 2
  #           if items.select{|ia| ia.is_deleted == false}.size > 0
  #           category = items.first.category
  #           favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
  #           cat_json = {:id => category.id,
  #                       :name => category.name,
  #                       :cat_parent_name => category.parent.name,
  #                       :items => items.select{|ia| ia.is_deleted == false}.map { |i| {:id => i.id,
  #                                                  :name => i.name,
  #                                                  :description => i.description,
  #                                                  :is_shot => i.is_shot,
  #                                                  :shot_price => i.shot_price,
  #                                                  :is_shot => i.is_shot,
  #                                                  :shot_price => i.shot_price,
  #                                                  :is_sugar => i.is_sugar,
  #                                                  #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
  #                                                  :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map{|shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name}},
  #                                                  :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
  #                                                  :base_price => i.base_price,
  #                                                  :category_id => i.category_id,
  #                                                  :asset_id => i.asset.blank? ? nil : i.asset.id,
  #                                                  :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
  #                                                  :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
  #                                                  #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
  #                                                  :item_all_add_ons => i.item_add_ons_group_by(i)
  #                       } }
  #           }
  #           cat_json_array_2 << cat_json
  #             end
  #         end
  #       end
  #      end
  #     end
  #     cat_json_array_1 = cat_json_array_1.sort_by! { |x| x[:id] }
  #     cat_json_array_2 = cat_json_array_2.sort_by! { |x| x[:id] }
  #     render :json => {:success => "true",
  #                      :data => {
  #                          :drink => cat_json_array_1,
  #                          :food => cat_json_array_2
  #                      }
  #     }
  #   else
  #     render :json => {:success => "false", :errors => "params shop id is missing"}
  #   end
  # end

  def add_to_favourite_shop
    unless params[:shop_id].blank?
      @favourite = Favourite.find_by_shop_id_and_user_id_and_item_id(params[:shop_id], @user.id, nil)
      if @favourite.blank?
        Favourite.create!(:shop_id => params[:shop_id], :user_id => @user.id, :is_like => params[:is_like])
        render :json => {:success => "true", :is_like => params[:is_like], :message => "Favorite shop successfully added"}
      else
        @favourite.update_attribute(:is_like, params[:is_like])
        render :json => {:success => "true", :is_like => params[:is_like], :message => "Favorite successfully updated"}
      end
    else
      render :json => {:success => "false", :errors => "params shop_id is missing"}
    end
  end

  def save_rating
    unless params[:shop_id].blank? or params[:rating].blank?
      @review = Review.find_by_shop_id_and_user_id(params[:shop_id], @user.id)
      if @review.blank?
        Review.create!(:shop_id => params[:shop_id], :user_id => @user.id, :rating => params[:rating])
        render :json => {:success => "true", :rating => params[:rating], :message => "Rating successfully added"}
      else
        @review.update_attribute(:rating, params[:rating])
        render :json => {:success => "true", :rating => params[:rating], :message => "Rating successfully updated"}
      end
    else
      render :json => {:success => "false", :errors => "params shop_id is missing"}
    end
  end

  def add_to_favourite_item
    if params[:item_id].present? and params[:shop_id].present? and params[:item_id].present?
      @favourite = Favourite.find_by_shop_id_and_user_id_and_item_id(params[:shop_id], @user.id, params[:item_id])
      if @favourite.blank?
        if Favourite.create(:shop_id => params[:shop_id], :item_id => params[:item_id], :user_id => @user.id, :is_like => params[:is_like])
          render :json => {:success => "true", :message => "Favorite item successfully added"}
        else
          render :json => {:success => "false", :errors => "fail to save"}
        end
      else
        if @favourite.update_attribute(:is_like, params[:is_like])
          render :json => {:success => "true", :is_like => params[:is_like], :message => "Favorite successfully updated"}
        else
          render :json => {:success => "false", :errors => "fail to update"}
        end
      end
    else
      render :json => {:success => "false", :errors => "params shop_id is missing"}
    end
  end

  def add_to_favourite_shop
    unless params[:shop_id].blank?
      @favourite = Favourite.find_by_shop_id_and_user_id_and_item_id(params[:shop_id], @user.id, nil)
      if @favourite.blank?
        Favourite.create!(:shop_id => params[:shop_id], :user_id => @user.id, :is_like => params[:is_like])
        render :json => {:success => "true", :is_like => params[:is_like], :message => "Favorite shop successfully added"}
      else
        @favourite.update_attribute(:is_like, params[:is_like])
        render :json => {:success => "true", :is_like => params[:is_like], :message => "Favorite successfully updated"}
      end
    else
      render :json => {:success => "false", :errors => "params shop_id is missing"}
    end
  end

  def get_customer_favorite_shop_items
    unless params[:shop_id].blank?
      favourite_items = @user.get_customer_favorite_items(@user, params[:shop_id])
      render :json => {:success => "true",
                       :favourite_items => favourite_items.blank? ? [] : favourite_items.map { |i| {:id => i.id, :name => i.name, :base_price => i.base_price, :category_id => i.category_id, :parent_category_name => i.category.parent.name} }
             }
    else
      render :json => {:success => "false", :errors => "shop_id is missing"}
    end
  end

  # def add_card_to_customer
  #   unless @user.customer_id.blank?
  #     result = Braintree::CreditCard.create(
  #         :customer_id => @user.customer_id,
  #         :number => params[:credit_card][:card_number],
  #         :cvv => params[:credit_card][:cvv],
  #         :expiration_date => params[:credit_card][:expiration_date],
  #         :cardholder_name => params[:credit_card][:cardholder_name]
  #     )
  #     if result.success?
  #       unless check_existing_card(result.credit_card)
  #         return render :json => {:success => "false", :message => "Credit Card Already Exists to Your Account"}
  #       else
  #         return render :json => {:success => "true", :message => "User Updated", :credit_card => {:id => result.credit_card.id, :number => result.credit_card.masked_number, :label => result.credit_card.cardholder_name, :expiry_date => result.credit_card.expiration_date, :postal_code => (result.credit_card.billing_address.present? ? result.credit_card.billing_address.postal_code : ""), :card_type => result.credit_card.card_type}}
  #       end
  #     else
  #       msg ||= []
  #       result.errors.each { |error| msg << error.message }
  #       return render :json => {:success => "false", :message => "Card Not Added, #{msg.join("\n")}"}
  #     end
  #   else
  #     return render :json => {:success => "false", :message => "Customer don't have account on braintree"}
  #   end
  # end

  def add_card_to_customer
    # @user = User.last
    # params[:credit_card][:stripe_token] = "tok_18cCleExoJqF42CX77nyZ8oH"
    unless @user.customer_id.blank?
      customer = Stripe::Customer.retrieve(@user.customer_id)
      if check_existing_card(customer, params[:credit_card][:stripe_token])
        return render :json => {:success => "false", :message => "Credit Card Already Exists to Your Account.#{@stripe_error}"}
      else
        begin
          credit_card = customer.sources.create(:source => params[:credit_card][:stripe_token])
          return render :json => {:success => "true", :message => "User Updated", :credit_card => {:id => credit_card.id, :number => credit_card.last4, :label => @user.name, :expiry_date => "#{credit_card.exp_month}/#{credit_card.exp_year}", :postal_code => credit_card.address_zip.nil? ? "" : credit_card.address_zip, :card_type => credit_card.brand}}
        rescue Stripe::CardError => e
          body = e.json_body
          err = body[:error]
          return render :json => {:success => "false", :message => "Card Not Added, #{err[:message]}"}
        end
      end
    else
      return render :json => {:success => "false", :message => "Customer don't have account on stripe."}
    end
  end

  def get_charges_ratios
    preferences = Preferences.last
    user = User.find(params[:user_id])
    if user.present?
      if preferences.present?
        render :json => {:success => "true", :tax_ratio => preferences.tax_percentage, :convenience_ratio => preferences.convenience_fee, :cash_convenience_fee => preferences.cash_convenience_fee, :user_current_reward => user.convenience_fee}
      else
        render :json => {:success => "false", :message => 'These values are not yet available.'}
      end
    else
      render :json => {:success => "false", :message => 'This user is no more available.'}
    end
  end

  def save_order
    puts "CCC", params.inspect
    @order = Order.new(order_params)
    @order.status = 'open'
    if @order.save
      if @order.order_line_items.present?
        @order.order_line_items.each do |order_line_item|
          if order_line_item.item_size.present?
            order_line_item.update_attributes(:price => order_line_item.item_size.price, :total_price => order_line_item.item_size.price * order_line_item.quantity, :shot_price => order_line_item.item_size.item.shot_price.blank? ? nil : order_line_item.item_size.item.shot_price, :shot_total_price => order_line_item.no_of_shots.blank? ? nil : order_line_item.no_of_shots * order_line_item.item_size.item.shot_price)
            if order_line_item.order_add_ons.present?
              order_line_item.order_add_ons.each do |order_add_on|
                order_add_on.update_attributes(:order_id => @order.id, :price => order_add_on.item_add_on.add_on.cost_per_unit, :total_price => order_add_on.item_add_on.add_on.cost_per_unit * order_add_on.quantity)
              end
            end
          else
            order_line_item.update_attributes(:price => order_line_item.item.base_price, :total_price => order_line_item.item.base_price * order_line_item.quantity, :shot_price => nil, :shot_total_price => nil)
            if order_line_item.order_add_ons.present?
              order_line_item.order_add_ons.each do |order_add_on|
                order_add_on.update_attributes(:order_id => @order.id, :price => order_add_on.item_add_on.add_on.cost_per_unit, :total_price => order_add_on.item_add_on.add_on.cost_per_unit * order_add_on.quantity)
              end
            end
          end
        end
      end
      @order = Order.find_by_id(@order.id)
      line_item_price = @order.order_line_items.blank? ? 0 : @order.order_line_items.where("order_line_items.total_price is not null").sum(&:total_price)
      add_ons_price = @order.order_add_ons.blank? ? 0 : @order.order_add_ons.sum(&:total_price)
      shot_price = @order.order_line_items.blank? ? 0 : @order.order_line_items.where("order_line_items.shot_total_price is not null").sum(&:shot_total_price)
      sugar_price = @order.order_line_items.blank? ? 0 : @order.order_line_items.where("order_line_items.sugar_total_price is not null").sum(&:sugar_total_price)
      final_amount = (line_item_price + add_ons_price + shot_price + sugar_price) > 0 ? (line_item_price + add_ons_price + shot_price + sugar_price) : 0
      # convenience_fee = final_amount/100 * Preferences.last.convenience_fee
      # user_reward = User.find(params[:user_id]).convenience_fee
      # remaining_con_fee = user_reward  - convenience_fee
      # final_amount = final_amount + convenience_fee
      # order_tax = final_amount/100 * Preferences.last.tax_percentage
      # if @order.is_expressOrder
      #   final_amount = final_amount + 10
      # end
      @order.update_attributes(:total_amount => params[:final_amount], :tax => params[:tax], :convenience_fee => params[:convenience_fee], :reward_used => params[:reward_fee])
      @order.user.update_attributes(:convenience_fee => params[:remaining_reward])
      puts "SSSS", @order.shop.inspect
      merchant = @order.shop.user
      puts "MM", merchant.inspect
      puts "GGG", merchant.registration_id.inspect
      puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", merchant.device_id.inspect
      unless merchant.device_id.blank?
        orders = Order.where(:is_new => true, :shop_id => @order.shop.id).order("id asc")
        puts "OOOOOOOOO", orders.size
        start_time = nil
        end_time = nil
        if orders.size > 1
          start_time = orders.first.created_at
          end_time = orders.last.created_at
          order_count = orders.size
        else
          order_count = 1
          start_time = @order.created_at
        end
        if params[:device_type].blank?
          send_order_push_notification(@order, merchant.registration_id, start_time, end_time, order_count)
          send_order_push_notification_ios(@order, merchant.device_id, start_time, end_time, order_count)
        elsif params[:device_type] == 'iphone'
          send_order_push_notification(@order, merchant.registration_id, start_time, end_time, order_count)
          send_order_push_notification_ios(@order, merchant.device_id, start_time, end_time, order_count)
        end
      end
      return render :json => {:success => "true", :message => "Order successfully saved"}
    else
      @errors = @order.errors
      puts "EE", @errors.inspect
      error_string = ""
      @order.errors.full_messages.each do |msg|
        error_string += msg
      end
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  def order_again
    @order = Order.find_by_id(@order.id)
    @new_order = Order.new()
    @new_order.shop_id = @order.shop_id
    @new_order.user_id = @order.user_id
    @new_order.user_id = @order.user_id
    @new_order.status = 'open'
    @new_order.total_amount = @order.total_amount
    @new_order.card_id = @order.card_id
    @new_order.is_new = @order.is_new
    unless @order.order_line_items.blank?
      order_line_items.each do |order_line_item|
        @order_line_item = OrderLineItem.new(:item_size_id => order_line_item.item_size_id, :price => order_line_item.price, :quantity => order_line_item.quantity, :total_price => order_line_item.total_price)
        unless order_line_item.order_add_ons.blank?
          order_line_item.order_add_ons.each do |order_add_on|
            @order_line_item.order_add_ons << OrderAddOn.new(:item_add_on_id => order_add_on.item_add_on_id, :quantity => order_add_on.quantity, :price => order_add_on.price, :total_price => order_add_on.total_price)
          end
        end
        @new_order.order_line_items << @order_line_item
      end
    end
    if @new_order.save
      merchant = @order.shop.user
      unless merchant.registration_id.blank?
        orders = Order.where(:is_new => true).order("id asc")
        start_time = nil
        end_time = nil
        if orders.size > 1
          start_time = orders.first.created_at
          end_time = orders.last.created_at
          order_count = orders.size
        else
          order_count = 1
          start_time = @order.created_at
        end
        send_order_push_notification(@order, merchant.registration_id, start_time, end_time, order_count)
      end
      return render :json => {:success => "true", :message => "Order successfully saved"}
    else
      @errors = @order.errors
      error_string = ""
      @order.errors.full_messages.each do |msg|
        error_string += msg
      end
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  # def update_card_info
  #   unless @user.customer_id.blank?
  #     result = Braintree::CreditCard.update(
  #         params[:credit_card][:token],
  #         :cvv => params[:credit_card][:cvv],
  #         :number => params[:credit_card][:card_number],
  #         :expiration_date => params[:credit_card][:expiration_date],
  #         :cardholder_name => params[:credit_card][:cardholder_name]
  #     )
  #     if result.success?
  #       return render :json => {:success => "true", :message => "User Updated", :credit_card => {:id => result.credit_card.id, :number => result.credit_card.masked_number, :label => result.credit_card.cardholder_name, :expiry_date => result.credit_card.expiration_date, :postal_code => (result.credit_card.billing_address.present? ? result.credit_card.billing_address.postal_code : ""), :card_type => result.credit_card.card_type}}
  #     else
  #       return render :json => {:success => "false", :message => "Not Updated"}
  #     end
  #   else
  #     return render :json => {:success => "false", :message => "Customer don't have account on braintree"}
  #   end
  # end

  def update_card_info
    unless @user.customer_id.blank?
      begin
        customer = Stripe::Customer.retrieve(@user.customer_id)
        card = customer.sources.retrieve(params[:credit_card][:token]) # params[:credit_card][:token] is credit card token sent in after_sign_in_data_customer as credit card id
        card.name = params[:credit_card][:cardholder_name]
        card.save
        return render :json => {:success => "true", :message => "User Updated", :credit_card => {:id => card.id, :number => card.last4, :label => card.name, :expiry_date => "#{card.exp_month}/#{card.exp_year}", :postal_code => (card.address_zip.present? ? card.address_zip : ""), :card_type => card.brand}}
      rescue Stripe::StripeError => e
        body = e.json_body
        err = body[:error]
        return render :json => {:success => "false", :message => "Not Updated. #{err}"}
      end
    else
      return render :json => {:success => "false", :message => "Customer don't have account on stripe."}
    end
  end

  def update_customer
    puts "CCC", params.inspect
    successfully_updated = if needs_password?(@user, params)
                             puts "CCCii"
                             @user.update(customer_params)
                           else
                             params[:user].delete(:password)
                             @user.update_without_password(customer_params)
                           end

    puts "CCCC", successfully_updated.inspect

    if successfully_updated
      render :json => {:success => "true", :picture_url => @user.asset.blank? ? nil : @user.asset.avatar.url(:original), :message => "Customer was updated"}
    else
      error_string = ""
      @user.errors.full_messages.each do |msg|
        error_string += msg
      end
      puts "CCC", @user.errors.inspect
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  def forgot_password
    @user = User.find_by_email(params[:user][:email])
    unless @user.blank?
      @user = User.send_reset_password_instructions(params[:user])
      render :json => {:success => "true", :message => "email successfully send"}
    else
      render :json => {:success => "false", :message => "Invalid email"}
    end
  end

  def order_detail
    @order = Order.find_by_id(params[:id])
    shop = @order.shop
    result = nil
    unless @order.card_id.blank?
      # result = Braintree::CreditCard.find(@order.card_id)
      customer = Stripe::Customer.retrieve(@order.user.customer_id)
      card = customer.sources.retrieve(@order.card_id)
    end
    puts "CC", result.inspect
    unless @order.blank?
      render :json => {:success => "true",
                       :data => {
                           :shop => {:id => shop.id, :latitude => shop.latitude, :longitude => shop.longitude, :address => shop.address, :city => shop.city, :state => shop.state, :zip_code => shop.zip_code, :estimated_time => OrderTime.last.time},
                           :order => {:id => @order.id, :shop_name => @order.shop.name, :order_number => @order.order_number, :status => @order.status, :total_amount => @order.total_amount, :created_at => @order.created_at, :estimated_time => @order.estimated_time, :completed_time => @order.completed_time.blank? ? nil : @order.completed_time.strftime("%I:%M %p"), :tax => @order.tax, :convenience_fee => @order.convenience_fee, :reward_used => @order.reward_used, :is_express => @order.is_expressOrder},
                           #:order_line_items1 => @order.order_line_items.blank? ? [] : @order.order_line_items.map { |order_line_item| puts 'GGG',  order_line_item.item_size.inspect  },
                           :order_line_items => @order.order_line_items.blank? ? [] : @order.order_line_items.map { |order_line_item| {:id => order_line_item.id, :category_id => order_line_item.item.blank? ? order_line_item.item_size.item.category.id : order_line_item.item.category.id, :item_size_id => order_line_item.item_size_id, :item_name => order_line_item.item.blank? ? order_line_item.item_size.item.name : order_line_item.item.name, :item_id => order_line_item.item.blank? ? order_line_item.item_size.item_id : order_line_item.item_id, :item_description => order_line_item.item.blank? ? order_line_item.item_size.item.description : order_line_item.item.description, :price => order_line_item.price, :total_price => order_line_item.total_price, :size => order_line_item.item.blank? ? order_line_item.item_size.size.size : nil, :quantity => order_line_item.quantity, :total => ((order_line_item.item.blank? ? order_line_item.item_size.price : order_line_item.item.base_price) * order_line_item.quantity).round(2), :no_of_shots => order_line_item.no_of_shots, :shot_price => order_line_item.shot_price, :sugar_name => order_line_item.sugar.blank? ? nil : order_line_item.sugar.name, :sugar_quantity => order_line_item.sugar_quantity, :sugar_id => order_line_item.sugar_id, :order_add_ons => order_line_item.order_add_ons.blank? ? [] : order_line_item.order_add_ons.map { |order_add_on| {:id => order_add_on.id, :item_add_on_id => order_add_on.item_add_on_id, :order_line_item_id => order_add_on.order_line_item_id, :quantity => order_add_on.quantity, :price => order_add_on.price, :total_price => order_add_on.total_price, :name => order_add_on.item_add_on.add_on.name} }} },
                           :credit_card => card.blank? ? nil : {:id => card.id, :number => card.last4, :label => card.name, :expiry_date => "#{card.exp_month}/#{card.exp_year}", :postal_code => (card.address_zip.present? ? card.address_zip : ""), :card_type => card.brand}
                       }}
    else
      return render :json => {:success => "false", :message => "Order not found"}
    end
  end

  def all_order_detail
    @orders = @user.orders
    render :json => {:success => "true",
                     :data => {
                         :orders => @orders.blank? ? [] : @orders.map { |order| {:id => order.id, :name => order.shop.name, :order_number => order.order_number, :status => order.status, :total_amount => order.total_amount, :created_at => order.created_at, :picture_url => order.shop.asset.blank? ? nil : order.shop.asset.avatar.url(:thumb), :convenience_fee => order.convenience_fee, :reward_used => order.reward_used, :is_express => order.is_expressOrder} }
                     }}

  end

  def support_request
    unless params[:description].blank?
      UserMailer.support_request(params[:description], @user, request.host_with_port, request.protocol)
      render :json => {:success => "true", :message => "Support request successfully sent"}
    else
      render :json => {:success => "false", :message => "Support request not sent"}
    end
  end

  # def get_shop_status
  #   puts "OOOOOOONNNNN", Time.now.utc - 7.hour
  #   if params[:time].blank?
  #     params[:time] = Time.now.utc - 7.hour
  #   end
  #   @shop = Shop.find_by_id(params[:id])
  #   unless @shop.blank?
  #     #puts "OOOOOOOOOOOOsss", @shop.shop_status(@shop)
  #     #puts "OOOOOOOOOOOOssssss", @shop.status
  #     status = false
  #     if @shop.status == true
  #       if @shop.shop_status(@shop, params[:time]) == 1
  #         puts "IIII"
  #         status = true
  #       end
  #     end
  #     render :json => {:success => "true", :status => status}
  #   else
  #     render :json => {:success => "false"}
  #   end
  # end


  # get_shop_status + get_menu services
  def get_shop_status
    if params[:time].blank?
      params[:time] = Time.now.utc - 7.hour
    end
    @shop = Shop.find_by_id(params[:shop_id])
    unless @shop.blank?
      status = false
      if @shop.status == true
        if @shop.shop_status(@shop, params[:time]) == 1
          status = true
        end
      end
      cat_json_array = []
      cat_json_array_1 = []
      cat_json_array_2 = []
      cat_json_array_3 = []
      @shop.items.group_by { |item| item.category }.each do |category, items|
        items = items.sort_by { |i| i.created_at }.reverse
        # unless category.parent.id == 3
        puts "IIII", items.first.inspect
        category = items.first.category
        favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
        cat_json = {:id => category.id,
                    :name => category.name,
                    :cat_parent_name => category.parent.name,
                    :items => items.select { |ia| ia.is_deleted == false }.map { |i| {
                        :id => i.id,
                        :name => i.name,
                        :description => i.description,
                        :is_shot => i.is_shot,
                        :shot_price => i.shot_price,
                        :is_shot => i.is_shot,
                        :shot_price => i.shot_price,
                        :is_sugar => i.is_sugar,
                        :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map { |shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name} },
                        #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
                        :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
                        :base_price => i.base_price,
                        :category_id => i.category_id,
                        :asset_id => i.asset.blank? ? nil : i.asset.id,
                        :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
                        :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
                        #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
                        :item_all_add_ons => i.item_add_ons_group_by(i)
                    } }
        }
        cat_json_array << cat_json
        # unless category.parent.id == 3
        if category.parent.id == 1
          if items.select { |ia| ia.is_deleted == false }.size > 0
            category = items.first.category
            favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
            cat_json = {:id => category.id,
                        :name => category.name,
                        :cat_parent_name => category.parent.name,
                        :items => items.select { |ia| ia.is_deleted == false }.map { |i| {
                            :id => i.id,
                            :name => i.name,
                            :description => i.description,
                            :is_shot => i.is_shot,
                            :shot_price => i.shot_price,
                            :is_shot => i.is_shot,
                            :shot_price => i.shot_price,
                            :is_sugar => i.is_sugar,
                            #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
                            :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map { |shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name} },
                            :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
                            :base_price => i.base_price,
                            :category_id => i.category_id,
                            :asset_id => i.asset.blank? ? nil : i.asset.id,
                            :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
                            :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
                            #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
                            :item_all_add_ons => i.item_add_ons_group_by(i)
                        } }
            }
            cat_json_array_1 << cat_json
          end
        elsif category.parent.id == 2
          if items.select { |ia| ia.is_deleted == false }.size > 0
            category = items.first.category
            favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
            cat_json = {:id => category.id,
                        :name => category.name,
                        :cat_parent_name => category.parent.name,
                        :items => items.select { |ia| ia.is_deleted == false }.map { |i| {
                            :id => i.id,
                            :name => i.name,
                            :description => i.description,
                            :is_shot => i.is_shot,
                            :shot_price => i.shot_price,
                            :is_shot => i.is_shot,
                            :shot_price => i.shot_price,
                            :is_sugar => i.is_sugar,
                            #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
                            :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map { |shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name} },
                            :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
                            :base_price => i.base_price,
                            :category_id => i.category_id,
                            :asset_id => i.asset.blank? ? nil : i.asset.id,
                            :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
                            :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
                            #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
                            :item_all_add_ons => i.item_add_ons_group_by(i)
                        } }
            }
            cat_json_array_2 << cat_json
          end
        elsif category.parent.id == 3
          if items.select { |ia| ia.is_deleted == false }.size > 0
            category = items.first.category
            favourite_item_ids = @user.favourites.map { |favourite| favourite.item_id if favourite.item and favourite.is_like == true }
            cat_json = {:id => category.id,
                        :name => category.name,
                        :cat_parent_name => category.parent.name,
                        :items => items.select { |ia| ia.is_deleted == false }.map { |i| {
                            :id => i.id,
                            :name => i.name,
                            :description => i.description,
                            :is_shot => i.is_shot,
                            :shot_price => i.shot_price,
                            :is_shot => i.is_shot,
                            :shot_price => i.shot_price,
                            :is_sugar => i.is_sugar,
                            #:sugars => Sugar.all.blank? ? [] : Sugar.all.map{|sugar| {:id => sugar.id, :name => sugar.name}},
                            :sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @shop.shop_sugars.where(:is_archived => false).all.map { |shop_sugar| {:id => shop_sugar.sugar_id, :name => shop_sugar.sugar.name} },
                            :is_favourite => favourite_item_ids.include?(i.id) ? true : false,
                            :base_price => i.base_price,
                            :category_id => i.category_id,
                            :asset_id => i.asset.blank? ? nil : i.asset.id,
                            :asset_url => i.asset.blank? ? nil : i.asset.avatar.url(:thumb),
                            :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} },
                            #:item_add_ons => i.item_add_ons.group_by { |item_add_on| item_add_on.add_on.category }.map { |group, item_add_ons| {group.name.to_sym => item_add_ons.map { |i_add_on| {:id => i_add_on.id, :add_on_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.id, :name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.name, :number_of_units => i_add_on.add_on.blank? ? nil : i_add_on.add_on.number_of_units, :cost_per_unit => i_add_on.add_on.blank? ? nil : i_add_on.add_on.cost_per_unit, :category_id => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category_id, :category_name => i_add_on.add_on.blank? ? nil : i_add_on.add_on.category.name} }} }
                            :item_all_add_ons => i.item_add_ons_group_by(i)
                        } }
            }
            cat_json_array_3 << cat_json
          end
        end
        # end
        # end
      end
      cat_json_array_1 = cat_json_array_1.sort_by! { |x| x[:id] }
      cat_json_array_2 = cat_json_array_2.sort_by! { |x| x[:id] }
      cat_json_array_3 = cat_json_array_3.sort_by! { |x| x[:id] }
      render :json => {:success => "true",
                       :data => {
                           :hookah => cat_json_array_1,
                           :refill => cat_json_array_2,
                           :charcoal => cat_json_array_3
                       }, :status => status
             }
    else
      render :json => {:success => "false"}
    end
  end

  def get_shop_distance_away
    shop =Shop.find_by_id(params[:id])
    begin
      @xml = Net::HTTP.get(URI.parse("http://maps.googleapis.com/maps/api/directions/xml?origin=#{@latitude},#{@longitude}&destination=#{shop.latitude},#{shop.longitude}&sensor=false"))
      @result = Hash.from_xml(@xml)
      time = @result.present? ? @result["DirectionsResponse"]["route"]["leg"]["duration"]["text"] : "0"
    rescue Exception => exc
      time = distance = ""
    end
    render :json => {:success => "true", :distance_away => time}
  end

  def get_shop_hours
    if params[:shop_id].present?
      shop = Shop.find(params[:shop_id])
      render :json => {:success => "true", :shop_hours => shop.shop_timings(shop)}
    else
      render :json => {:success => "false", :message => "Shop id is null."}
    end
  end


  def after_sign_in_data_customer
    if params[:time].blank?
      params[:time] = Time.now.utc - 5.hour
    end
    favourite_shop_ids = @user.favourites.where(:is_like => true).map { |favourite| favourite.shop.id if favourite.shop and favourite.item.blank? and not favourite.shop.latitude.blank? }
    #shops = Shop.where("latitude is not NULL")
    shops = Shop.includes(:user).where("users.status !=? and latitude is not NULL", 'inactive')
    distance_shops, shops_hash = Shop.distance_shops(@user, @latitude, @longitude)
    @customer = nil
    unless @user.customer_id.blank?
      @credit_cards = Stripe::Customer.retrieve(@user.customer_id).sources.all(:object => "card")
    end
    render :json => {:success => "true",
                     :data => {
                         :customer => @user.customer_json,
                         :shops => shops.blank? ? [] : shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :hours => shop.hours, :status => shop.status == true ? shop.shop_status(shop, params[:time]) == 1 ? true : false : false, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :user_rating => shop.user_rating(@user, shop), :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop), :estimated_time => OrderTime.last.time, :description => shop.description, :facebook_link => shop.facebook_link, :twitter_link => shop.twitter_link, :yelp_link => shop.yelp_link, :instagram_link => shop.instagram_link, :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:medium)} },
                         :favourite_shops => @user.favourite_shops.blank? ? [] : @user.favourite_shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:medium), :hours => shop.hours, :status => shop.status == true ? shop.shop_status(shop, params[:time]) == 1 ? true : false : false, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
                         :top_rated_shops => Shop.top_rated_shops.blank? ? [] : Shop.top_rated_shops.map { |shop| {:distance => shop.shop_distance(shop, @latitude, @longitude), :id => shop.id, :name => shop.name, :phone => shop.phone, :address => shop.address, :latitude => shop.latitude, :longitude => shop.longitude, :picture_url => shop.asset.blank? ? nil : shop.asset.avatar.url(:medium), :hours => shop.hours, :status => shop.status == true ? shop.shop_status(shop, params[:time]) == 1 ? true : false : false, :reviews_count => shop.reviews.size, :average_rating => shop.average_rating, :is_favourite => favourite_shop_ids.include?(shop.id) ? true : false, :shop_hours => shop.shop_timings(shop)} },
                         :distance_shops => distance_shops.blank? ? [] : distance_shops.map { |key, val| {:distance => val, :id => shops_hash[key].id, :name => shops_hash[key].name, :phone => shops_hash[key].phone, :address => shops_hash[key].address, :latitude => shops_hash[key].latitude, :longitude => shops_hash[key].longitude, :picture_url => shops_hash[key].asset.blank? ? nil : shops_hash[key].asset.avatar.url(:medium), :hours => shops_hash[key].hours, :status => shops_hash[key].status == true ? shops_hash[key].shop_status(shops_hash[key], params[:time]) == 1 ? true : false : false, :reviews_count => shops_hash[key].reviews.size, :average_rating => shops_hash[key].average_rating, :is_favourite => favourite_shop_ids.include?(shops_hash[key].id) ? true : false, :shop_hours => shops_hash[key].shop_timings(shops_hash[key])} },
                         :credit_cards => @credit_cards.blank? ? [] : @credit_cards.map { |f| {:id => f.id, :number => f.last4, :label => @user.name,
                                                                                               :expiry_date => "#{f.exp_month}/#{f.exp_year}",
                                                                                               :postal_code => (f.address_zip.present? ? f.address_zip : ""), :card_type => f.brand} }
                     }
           }
  end


  def get_customer_category(c, shop, request)
    {:id => c.id,
     :name => c.name,
     :subcategories => c.sub_categories.map { |sc| sc.get_sub_category(sc) },
     :items => c.get_items(c.sub_categories, shop, request),
     :add_ons => c.get_add_ons(c.sub_categories, shop)
    }
  end


  def needs_password?(user, params)
    params[:user][:password].present?
  end

  def check_session_create
    if params[:token].present?
      @user = User.find_by_authentication_token(params[:token])
      render :json => {:success => "false", :errors => " authentication failed "} unless @user.present?
    else
      render :json => {:success => "false", :errors => " authentication failed "}
    end
  end

  def check_lat_long
    if params[:lat].present? && params[:long].present?
      @latitude = params[:lat]
      @longitude = params[:long]
    else
      render :json => {:success => "false", :errors => "Please Enable location services"}
    end
  end

  # def check_existing_card(card)
  #   customer = Braintree::Customer.find(@user.customer_id)
  #   sel = Braintree::Customer.find(@user.customer_id).credit_cards.select { |cc| cc.unique_number_identifier == card.unique_number_identifier }
  #   customer.credit_cards.each do |a|
  #   end
  #   if sel.size> 1
  #     res = Braintree::CreditCard.delete(card.token)
  #     return false
  #   else
  #     return true
  #   end
  # end

  def check_existing_card(customer, stripe_card_token)
    begin
      card_fingerprint = Stripe::Token.retrieve(stripe_card_token).try(:card).try(:fingerprint)
      default_card = customer.sources.all(:object => "card").data.select { |card| card.fingerprint == card_fingerprint }.last if card_fingerprint
      if default_card
        return true
      else
        return false
      end
    rescue Stripe::StripeError => e
      @stripe_error = e.message
      return true
    end
  end

  def order_params
    params.require(:order).permit(:id, :shop_id, :user_id, :card_id, :order_number, :status, :total_amount, :table_number, :is_expressOrder, :order_line_items_attributes => [:id, :order_id, :item_id, :item_size_id, :price, :quantity, :no_of_shots, :sugar_id, :sugar_quantity, :order_add_ons_attributes => [:id, :quantity, :item_add_on_id, :order_line_item_id, :quantity]])
  end

  def send_order_push_notification(order, registration_id, start_time, end_time, order_count)
    today_customer_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).all.group_by { |order| order.user_id }.size
    today_order_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).size
    today_sale = Order.where("Date(created_at) = ? and status= ? and shop_id= ?", Date.today, 'accepted', order.shop.id).sum('total_amount')
    destination = [registration_id]
    puts "PPPPP0", destination.inspect
    data = {:order_id => order.id, :customer_name => @user.full_name, :start_time => start_time.to_s, :end_time => end_time.to_s, :order_count => order_count, :today_customer_count => today_customer_count, :today_order_count => today_order_count, :today_sale => today_sale}
    GCM.send_notification(destination, data, :collapse_key => "placar_score_global", :time_to_live => 3600, :delay_while_idle => false)
  end

  def send_order_push_notification_ios(order, device_token, start_time, end_time, order_count)
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", device_token.inspect
    today_customer_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).all.group_by { |order| order.user_id }.size
    today_order_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).size
    today_sale = Order.where("Date(created_at) = ? and status= ? and shop_id= ?", Date.today, 'accepted', order.shop.id).sum('total_amount')
    data = {:order_id => order.id, :customer_name => @user.full_name, :start_time => start_time.to_s, :end_time => end_time.to_s, :order_count => order_count, :today_customer_count => today_customer_count, :today_order_count => today_order_count, :today_sale => today_sale}
    notification = Houston::Notification.new(device: device_token)
    notification.badge = 0
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = data
    notification.alert = "New order has been placed."
    certificate = File.read("config/Merchant_production.pem")
    pass_phrase = "push"
    connection = Houston::Connection.new("apn://gateway.push.apple.com:2195", certificate, pass_phrase)
    connection.open
    connection.write(notification.message)
    connection.close
  end


  def customer_params
    params.require(:user).permit(:registration_id, :current_password, :id, :name, :email, :phone, :password, :password_confirmation, :asset_attributes => [:id, :owner_id, :owner_type, :owner, :avatar, :avatar_file_name, :avatar_content_type, :avatar_file_size]) #added new param of convenience_fee for customers
  end


end
