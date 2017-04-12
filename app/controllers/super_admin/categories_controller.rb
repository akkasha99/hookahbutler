class SuperAdmin::CategoriesController < SuperAdmin::SuperAdminController
  add_breadcrumb "CATEGORIES", "/super_admin/categories"
  layout "super_admin"

  def index
    @categories = Category.where(:parent_id => nil)

  end

  def new
    @category = Category.new
    #render :layout => false
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:notice] = "Category was successfully Added."
      render :json => {:success => true, :url => super_admin_categories_path}.to_json
    else
      @errors = @category.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def edit
    @category = Category.find_by_id(params[:id])
    #render :layout => false
  end

  def update
    @category = Category.find_by_id(params[:id])
    if @category.update_attributes(category_params)
      flash[:notice] = "Category was successfully Added."
      render :json => {:success => true, :url => super_admin_categories_path}.to_json
    else
      @category = @user.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def category_params
    params.require(:category).permit(:name, :parent_id, :parent_type)
  end


end
