class SuperAdmin::MetaCategoriesController < SuperAdmin::SuperAdminController
  add_breadcrumb "META CATEGORIES", "/super_admin/categories"
  layout "super_admin"

  def index
    @meta_categories = MetaCategory.all
  end

  def new
    @meta_category = MetaCategory.new
    #render :layout => false
  end

  def create
    @meta_category = MetaCategory.new(meta_category_params)
    if @meta_category.save
      flash[:notice] = "MetaCategory was successfully Added."
      render :json => {:success => true, :url => super_admin_meta_categories_path}.to_json
    else
      @errors = @meta_category.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def edit
    @meta_category = MetaCategory.find_by_id(params[:id])
    #render :layout => false
  end

  def update
    @meta_category = MetaCategory.find_by_id(params[:id])
    if @meta_category.update_attributes(meta_category_params)
      flash[:notice] = "Category was successfully Added."
      render :json => {:success => true, :url => super_admin_meta_categories_path}.to_json
    else
      @errors = @meta_category.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def meta_category_params
    params.require(:meta_category).permit(:name, :category_id, :parent_type)
  end


end
