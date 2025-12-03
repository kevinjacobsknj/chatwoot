class Api::V1::Accounts::Captain::DocumentsController < Api::V1::Accounts::Captain::BaseController
  before_action :set_document, only: [:show, :destroy]

  def index
    @documents = Current.account.willo_ai_documents.includes(:assistant).order(created_at: :desc)
    @documents = @documents.for_assistant(params[:assistant_id]) if params[:assistant_id].present?
    @documents = @documents.where('name ILIKE ?', "%#{params[:searchKey]}%") if params[:searchKey].present?
    @documents = @documents.page(params[:page] || 1).per(25)

    render json: {
      payload: @documents.map { |d| document_json(d) },
      meta: {
        current_page: @documents.current_page,
        total_pages: @documents.total_pages,
        total_count: @documents.total_count
      }
    }
  end

  def show
    render json: document_json(@document)
  end

  def create
    @document = Current.account.willo_ai_documents.new(document_params)

    if @document.save
      render json: document_json(@document), status: :created
    else
      render json: { errors: @document.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy!
    head :no_content
  end

  private

  def set_document
    @document = Current.account.willo_ai_documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :external_link, :content, :assistant_id, :status)
  end

  def document_json(document)
    {
      id: document.id,
      name: document.name,
      external_link: document.external_link,
      content: document.content,
      status: document.status,
      assistant_id: document.assistant_id,
      assistant: document.assistant ? { id: document.assistant.id, name: document.assistant.name } : nil,
      account_id: document.account_id,
      created_at: document.created_at,
      updated_at: document.updated_at
    }
  end
end
