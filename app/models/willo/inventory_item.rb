# == Schema Information
#
# Table name: willo_inventory
#
#  id                :bigint           not null, primary key
#  account_id        :bigint           not null
#  product_name      :string           not null
#  product_category  :string(100)
#  current_stock     :integer          default(0)
#  reorder_threshold :integer          default(5)
#  unit_cost         :decimal(10, 2)
#  supplier          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Willo::InventoryItem < ApplicationRecord
  self.table_name = 'willo_inventory'

  PRODUCT_CATEGORIES = %w[Color Care Styling Tools].freeze

  belongs_to :account

  has_many :service_products, class_name: 'Willo::ServiceProduct', foreign_key: :willo_inventory_item_id,
                              dependent: :restrict_with_error, inverse_of: :inventory_item

  validates :product_name, presence: true
  validates :product_category, inclusion: { in: PRODUCT_CATEGORIES }, allow_blank: true
  validates :current_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_threshold, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :by_category, ->(category) { where(product_category: category) }
  scope :low_stock, -> { where('current_stock <= reorder_threshold') }
  scope :in_stock, -> { where('current_stock > 0') }

  def low_stock?
    current_stock <= reorder_threshold
  end

  def deduct_stock(quantity)
    return false if quantity > current_stock

    update(current_stock: current_stock - quantity)
  end

  def add_stock(quantity)
    update(current_stock: current_stock + quantity)
  end
end
