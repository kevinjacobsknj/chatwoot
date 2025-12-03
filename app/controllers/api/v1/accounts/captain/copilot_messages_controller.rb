class Api::V1::Accounts::Captain::CopilotMessagesController < Api::V1::Accounts::Captain::BaseController
  def index
    # Placeholder for copilot messages listing
    render json: { payload: [], meta: { total_count: 0 } }
  end

  def create
    # Placeholder for creating a new copilot message
    render json: {
      id: SecureRandom.uuid,
      content: params[:content],
      role: 'assistant',
      created_at: Time.current
    }, status: :created
  end
end
