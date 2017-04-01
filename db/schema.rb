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

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "app_traces", force: :cascade do |t|
    t.boolean  "analysis_computed",    default: false
    t.string   "archive",                              null: false
    t.string   "app"
    t.string   "app_version"
    t.string   "cmd"
    t.integer  "connectivity"
    t.text     "comments"
    t.integer  "events_count"
    t.boolean  "events_imported",      default: false
    t.string   "git_hash"
    t.string   "host_id"
    t.string   "kernel"
    t.text     "log"
    t.string   "machine"
    t.text     "net"
    t.text     "opt_b"
    t.text     "opt_f"
    t.text     "opt_u"
    t.integer  "os"
    t.integer  "process_traces_count"
    t.integer  "socket_traces_count"
    t.integer  "user_id"
    t.text     "version"
    t.text     "workload"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["app"], name: "index_app_traces_on_app", using: :btree
    t.index ["connectivity"], name: "index_app_traces_on_connectivity", using: :btree
    t.index ["os"], name: "index_app_traces_on_os", using: :btree
    t.index ["user_id"], name: "index_app_traces_on_user_id", using: :btree
  end

  create_table "process_traces", force: :cascade do |t|
    t.integer  "app_trace_id"
    t.boolean  "events_imported",     default: false
    t.string   "name"
    t.integer  "events_count"
    t.integer  "socket_traces_count"
    t.boolean  "analysis_computed",   default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["app_trace_id"], name: "index_process_traces_on_app_trace_id", using: :btree
  end

  create_table "socket_traces", force: :cascade do |t|
    t.integer  "app_trace_id"
    t.integer  "events_count"
    t.boolean  "events_imported",   default: false
    t.integer  "process_trace_id"
    t.integer  "index"
    t.integer  "socket_type"
    t.boolean  "analysis_computed", default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["app_trace_id"], name: "index_socket_traces_on_app_trace_id", using: :btree
    t.index ["process_trace_id"], name: "index_socket_traces_on_process_trace_id", using: :btree
    t.index ["socket_type"], name: "index_socket_traces_on_socket_type", using: :btree
  end

  create_table "stat_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "info"
    t.integer  "parent_category_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["parent_category_id"], name: "index_stat_categories_on_parent_category_id", using: :btree
  end

  create_table "stats", force: :cascade do |t|
    t.boolean  "apply_to_app_trace",     default: false
    t.boolean  "apply_to_process_trace", default: false
    t.boolean  "apply_to_socket_trace",  default: false
    t.text     "event_filters"
    t.string   "name"
    t.string   "node"
    t.integer  "stat_category_id"
    t.integer  "stat_type"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["stat_category_id"], name: "index_stats_on_stat_category_id", using: :btree
  end

end
