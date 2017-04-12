class User < ActiveRecord::Base
  #before_create :register_user
  before_create :generate_token
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessor :customer, :credit_card, :json_role, :request_type

  #attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :roles_users, :dependent => :destroy
  has_many :roles, :through => :roles_users

  #has_many :merchants, :as => :super_admin, :class_name => "User", :dependent => :destroy
  #belongs_to :super_admin, :polymorphic => true


  has_one :shop, :dependent => :destroy
  accepts_nested_attributes_for :shop, :allow_destroy => true, :update_only => true

  has_many :reviews

  #has_many :orders

  has_many :orders, -> { order 'created_at desc' }, :dependent => :destroy

  has_many :favourites

  has_one :asset, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :asset, :allow_destroy => true

  has_many :order_transactions


  def register_user
    return true if self.super_admin?
    return false if customer.blank?
    self.merchant? ? register_merchant : register_customer
  end

  def register_customer
    customer["credit_card"] = credit_card
    result = Braintree::Customer.create(customer)
    if result.success?
      self.customer_id = result.customer.id
      self.code = (0...8).map { 65.+(rand(26)).chr }.join
      self.name = customer["name"]
      self.address = credit_card["billing_address"]["street_address"]
      self.phone = customer["phone"]
      self.city = credit_card["billing_address"]["city"]
      self.state = credit_card["billing_address"]["state"]
      self.country = customer["country_name"]
      return true
    else
      codes = []
      result.errors.each { |a| codes << a.code }
      self.errors.add("Braintree:", codes.join(","))
      return false
    end
  end

  def register_merchant
    #@result = Braintree::MerchantAccount.create(
    #    :applicant_details => {
    #        #:company_name => customer["company_name"],
    #        #:tax_id => customer["tax_id"],
    #        :first_name => customer["name"],
    #        :last_name => customer["name"],
    #        :email => self.email,
    #        :phone => customer["phone"],
    #        :address => {
    #            :street_address => customer["billing_address"]["street_address"],
    #            :postal_code => customer["postal_code"],
    #            :locality => customer["billing_address"]["city"],
    #            :region => customer["billing_address"]["state"],
    #        },
    #        :date_of_birth => customer["date_of_birth"],
    #        :routing_number => customer["routing_number"],
    #        :account_number => customer["account_number"]
    #    },
    #    :tos_accepted => true,
    #    :master_merchant_account_id => "3fsj28htzdwyh7dh"
    #)
    #if @result.success?
    #  self.customer_id = @result.merchant_account.id
    #  self.code = (0...8).map { 65.+(rand(26)).chr }.join
    #  self.name = customer["name"]
    #  self.address = customer["billing_address"]["street_address"]
    #  self.phone = customer["phone"]
    #  self.city = customer["billing_address"]["city"]
    #  self.state = customer["billing_address"]["state"]
    #  self.country = customer["country_name"]
    #  return true
    #else
    #  @result.errors.each { |error| self.errors.add(" ", error.message) }
    #  return false
    #end

  end

  def customer?
    roles.include?(Role.find_by_name("customer"))
  end

  def self.customers
    User.includes(:roles).where("roles.name" => "customer").order("users.id desc")
  end

  def self.merchants
    User.includes(:roles).where("roles.name" => "merchant")
  end


  def role
    return "super_admin" if super_admin?
    return "customer" if customer?
  end

  def super_admin?
    roles.include?(Role.find_by_name("super_admin"))
  end

  def customer?
    roles.include?(Role.find_by_name("customer"))
  end

  def merchant?
    roles.include?(Role.find_by_name("merchant"))
  end

  def full_name
    "#{name}"
  end

  def favourite_shops
    shops = []
    favourites.where(:is_like => true).each do |favourite|
      if favourite.shop and favourite.item.blank? and not favourite.shop.latitude.blank?
        if favourite.shop.user.status != 'inactive'
          shops << favourite.shop
        end
      end
    end
    unless shops.blank?
      shops = shops.uniq_by { |s| s.id }
    end
    return shops
  end

  def get_customer_favorite_items(user, shop_id)
    favourite_items = []
    user.favourites.each do |favourite|
      if favourite.shop.present? and favourite.item.present? and not favourite.shop.latitude.blank?
        puts "CCC" , favourite.shop_id, shop_id.to_i
        if favourite.shop_id == shop_id.to_i and favourite.is_like == true
          puts "CCC11"
          favourite_items << favourite.item
        end
      end
    end
    return favourite_items
  end

  def customer_json
    {
        :token => self.authentication_token,
        :id => self.id,
        :customer_id => self.customer_id,
        :email => self.email,
        :name => self.name,
        :phone => self.phone,
        :credit => self.convenience_fee,  #added convenience fee as credit in response of sign up and sign in
        :picture_url => self.asset.blank? ? nil : self.asset.avatar.url(:medium)
    }
  end

  protected

  def generate_token
    self.authentication_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(authentication_token: random_token)
      update_attributes!(:authentication_token => random_token)
    end
  end

end

