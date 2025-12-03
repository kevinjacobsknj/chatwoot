class Api::V1::Accounts::Captain::ScenariosController < Api::V1::Accounts::Captain::BaseController
  before_action :set_assistant
  before_action :set_scenario, only: [:show, :update, :destroy]

  def index
    @scenarios = @assistant.scenarios.order(created_at: :desc)
    @scenarios = @scenarios.where('title ILIKE ?', "%#{params[:searchKey]}%") if params[:searchKey].present?
    @scenarios = @scenarios.page(params[:page] || 1).per(25)

    render json: {
      payload: @scenarios.map { |s| scenario_json(s) },
      meta: {
        current_page: @scenarios.current_page,
        total_pages: @scenarios.total_pages,
        total_count: @scenarios.total_count
      }
    }
  end

  def show
    render json: scenario_json(@scenario)
  end

  def create
    @scenario = @assistant.scenarios.new(scenario_params)
    @scenario.account = Current.account

    if @scenario.save
      render json: scenario_json(@scenario), status: :created
    else
      render json: { errors: @scenario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @scenario.update(scenario_params)
      render json: scenario_json(@scenario)
    else
      render json: { errors: @scenario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @scenario.destroy!
    head :no_content
  end

  private

  def set_assistant
    @assistant = Current.account.willo_ai_assistants.find(params[:assistant_id])
  end

  def set_scenario
    @scenario = @assistant.scenarios.find(params[:id])
  end

  def scenario_params
    params.require(:scenario).permit(:title, :description, :instruction, :enabled, tools: [])
  end

  def scenario_json(scenario)
    {
      id: scenario.id,
      title: scenario.title,
      description: scenario.description,
      instruction: scenario.instruction,
      tools: scenario.tools,
      enabled: scenario.enabled,
      assistant_id: scenario.assistant_id,
      account_id: scenario.account_id,
      created_at: scenario.created_at,
      updated_at: scenario.updated_at
    }
  end
end
