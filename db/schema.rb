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

ActiveRecord::Schema.define(version: 20160509085131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accesses", force: :cascade do |t|
    t.integer "container_id"
    t.integer "user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.integer "container_id"
    t.integer "user_id"
  end

  create_table "connects", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "partner"
    t.string   "partner_id"
    t.string   "partner_auth_data"
    t.datetime "partner_expire"
    t.text     "partner_data"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "containers", force: :cascade do |t|
    t.string   "docker_id"
    t.integer  "user_id"
    t.integer  "plan_id"
    t.integer  "host_id"
    t.string   "port"
    t.string   "name"
    t.string   "status"
    t.boolean  "is_private",    null: false
    t.datetime "active_until"
    t.hstore   "server_config"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "is_paid"
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "device_type"
    t.string   "push_token"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "games", force: :cascade do |t|
    t.string   "name"
    t.string   "sname"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "features"
    t.integer  "order"
  end

  create_table "hosts", force: :cascade do |t|
    t.string   "name"
    t.integer  "ip",           limit: 8
    t.string   "domain"
    t.string   "location"
    t.string   "host_user"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "country_code"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "alert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "host_id"
    t.string   "name"
    t.integer  "max_players"
    t.integer  "ram"
    t.integer  "storage"
    t.string   "storage_type"
    t.string   "price"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "rewards", force: :cascade do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.hstore   "referral_data"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "steam_server_login_tokens", force: :cascade do |t|
    t.integer  "app_id"
    t.string   "token"
    t.boolean  "in_use",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "subscription_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "container_id"
    t.integer  "plan_id"
    t.string   "status"
    t.text     "comment"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "full_name"
    t.string   "s3_region"
    t.string   "s3_bucket"
    t.boolean  "has_avatar",   default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "locale"
    t.boolean  "confirmation", default: false
  end

end
