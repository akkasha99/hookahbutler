class SuperAdmin::CouponCodesController < ApplicationController
  layout "super_admin"

  def new
    @coupon_code = CouponCode.new
    @coupon_codes_setting = CouponCode.new
  end

  def edit
    @coupon_code =Blog.find(params[:id])
  end

  def create_setting
    coupin_code = CouponCode.where(:is_setting => false).first
    if coupin_code.present?
      coupin_code.update_attributes(:coupon_value => params[:coupon_code][:coupon_value], :coupon_type => params[:coupon_code][:coupon_type], :number_of_days => params[:coupon_code][:number_of_days])
      flash[:notice] = "Coupon Code was successfully Updated."
      render :json => {:success => true, :url => '/super_admin/coupon_codes'}.to_json
    else
      coupin_code = CouponCode.new(:is_send => params[:coupon_code][:is_send], :promotion_code_user_type => params[:coupon_code][:promotion_code_user_type], :user_id => params[:coupon_code][:user_id], :coupon_value => params[:coupon_code][:coupon_value], :coupon_type => params[:coupon_code][:coupon_type], :number_of_days => params[:coupon_code][:number_of_days], :is_setting => false)
      if coupin_code.save
        flash[:notice] = "Coupon Code was successfully Added."
        render :json => {:success => true, :url => '/super_admin/coupon_codes'}.to_json
      else
        flash[:notice] = "Error: Coupon Code Not Added."
        render :json => {:success => false, :url => '/super_admin/coupon_codes'}.to_json
      end
    end

  end

  def create
    unless params[:coupon_code][:valid_from].blank?
      time = Time.strptime(params[:coupon_code][:valid_from], '%m-%d-%Y')
      params[:coupon_code][:valid_from] = time.strftime("%Y/%m/%d")
    end
    unless params[:coupon_code][:valid_to].blank?
      time = Time.strptime(params[:coupon_code][:valid_to], '%m-%d-%Y')
      params[:coupon_code][:valid_to] = time.strftime("%Y/%m/%d")
    end
    if params[:coupon_code][:per_user] == ""
      params[:coupon_code][:per_user] = 0
    end
    if params[:coupon_code][:per_coupon] == ""
      params[:coupon_code][:per_coupon] = 0
    end
    @coupon_code = CouponCode.new(params_coupon_code)
    if @coupon_code.save
      flash[:notice] = ":Coupon Code was successfully Added."
      user_array = []
      if @coupon_code.is_send == true
        if @coupon_code.coupon_group != "none"
          # if @coupon_code.promotion_code_user_id == 0
          if @coupon_code.coupon_group == "all"
            # "coupon_group"=>"customers", "promotion_code_user_id"=>["All"]}
            if (params[:coupon_code][:promotion_code_user_id] == ["All"])
              users = User.all
              users.each do |a|
                @coupon_code_users = CouponCodeUser.create(:coupon_code_id => @coupon_code.id, :user_id => a.id)
                user_array << a
              end
            else
              unless params[:coupon_code][:promotion_code_user_id].blank?
                params[:coupon_code][:promotion_code_user_id].each do |a|
                  @coupon_code_users = CouponCodeUser.create(:coupon_code_id => @coupon_code.id, :user_id => a.to_i)
                  user = User.find(a)
                  user_array << user
                end
              end
            end
          elsif @coupon_code.coupon_group == "customers"
            if (params[:coupon_code][:promotion_code_user_id] == ["All"])
              users = User.customers
              users.each do |a|
                @coupon_code_users = CouponCodeUser.create(:coupon_code_id => @coupon_code.id, :user_id => a.id)
                user_array << a
              end
            else
              unless params[:coupon_code][:promotion_code_user_id].blank?
                params[:coupon_code][:promotion_code_user_id].each do |a|
                  @coupon_code_users = CouponCodeUser.create(:coupon_code_id => @coupon_code.id, :user_id => a.to_i)
                  user = User.find(a)
                  user_array << user
                end
              end
            end
          end
          user_array.each do |user|
            send_coupon_code_push_notification(@coupon_code, user)
          end
          # emails = CouponEmail.new(@coupon_code, user_array, request.protocol, request.host_with_port)
          # Delayed::Job.enqueue(emails)
          # else
          #   if @coupon_code.promotion_code_user.present?
          #     user = @coupon_code.promotion_code_user
          #     user_array << user
          #     emails = CouponEmail.new(@coupon_code, user_array, request.protocol, request.host_with_port)
          #
          #     Delayed::Job.enqueue(emails)
          #   end
          # end
        end
      end
      #redirect_to super_admin_blogs_path
      render :json => {:success => true, :url => super_admin_coupon_codes_path}.to_json
    else
      render :new
      @errors = @coupon_code.errors
      #@message = nil
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def send_coupon_code_push_notification(coupon_code, user)
    message = "your coupon code is #{coupon_code.code}"
    data = { :success => "success", :message => message}
    puts "00000000000000000000000000000000000000000000000000000000000000",data.inspect
    notification = Houston::Notification.new(:device => user.device_id)
    notification.badge = 0
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = data
    notification.alert = message
    certificate = File.read("config/Customer_Production.pem")
    pass_phrase = "push"
    connection = Houston::Connection.new("apn://gateway.push.apple.com:2195", certificate, pass_phrase)
    connection.open
    connection.write(notification.message)
    connection.close
  end

  def update
    @coupon_code = Blog.find_by_id(params[:id])
    if @coupon_code.update_attributes(params[:blog])
      flash[:notice] = "Blog was successfully updated."
      redirect_to super_admin_blogs_path
    else
      render :edit
    end
  end

  def index
    @coupon_code =CouponCode.new
    @users = User.all
    @coupon_codes = CouponCode.all.where(:is_setting => true)
    @coupon_code_setting = CouponCode.where(:is_setting => false).first
    @coupon_code_setting = CouponCode.new() if @coupon_code_setting.blank?
    @coupon_codes = @coupon_codes.paginate(:page => params[:page], :per_page => 10)
    if params[:page].present?
      render :partial => "super_admin/coupon_codes/coupon_list"
    end
  end

  def get_users
    if params[:id] == "all"
      @users = User.all
    elsif params[:id] == "customers"
      @users = User.customers
    elsif params[:id] == "drivers"
      @users = User.drivers
    elsif params[:id] == "none"
      @users = []
    end
    render :partial => "super_admin/coupon_codes/user_drop_down"
  end

  def search_coupon
    @coupon_codes = CouponCode.all
    if params[:code].present?
      @coupon_codes = @coupon_codes.where(:code => params[:code])
    end
    if params[:valid_from].present?
      @coupon_codes = @coupon_codes.select { |coupon_code| coupon_code.valid_from.strftime("%m-%d-%Y").downcase >= params[:valid_from].downcase }
    end
    if params[:valid_to].present?
      @coupon_codes = @coupon_codes.select { |coupon_code| coupon_code.valid_to.strftime("%m-%d-%Y").downcase <= params[:valid_to].downcase }
    end
    if params[:status].present?
      if params[:status] == "Open"
        @coupon_codes = @coupon_codes.select { |coupon_code| coupon_code.status == params[:status] }
      elsif params[:status] == "Expired"
        @coupon_codes = @coupon_codes.select { |coupon_code| coupon_code.status == params[:status] }
      end
    end
    if params[:last_name].present?
      @coupon_codes = @coupon_codes.select { |coupon_code| coupon_code.promotion_code_user.present? ? coupon_code.promotion_code_user.last_name == params[:last_name] : nil }
    end
    @coupon_codes = @coupon_codes.paginate(:page => params[:page], :per_page => 10)
    render :partial => "super_admin/coupon_codes/coupon_list"
    #sss
  end

  def disable_blog
    @coupon_code = Blog.find_by_id(params[:id])
    if @coupon_code.update_attributes(:is_archived => params[:status])
      @coupon_codes = Blog.all
      render :partial => "super_admin/blogs/list"
    end
  end

  private

  def params_coupon_code
    params.require(:coupon_code).permit(:is_send, :promotion_code_user_id, :promotion_code_user_type, :user_id, :code, :coupon_value, :coupon_type, :valid_from, :valid_to, :per_user, :per_coupon, :number_to_share, :coupon_group, :is_setting)
  end
end

