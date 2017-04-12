def create_user
  puts "Deleting existing roles..."
  roles = Role.all
  roles.each { |role| role.destroy } if roles.present?

  puts "Creating roles..."
  %w(super_admin merchant customer).each do |name|
    Role.create!(:name => name)
  end

  puts "Deleting existing users.."
  users = User.all
  users.each { |user| user.destroy } if users.present?

  ActionController::Parameters.permit_all_parameters = true
  puts "Creating default super super_admin ...."
  super_params = ActionController::Parameters.new({
                                                      :user => {
                                                          :email => "super_admin@hookahbutler.com",
                                                          :password => "12345678",
                                                          :password_confirmation => "12345678",
                                                          :name => "Super Admin",
                                                      }
                                                  })
  super_admin = User.new(super_params[:user])
  super_admin.roles << Role.find_by_name("super_admin")
  super_admin.save!

end

def create_categories
  puts "Deleting existing categories.."
  categories = Category.all
  categories.each { |category| category.destroy } if categories.present?

  cat1 = Category.create!(:name => "HOOKAH")
  cat2 = Category.create!(:name => "REFILL")
  cat3 = Category.create!(:name => "CHARCOAL")
  Category.create!(:name => "HOT DRINKS", :parent_id => cat1.id, :parent_type => "Category")
  Category.create!(:name => "COLD DRINKS", :parent_id => cat2.id, :parent_type => "Category")
  Category.create!(:name => "SYRUPS", :parent_id => cat3.id, :parent_type => "Category")
end

def create_sizes
  puts "Deleting existing categories.."
  sizes = Size.all
  sizes.each { |size| size.destroy } if sizes.present?
  puts "Create Default Sizes"
  Size.create!(:size => "Small")
  Size.create!(:size => "Medium")
  Size.create!(:size => "Large")
end


def seed_order_times
  OrderTime.create!(:time => 5)
  OrderTime.create!(:time => 10)
  OrderTime.create!(:time => 15)
  OrderTime.create!(:time => 20)
  OrderTime.create!(:time => 25)
  OrderTime.create!(:time => 30)
end

def seed_preferences
  Preferences.create!(:tax_percentage => 8.875, :convenience_fee => 10, :reward => 10,:cash_convenience_fee => 1)
end


create_user
create_categories
create_sizes
seed_order_times
seed_preferences



