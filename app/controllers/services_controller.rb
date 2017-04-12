class ServicesController < ApplicationController
  #include ActionView::Helpers::DateHelper
  respond_to :json
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!
  before_filter :check_session_create, :except => [:sign_in, :forgot_password, :push_testing, :auto_login]
  #before_filter :check_session_create, :except => [:sign_in]

  include ApplicationHelper

  def push_testing
    # params[:device_id] = "<68826e77 e36128cb fd851b32 dd1b60c8 f3452af0 bf973923 0338c104 86ce9083>" ## device_id for Customer_development.pem
    # params[:device_id] = "<3425b325 781d14ce 678ea3c6 e08d9615 12017663 0f33982f 09296540 9c30cd9d>" ## device_id for Merchant_development.pem
    if params[:device_id].present?
      notification = Houston::Notification.new(device: params[:device_id])
      notification.badge = 0
      notification.sound = "sosumi.aiff"
      notification.content_available = true
      notification.custom_data = {:id => "mmmm"}
      notification.alert = "This is test message"
      # certificate = File.read("config/Merchant_development.pem")
      certificate = File.read("config/Customer_Production.pem")
      pass_phrase = "push"
      connection = Houston::Connection.new("apn://gateway.push.apple.com:2195", certificate, pass_phrase)
      connection.open
      connection.write(notification.message)
      connection.close
      render :json => {:success => 'true', :message => 'message send '}
    else
      render :json => {:success => 'false', :message => 'device_id not found'}
    end
  end

  def sign_in
    # puts "RRRRRRRRRRRRRRRRRRRRRRRRRRR", request.location.inspect
    if params[:email].present? and params[:password].present?
      @user = User.where(:email => params[:email], :status => 'active', :is_verified => true).first
      if @user.blank?
        render :json => {:success => "false", :errors => "failed sign in, user cannot be found."}
      else
        if @user.merchant?
          if not @user.valid_password?(params[:password])
            render :json => {:success => "false", :errors => "Invalid email or password."}
          else
            if params[:device_type].blank?
              unless params[:registration_id].blank?
                @user.update_attribute(:registration_id, params[:registration_id])
                @shop = @user.shop
                merchant_account = Stripe::Customer.retrieve(@user.customer_id)
                bank_account = merchant_account.sources.retrieve(@shop.bank_account_id)
                @account_number = bank_account.last4
                @routing_number = bank_account.routing_number
                render :json => {:success => "true",
                                 :data => {
                                     :merchant => merchant_json,
                                     :shop => @shop.shop_json(@shop),
                                     :order_times => OrderTime.all.map { |order_time| {:id => order_time.id, :time => order_time.time} }
                                 }
                       }
              else
                render :json => {:success => "false", :errors => "registration_id missing"}
              end
            elsif params[:device_type] == 'iphone'
              unless params[:device_id].blank?
                @user.update_attribute(:device_id, params[:device_id])
                @shop = @user.shop
                merchant_account = Stripe::Customer.retrieve(@user.customer_id)
                bank_account = merchant_account.sources.retrieve(@shop.bank_account_id)
                @account_number = bank_account.last4
                @routing_number = bank_account.routing_number
                render :json => {:success => "true",
                                 :data => {
                                     :merchant => merchant_json,
                                     :shop => @shop.shop_json(@shop),
                                     :order_times => OrderTime.all.map { |order_time| {:id => order_time.id, :time => order_time.time} }
                                 }
                       }
              else
                render :json => {:success => "false", :errors => "Device id is missing"}
              end
            end
          end
        else
          render :json => {:success => " false ", :errors => " User is not merchant."}
        end
      end
    else
      render :json => {:success => " false ", :errors => " email or password missing"}
    end
  end


  def auto_login
    if params[:user_token].present?
      @user = User.where(:authentication_token => params[:user_token]).first
      if @user.blank?
        render :json => {:success => "false", :errors => "failed sign in, user cannot be found."}
      else
        if @user.merchant?
          if params[:device_type].blank?
            render :json => {:success => "false", :errors => "Device type is missing"}
          elsif params[:device_type] == 'iphone'
            unless params[:device_id].blank?
              @user.update_attribute(:device_id, params[:device_id])
              @shop = @user.shop
              merchant_account = Stripe::Customer.retrieve(@user.customer_id)
              bank_account = merchant_account.sources.retrieve(@shop.bank_account_id)
              @account_number = bank_account.last4
              @routing_number = bank_account.routing_number
              render :json => {:success => "true",
                               :data => {
                                   :merchant => merchant_json,
                                   :shop => @shop.shop_json(@shop),
                                   :order_times => OrderTime.all.map { |order_time| {:id => order_time.id, :time => order_time.time} }
                               }
                     }
            else
              render :json => {:success => "false", :errors => "Device id is missing"}
            end
          end
        else
          render :json => {:success => " false ", :errors => "This merchant doesn't exist."}
        end
      end
    else
      render :json => {:success => " false ", :errors => " email or password missing"}
    end
  end

  def get_customer_menu
    if params[:shop_id].present?
      @shop = Shop.includes(:items => [:item_sizes]).where("shops.id=?", params[:shop_id]).first
      @sizes = Size.all
      render :json => {:success => "true",
                       :data => {
                           :categories => Category.includes(:sub_categories => [:items]).where("categories.parent_id is null").map { |c| c.get_category(c, @shop, request) },
                           :sugars => Sugar.all.blank? ? [] : Sugar.all.map { |sugar| {:id => sugar.id, :name => sugar.name} },
                           :shop_sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @user.shop.shop_sugars.where(:is_archived => false).all.map { |shop_sugar| {:id => shop_sugar.id, :sugar_id => shop_sugar.sugar_id, :shop_id => shop_sugar.shop_id, :price => shop_sugar.sugar.price, :name => shop_sugar.sugar.name} },
                           :sizes => @sizes.map { |s| {:id => s.id, :name => s.size} }
                       }
             }
    else
      render :json => {:success => " false ", :errors => "params shop id is missing"}
    end
  end

  def save_item
    puts "PPP", params.inspect
    @item = Item.new(item_params)
    @sizes = Size.all
    if @item.save
      render :json => {
                 :success => "true",
                 :data => {
                     :categories => Category.includes(:sub_categories).where(:parent_id => nil).map { |c| c.get_category(c, @shop, request) },
                     :sugars => Sugar.all.blank? ? [] : Sugar.all.map { |sugar| {:id => sugar.id, :name => sugar.name} },
                     :shop_sugars => @shop.shop_sugars.where(:is_archived => false).blank? ? [] : @user.shop.shop_sugars.where(:is_archived => false).all.map { |shop_sugar| {:id => shop_sugar.id, :sugar_id => shop_sugar.sugar_id, :shop_id => shop_sugar.shop_id, :price => shop_sugar.sugar.price, :name => shop_sugar.sugar.name} },
                     :sizes => @sizes.map { |s| {:id => s.id, :name => s.size} } #,:item => {:id => @item.id}
                 }}
    else
      puts "CCCC", @item.errors.inspect
      @errors = @item.errors
      error_string = ""
      @item.errors.full_messages.each do |msg|
        error_string += msg
      end
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  def update_item
    puts "sss", params.inspect
    item = Item.find_by_id(params[:id])
    @item = item if @shop.items.include?(item)
    @sizes = Size.all
    unless params[:archived].blank?
      params[:archived].each do |k, v|
        puts "PPPP", k
        puts "Val", v
        ItemAddOn.find(v).update_attributes(:is_archived => true)
      end
    end
    #array_ids = []
    #unless params[:item][:item_add_ons_attributes].blank?
    #  params[:item][:item_add_ons_attributes].each do |k, v|
    #    puts "PPPPP", k
    #    puts "VVVVVV", v['id']
    #    array_ids << v['id']
    #  end
    #  unless @item.item_add_ons.blank?
    #    @item.item_add_ons.each do |iao|
    #      puts "ids array", array_ids
    #      puts "Comparre", iao.id
    #      unless array_ids.include?(iao.id.to_s)
    #        ItemAddOn.find(iao.id).update_attributes(:is_archived => true)
    #        puts "Updated"
    #      end
    #    end
    #  end
    #end
    if @item.update_attributes(item_params)
      render :json => {:success => "true",
                       :data => {:categories => Category.includes(:sub_categories).where(:parent_id => nil).map { |c| c.get_category(c, @shop, request) },
                                 :sizes => @sizes.map { |s| {:id => s.id, :name => s.size} }}

             }
    else
      @errors = @item.errors
      puts "EEEEEEEEE", @errors.inspect
      error_string = ""
      @item.errors.full_messages.each do |msg|
        error_string += msg
      end
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  def save_add_on
    @add_on = AddOn.new(add_on_params)
    @sizes = Size.all
    if @add_on.save
      render :json => {:success => "true",
                       :data => {:categories => Category.includes(:sub_categories).where(:parent_id => nil).map { |c| c.get_category(c, @shop, request) },
                                 :sizes => @sizes.map { |s| {:id => s.id, :name => s.size} },
                                 :add_on => {:id => @add_on.id}
                       }

             }
    else
      @errors = @add_on.errors
      error_string = ""
      @add_on.errors.full_messages.each do |msg|
        error_string += msg
      end
      render :json => {:success => "false", :message => "Something went wrong #{error_string}", :errors => @add_on.errors.full_messages.map { |msg| msg }}
    end
  end

  def update_add_on
    add_on = AddOn.find_by_id(params[:id])
    @add_on = add_on if @shop.add_ons.include?(add_on)
    @sizes = Size.all
    if @add_on.update_attributes(add_on_params)
      render :json => {:success => "true",
                       :data => {:categories => Category.includes(:sub_categories).where(:parent_id => nil).map { |c| c.get_category(c, @shop, request) },
                                 :sizes => @sizes.map { |s| {:id => s.id, :name => s.size} }}

             }
    else
      @errors = @add_on.errors
      error_string = ""
      @add_on.errors.full_messages.each do |msg|
        error_string += msg
      end
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  def open_shop
    unless params[:shop][:status].blank?
      if @shop.update_attributes(:status => params[:shop][:status])
        render :json => {:success => "true", :status => params[:shop][:status], :message => "shop status change"}
      else
        render :json => {:success => "false", :message => "shop status not change"}
      end
    else
      render :json => {:success => "false", :message => "Param status not found"}
    end
  end

  #
  #def update_merchant
  #  successfully_updated = if needs_password?(@user, params)
  #                           @user.update(merchant_params)
  #                         else
  #                           params[:user].delete(:password)
  #                           @user.update_without_password(merchant_params)
  #                         end
  #
  #  if successfully_updated
  #    render :json => {:success => "true", :message => "Merchant was updated"}
  #  else
  #    render :json => {:success => "false", :message => "Merchant was not updated"}
  #  end
  #end

  def order_detail
    @order = Order.find_by_id(params[:id])
    result = nil
    unless @order.card_id.blank?
      begin
        customer = Stripe::Customer.retrieve(@order.user.customer_id)
        result = customer.sources.retrieve(@order.card_id)
        @order.update_attribute(:is_new, false) if @order.is_new == true
      rescue Stripe::CardError => e
        body = e.json_body
        err = body[:error]
        render :json => {:success => "false", :message => "Something went wrong, #{err[:message]}"}
      end
    end
    unless @order.blank?
      render :json => {:success => "true",
                       :data => {
                           :order => {:id => @order.id, :shop_name => @order.shop.name, :order_number => @order.order_number, :status => @order.status, :total_amount => @order.total_amount, :table_number => @order.table_number, :is_expressOrder => @order.is_expressOrder, :created_at => @order.created_at, :estimated_time => @order.estimated_time, :completed_time => @order.completed_time.blank? ? nil : @order.completed_time, :tax => @order.tax, :customer_name => @order.user.full_name, :convenience_fee => @order.convenience_fee, :reward_used => @order.reward_used},
                           :order_line_items => @order.order_line_items.blank? ? [] : @order.order_line_items.map { |order_line_item| {:id => order_line_item.id, :item_name => order_line_item.item_size.blank? ? order_line_item.item.name : order_line_item.item_size.item.name, :item_description => order_line_item.item_size.blank? ? order_line_item.item.description : order_line_item.item_size.item.description, :price => order_line_item.price, :total_price => order_line_item.total_price, :size => order_line_item.item_size.blank? ? nil : order_line_item.item_size.size.size, :quantity => order_line_item.quantity, :total => order_line_item.item_size.blank? ? (order_line_item.item.base_price) * (order_line_item.quantity).round(2) : (order_line_item.item_size.price) * (order_line_item.quantity).round(2), :no_of_shots => order_line_item.no_of_shots, :shot_price => order_line_item.shot_price, :sugar_name => order_line_item.sugar.blank? ? nil : order_line_item.sugar.name, :sugar_quantity => order_line_item.sugar_quantity, :sugar_id => order_line_item.sugar_id, :order_add_ons => order_line_item.order_add_ons.blank? ? [] : order_line_item.order_add_ons.map { |order_add_on| {:id => order_add_on.id, :name => order_add_on.item_add_on.add_on.name, :item_add_on_id => order_add_on.item_add_on_id, :order_line_item_id => order_add_on.order_line_item_id, :quantity => order_add_on.quantity, :price => order_add_on.price, :total_price => order_add_on.total_price} }} },
                           :credit_card => result.blank? ? nil : {:id => result.id, :number => result.last4, :label => result.name, :expiry_date => "#{result.exp_month}/#{result.exp_year}", :postal_code => result.address_zip.nil? ? "" : result.address_zip, :card_type => result.brand}
                       }}
      #puts "CCC", abc
    else
      return render :json => {:success => "false", :message => "Order not found"}
    end
  end

  def all_order_detail
    @orders = @user.shop.orders
    render :json => {:success => "true",
                     :data => {
                         :orders => @orders.blank? ? [] : @orders.map { |order| {:id => order.id, :name => order.shop.name, :order_number => order.order_number, :status => order.status, :total_amount => order.total_amount, :table_number => order.table_number, :is_expressOrder => order.is_expressOrder, :customer_name => order.user.full_name, :created_at => order.created_at, :picture_url => order.user.asset.blank? ? nil : order.user.asset.avatar.url(:thumb), :convenience_fee => order.convenience_fee, :reward_used => order.reward_used} }.reverse
                     }}

  end

  def delete_item_add_ons
    puts "IIII"
    if params[:id].present?
      item_add_on = ItemAddOn.find_by_id(params[:id])
      if item_add_on.present?
        item_add_on.destroy
        puts "IIIIDD"
        render :json => {:success => "true", :message => "item add on deleted"}
      else
        puts "IIIIDDGG"
        render :json => {:success => "false", :message => "item add on not found"}
      end
    else
      puts "IIIIDDGGBBB"
      render :json => {:success => "false", :message => "params id is missing"}
    end
  end

  def update_shop_hour
    @shop = @user.shop
    if @shop.update_attributes(shop_params)
      puts "SSSS PPPP", shop_params.inspect
      render :json => {:success => "true", :message => "Shop  was updated", :shop_hours => @shop.shop_timings(@shop)}
    else
      error_string = ""
      @shop.errors.full_messages.each do |msg|
        error_string += msg
      end
      puts "CCC", @shop.errors.inspect
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  # def accept_order
  #   @order = Order.find_by_id(params[:order][:id])
  #   unless @order.blank?
  #     unless @order.status == 'accepted'
  #       line_item_price = @order.order_line_items.blank? ? 0 : @order.order_line_items.sum(&:total_price)
  #       add_ons_price = @order.order_add_ons.blank? ? 0 : @order.order_add_ons.sum(&:total_price)
  #       final_amount = (line_item_price + add_ons_price) > 0 ? (line_item_price + add_ons_price) : 0
  #       @customer = BraintreeRails::Customer.find(@order.user.customer_id)
  #       @merchant = @user
  #       result = Braintree::Transaction.sale(
  #           :customer_id => @customer.id,
  #           :service_fee_amount => 0,
  #           :amount => final_amount.round(2),
  #           :merchant_account_id => @merchant.customer_id,
  #           :payment_method_token => @order.card_id,
  #           :options => {
  #               :submit_for_settlement => true
  #           }
  #       )
  #       if result.success?
  #         if @order.update_attributes(:estimated_time => params[:order][:estimated_time], :status => params[:order][:status])
  #           OrderTransaction.create!(:shop_id => @order.shop_id, :user_id => @order.user_id, :order_id => @order.id, :amount => final_amount, :transaction_id => result.transaction.id, :status => result.transaction.status, :transaction_type => result.transaction.type)
  #           if @order.user.device_type.blank?
  #             send_order_accepted_push_notification(@order, @order.user.registration_id, true, "Order successfully accepted")
  #             UserMailer.order_mail(@order, @order.user, request.host, request.protocol).deliver
  #           else
  #             send_order_accepted_push_notification_ios(@order, @order.user.device_id, true, "Order successfully accepted")
  #             UserMailer.order_mail(@order, @order.user, request.host, request.protocol).deliver
  #           end
  #           today_sale = Order.where("Date(created_at) = ? and status= ? and shop_id= ?", Date.today, 'accepted', @order.shop_id).sum('total_amount')
  #           render :json => {:success => "true", :status => @order.status, :today_sale => today_sale, :message => "Order Status changed"}
  #         else
  #           render :json => {:success => "false", :message => "Order no accepted"}
  #         end
  #       else
  #         msg ||= []
  #         result.errors.each { |error| msg << error.message }
  #         @order.update_attribute(:status, 'canceled')
  #         if @order.user.device_type.blank?
  #           send_order_accepted_push_notification(@order, @order.user.registration_id, true, "Your Order Failed due to payment process reason #{msg.join("\n")}")
  #           UserMailer.cancel_order_mail(@order, @order.user, params[:order][:reason], request.host, request.protocol).deliver
  #         elsif params[:device_type] == 'iphone'
  #           send_order_accepted_push_notification_ios(@order, @order.user.device_id, true, "Your Order Failed due to payment process reason #{msg.join("\n")}")
  #           UserMailer.cancel_order_mail(@order, @order.user, params[:order][:reason], request.host, request.protocol).deliver
  #         end
  #
  #         return render :json => {:success => "false", :message => "Something wrong, #{msg.join("\n")}"}
  #       end
  #     else
  #       render :json => {:success => "false", :message => "Order Already accepted"}
  #     end
  #   else
  #     render :json => {:success => "false", :message => "Order no found"}
  #   end
  # end

  def accept_order
    @order = Order.find_by_id(params[:order][:id])
    unless @order.blank?
      unless @order.status == 'accepted'
        line_item_price = @order.order_line_items.blank? ? 0 : @order.order_line_items.sum(&:total_price)
        add_ons_price = @order.order_add_ons.blank? ? 0 : @order.order_add_ons.sum(&:total_price)
        final_amount = (@order.total_amount > 0 ? @order.total_amount : 0) * 100
        begin
          if @order.card_id.present? #if card_id not present it means order charged in cash.
            hookah_amount = ((@order.is_expressOrder? ? 8 : 0) + @order.convenience_fee) * 100
            stripe_fee_on_order = (final_amount * 0.029) + 30
            hookah_amount += stripe_fee_on_order
            merchant_amount = final_amount - hookah_amount
            charge = Stripe::Charge.create(
                :amount => "#{(final_amount).round}", #as in stripe amount charged is in cents
                :currency => 'usd',
                :customer => @order.user.customer_id,
                :card => @order.card_id,
                :description => "Customer is being charged for order:# #{@order.order_number}",
                :destination => @order.shop.stripe_account_id,
                :application_fee => hookah_amount.round
            )
            # charge = Stripe::Charge.create(
            #     :amount => "#{(hookah_amount).round}", #as in stripe amount charged is in cents
            #     :currency => 'usd',
            #     :customer => @order.shop.user.customer_id,
            #     :description => "Merchant charged for convenience fee + stripe fee:# #{@order.order_number}"
            # )

