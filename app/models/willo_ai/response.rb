class WilloAi::Response < ApplicationRecord
  self.table_name = 'willo_ai_responses'

  belongs_to :account
  belongs_to :assistant, class_name: 'WilloAi::Assistant'
  belongs_to :document, class_name: 'WilloAi::Document', optional: true

  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :approved

  validates :question, presence: true
  validates :answer, presence: true

  scope :for_assistant, ->(assistant_id) { where(assistant_id: assistant_id) if assistant_id.present? }
  scope :for_document, ->(document_id) { where(document_id: document_id) if document_id.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :search, ->(query) { where('question ILIKE ? OR answer ILIKE ?', "%#{query}%", "%#{query}%") if query.present? }
end
