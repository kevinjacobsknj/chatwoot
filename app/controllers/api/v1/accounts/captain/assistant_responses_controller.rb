class Api::V1::Accounts::Captain::AssistantResponsesController < Api::V1::Accounts::Captain::BaseController
  before_action :set_response, only: [:show, :update, :destroy]

  def index
    @responses = Current.account.willo_ai_responses.includes(:assistant, :document).order(created_at: :desc)
    @responses = @responses.for_assistant(params[:assistant_id]) if params[:assistant_id].present?
    @responses = @responses.for_document(params[:document_id]) if params[:document_id].present?
    @responses = @responses.by_status(params[:status]) if params[:status].present?
    @responses = @responses.search(params[:search]) if params[:search].present?
    @responses = @responses.page(params[:page] || 1).per(25)

    render json: {
      payload: @responses.map { |r| response_json(r) },
      meta: {
        current_page: @responses.current_page,
        total_pages: @responses.total_pages,
        total_count: @responses.total_count
      }
    }
  end

  def show
    render json: response_json(@response)
  end

  def create
    @response = Current.account.willo_ai_responses.new(response_params)

    if @response.save
      render json: response_json(@response), status: :created
    else
      render json: { errors: @response.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @response.update(response_params)
      render json: response_json(@response)
    else
      render json: { errors: @response.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @response.destroy!
    head :no_content
  end

  private

  def set_response
    @response = Current.account.willo_ai_responses.find(params[:id])
  end

  def response_params
    params.require(:assistant_response).permit(:question, :answer, :assistant_id, :document_id, :status)
  end

  def response_json(response)
    {
      id: response.id,
      question: response.question,
      answer: response.answer,
      status: response.status,
      assistant_id: response.assistant_id,
      assistant: response.assistant ? { id: response.assistant.id, name: response.assistant.name } : nil,
      document_id: response.document_id,
      document: response.document ? { id: response.document.id, name: response.document.name } : nil,
      account_id: response.account_id,
      created_at: response.created_at,
      updated_at: response.updated_at
    }
  end
end
