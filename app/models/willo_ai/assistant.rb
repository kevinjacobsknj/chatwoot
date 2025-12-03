class WilloAi::Assistant < ApplicationRecord
  self.table_name = 'willo_ai_assistants'

  belongs_to :account
  has_many :documents, class_name: 'WilloAi::Document', foreign_key: :assistant_id, dependent: :destroy_async
  has_many :responses, class_name: 'WilloAi::Response', foreign_key: :assistant_id, dependent: :destroy_async
  has_many :scenarios, class_name: 'WilloAi::Scenario', foreign_key: :assistant_id, dependent: :destroy_async
  has_many :inboxes, class_name: 'WilloAi::Inbox', foreign_key: :captain_assistant_id, dependent: :destroy_async
  # Note: Custom tools are account-scoped, not assistant-scoped
  # Access them via Current.account.willo_ai_custom_tools

  validates :name, presence: true
  validates :name, uniqueness: { scope: :account_id }

  # Config is a JSON column for storing assistant settings
  # Example: { "model": "gpt-4", "temperature": 0.7 }
  def config
    self[:config] || {}
  end
end
