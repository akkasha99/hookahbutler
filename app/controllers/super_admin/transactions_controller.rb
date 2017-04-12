class SuperAdmin::TransactionsController < ApplicationController
  layout "super_admin"

  def index
    @shop_charged_transactions = Shop.includes(:order_transactions).where(:order_transactions => {:transaction_type => "cash", :is_charged => true})
    @shop_un_charged_transactions = Shop.includes(:order_transactions).where(:order_transactions => {:transaction_type => "cash", :is_charged => false})
  end

  def charged_shop_transactions
    @charged_transactions = OrderTransaction.where(:transaction_type => "cash", :is_charged => true, :shop_id => params[:id])
  end

  def uncharged_shop_transactions
    @uncharged_transactions = OrderTransaction.where(:transaction_type => "cash", :is_charged => false, :shop_id => params[:id])
  end

  def charge_merchants
    order_transaction = OrderTransaction.where("shop_id=? AND transaction_type=? AND is_charged=?", params[:id], "cash", false)
    if !order_transaction.blank?
      if order_transaction.update_all(:is_charged => true)
      else
        render :text => "false"
      end
    end
    render :text => "success"
  end

end
