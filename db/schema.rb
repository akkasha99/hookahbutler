# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160902153453) do

  create_table "add_ons", force: true do |t|
    t.integer  "category_id"
    t.string   "name"
    t.string   "description"
    t.float    "cost_per_unit"
    t.integer  "number_of_units"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",      default: false
  end

  create_table "assets", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      default: "active"
  end

  create_table "coupon_code_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "coupon_code_id"
    t.integer  "generated_by_user"
    t.integer  "consumer_id"
    t.boolean  "is_consumed",       default: false
    t.boolean  "is_applied",        default: false
    t.boolean  "is_send",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_codes", force: true do |t|
    t.string   "code"
    t.string   "coupon_type"
    t.float    "coupon_value"
    t.datetime "created_at"
    t.integer  "number_of_days"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.integer  "user_id"
    t.string   "send_to_users"
    t.integer  "per_user",                 default: 0
    t.integer  "per_coupon",               default: 0
    t.string   "status",                   default: "Open"
    t.integer  "promotion_code_user_id"
    t.string   "promotion_code_user_type"
    t.string   "coupon_group"
    t.boolean  "is_send",                  default: true
    t.boolean  "send_by_email",            default: false
    t.boolean  "send_by_notification",     default: false
    t.string   "message_subject"
    t.string   "message_body"
    t.integer  "number_to_share",          default: 0
    t.boolean  "is_setting",               default: false
    t.boolean  "is_expired",               default: false
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "favourites", force: true do |t|
    t.integer  "shop_id"
    t.integer  "item_size_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id"
    t.boolean  "is_like",      default: false
  end

  create_table "item_add_ons", force: true do |t|
    t.integer  "add_on_id"
    t.integer  "item_id"
    t.integer  "item_size_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_archived",  default: false
  end

  create_table "item_sizes", force: true do |t|
    t.integer  "item_id"
    t.integer  "size_id"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.string   "name"
    t.float    "base_price"
    t.integer  "shop_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.boolean  "is_shot",     default: false
    t.float    "shot_price"
    t.boolean  "is_deleted",  default: false
    t.boolean  "is_sugar",    default: false
  end

  create_table "meta_categories", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "category_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_add_ons", force: true do |t|
    t.integer  "item_add_on_id"
    t.integer  "order_line_item_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price"
    t.float    "total_price"
    t.integer  "order_id"
  end

  create_table "order_line_items", force: true do |t|
    t.integer  "item_size_id"
    t.integer  "order_id"
    t.float    "price"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total_price"
    t.integer  "no_of_shots"
    t.float    "shot_price"
    t.float    "shot_total_price"
    t.integer  "item_id"
    t.integer  "sugar_id"
    t.integer  "sugar_quantity"
    t.float    "sugar_total_price"
  end

  create_table "order_times", force: true do |t|
    t.integer  "time"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_transactions", force: true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.integer  "order_id"
    t.string   "transaction_id"
    t.string   "charge_id"
    t.string   "status"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "convenience_fee"
    t.boolean  "is_charged",       default: false
    t.string   "transaction_type"
  end

  create_table "orders", force: true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.string   "order_number"
    t.string   "status"
    t.float    "total_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "card_id"
    t.integer  "estimated_time"
    t.boolean  "is_new",          default: true
    t.datetime "completed_time"
    t.string   "reason"
    t.float    "tax"
    t.float    "refunded_amount"
    t.integer  "table_number"
    t.boolean  "is_expressOrder", default: false
    t.float    "convenience_fee"
    t.float    "reward_used"
  end

  create_table "preferences", force: true do |t|
    t.float    "tax_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "convenience_fee"
    t.float    "reward"
    t.float    "cash_convenience_fee"
  end

  create_table "reviews", force: true do |t|
    t.float    "rating"
    t.integer  "shop_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_daily_slots", force: true do |t|
    t.integer  "shop_hour_id"
    t.string   "name"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shop_daily_slots", ["shop_hour_id"], name: "index_shop_daily_slots_on_shop_hour_id", using: :btree

  create_table "shop_hours", force: true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_open"
  end

  create_table "shop_sugars", force: true do |t|
    t.integer  "shop_id"
    t.integer  "sugar_id"
    t.boolean  "is_archived", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shops", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",            default: false
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "country"
    t.text     "description"
    t.string   "facebook_link"
    t.string   "twitter_link"
    t.string   "yelp_link"
    t.string   "instagram_link"
    t.string   "bank_account_id"
    t.string   "stripe_account_id"
  end

  create_table "sizes", force: true do |t|
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sugars", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.boolean  "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",         null: false
    t.string   "encrypted_password",     default: "",         null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer_id"
    t.string   "code"
    t.string   "city"
    t.string   "state"
    t.string   "address"
    t.string   "country"
    t.string   "phone"
    t.datetime "date_of_birth"
    t.string   "zip"
    t.string   "registration_id"
    t.string   "status",                 default: "inactive"
    t.string   "device_id"
    t.string   "device_type"
    t.float    "convenience_fee"
    t.boolean  "is_verified",            default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
