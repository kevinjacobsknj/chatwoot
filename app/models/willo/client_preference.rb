# == Schema Information
#
# Table name: willo_client_preferences
#
#  id                      :bigint           not null, primary key
#  contact_id              :bigint           not null
#  account_id              :bigint           not null
#  color_formula           :text
#  allergies               :text
#  preferred_stylist_id    :bigint
#  preferred_products      :text             default([]), is an Array
#  service_notes           :text
#  last_service_date       :datetime
#  total_lifetime_spending :decimal(10, 2)   default(0)
#  visit_count             :integer          default(0)
#  average_ticket          :decimal(10, 2)   default(0)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Willo::ClientPreference < ApplicationRecord
  self.table_name = 'willo_client_preferences'

  belongs_to :contact
  belongs_to :account
  belongs_to :preferred_stylist, class_name: 'User', optional: true

  validates :contact_id, uniqueness: { scope: :account_id }

  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :with_allergies, -> { where.not(allergies: [nil, '']) }
  scope :high_value, ->(threshold = 1000) { where('total_lifetime_spending >= ?', threshold) }

  def self.update_from_service(service)
    preference = find_or_initialize_by(contact_id: service.contact_id, account_id: service.account_id)

    preference.last_service_date = service.appointment_date
    preference.visit_count = (preference.visit_count || 0) + 1 if preference.new_record? || service.id_previously_changed?

    total_spent = Willo::Service.where(contact_id: service.contact_id, account_id: service.account_id).sum(:price) || 0
    preference.total_lifetime_spending = total_spent
    preference.average_ticket = preference.visit_count.positive? ? total_spent / preference.visit_count : 0

    preference.save
    preference
  end

  def formatted_spending
    ActionController::Base.helpers.number_to_currency(total_lifetime_spending)
  end
end
