class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  #def after_sign_in_path_for(resource_or_scope)
  #  if current_user.present? and !current_user.customer?
  #    "/#{current_user.role}s"
  #  elsif current_user.customer?
  #    sign_out_path
  #  else
  #    root_url
  #  end
  #end

  #before_filter :configure_permitted_parameters, if: :devise_controller?

  #def configure_permitted_parameters
  #  puts "IIIII"
  #  devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, shop_attributes: [:id, :user_id, :name, :phone, :address]) }
  #  #devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:is_disabled, :email_sent_at, :send_email, :driver_id, :authentication_token, :status, :facebook_uid, :customer_id, :first_name, :last_name, :email, :password, :password_confirmation, profile_attributes: [:id, :user_id, :phone_number, :phone_type_id, :vehicle_type_id]) }
  #end

end
