class SuperAdmin::ProfilesController < SuperAdmin::SuperAdminController

  before_filter :authenticate_user!

  layout "super_admin"

  def profile
    @user = current_user
  end

  def update
    @user = User.find_by_id(current_user.id)
    successfully_updated = if needs_password?(@user, params)
                             @user.update(user_params)
                           else
                             params[:user].delete(:password)
                             @user.update_without_password(user_params)
                           end
    if successfully_updated
      flash[:notice] = "Super Admin was successfully Updated."
      render :json => {:success => true, :url => super_admin_customers_path}.to_json
    else
      @errors = @user.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  private

  def needs_password?(user, params)
    params[:user][:password].present?
  end

  def user_params
    params.require(:user).permit(:registration_id, :current_password, :id, :name, :email, :phone, :password, :password_confirmation, asset_attributes: [:id, :owner_id, :owner_type, :owner, :avatar, :avatar_file_name, :avatar_content_type, :avatar_file_size])
  end


end
