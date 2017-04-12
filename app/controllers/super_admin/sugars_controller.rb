class SuperAdmin::SugarsController < SuperAdmin::SuperAdminController
  add_breadcrumb "Sugars", "/super_admin/sugars"
  layout "super_admin"

  def index
    @sugars = Sugar.all
  end

  def new
    @sugar = Sugar.new
    #render :layout => false
  end

  def create
    @sugar = Sugar.new(sugar_params)
    if @sugar.save
      flash[:notice] = "Sugar was successfully Added."
      render :json => {:success => true, :url => super_admin_sugars_path}.to_json
    else
      @errors = @sugar.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def edit
    @sugar = Sugar.find_by_id(params[:id])
    #render :layout => false
  end

  def update
    @sugar = Sugar.find_by_id(params[:id])
    if @sugar.update_attributes(sugar_params)
      flash[:notice] = "Sugar was successfully Added."
      render :json => {:success => true, :url => super_admin_sugars_path}.to_json
    else
      @errors = @sugar.errors
      render :json => {:success => false, :html => render_to_string(:partial => '/layouts/errors')}.to_json
    end
  end

  def disable_sugar
    @sugar = Sugar.find_by_id(params[:id])
    if @sugar.update_attributes(:is_deleted => params[:status])
      @sugars = Sugar.all
      render :partial => "super_admin/sugars/list"
    end
  end

  def sugar_params
    params.require(:sugar).permit(:name, :price)
  end


end
