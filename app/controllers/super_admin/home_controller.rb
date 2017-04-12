class SuperAdmin::HomeController < SuperAdmin::SuperAdminController

  def index
    redirect_to super_admin_categories_path
  end

end
