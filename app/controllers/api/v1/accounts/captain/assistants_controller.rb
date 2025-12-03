class Api::V1::Accounts::Captain::AssistantsController < Api::V1::Accounts::Captain::BaseController
  before_action :set_assistant, only: [:show, :update, :destroy, :playground]

  def index
    @assistants = Current.account.willo_ai_assistants.order(created_at: :desc)
    @assistants = @assistants.where('name ILIKE ?', "%#{params[:searchKey]}%") if params[:searchKey].present?
    @assistants = @assistants.page(params[:page] || 1).per(25)

    render json: {
      payload: @assistants.map { |a| assistant_json(a) },
      meta: {
        current_page: @assistants.current_page,
        total_pages: @assistants.total_pages,
        total_count: @assistants.total_count
      }
    }
  end

  def show
    render json: assistant_json(@assistant)
  end

  def create
    @assistant = Current.account.willo_ai_assistants.new(assistant_params)

    if @assistant.save
      render json: assistant_json(@assistant), status: :created
    else
      render json: { errors: @assistant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @assistant.update(assistant_params)
      render json: assistant_json(@assistant)
    else
      render json: { errors: @assistant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @assistant.destroy!
    head :no_content
  end

  def playground
    # Placeholder for AI playground functionality
    # This would integrate with an LLM API (OpenAI, Anthropic, etc.)
    render json: {
      response: "This is a placeholder response. Integrate your preferred AI provider here.",
      message_content: params[:message_content],
      assistant_id: @assistant.id
    }
  end

  def tools
    # Return available tools for the assistant
    custom_tools = Current.account.willo_ai_custom_tools.enabled
    render json: { tools: custom_tools.map { |t| custom_tool_json(t) } }
  end

  private

  def set_assistant
    @assistant = Current.account.willo_ai_assistants.find(params[:id])
  end

  def assistant_params
    params.require(:assistant).permit(:name, :description, config: {})
  end

  def assistant_json(assistant)
    {
      id: assistant.id,
      name: assistant.name,
      description: assistant.description,
      config: assistant.config,
      account_id: assistant.account_id,
      created_at: assistant.created_at,
      updated_at: assistant.updated_at
    }
  end

  def custom_tool_json(tool)
    {
      id: tool.id,
      slug: tool.slug,
      title: tool.title,
      description: tool.description,
      enabled: tool.enabled
    }
  end
end
