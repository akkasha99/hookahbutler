class SuperAdmin::AnalyticsController < SuperAdmin::SuperAdminController
  #before_filter :set_partner, :except => [:create]
  layout "super_admin"

  def index
    @total_revenue =Order.where("total_amount is not null and status = 'accepted'").sum('total_amount')
    @total_sales = Order.where("total_amount is not null").sum('total_amount').round(2)
    @total_customers =User.customers.size
    @new_customers =User.customers.where("Date(users.created_at) >?", Date.today - 7.days).size
    @repeated_customers =User.customers
    @repeated_customers = @repeated_customers.select { |repeated_customer| repeated_customer.orders.size > 1 }.size
    #@drinks_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).where("categories.name = 'HOT DRINKS' or categories.name = 'COLD DRINKS'").size
    @drinks_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'DRINKS' : line_item.item.category.parent.name == 'DRINKS' }.sum(&:quantity)
    @food_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'FOOD' : line_item.item.category.parent.name == 'FOOD' }.sum(&:quantity)
    #@add_ons = OrderAddOn.where("total_price is not null").sum(&:quantity)
    @add_ons = AddOn.all.size
    @total_orders =Order.all.size
    @avg_order = Order.average(:total_amount)
    @avg_order_time = Order.average(:estimated_time)
    @refunded_order = 0
    @refunded_order_amount = 0
    @sales_array= []
    @revenue_array= []
    @order_array = []
    @customer_array = []
    @order_array = []
    @categories = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    12.times.each do |i|
      sales_amount = 0.0
      revenue_amount = 0.0
      orders = Order.where("date_part('month', created_at) = ?", i + 1)
      orders.map { |order| sales_amount += order.total_amount unless order.total_amount.blank? }
      orders.map { |order| revenue_amount += order.total_amount if order.total_amount.present? and order.status == 'accepted' }
      @sales_array << sales_amount
      @revenue_array << revenue_amount
      @customer_array << User.customers.where("date_part('month', users.created_at) = ?", i + 1).size
      @order_array << Order.where("date_part('month', created_at) = ?", i + 1).size
    end
  end

  def get_analytics
    start_date = params[:start_date]
    end_date = params[:end_date]
    @total_revenue =Order.where("total_amount is not null and status = 'accepted' and orders.created_at between ? and ?", start_date, end_date).sum('total_amount')
    @total_sales = Order.where("total_amount is not null and orders.created_at between ? and ?", start_date, end_date).sum('total_amount').round(2)
    @total_customers =User.customers.where("users.created_at between ? and ?", start_date, end_date).size
    @new_customers =User.customers.where(" Date(users.created_at) >?", Date.today - 7.days).size
    @repeated_customers =User.customers
    @repeated_customers = @repeated_customers.select { |repeated_customer| repeated_customer.orders.size > 1 }.size
    #@drinks_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).where("categories.name = 'HOT DRINKS' or categories.name = 'COLD DRINKS'").size
    @drinks_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'DRINKS' : line_item.item.category.parent.name == 'DRINKS' }.sum(&:quantity)
    @food_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'FOOD' : line_item.item.category.parent.name == 'FOOD' }.sum(&:quantity)
    #@add_ons = OrderAddOn.where("total_price is not null").sum(&:quantity)
    @add_ons = AddOn.all.size
    @total_orders =Order.where("created_at between ? and ?", start_date, end_date).size
    @avg_order = Order.average(:total_amount)
    @avg_order_time = Order.average(:estimated_time)
    @refunded_order = 0
    @refunded_order_amount = 0
    @sales_array= []
    @revenue_array= []
    @order_array = []
    @customer_array = []
    @order_array = []
    @categories = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    12.times.each do |i|
      sales_amount = 0.0
      revenue_amount = 0.0
      orders = Order.where("date_part('month', created_at) = ?", i + 1)
      orders.map { |order| sales_amount += order.total_amount unless order.total_amount.blank? }
      orders.map { |order| revenue_amount += order.total_amount if order.total_amount.present? and order.status == 'accepted' }
      @sales_array << sales_amount
      @revenue_array << revenue_amount
      @customer_array << User.customers.where("date_part('month', users.created_at) = ?", i + 1).size
      @order_array << Order.where("date_part('month', created_at) = ?", i + 1).size
    end
    render :partial => "/super_admin/analytics/analytic_list"
  end

  def get_order_stats
    if params[:id].blank?
      @total_sales = Order.where("total_amount is not null").sum('total_amount')
      @total_orders =Order.all.size
      @avg_order = Order.average(:total_amount)
      @avg_order_time = Order.average(:estimated_time)
      @refunded_order = 0
      @refunded_order_amount = 0
    else
      @shop = Shop.find_by_user_id(params[:id])
      @total_sales = Order.where("total_amount is not null and shop_id = ?", @shop.id).sum('total_amount')
      @total_orders =Order.where(:shop_id => @shop.id).size
      @avg_order = Order.where(:shop_id => @shop.id).average(:total_amount)
      @avg_order_time = Order.where(:shop_id => @shop.id).average(:estimated_time)
      @refunded_order = 0
      @refunded_order_amount = 0
    end

    render :partial => "super_admin/analytics/orders"

  end

  def get_customer_stats
    if params[:id].blank?
      @total_customers =User.customers.size
      @new_customers =User.customers.where("Date(users.created_at) >?", Date.today - 7.days).size
      @repeated_customers =User.customers
      @repeated_customers = @repeated_customers.select { |repeated_customer| repeated_customer.orders.size > 1 }.size
      @drinks_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'DRINKS' : line_item.item.category.parent.name == 'DRINKS' }.sum(&:quantity)
      @food_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'FOOD' : line_item.item.category.parent.name == 'FOOD' }.sum(&:quantity)
      #@add_ons = OrderAddOn.where("total_price is not null").sum(&:quantity)
      @add_ons = AddOn.all.size
    else
      @shop = Shop.find_by_user_id(params[:id])
      @total_customers = @shop.orders.group_by { |order| order.user_id }.size
      @new_customers = @shop.orders.where("Date(created_at) >?", Date.today - 7.days).group_by { |order| order.user_id }.size
      @repeated_customers =@shop.orders.group_by { |order| order.user }.select { |repeated_customer| repeated_customer.orders.size > 1 }.size
      @drinks_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).where("items.shop_id=?", @shop.id).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'DRINKS' : line_item.item.category.parent.name == 'DRINKS' }.sum(&:quantity)
      @food_bought = OrderLineItem.includes(:item_size => [:item => [:category]]).where("items.shop_id=?", @shop.id).select { |line_item| line_item.item.blank? ? line_item.item_size.item.category.parent.name == 'FOOD' : line_item.item.category.parent.name == 'FOOD' }.sum(&:quantity)
      #@add_ons = OrderAddOn.includes(:order_line_item => [:order]).where("orders.shop_id=? and order_line_items.total_price is not null", @shop.id).sum(&:quantity)
      @add_ons = @shop.add_ons.size
    end

    render :partial => "super_admin/analytics/customers"

  end

  def break_down_by_state
    @state_array =[]
    @shops = Shop.all.group_by { |shop| shop.state }.each do |state, shops|
      customers = 0
      sales = 0
      orders = []
      shops.each do |shop|
        orders += shop.orders
      end
      unless orders.blank?
        customers = orders.group_by { |order| order.user_id }.size
        orders.select { |order| sales+= order.total_amount.blank? ? 0 : order.total_amount}
      end
      h = {:state => state, :orders => orders.size, :customers => customers, :sales => sales}
      @state_array << h
      #@state_hash[state]
      @state_array.each_with_index do |ar|
        puts "SSS", ar[:orders].inspect

      end
    end
  end

end
