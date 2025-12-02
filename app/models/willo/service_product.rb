# == Schema Information
#
# Table name: willo_service_products
#
#  id                     :bigint           not null, primary key
#  willo_service_id       :bigint           not null
#  willo_inventory_item_id :bigint           not null
#  quantity_used          :decimal(10, 2)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Willo::ServiceProduct < ApplicationRecord
  self.table_name = 'willo_service_products'

  belongs_to :willo_service, class_name: 'Willo::Service'
  belongs_to :inventory_item, class_name: 'Willo::InventoryItem', foreign_key: :willo_inventory_item_id,
                              inverse_of: :service_products

  validates :quantity_used, numericality: { greater_than: 0 }, allow_nil: true

  after_create :deduct_inventory
  after_destroy :restore_inventory

  private

  def deduct_inventory
    return unless quantity_used.present? && quantity_used.positive?

    inventory_item.deduct_stock(quantity_used.to_i)
  end

  def restore_inventory
    return unless quantity_used.present? && quantity_used.positive?

    inventory_item.add_stock(quantity_used.to_i)
  end
end
