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

ActiveRecord::Schema.define(version: 20170312153439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_traces", force: :cascade do |t|
    t.string   "archive",                             null: false
    t.string   "app"
    t.string   "cmd"
    t.integer  "connectivity"
    t.text     "description"
    t.boolean  "imported",            default: false
    t.string   "kernel"
    t.text     "log"
    t.string   "machine"
    t.integer  "os"
    t.integer  "socket_traces_count"
    t.boolean  "stats_computed",      default: false
    t.integer  "user_id"
    t.text     "version"
    t.text     "workload",                            null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["app"], name: "index_app_traces_on_app", using: :btree
    t.index ["connectivity"], name: "index_app_traces_on_connectivity", using: :btree
    t.index ["os"], name: "index_app_traces_on_os", using: :btree
    t.index ["user_id"], name: "index_app_traces_on_user_id", using: :btree
  end

  create_table "socket_traces", force: :cascade do |t|
    t.integer  "app_trace_id"
    t.integer  "socket_type"
    t.boolean  "stats_computed", default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["app_trace_id"], name: "index_socket_traces_on_app_trace_id", using: :btree
    t.index ["socket_type"], name: "index_socket_traces_on_socket_type", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "lastname",    null: false
    t.string   "firstname",   null: false
    t.string   "email",       null: false
    t.string   "institution"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
  end

end
