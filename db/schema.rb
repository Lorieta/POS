# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_05_102000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "delivery_id"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.index ["delivery_id"], name: "index_customers_on_delivery_id"
  end

  create_table "deliveries", force: :cascade do |t|
    t.string "branggay"
    t.string "building"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "floor"
    t.string "landmark"
    t.integer "order_id", null: false
    t.string "province"
    t.string "remarks"
    t.string "street"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["order_id"], name: "index_deliveries_on_order_id"
    t.index ["user_id"], name: "index_deliveries_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "group_id"
    t.date "order_date"
    t.integer "order_quantity"
    t.string "payment_method"
    t.integer "product_id", null: false
    t.string "status", default: "pending", null: false
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["group_id"], name: "index_orders_on_group_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "product_photo"
    t.float "product_price"
    t.string "product_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["category"], name: "index_products_on_category"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.string "phone_number"
    t.string "status", default: "user", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "deliveries"
  add_foreign_key "deliveries", "orders"
  add_foreign_key "deliveries", "users"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "products"
  add_foreign_key "products", "users"
end
