class Api::V1::Accounts::Captain::CopilotThreadsController < Api::V1::Accounts::Captain::BaseController
  def index
    # Placeholder for copilot threads listing
    render json: { payload: [], meta: { total_count: 0 } }
  end

  def create
    # Placeholder for creating a new copilot thread
    render json: { id: SecureRandom.uuid, created_at: Time.current }, status: :created
  end
end
