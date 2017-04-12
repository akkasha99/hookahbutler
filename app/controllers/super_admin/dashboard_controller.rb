class SuperAdmin::DashboardController < SuperAdmin::SuperAdminController
  #before_filter :set_partner, :except => [:create]
  layout "super_admin"

  def index
    #@customers_count = User.customers.size
    #@drivers_count = User.drivers.size
    #@delivered_jobs_count = User.total_delivered_jobs.size
    #@ziply_revenue = TransactionHistory.sum(:ziply_revenue) # => 4562
    #@driver_revenue = TransactionHistory.sum(:driver_amount) # => 4562
    @stores = User.merchants.size
    @new_stores = User.merchants.where("Date(users.created_at) > ?", Date.today - 7.day).size
    @customers = User.customers.size
    @new_customers = User.customers.where("Date(users.created_at) > ?", Date.today - 7.day).size
    @orders = Order.all.size
    @new_orders = Order.where("Date(created_at) > ?", Date.today - 7.day).size
    @sale = Order.where(:status => 'accepted').sum('total_amount')
    @today_sale = Order.where("Date(created_at) = ? and status= ?", Date.today, 'accepted').sum('total_amount')
    @reviews = Review.all.size
    @today_reviews = Review.where("Date(created_at) > ?", Date.today - 7.day).size
    @active_stores = Shop.all.sort_by { |shop| shop.orders.size }
    @recent_orders = Order.order("created_at desc")
  end

  def get_dashboard
    start_date = params[:start_date]
    end_date = params[:end_date]
    @stores = User.merchants.where("users.created_at between ? and ?", start_date, end_date).size
    @new_stores = User.merchants.where("Date(users.created_at) > ? ", Date.today - 7.day).size
    @customers = User.customers.where("users.created_at between ? and ?", start_date, end_date).size
    @new_customers = User.customers.where("Date(users.created_at) > ?", Date.today - 7.day).size
    @orders = Order.where("orders.created_at between ? and ?", start_date, end_date).size
    @new_orders = Order.where("Date(created_at) > ?", Date.today - 7.day).size
    @sale = Order.where("orders.created_at between ? and ? and status =?", start_date, end_date, 'accepted').sum('total_amount')
    @today_sale = Order.where("Date(created_at) = ? and status= ?", Date.today, 'accepted').sum('total_amount')
    @reviews = Review.where("reviews.created_at between ? and ?", start_date, end_date).size
    @today_reviews = Review.where("Date(created_at) > ?", Date.today - 7.day).size
    render :partial => "/super_admin/dashboard/dash_list"
  end

  def get_active_store
    start_date = params[:start_date]
    end_date = params[:end_date]
    @active_stores = Shop.includes(:orders).where("orders.created_at between ? and ?", start_date, end_date.to_date + 1.day).sort_by { |shop| shop.orders.size }
    render :partial => "/super_admin/dashboard/active_stores"
  end

  def get_recent_orders
    start_date = params[:start_date]
    end_date = params[:end_date]
    @recent_orders = Order.where("orders.created_at between ? and ?", start_date, end_date.to_date + 1.day).order("created_at desc")
    render :partial => "/super_admin/dashboard/recent_orders"
  end

end
