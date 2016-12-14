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

ActiveRecord::Schema.define(version: 20160818140248) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "document_type"
    t.index ["document_type", "document_id"], name: "index_bookmarks_on_document_type_and_document_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",                      default: 0, null: false
    t.integer  "attempts",                      default: 0, null: false
    t.text     "handler",                                   null: false
    t.text     "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "spotlight_attachments", force: :cascade do |t|
    t.string   "name"
    t.string   "file"
    t.string   "uid"
    t.integer  "exhibit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exhibit_id"], name: "index_spotlight_attachments_on_exhibit_id"
  end

  create_table "spotlight_blacklight_configurations", force: :cascade do |t|
    t.integer  "exhibit_id"
    t.text     "facet_fields"
    t.text     "index_fields"
    t.text     "search_fields"
    t.text     "sort_fields"
    t.text     "default_solr_params"
    t.text     "show"
    t.text     "index"
    t.integer  "default_per_page"
    t.text     "per_page"
    t.text     "document_index_view_types"
    t.string   "thumbnail_size"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["exhibit_id"], name: "index_spotlight_blacklight_configurations_on_exhibit_id"
  end

  create_table "spotlight_contact_emails", force: :cascade do |t|
    t.integer  "exhibit_id"
    t.string   "email",                default: "", null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["confirmation_token"], name: "index_spotlight_contact_emails_on_confirmation_token", unique: true
    t.index ["email", "exhibit_id"], name: "index_spotlight_contact_emails_on_email_and_exhibit_id", unique: true
    t.index ["exhibit_id"], name: "index_spotlight_contact_emails_on_exhibit_id"
  end

  create_table "spotlight_contacts", force: :cascade do |t|
    t.string   "slug"
    t.string   "name"
    t.string   "email"
    t.string   "title"
    t.string   "location"
    t.boolean  "show_in_sidebar"
    t.integer  "weight",          default: 50
    t.integer  "exhibit_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "contact_info"
    t.string   "avatar"
    t.integer  "avatar_crop_x"
    t.integer  "avatar_crop_y"
    t.integer  "avatar_crop_w"
    t.integer  "avatar_crop_h"
    t.integer  "avatar_id"
    t.index ["avatar_id"], name: "index_spotlight_contacts_on_avatar_id"
    t.index ["exhibit_id"], name: "index_spotlight_contacts_on_exhibit_id"
  end

  create_table "spotlight_custom_fields", force: :cascade do |t|
    t.integer  "exhibit_id"
    t.string   "slug"
    t.string   "field"
    t.text     "configuration"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "field_type"
    t.boolean  "readonly_field", default: false
    t.index ["exhibit_id"], name: "index_spotlight_custom_fields_on_exhibit_id"
  end

  create_table "spotlight_exhibits", force: :cascade do |t|
    t.string   "title",                          null: false
    t.string   "subtitle"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "layout"
    t.boolean  "published",      default: false
    t.datetime "published_at"
    t.string   "featured_image"
    t.integer  "masthead_id"
    t.integer  "thumbnail_id"
    t.integer  "weight",         default: 50
    t.integer  "site_id"
    t.index ["site_id"], name: "index_spotlight_exhibits_on_site_id"
    t.index ["slug"], name: "index_spotlight_exhibits_on_slug", unique: true
  end

  create_table "spotlight_featured_images", force: :cascade do |t|
    t.string   "type"
    t.boolean  "display"
    t.string   "image"
    t.string   "source"
    t.string   "document_global_id"
    t.integer  "image_crop_x"
    t.integer  "image_crop_y"
    t.integer  "image_crop_w"
    t.integer  "image_crop_h"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "iiif_url"
  end

  create_table "spotlight_filters", force: :cascade do |t|
    t.string   "field"
    t.string   "value"
    t.integer  "exhibit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exhibit_id"], name: "index_spotlight_filters_on_exhibit_id"
  end

  create_table "spotlight_locks", force: :cascade do |t|
    t.string   "on_type"
    t.integer  "on_id"
    t.string   "by_type"
    t.integer  "by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["by_type", "by_id"], name: "index_spotlight_locks_on_by_type_and_by_id"
    t.index ["on_id", "on_type"], name: "index_spotlight_locks_on_on_id_and_on_type", unique: true
    t.index ["on_type", "on_id"], name: "index_spotlight_locks_on_on_type_and_on_id"
  end

  create_table "spotlight_main_navigations", force: :cascade do |t|
    t.string   "label"
    t.integer  "weight",     default: 20
    t.string   "nav_type"
    t.integer  "exhibit_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "display",    default: true
    t.index ["exhibit_id"], name: "index_spotlight_main_navigations_on_exhibit_id"
  end

  create_table "spotlight_mastheads", force: :cascade do |t|
    t.boolean  "display"
    t.string   "image"
    t.string   "source"
    t.string   "document_global_id"
    t.integer  "image_crop_x"
    t.integer  "integer"
    t.integer  "image_crop_y"
    t.integer  "image_crop_w"
    t.integer  "image_crop_h"
    t.integer  "exhibit_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["exhibit_id"], name: "index_spotlight_mastheads_on_exhibit_id"
  end

  create_table "spotlight_pages", force: :cascade do |t|
    t.string   "title"
    t.string   "type"
    t.string   "slug"
    t.string   "scope"
    t.text     "content"
    t.integer  "weight",            default: 50
    t.boolean  "published"
    t.integer  "exhibit_id"
    t.integer  "created_by_id"
    t.integer  "last_edited_by_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "parent_page_id"
    t.boolean  "display_sidebar"
    t.boolean  "display_title"
    t.integer  "thumbnail_id"
    t.index ["exhibit_id"], name: "index_spotlight_pages_on_exhibit_id"
    t.index ["parent_page_id"], name: "index_spotlight_pages_on_parent_page_id"
    t.index ["slug", "scope"], name: "index_spotlight_pages_on_slug_and_scope", unique: true
  end

  create_table "spotlight_resources", force: :cascade do |t|
    t.integer  "exhibit_id"
    t.string   "type"
    t.string   "url"
    t.text     "data"
    t.datetime "indexed_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.binary   "metadata"
    t.integer  "index_status"
    t.index ["exhibit_id"], name: "index_spotlight_resources_on_exhibit_id"
    t.index ["index_status"], name: "index_spotlight_resources_on_index_status"
  end

  create_table "spotlight_roles", force: :cascade do |t|
    t.integer "user_id"
    t.string  "role"
    t.integer "resource_id"
    t.string  "resource_type"
    t.index ["resource_type", "resource_id", "user_id"], name: "index_spotlight_roles_on_resource_and_user_id", unique: true
    t.index ["user_id"], name: "index_spotlight_roles_on_user_id"
  end

  create_table "spotlight_searches", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.string   "scope"
    t.text     "short_description"
    t.text     "long_description"
    t.text     "query_params"
    t.integer  "weight"
    t.boolean  "published"
    t.integer  "exhibit_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "featured_item_id"
    t.integer  "masthead_id"
    t.integer  "thumbnail_id"
    t.string   "default_index_view_type"
    t.index ["exhibit_id"], name: "index_spotlight_searches_on_exhibit_id"
    t.index ["slug", "scope"], name: "index_spotlight_searches_on_slug_and_scope", unique: true
  end

  create_table "spotlight_sites", force: :cascade do |t|
    t.string  "title"
    t.string  "subtitle"
    t.integer "masthead_id"
    t.index ["masthead_id"], name: "index_spotlight_sites_on_masthead_id"
  end

  create_table "spotlight_solr_document_sidecars", force: :cascade do |t|
    t.integer  "exhibit_id"
    t.boolean  "public",        default: true
    t.text     "data"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "document_id"
    t.string   "document_type"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.binary   "index_status"
    t.index ["exhibit_id"], name: "index_spotlight_solr_document_sidecars_on_exhibit_id"
    t.index ["resource_type", "resource_id"], name: "spotlight_solr_document_sidecars_resource"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_id"
    t.string   "taggable_type"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "guest",                  default: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
