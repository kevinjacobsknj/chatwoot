class WilloAi::Inbox < ApplicationRecord
  self.table_name = 'willo_ai_inboxes'

  belongs_to :assistant, class_name: 'WilloAi::Assistant', foreign_key: :captain_assistant_id
  belongs_to :inbox, class_name: '::Inbox'

  validates :inbox_id, uniqueness: { scope: :captain_assistant_id }

  scope :for_assistant, ->(assistant_id) { where(captain_assistant_id: assistant_id) }

  # Alias for cleaner code
  def assistant_id
    captain_assistant_id
  end

  def assistant_id=(value)
    self.captain_assistant_id = value
  end
end
