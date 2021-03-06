# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090617162631) do

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  create_table "groups", :force => true do |t|
    t.string "name"
  end

  create_table "groups_users", :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "lessons", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_urls", :force => true do |t|
    t.string   "url"
    t.string   "type"
    t.integer  "running_lesson_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "running_courses", :force => true do |t|
    t.integer  "course_id"
    t.integer  "user_id"
    t.string   "state",      :default => "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "running_lessons", :force => true do |t|
    t.integer  "lesson_id"
    t.integer  "user_id"
    t.integer  "running_course_id"
    t.string   "state",             :default => "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "os_user"
    t.integer  "os_gid"
    t.string   "os_secret"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
