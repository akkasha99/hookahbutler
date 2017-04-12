class Users::SessionsController < Devise::SessionsController
  layout :resolve_layout


  def super_admin_new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
    #render :layout => false
  end

  #def create
  #  self.resource = warden.authenticate!(auth_options)
  #  set_flash_message(:notice, :signed_in) if is_flashing_format?
  #  sign_in(resource_name, resource)
  #  yield resource if block_given?
  #  respond_with resource, :location => after_sign_in_path_for(resource)
  #end

  #def create
  #  resource = User.find_for_database_authentication(:email => params[:user][:email])
  #  return invalid_login_attempt unless resource
  #  if resource.valid_password?(params[:user][:password])
  #    sign_in(resource_name, resource)
  #    render :json => {:success => true, :user_id => resource.id, :url => after_sign_in_path_for(resource)}
  #    return
  #  end
  #end
  #
  #def invalid_login_attempt
  #  warden.custom_failure!
  #  render :json => {:success => false, :errors => ["Invalid email or password."]}
  #end

  def create
    resource = User.find_for_database_authentication(:email => params[:user][:email])
    unless resource.blank?
      if resource.valid_password?(params[:user][:password])
        sign_in(resource_name, resource)
        render :json => {:success => true, :user_id => resource.id, :url => after_sign_in_path_for(resource)}
        return
      else
        render :json => {:success => false, :errors => ["Invalid email or password."]}
        return
      end
    else
      render :json => {:success => false, :errors => ["Invalid email or password."]}
      return
    end
  end

  private

  def resolve_layout
    case action_name
      when "new"
        "super_admin_non_login"
      else
        "application"
    end
  end

end
