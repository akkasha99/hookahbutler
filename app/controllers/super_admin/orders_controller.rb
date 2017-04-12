class SuperAdmin::OrdersController < SuperAdmin::SuperAdminController
  add_breadcrumb "ORDERS", "/super_admin/orders"
  layout "super_admin"

  def index
    @orders = Order.all.order("id desc")
    @categories = Category.all
  end

  def edit
    @order = Order.find_by_id(params[:id])
    @credit_card = nil
    unless @order.card_id.blank?
      #@credit_card = Braintree::CreditCard.find(@order.card_id)
    end
    #render :layout => false
  end

  def show
    @order = Order.find_by_id(params[:id])
    @credit_card = nil
    unless @order.card_id.blank?
      #@credit_card = Braintree::CreditCard.find(@order.card_id)
    end
  end

  def update
    @order = Order.find_by_id(params[:id])
    if @order.update_attributes(order_param)
      flash[:notice] = "Order was successfully Added."
      render :json => {:success => true, :url => super_admin_orders_path}.to_json
    else
      @category = @order.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def order_param
    params.require(:order).permit(:shop_id, :user_id, :order_number, :status, :total_amount)
  end


end
