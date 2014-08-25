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

ActiveRecord::Schema.define(version: 20140824051442) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "holidays", force: true do |t|
    t.date     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "holidays", ["data"], name: "index_holidays_on_data", unique: true, using: :btree

  create_table "off_days", force: true do |t|
    t.date     "date"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "off_days", ["date"], name: "index_off_days_on_date", unique: true, using: :btree
  add_index "off_days", ["user_id"], name: "index_off_days_on_user_id", using: :btree

  create_table "order_entries", force: true do |t|
    t.integer  "order"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_entries", ["user_id"], name: "index_order_entries_on_user_id", using: :btree

  create_table "scheduled_till_dates", force: true do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduled_till_dates", ["date"], name: "index_scheduled_till_dates_on_date", unique: true, using: :btree

  create_table "schedules", force: true do |t|
    t.date     "date"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["date"], name: "index_schedules_on_date", unique: true, using: :btree
  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree

end
