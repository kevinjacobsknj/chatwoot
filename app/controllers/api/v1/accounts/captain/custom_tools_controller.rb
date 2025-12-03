class Api::V1::Accounts::Captain::CustomToolsController < Api::V1::Accounts::Captain::BaseController
  before_action :set_custom_tool, only: [:show, :update, :destroy]

  def index
    @custom_tools = Current.account.willo_ai_custom_tools.order(created_at: :desc)
    @custom_tools = @custom_tools.where('title ILIKE ? OR slug ILIKE ?', "%#{params[:searchKey]}%", "%#{params[:searchKey]}%") if params[:searchKey].present?
    @custom_tools = @custom_tools.page(params[:page] || 1).per(25)

    render json: {
      payload: @custom_tools.map { |t| custom_tool_json(t) },
      meta: {
        current_page: @custom_tools.current_page,
        total_pages: @custom_tools.total_pages,
        total_count: @custom_tools.total_count
      }
    }
  end

  def show
    render json: custom_tool_json(@custom_tool)
  end

  def create
    @custom_tool = Current.account.willo_ai_custom_tools.new(custom_tool_params)

    if @custom_tool.save
      render json: custom_tool_json(@custom_tool), status: :created
    else
      render json: { errors: @custom_tool.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @custom_tool.update(custom_tool_params)
      render json: custom_tool_json(@custom_tool)
    else
      render json: { errors: @custom_tool.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_tool.destroy!
    head :no_content
  end

  private

  def set_custom_tool
    @custom_tool = Current.account.willo_ai_custom_tools.find(params[:id])
  end

  def custom_tool_params
    params.require(:custom_tool).permit(
      :slug, :title, :description, :http_method, :endpoint_url,
      :request_template, :response_template, :auth_type, :enabled,
      auth_config: {}, param_schema: []
    )
  end

  def custom_tool_json(tool)
    {
      id: tool.id,
      slug: tool.slug,
      title: tool.title,
      description: tool.description,
      http_method: tool.http_method,
      endpoint_url: tool.endpoint_url,
      request_template: tool.request_template,
      response_template: tool.response_template,
      auth_type: tool.auth_type,
      auth_config: tool.auth_config,
      param_schema: tool.param_schema,
      enabled: tool.enabled,
      account_id: tool.account_id,
      created_at: tool.created_at,
      updated_at: tool.updated_at
    }
  end
end
