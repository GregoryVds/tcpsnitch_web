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

  create_table "datasets", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.integer  "user_id"
    t.string   "zip_file",    null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["user_id"], name: "index_datasets_on_user_id", using: :btree
  end

  create_table "executions", force: :cascade do |t|
    t.string   "app",                        null: false
    t.string   "cmd"
    t.integer  "connectivity", default: 0,   null: false
    t.string   "kernel"
    t.text     "log"
    t.string   "machine"
    t.text     "net"
    t.string   "os",           default: "0", null: false
    t.integer  "dataset_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["app"], name: "index_executions_on_app", using: :btree
    t.index ["connectivity"], name: "index_executions_on_connectivity", using: :btree
    t.index ["dataset_id"], name: "index_executions_on_dataset_id", using: :btree
    t.index ["os"], name: "index_executions_on_os", using: :btree
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

  add_foreign_key "datasets", "users"
  add_foreign_key "executions", "datasets"
end
