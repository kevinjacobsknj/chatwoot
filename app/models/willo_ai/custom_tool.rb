class WilloAi::CustomTool < ApplicationRecord
  self.table_name = 'willo_ai_custom_tools'

  belongs_to :account

  enum :http_method, { get: 'GET', post: 'POST', put: 'PUT', patch: 'PATCH', delete: 'DELETE' }, default: :get
  enum :auth_type, { none: 'none', api_key: 'api_key', bearer: 'bearer', basic: 'basic' }, default: :none

  validates :slug, presence: true, uniqueness: { scope: :account_id }
  validates :title, presence: true
  validates :endpoint_url, presence: true

  scope :enabled, -> { where(enabled: true) }
end
