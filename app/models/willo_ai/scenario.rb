class WilloAi::Scenario < ApplicationRecord
  self.table_name = 'willo_ai_scenarios'

  belongs_to :account
  belongs_to :assistant, class_name: 'WilloAi::Assistant'

  validates :title, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :for_assistant, ->(assistant_id) { where(assistant_id: assistant_id) }
end
