# == Schema Information
#
# Table name: willo_services
#
#  id               :bigint           not null, primary key
#  contact_id       :bigint           not null
#  account_id       :bigint           not null
#  service_name     :string           not null
#  service_category :string(100)
#  duration_minutes :integer
#  price            :decimal(10, 2)
#  stylist_id       :bigint
#  appointment_date :datetime         not null
#  notes            :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Willo::Service < ApplicationRecord
  self.table_name = 'willo_services'

  SERVICE_CATEGORIES = %w[Color Cut Style Treatment].freeze

  belongs_to :contact
  belongs_to :account
  belongs_to :stylist, class_name: 'User', optional: true

  has_many :service_products, class_name: 'Willo::ServiceProduct', foreign_key: :willo_service_id, dependent: :destroy,
                              inverse_of: :willo_service
  has_many :inventory_items, through: :service_products

  validates :service_name, presence: true
  validates :appointment_date, presence: true
  validates :service_category, inclusion: { in: SERVICE_CATEGORIES }, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true

  scope :for_contact, ->(contact_id) { where(contact_id: contact_id) }
  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :by_category, ->(category) { where(service_category: category) }
  scope :upcoming, -> { where('appointment_date > ?', Time.current).order(appointment_date: :asc) }
  scope :past, -> { where('appointment_date <= ?', Time.current).order(appointment_date: :desc) }

  after_create :update_client_preferences
  after_update :update_client_preferences, if: :saved_change_to_price?

  private

  def update_client_preferences
    Willo::ClientPreference.update_from_service(self)
  end
end
