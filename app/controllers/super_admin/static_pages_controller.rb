class SuperAdmin::StaticPagesController < ApplicationController
  def privacy_policy
    @user = User.new
    render 'privacy_policy', :layout => 'static_pages_layout'
  end

  def terms_and_conditions_user
    @user = User.new
    render 'terms_and_conditions_user', :layout => 'static_pages_layout'
  end

  def terms_and_conditions_merchant
    @user = User.new
    render 'terms_and_conditions_merchant', :layout => 'static_pages_layout'
  end
end