=begin
2 sep
charge = Stripe::Charge.create(
                :amount => "#{(hookah_amount).to_i}", #as in stripe amount charged is in cents
                :currency => 'usd',
                :customer => @order.user.customer_id,
                :card => @order.card_id,
                :description => "Customer is being charged for order:# #{@order.order_number}"
            )
            charge = Stripe::Charge.create(
                :amount => "#{(merchant_amount).to_i}", #as in stripe amount charged is in cents
                :currency => 'usd',
                :customer => @order.user.customer_id,
                :card => @order.card_id,
                :description => "Customer is being charged for order:# #{@order.order_number}",
                :destination => @order.shop.stripe_account_id
            )
=end

=begin
previous code
=end
            # charge = Stripe::Charge.create(
            #     :amount => "#{(final_amount * 100).to_i}", #as in stripe amount charged is in cents
            #     :currency => 'usd',
            #     :customer => @order.user.customer_id,
            #     :card => @order.card_id,
            #     :description => "Customer is being charged for order:# #{@order.order_number}"
            # )
            # transfer_amount = final_amount - ((@order.is_expressOrder? ? 8 : 0) + @order.convenience_fee)
            # transfer = Stripe::Transfer.create(
            #     :amount => "#{(transfer_amount * 100).to_i}",
            #     :currency => 'usd',
            #     :destination => @order.shop.stripe_account_id,
            #     :description => 'Transfer the money to merchant.'
            # )
          end
          if @order.update_attributes(:estimated_time => params[:order][:estimated_time], :status => params[:order][:status])
            OrderTransaction.create!(:shop_id => @order.shop_id, :user_id => @order.user_id, :order_id => @order.id, :amount => final_amount, :transaction_id => @order.card_id.present? ? charge.balance_transaction : nil, :status => @order.card_id.present? ? charge.status : nil, :charge_id => @order.card_id.present? ? charge.id : nil, :convenience_fee => @order.convenience_fee, :transaction_type => @order.card_id.present? ? "card" : "cash")
            if @order.user.device_type.blank?
              send_order_accepted_push_notification(@order, @order.user.registration_id, true, "Order successfully accepted")
              UserMailer.order_mail(@order, @order.user, request.host, request.protocol).deliver
            else
              send_order_accepted_push_notification_ios(@order, @order.user.device_id, true, "Order successfully accepted")
              UserMailer.order_mail(@order, @order.user, request.host, request.protocol).deliver
            end
            today_sale = Order.where("Date(created_at) = ? and status= ? and shop_id= ?", Date.today, 'accepted', @order.shop_id).sum('total_amount')
            render :json => {:success => "true", :status => @order.status, :today_sale => today_sale, :message => "Order Status changed"}
          else
            render :json => {:success => "false", :message => "Order no accepted"}
          end
        rescue Stripe::CardError, Stripe::InvalidRequestError => e
          puts "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", e.inspect
          body = e.json_body
          err = body[:error]
          @order.update_attribute(:status, 'canceled')
          if @order.user.device_type.blank?
            send_order_accepted_push_notification(@order, @order.user.registration_id, true, "Your Order Failed due to payment process reason #{msg.join("\n")}")
            UserMailer.cancel_order_mail(@order, @order.user, params[:order][:reason], request.host, request.protocol).deliver
          elsif params[:device_type] == 'iphone'
            send_order_accepted_push_notification_ios(@order, @order.user.device_id, true, "Your Order Failed due to payment process reason #{msg.join("\n")}")
            UserMailer.cancel_order_mail(@order, @order.user, params[:order][:reason], request.host, request.protocol).deliver
          end
          return render :json => {:success => "false", :message => "Something wrong, #{err[:message]}"}
        end
      else
        render :json => {:success => "false", :message => "Order Already accepted"}
      end
    else
      render :json => {:success => "false", :message => "Order no found"}
    end
  end

  def cancel_order
    @order = Order.find_by_id(params[:order][:id])
    if @order.update_attributes(:status => 'canceled', :reason => params[:order][:reason])
      if @order.user.device_type.blank?
        send_order_accepted_push_notification(@order, @order.user.registration_id, true, "Your Order Canceled due to '#{@order.reason}'")
        UserMailer.cancel_order_mail(@order, @order.user, params[:order][:reason], request.host, request.protocol).deliver
      else
        send_order_accepted_push_notification_ios(@order, @order.user.device_id, true, "Your Order Canceled due to '#{@order.reason}'")
        UserMailer.cancel_order_mail(@order, @order.user, params[:order][:reason], request.host, request.protocol).deliver
      end
      render :json => {:success => "true", :message => "Order successfully canceled"}
    else
      render :json => {:success => "false", :message => "Order not canceled"}
    end
  end

  def complete_order
    @order = Order.find_by_id(params[:order][:id])
    if @order.update_attributes(:status => 'closed', :completed_time => Time.now)
      render :json => {:success => "true", :message => "Order successfully Completed"}
    else
      render :json => {:success => "false", :message => "Order not Completed"}
    end
  end

  # def refund_order
  #   @order = Order.find_by_id(params[:order][:id])
  #   unless @order.order_transaction.blank?
  #     result = Braintree::Transaction.refund(@order.order_transaction.transaction_id)
  #     if result.success?
  #       @order.order_transaction.update_attributes(:status => 'refunded')
  #       @order.update_attributes(:status => 'refunded', :refunded_amount => @order.total_amount)
  #       return render :json => {:success => "true", :message => "Order successfully refunded"}
  #     else
  #       msg ||= []
  #       result.errors.each { |error| msg << error.message }
  #       return render :json => {:success => "false", :message => "#{msg.join("\n")}"}
  #     end
  #   else
  #     render :json => {:success => "false", :message => "Order transaction not found"}
  #   end
  #   end
  def refund_order
    @order = Order.find_by_id(params[:order][:id])
    unless @order.order_transaction.blank?
      begin
        refund = Stripe::Refund.create(
            charge: @order.order_transaction.charge_id
        )
        @order.order_transaction.update_attributes(:status => 'refunded')
        @order.update_attributes(:status => 'refunded', :refunded_amount => @order.total_amount)
        return render :json => {:success => "true", :message => "Order successfully refunded"}
      rescue Stripe::StripeError => e
        body = e.json_body
        err = body[:error]
        return render :json => {:success => "false", :message => "#{err[:message]}"}
      end
    else
      render :json => {:success => "false", :message => "Order transaction not found"}
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


  def change_password
    puts "CCCCJHJJJJHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
    check_password = @user.valid_password?(params[:user][:current_password])
    if check_password == true
      if @user.update_attribute('password', params[:user][:password])
        render :json => {:success => "true", :message => "Password successfully changed"}
      else
        render :json => {:success => "false", :message => "Pass change failed with error"}
      end
    else
      render :json => {:success => "false", :message => "Current password is invalid"}
    end
  end

  def update_bank_account
    result = Braintree::MerchantAccount.update(
        @user.customer_id,
        :funding => {
            :destination => Braintree::MerchantAccount::FundingDestination::Bank,
            :account_number => params[:account_number],
            :routing_number => params[:routing_number]
        })
    if result.success?
      render :json => {:success => "true", :message => "Account successfully updated"}
    else
      msg ||= []
      result.errors.each { |error| msg << error.message }
      return render :json => {:success => "false", :message => "Something wrong, #{msg.join("\n")}"}
    end
  end

  def update_merchant
    if @user.update_without_password(merchant_params)
      render :json => {:success => "true", :picture_url => @user.shop.asset.blank? ? nil : @user.shop.asset.avatar.url(:original), :picture_id => @user.shop.asset.blank? ? nil : @user.shop.asset.id, :logo_url => @user.asset.blank? ? nil : @user.asset.avatar.url(:thumb), :logo_id => @user.asset.blank? ? nil : @user.asset.id, :message => "Merchant  was updated"}
    else
      error_string = ""
      @user.errors.full_messages.each do |msg|
        error_string += msg
      end
      puts "CCC", @user.errors.inspect
      render :json => {:success => "false", :message => "Something went wrong #{error_string}"}
    end
  end

  def support_request
    unless params[:description].blank?
      UserMailer.support_request(params[:description], @user, request.host_with_port, request.protocol).deliver
      render :json => {:success => "true", :message => "Support request successfully sent"}
    else
      render :json => {:success => "false", :message => "Support request not sent"}
    end
  end

  def get_notification
    unless @user.registration_id.blank?
      orders = Order.where(:is_new => true, :shop_id => @shop.id).order("id asc")
      unless orders.blank?
        @order = orders.sort_by { |o| o.id }.reverse.last
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
        puts "NNNN", @user.registration_id.inspect
        if @user.device_type.blank?
          send_order_push_notification(@order, @user.registration_id, start_time, end_time, order_count)
        else
          send_order_push_notification_ios(@order, @user.device_id, start_time, end_time, order_count)
        end
      end
    end
    render :json => {:success => "true", :message => "Notification Received"}
  end


  def get_analytic_main
    shop = User.where(:authentication_token => params[:token]).first.shop
    start_date = params[:start_date]
    end_date = params[:end_date]
    orders = shop.orders.where("created_at between ? and ?", start_date, end_date.to_date + 1.day).size
    avg_order = shop.orders.where("created_at between ? and ?", start_date, end_date.to_date + 1.day).average(:total_amount)
    new_customers = User.customers.where(" Date(users.created_at) >?", Date.today - 7.days).size
    repeated_customers = User.customers.where("users.created_at between ? and ?", start_date, end_date.to_date + 1.day).select { |repeated_customer| repeated_customer.orders.size > 1 }.size
    new_reviews = Review.where(" created_at >?", Date.today - 7.days).size
    avg_reviews = Review.where("created_at between ? and ?", start_date, end_date.to_date + 1.day).average(:rating)
    render :json => {:success => "true",
                     :data => {
                         :analytic_main => {:orders => orders, :avg_order => avg_order, :new_customers => new_customers, :repeated_customers => repeated_customers, :new_reviews => new_reviews, :avg_reviews => avg_reviews}
                     }}

  end

  # def get_sales_break_down
  #   start_date = params[:start_date]
  #   end_date = params[:end_date]
  #   drinks_json = []
  #   total_quantity = 0
  #   total_amount = 0
  #   OrderLineItem.where("created_at between ? and ?", start_date, end_date).includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'DRINKS' : line_item.item.category.parent.name == 'DRINKS' }.group_by { |line_item| line_item.item_size_id }.each do |size_id, line_items|
  #     drinks_item_sum = 0
  #     drinks_item_quantity = 0
  #     line_items.select { |line_item| drinks_item_sum+=line_item.total_price }
  #     total_amount += drinks_item_sum
  #     line_items.select { |line_item| drinks_item_quantity+=line_item.quantity }
  #     total_quantity += drinks_item_quantity
  #     json = {:quantity => drinks_item_quantity, :item_name => line_items.first.item.blank? ? line_items.first.item_size.item.name : line_items.first.item.name, :sub_total => drinks_item_sum}
  #     drinks_json << json
  #   end
  #   drinks_final_json = {:total_quantity => total_quantity, :total_amount => total_amount, :items => drinks_json}
  #   food_json = []
  #   total_quantity = 0
  #   total_amount = 0
  #   OrderLineItem.where("created_at between ? and ?", start_date, end_date).includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'FOOD' : line_item.item.category.parent.name == 'FOOD' }.group_by { |line_item| line_item.item_size_id }.each do |size_id, line_items|
  #     food_item_sum = 0
  #     food_item_quantity = 0
  #     line_items.select { |line_item| food_item_sum+=line_item.total_price }
  #     total_amount += food_item_sum
  #     line_items.select { |line_item| food_item_quantity+=line_item.quantity }
  #     total_quantity += food_item_quantity
  #     json = {:quantity => food_item_quantity, :item_name => line_items.first.item.blank? ? line_items.first.item_size.item.name : line_items.first.item.name, :sub_total => food_item_sum}
  #     food_json << json
  #   end
  #   food_final_json = {:total_quantity => total_quantity, :total_amount => total_amount, :items => food_json}
  #   add_on_json = []
  #   total_quantity = 0
  #   total_amount = 0
  #   OrderAddOn.where("created_at between ? and ?", start_date, end_date).includes(:order_line_item, :item_add_on => [:add_on]).select { |order_add_on| order_add_on.item_add_on.add_on.category.parent.name == 'ADD ONS' }.group_by { |order_add_on| order_add_on.order_line_item }.each do |order_line_item, order_add_ons|
  #     add_on_item_sum = 0
  #     add_on_item_quantity = 0
  #     order_add_ons.map { |order_add_on| add_on_item_sum+=order_add_on.total_price }
  #     total_amount += add_on_item_sum
  #     order_add_ons.map { |order_add_on| add_on_item_quantity+=order_add_on.quantity }
  #     total_quantity += add_on_item_quantity
  #     json = {:quantity => add_on_item_quantity, :add_on_name => order_add_ons.first.item_add_on.add_on.name, :sub_total => add_on_item_sum}
  #     add_on_json << json
  #   end
  #   render :json => {:success => "true",
  #                    :data => {
  #                        :drinks => drinks_final_json,
  #                        :food => food_final_json,
  #                        :add_ons => add_on_json
  #                    }}
  # end

  def get_sales_break_down
    start_date = params[:start_date]
    end_date = params[:end_date]
    drinks_json = []
    total_quantity = 0
    total_amount = 0
    OrderLineItem.where("created_at between ? and ?", start_date, end_date.to_date + 1.day).includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'HOOKAH' : line_item.item.category.parent.name == 'HOOKAH' }.group_by { |line_item| line_item.item_size_id }.each do |size_id, line_items|
      drinks_item_sum = 0
      drinks_item_quantity = 0
      line_items.select { |line_item| drinks_item_sum+=line_item.total_price }
      total_amount += drinks_item_sum
      line_items.select { |line_item| drinks_item_quantity+=line_item.quantity }
      total_quantity += drinks_item_quantity
      json = {:quantity => drinks_item_quantity, :item_name => line_items.first.item.blank? ? line_items.first.item_size.item.name : line_items.first.item.name, :sub_total => drinks_item_sum}
      drinks_json << json
    end
    drinks_final_json = {:total_quantity => total_quantity, :total_amount => total_amount, :items => drinks_json}
    food_json = []
    total_quantity = 0
    total_amount = 0
    OrderLineItem.where("created_at between ? and ?", start_date, end_date.to_date + 1.day).includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'REFILL' : line_item.item.category.parent.name == 'REFILL' }.group_by { |line_item| line_item.item_size_id }.each do |size_id, line_items|
      food_item_sum = 0
      food_item_quantity = 0
      line_items.select { |line_item| food_item_sum+=line_item.total_price }
      total_amount += food_item_sum
      line_items.select { |line_item| food_item_quantity+=line_item.quantity }
      total_quantity += food_item_quantity
      json = {:quantity => food_item_quantity, :item_name => line_items.first.item.blank? ? line_items.first.item_size.item.name : line_items.first.item.name, :sub_total => food_item_sum}
      food_json << json
    end
    food_final_json = {:total_quantity => total_quantity, :total_amount => total_amount, :items => food_json}
    charcoal_json = []
    total_quantity = 0
    total_amount = 0
    OrderLineItem.where("created_at between ? and ?", start_date, end_date.to_date + 1.day).includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'CHARCOAL' : line_item.item.category.parent.name == 'CHARCOAL' }.group_by { |line_item| line_item.item_size_id }.each do |size_id, line_items|
      drinks_item_sum = 0
      drinks_item_quantity = 0
      line_items.select { |line_item| drinks_item_sum+=line_item.total_price }
      total_amount += drinks_item_sum
      line_items.select { |line_item| drinks_item_quantity+=line_item.quantity }
      total_quantity += drinks_item_quantity
      json = {:quantity => drinks_item_quantity, :item_name => line_items.first.item.blank? ? line_items.first.item_size.item.name : line_items.first.item.name, :sub_total => drinks_item_sum}
      charcoal_json << json
    end
    charcoal_final_json = {:total_quantity => total_quantity, :total_amount => total_amount, :items => drinks_json}
    render :json => {:success => "true",
                     :data => {
                         :hookah => drinks_final_json,
                         :refill => food_final_json,
                         :charcoal => charcoal_final_json
                     }}
  end


  def remove_pic
    @asset = Asset.find(params[:id])
    if @asset.destroy
      render :json => {:success => "true", :message => "Picture successfully destroyed"}
    else
      render :json => {:success => "false", :message => "Picture not destroyed"}
    end
  end


  def delete_item
    @item = Item.find(params[:item_id])
    if @item.update_attribute(:is_deleted, true)
      render :json => {:success => "true", :message => "Item successfully deleted"}
    else
      render :json => {:success => "false", :message => "Item not deleted"}
    end
  end

  def delete_add_on
    @add_on = AddOn.find(params[:add_on_id])
    if @add_on.update_attribute(:is_deleted, true)
      render :json => {:success => "true", :message => "Add on successfully deleted"}
    else
      render :json => {:success => "false", :message => "Add on not deleted"}
    end
  end

  def save_sugar
    params[:sugar].each do |key, val|
      ShopSugar.create(:shop_id => @user.shop.id, :sugar_id => val)
    end
    render :json => {:success => "true", :message => "Sugar added."}
  end

  def delete_sugar
    @sho_sugar = ShopSugar.find(params[:shop_sugar_id])
    if @sho_sugar.update_attributes(:is_archived => true)
      render :json => {:success => "true", :message => "Shop Sugar deleted."}
    else
      render :json => {:success => "false", :message => "Shop Sugar not deleted."}
    end
  end

  def shop_closed
    shop = Shop.find(params[:id])
    unless shop.nil?
      if shop.update_attributes(:status => (shop.status? ? false : true))
        render :json => {:success => 'true', :message => 'Shop Status Changed Successfully.'}
      else
        render :json => {:success => 'false', :message => 'Something Went Wrong, PLease try again later.'}
      end
    else
      render :json => {:success => 'false', :message => 'Shop doesn\'t exist.'}
    end
  end

  private

  def needs_password?(user, params)
    params[:user][:password].present?
  end


  #def shop_hours(shop)
  #  shop.shop_hours.map { |shop_hour| {:id => shop_hour.id, :name => shop_hour.name, :start_time => shop_hour.start_time, :end_time => shop_hour.end_time} }
  #end


  def merchant_json
    {
        :token => @user.authentication_token,
        :id => @user.id,
        :email => @user.email,
        :name => @user.name,
        :account_number => @account_number,
        :routing_number => @routing_number
    }
  end

  #def get_category(c)
  #  {:id => c.id,
  #   :name => c.name,
  #   :subcategories => c.sub_categories.map { |sc| get_sub_category(sc) },
  #   :items => get_items(c.sub_categories),
  #   :add_ons => get_add_ons(c.sub_categories)
  #  }
  #end
  #
  #def get_sub_category(sc)
  #  {:id => sc.id,
  #   :name => sc.name
  #  }
  #end
  #
  #def get_items(sub_categories)
  #  items = []
  #  sub_categories.each do |sub_category|
  #    items += @shop.items.includes(:category).select { |i| i.category.id == sub_category.id }
  #  end
  #  items.map { |i| {:id => i.id,
  #                   :name => i.name,
  #                   :base_price => i.base_price,
  #                   :category_id => i.category_id,
  #                   :item_sizes => i.item_sizes.map { |is| {:id => is.id, :size_id => is.size_id, :price => is.price, :name => is.size.size} }
  #  } }
  #end

  def get_item_sizes()

  end

  #def get_add_ons(sub_categories)
  #  add_ons = []
  #  sub_categories.each do |sub_category|
  #    add_ons += @shop.add_ons.includes(:category).select { |a| a.category.id == sub_category.id }
  #  end
  #  add_ons.map { |a| {:id => a.id,
  #                     :name => a.name,
  #                     :category_id => a.category_id,
  #                     :cost_per_unit => a.cost_per_unit,
  #                     :number_of_units => a.number_of_units,
  #                     :description => a.description
  #  } }
  #end

  def check_session_create
    if params[:token].present?
      @user = User.find_by_authentication_token(params[:token])
      @shop = @user.shop if @user.present?
      render :json => {:success => " false ", :errors => " authentication failed "} unless @user.present?
    else
      render :json => {:success => " false ", :errors => " authentication failed "}
    end
  end

  def send_order_accepted_push_notification(order, registration_id, success, message)
    destination = [registration_id]
    data = {:order_id => order.id, :success => success, :message => message}
    GCM.send_notification(destination, data, :collapse_key => "placar_score_global", :time_to_live => 3600, :delay_while_idle => false)
  end

  def send_order_accepted_push_notification_ios(order, device_token, success, message)
    data = {:order_id => order.id, :success => success, :message => message}
    notification = Houston::Notification.new(:device => device_token)
    notification.badge = 0
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = data
    notification.alert = message
    certificate = File.read("config/Customer_Production.pem")
    # certificate = File.read("config/swiftBeans_Production.pem")
    pass_phrase = "push"
    connection = Houston::Connection.new("apn://gateway.push.apple.com:2195", certificate, pass_phrase)
    connection.open
    connection.write(notification.message)
    connection.close
  end

  def send_order_push_notification(order, registration_id, start_time, end_time, order_count)
    today_customer_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).all.group_by { |order| order.user_id }.size
    today_order_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).size
    today_sale = Order.where("Date(created_at) = ? and status= ? and shop_id= ?", Date.today, 'accepted', order.shop.id).sum('total_amount')
    destination = [registration_id]
    data = {:order_id => order.id, :customer_name => @user.full_name, :start_time => start_time.to_s, :end_time => end_time.to_s, :order_count => order_count, :today_customer_count => today_customer_count, :today_order_count => today_order_count, :today_sale => today_sale}
    GCM.send_notification(destination, data, :collapse_key => "placar_score_global", :time_to_live => 3600, :delay_while_idle => false)
  end


  def send_order_push_notification_ios(order, device_token, start_time, end_time, order_count)
    today_customer_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).all.group_by { |order| order.user_id }.size
    today_order_count = Order.where("Date(created_at) = ? and shop_id= ?", Date.today, order.shop.id).size
    today_sale = Order.where("Date(created_at) = ? and status= ? and shop_id= ?", Date.today, 'accepted', order.shop.id).sum('total_amount')
    data = {:order_id => order.id, :customer_name => @user.full_name, :start_time => start_time.to_s, :end_time => end_time.to_s, :order_count => order_count, :today_customer_count => today_customer_count, :today_order_count => today_order_count, :today_sale => today_sale}
    notification = Houston::Notification.new(:device => device_token)
    notification.badge = 0
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = data
    notification.alert = 'notification'
    certificate = File.read("config/Customer_Production.pem")
    pass_phrase = "push"
    connection = Houston::Connection.new("apn://gateway.push.apple.com:2195", certificate, pass_phrase)
    connection.open
    connection.write(notification.message)
    connection.close
  end

  def merchant_params
    params.require(:user).permit(:registration_id, :current_password, :id, :name, :email, :password, :password_confirmation, :asset_attributes => [:id, :owner_id, :owner_type, :owner, :avatar, :avatar_file_name, :avatar_content_type, :avatar_file_size], :shop_attributes => [:id, :user_id, :name, :phone, :address, :city, :state, :zip_code, :description, :facebook_link, :twitter_link, :yelp_link, :instagram_link, :asset_attributes => [:id, :owner_id, :owner_type, :owner, :avatar, :avatar_file_name, :avatar_content_type, :avatar_file_size]])
  end

  def item_params
    params.require(:item).permit(:id, :name, :description, :is_shot, :shot_price, :base_price, :shop_id, :category_id, :is_sugar,
                                 # :item_add_ons_attributes => [:id, :add_on_id, :item_size_id],
                                 :item_sizes_attributes => [:id, :item_id, :size_id, :price], :asset_attributes => [:id, :owner_id, :owner_type, :owner, :avatar, :avatar_file_name, :avatar_content_type, :avatar_file_size])
  end

  def shop_params
    # params.require(:shop).permit(:id, :name, :shop_hours_attributes => [:id, :shop_id, :name, :start_time, :end_time, :is_open])
    params.require(:shop).permit(:id, :name, :shop_hours_attributes => [:id, :shop_id, :name, :start_time, :end_time, :is_open, :shop_daily_slots_attributes => [:id, :shop_hour_id, :name, :start_time, :end_time]])
    # params.require(:shop_hour).permit(:id, :is_open, :shop_daily_slots_attributes => [:id, :shop_hour_id, :name, :start_date, :end_date])
  end

  def add_on_params
    params.require(:add_on).permit(:id, :category_id, :name, :description, :cost_per_unit, :number_of_units, :shop_id)
  end

end