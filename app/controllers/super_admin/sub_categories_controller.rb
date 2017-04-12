class SuperAdmin::SubCategoriesController < SuperAdmin::SuperAdminController
  add_breadcrumb "SUB CATEGORIES", "/super_admin/sub_categories"
  layout "super_admin"

  def index
    @sub_categories = Category.where("parent_id IS NOT NULL").order("name asc")
  end

  def new
    @category = Category.new
    #render :layout => false
  end

  def create
    @category = Category.new(category_params)
    unless params[:category][:parent_id].blank?
      if @category.save
        flash[:notice] = "Sub Category was successfully Added."
        render :json => {:success => true, :url => super_admin_sub_categories_path}.to_json
      else
        @errors = @category.errors
        render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
      end
    else
      @category.errors.add(:parent_category, "Can't be Blank")
      @errors = @category.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def update
    @category = Category.find_by_id(params[:id])
    unless params[:category][:parent_id].blank?
      if @category.update_attributes(category_params)
        flash[:notice] = "Category was successfully Added."
        render :json => {:success => true, :url => super_admin_sub_categories_path}.to_json
      else
        @category = @user.errors
        render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
      end
    else
      @category.errors.add(:Parent_category, "Can't be Blank")
      @errors = @category.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def edit
    @category = Category.find_by_id(params[:id])
    #render :layout => false
  end

  def disable_category
    @category = Category.find_by_id(params[:id])
    if @category.update_attributes(:status => params[:status])
      @sub_categories = Category.where("parent_id IS NOT NULL")
      render :partial => "super_admin/sub_categories/list"
    end
  end

  def category_params
    params.require(:category).permit(:name, :parent_id, :parent_type)
  end


end
