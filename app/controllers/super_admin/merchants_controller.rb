class SuperAdmin::MerchantsController < SuperAdmin::SuperAdminController

  add_breadcrumb "STORE OWNERS", "/super_admin/merchants"

  layout "super_admin"

  def index
    @merchants = User.merchants.sort_by { |u| u.id }
  end

  def new
    @user= User.new
    #render :layout => false
  end

  def show
    user = User.find_by_id(params[:id])
    @merchant = user
    render :layout => false
  end


  def create
    unless params[:user][:date_of_birth].blank?
      time = Time.strptime(params[:user][:date_of_birth], '%m-%d-%Y')
      params[:user][:date_of_birth] = time.strftime("%Y/%m/%d")
    end
    @user = User.new(merchant_params)
    @user.roles << Role.find_by_name("merchant")
    if @user.valid?
      if register_merchant
        if @user.save
          seed_shop_hours(@user.shop)
          flash[:notice] = "Merchant was successfully Added."
          render :json => {:success => true, :url => super_admin_merchants_path}.to_json
        else
          @customer.delete if @customer.present?
          @errors = @user.errors
          render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
        end
      else
        @errors = @user.errors
        render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
      end
    else
      @errors = @user.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  # def register_merchant
  #   phone_number = nil
  #   unless params[:user][:shop_attributes][:phone].blank?
  #     phone_number = params[:user][:shop_attributes][:phone].gsub("-", "")
  #   end
  #   @result = Braintree::MerchantAccount.create(
  #       :individual => {
  #           :first_name => @user.name,
  #           :last_name => @user.name,
  #           :email => @user.email,
  #           :phone => phone_number,
  #           :date_of_birth => params[:user][:date_of_birth],
  #           #:ssn => "456-45-4567",
  #           :address => {
  #               :street_address => params[:user][:shop_attributes][:address],
  #               :locality => params[:user][:shop_attributes][:city],
  #               :region => params[:user][:shop_attributes][:state],
  #               :postal_code => params[:user][:shop_attributes][:zip_code]
  #           }
  #       },
  #       :funding => {
  #           :destination => Braintree::MerchantAccount::FundingDestination::Bank,
  #           :email => @user.email,
  #           :mobile_phone => phone_number,
  #           :account_number => params[:account_number],
  #           :routing_number => params[:routing_number]
  #       },
  #       :tos_accepted => true,
  #       :master_merchant_account_id => 'rac'
  #   # :master_merchant_account_id => '925frrrj5t56mf2g'
  #   #:id => "blue_ladders_store"
  #   )
  #   if @result.success?
  #     @user.customer_id = @result.merchant_account.id
  #     return true
  #   else
  #     @brain_errors = @result.errors
  #     @result.errors.each { |error| @user.errors.add(" ", error.message) }
  #     return false
  #   end
  # end

  # def register_merchant
  #   phone_number = nil
  #   unless params[:user][:shop_attributes][:phone].blank?
  #     phone_number = params[:user][:shop_attributes][:phone].gsub("-", "")
  #   end
  #   @result = Braintree::MerchantAccount.create(
  #       :individual => {
  #           :first_name => @user.name,
  #           :last_name => @user.name,
  #           :email => @user.email,
  #           :phone => phone_number,
  #           :date_of_birth => params[:user][:date_of_birth],
  #           #:ssn => "456-45-4567",
  #           :address => {
  #               :street_address => params[:user][:shop_attributes][:address],
  #               :locality => params[:user][:shop_attributes][:city],
  #               :region => params[:user][:shop_attributes][:state],
  #               :postal_code => params[:user][:shop_attributes][:zip_code]
  #           }
  #       },
  #       :funding => {
  #           :destination => Braintree::MerchantAccount::FundingDestination::Bank,
  #           :email => @user.email,
  #           :mobile_phone => phone_number,
  #           :account_number => params[:account_number],
  #           :routing_number => params[:routing_number]
  #       },
  #       :tos_accepted => true,
  #       :master_merchant_account_id => 'rac'
  #   # :master_merchant_account_id => '925frrrj5t56mf2g'
  #   #:id => "blue_ladders_store"
  #   )
  #   if @result.success?
  #     @user.customer_id = @result.merchant_account.id
  #     return true
  #   else
  #     @brain_errors = @result.errors
  #     @result.errors.each { |error| @user.errors.add(" ", error.message) }
  #     return false
  #   end
  # end

  def register_merchant
    begin
      stripe_account = Stripe::Account.create(
          :managed => false,
          :country => 'US',
          :email => @user.email
      )
      @customer = Stripe::Customer.create(
          :description => "This customer is a merchant",
          :email => @user.email
      )
      bank_account = @customer.sources.create(:source => params[:stripeToken])
      @user.customer_id = @customer.id
      @user.shop.bank_account_id = bank_account.id
      @user.shop.stripe_account_id = stripe_account.id
      return true
    rescue Stripe::StripeError => e
      @customer.delete if @customer.present?
      body = e.json_body
      err = body[:error]
      @user.errors.add(:customer_id, err[:message])
      return false
    end
  end


  # def edit
  #   @user = User.find_by_id(params[:id])
  #   merchant_account = Braintree::MerchantAccount.find(@user.customer_id)
  #   @account_number = merchant_account.funding_details.account_number_last_4
  #   @routing_number = merchant_account.funding_details.routing_number
  #   #render :layout => false
  # end

  def edit
    @user = User.find_by_id(params[:id])
    customer = Stripe::Customer.retrieve(@user.customer_id)
    bank_account = customer.sources.retrieve(@user.shop.bank_account_id)
    @account_number = bank_account.last4
    @routing_number = bank_account.routing_number
    # render :json => {:customer => customer, :bank_account => bank_account}
  end

  def update
    @user = User.find_by_id(params[:id])
    #if @user.update_attributes(merchant_params)
    #  flash[:notice] = "Merchant was successfully Added."
    #  render :json => {:success => true, :url => super_admin_merchants_path}.to_json
    #else
    #  @errors = @user.errors
    #  render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    #end
    unless params[:user][:date_of_birth].blank?
      time = Time.strptime(params[:user][:date_of_birth], '%m-%d-%Y')
      params[:user][:date_of_birth] = time.strftime("%Y/%m/%d")
    end
    if update_merchant_bank_account
      puts "CCCC"
      successfully_updated = if needs_password?(@user, params)
                               @user.update(merchant_params)
                             else
                               params[:user].delete(:password)
                               @user.update_without_password(merchant_params)
                             end
      if successfully_updated
        flash[:notice] = "Merchant was successfully Added."
        render :json => {:success => true, :url => super_admin_merchants_path}.to_json
      else
        @errors = @user.errors
        render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
      end
    else
      @errors = @user.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def update_merchant_bank_account
    phone_number = nil
    unless params[:user][:shop_attributes][:phone].blank?
      phone_number = params[:user][:shop_attributes][:phone].gsub("-", "")
    end
    merchant = User.find_by_id(@user.id)
    begin
      customer = Stripe::Customer.retrieve(merchant.customer_id)
      bank_account = customer.sources.retrieve(merchant.shop.bank_account_id)
      # bank_account.metadata[""] = ""
      abc = bank_account.save
      return true
    rescue Exception => e
      body = e.message
      # err = body[:error]
      @user.errors.add("", body)
      return false
    end
  end

  def tax_ratios
    @preferences = Preferences.last
  end

  def update_tax_ratios
    preferences = Preferences.last
    if preferences.update_attributes(:tax_percentage => params[:preferences][:tax_percentage], :convenience_fee => params[:preferences][:convenience_fee], :reward => params[:preferences][:reward], :cash_convenience_fee => params[:preferences][:cash_convenience_fee])
      render :json => {:success => true, :message => "Updated Successfully"}
    else
      render :json => {:success => false, :message => preferences.errors.last}
    end
  end

  # def update_merchant_bank_account
  #   phone_number = nil
  #   unless params[:user][:shop_attributes][:phone].blank?
  #     phone_number = params[:user][:shop_attributes][:phone].gsub("-", "")
  #   end
  #   merchant = User.find_by_id(@user.id)
  #   result = Braintree::MerchantAccount.update(
  #       merchant.customer_id,
  #       :individual => {
  #           :first_name => params[:user][:name],
  #           :last_name => params[:user][:name],
  #           :email => params[:user][:email],
  #           :phone => phone_number,
  #           :date_of_birth => params[:user][:date_of_birth],
  #           :address => {
  #               :street_address => params[:user][:shop_attributes][:address],
  #               :locality => params[:user][:shop_attributes][:city],
  #               :region => params[:user][:shop_attributes][:state],
  #               :postal_code => params[:user][:shop_attributes][:zip_code]
  #           }
  #       },
  #       :funding => {
  #           :destination => Braintree::MerchantAccount::FundingDestination::Bank,
  #           :email => params[:user][:email],
  #           :mobile_phone => phone_number,
  #           :account_number => params[:account_number],
  #           :routing_number => params[:routing_number]
  #       })
  #   if result.success?
  #     return true
  #   else
  #     #@brain_errors = result.errors
  #     #render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
  #     #return false
  #     @brain_errors = result.errors
  #     result.errors.each { |error| @user.errors.add(" ", error.message) }
  #     return false
  #   end
  # end


  def disable_merchant
    @user = User.find_by_id(params[:id])
    if params[:status] == 'active'
      begin
        customer = Stripe::Customer.retrieve(@user.customer_id)
        bank_account = customer.sources.retrieve(@user.shop.bank_account_id)
        if bank_account.status == 'verified'
          @user.update_attributes(:status => params[:status], :is_verified => true)
          @merchants = User.merchants
          render :partial => "super_admin/merchants/list"
        else
          @user.update_attributes(:status => 'inactive')
          render :text => "false"
        end
      rescue Stripe::StripeError => e
        @user.update_attributes(:status => 'inactive', :is_verified => false)
        render :text => "false"
      end
    else
      @user.update_attributes(:status => params[:status])
      @merchants = User.merchants
      render :partial => "super_admin/merchants/list"
    end
  end

  def verify_account
    user = User.find_by_id(params[:merchant_id])
    begin
      bank_status = nil
      customer = Stripe::Customer.retrieve(user.customer_id)
      bank_account = customer.sources.retrieve(user.shop.bank_account_id)
      if bank_account.status != 'verified'
        bank_testing = bank_account.verify(:amounts => [params[:transaction1], params[:transaction2]])
        bank_status = bank_testing.status
      else
        bank_status = 'verified'
      end
      if bank_status == 'verified'
        user.update_attributes(:is_verified => true, :status => 'active')
        render :text => 'true'
      else
        user.update_attributes(:is_verified => false, :status => 'inactive')
        render :text => 'false'
      end
    rescue Stripe::StripeError => e
      user.update_attributes(:is_verified => false, :status => 'inactive')
      body = e.json_body
      err = body[:error]
      render :text => 'false'
    end
  end


  #def merchant_params
  #  params.require(:merchant).permit(:name, :parent_id, :parent_type)
  #end

  private

  # def seed_shop_hours(shop)
  #   start_time = "8:00 am"
  #   end_time = "07:00 pm"
  #   ShopHour.create!(:shop_id => shop.id, :name => 'MONDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
  #   ShopHour.create!(:shop_id => shop.id, :name => 'TUESDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
  #   ShopHour.create!(:shop_id => shop.id, :name => 'WEDNESDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
  #   ShopHour.create!(:shop_id => shop.id, :name => 'THURSDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
  #   ShopHour.create!(:shop_id => shop.id, :name => 'FRIDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
  #   ShopHour.create!(:shop_id => shop.id, :name => 'SATURDAY', :start_time => start_time, :end_time => end_time, :is_open => true)
  #   ShopHour.create!(:shop_id => shop.id, :name => 'SUNDAY', :start_time => start_time, :end_time => end_time, :is_open => false)
  # end

  def seed_shop_hours(shop)
    slot1_start_time = '12:00 am'
    slot1_end_time = '04:00 am'
    slot2_start_time = '12:00 pm'
    slot2_end_time = '11:59 pm'
    mon_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'MONDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => true)
    ShopDailySlot.create!(:shop_hour_id => mon_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => mon_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
    tue_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'TUESDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => true)
    ShopDailySlot.create!(:shop_hour_id => tue_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => tue_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
    wed_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'WEDNESDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => true)
    ShopDailySlot.create!(:shop_hour_id => wed_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => wed_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
    thu_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'THURSDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => true)
    ShopDailySlot.create!(:shop_hour_id => thu_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => thu_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
    fri_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'FRIDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => true)
    ShopDailySlot.create!(:shop_hour_id => fri_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => fri_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
    sat_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'SATURDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => true)
    ShopDailySlot.create!(:shop_hour_id => sat_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => sat_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
    sun_shop_hour = ShopHour.create!(:shop_id => shop.id, :name => 'SUNDAY', :start_time => slot1_start_time, :end_time => slot1_end_time, :is_open => false)
    ShopDailySlot.create!(:shop_hour_id => sun_shop_hour.id, :name => 'slot1', :start_time => slot1_start_time, :end_time => slot1_end_time)
    ShopDailySlot.create!(:shop_hour_id => sun_shop_hour.id, :name => 'slot2', :start_time => slot2_start_time, :end_time => slot2_end_time)
  end

  def needs_password?(user, params)
    params[:user][:password].present?
  end

  def merchant_params
    params.require(:user).permit(:current_password, :id, :name, :email, :customer_id, :code, :city, :state, :zip, :country, :address, :phone, :zip, :date_of_birth, :password, :password_confirmation, :shop_attributes => [:id, :user_id, :name, :phone, :address, :status, :hours, :city, :state, :zip_code, :country, :bank_account_id])
  end


end
