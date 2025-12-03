class WilloAi::Document < ApplicationRecord
  self.table_name = 'willo_ai_documents'

  belongs_to :account
  belongs_to :assistant, class_name: 'WilloAi::Assistant'
  has_many :responses, class_name: 'WilloAi::Response', foreign_key: :document_id, dependent: :nullify

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }, default: :pending

  validates :name, presence: true
  validates :external_link, uniqueness: { scope: :assistant_id }, allow_blank: true

  scope :for_assistant, ->(assistant_id) { where(assistant_id: assistant_id) if assistant_id.present? }
end
