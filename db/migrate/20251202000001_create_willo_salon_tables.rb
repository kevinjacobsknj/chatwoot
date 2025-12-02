class CreateWilloSalonTables < ActiveRecord::Migration[7.1]
  def change
    create_willo_services
    create_willo_client_preferences
    create_willo_inventory
    create_willo_service_products
  end

  private

  def create_willo_services
    create_table :willo_services do |t|
      t.references :contact, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :service_name, null: false
      t.string :service_category, limit: 100
      t.integer :duration_minutes
      t.decimal :price, precision: 10, scale: 2
      t.references :stylist, foreign_key: { to_table: :users }
      t.timestamp :appointment_date, null: false
      t.text :notes

      t.timestamps
    end

    add_index :willo_services, :appointment_date, name: 'idx_willo_services_date'
  end

  def create_willo_client_preferences
    create_table :willo_client_preferences do |t|
      t.references :contact, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.text :color_formula
      t.text :allergies
      t.references :preferred_stylist, foreign_key: { to_table: :users }
      t.text :preferred_products, array: true, default: []
      t.text :service_notes
      t.timestamp :last_service_date
      t.decimal :total_lifetime_spending, precision: 10, scale: 2, default: 0
      t.integer :visit_count, default: 0
      t.decimal :average_ticket, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :willo_client_preferences, [:contact_id, :account_id], unique: true,
              name: 'idx_willo_client_prefs_contact_account'
  end

  def create_willo_inventory
    create_table :willo_inventory do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :product_name, null: false
      t.string :product_category, limit: 100
      t.integer :current_stock, default: 0
      t.integer :reorder_threshold, default: 5
      t.decimal :unit_cost, precision: 10, scale: 2
      t.string :supplier

      t.timestamps
    end

    add_index :willo_inventory, [:account_id, :product_name], name: 'idx_willo_inventory_account_product'
  end

  def create_willo_service_products
    create_table :willo_service_products do |t|
      t.references :willo_service, null: false, foreign_key: { on_delete: :cascade }
      t.references :willo_inventory_item, null: false, foreign_key: { to_table: :willo_inventory, on_delete: :cascade }
      t.decimal :quantity_used, precision: 10, scale: 2

      t.timestamps
    end
  end
end
