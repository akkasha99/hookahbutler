class SuperAdmin::CustomersController < SuperAdmin::SuperAdminController

  add_breadcrumb "CUSTOMERS", "/super_admin/customers"
  layout "super_admin"

  def index
    @customers = User.customers
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


  # def create
  #   @user = User.new(merchant_params)
  #   @user.roles << Role.find_by_name("customer")
  #   result = Braintree::Customer.create(
  #       :first_name => params[:user][:name],
  #       :email => params[:user][:email]
  #   )
  #   if result.success?
  #     @user.customer_id = result.customer.id
  #     if @user.save
  #       UserMailer.welcome(@user).deliver
  #       flash[:notice] = "Customer was successfully Added."
  #       render :json => {:success => true, :url => super_admin_customers_path}.to_json
  #     else
  #       @errors = @user.errors
  #       render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
  #     end
  #   else
  #     @errors = @user.errors
  #     render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
  #   end
  # end

  def create
    @user = User.new(merchant_params)
    @user.roles << Role.find_by_name("customer")
    if @user.valid? && create_stripe_customer(@user)
      if @user.save
        UserMailer.welcome(@user).deliver
        flash[:notice] = "Customer was successfully Added."
        render :json => {:success => true, :url => super_admin_customers_path}.to_json
      else
        @errors = @user.errors
        render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
      end
    else
      @errors = @user.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def register_customer
    customer["credit_card"] = credit_card
    result = Braintree::Customer.create(customer)
    if result.success?
      self.customer_id = result.customer.id
      self.code = (0...8).map { 65.+(rand(26)).chr }.join
      self.name = customer["name"]
      self.address = credit_card["billing_address"]["street_address"]
      self.phone = customer["phone"]
      self.city = credit_card["billing_address"]["city"]
      self.state = credit_card["billing_address"]["state"]
      self.country = customer["country_name"]
      return true
    else
      codes = []
      result.errors.each { |a| codes << a.code }
      self.errors.add("Braintree:", codes.join(","))
      return false
    end
  end

  def edit
    @user = User.find_by_id(params[:id])
    #render :layout => false
  end

  def update
    @user = User.find_by_id(params[:id])
    successfully_updated = if needs_password?(@user, params)
                             @user.update(merchant_params)
                           else
                             params[:user].delete(:password)
                             @user.update_without_password(merchant_params)
                           end
    if successfully_updated
      flash[:notice] = "Customer was successfully Added."
      render :json => {:success => true, :url => super_admin_customers_path}.to_json
    else
      @errors = @user.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def disable_customer
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(:status => params[:status])
      @customers = User.customers
      render :partial => "super_admin/customers/list"
    end
  end


  #def merchant_params
  #  params.require(:merchant).permit(:name, :parent_id, :parent_type)
  #end

  private

  def create_stripe_customer(user)
    begin
      result = Stripe::Customer.create(
          :description => "Customer for #{User.last.email}",
          :email => params[:user][:email],
      )
      user.customer_id = result.id
      return true
    rescue Stripe::StripeError => e
      body = e.json_body
      err = body[:error]
      user.errors.add("", err[:message])
      return false
    end
  end

  def needs_password?(user, params)
    params[:user][:password].present?
  end

  def merchant_params
    params.require(:user).permit(:registration_id, :current_password, :id, :name, :email, :phone, :password, :password_confirmation, :asset_attributes => [:id, :owner_id, :owner_type, :owner, :avatar, :avatar_file_name, :avatar_content_type, :avatar_file_size])
  end


end
