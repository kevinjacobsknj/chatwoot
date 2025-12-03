class Api::V1::Accounts::Captain::InboxesController < Api::V1::Accounts::Captain::BaseController
  before_action :set_assistant
  before_action :set_willo_inbox, only: [:destroy]

  def index
    @willo_inboxes = @assistant.inboxes.includes(:inbox)

    render json: {
      payload: @willo_inboxes.map { |wi| inbox_json(wi) }
    }
  end

  def create
    inbox = Current.account.inboxes.find(inbox_params[:inbox_id])
    @willo_inbox = @assistant.inboxes.new(inbox: inbox)

    if @willo_inbox.save
      render json: inbox_json(@willo_inbox), status: :created
    else
      render json: { errors: @willo_inbox.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @willo_inbox.destroy!
    head :no_content
  end

  private

  def set_assistant
    @assistant = Current.account.willo_ai_assistants.find(params[:assistant_id])
  end

  def set_willo_inbox
    @willo_inbox = @assistant.inboxes.find_by!(inbox_id: params[:inbox_id])
  end

  def inbox_params
    params.require(:inbox).permit(:inbox_id)
  end

  def inbox_json(willo_inbox)
    inbox = willo_inbox.inbox
    {
      id: willo_inbox.id,
      assistant_id: willo_inbox.assistant_id,
      inbox_id: inbox.id,
      inbox: {
        id: inbox.id,
        name: inbox.name,
        channel_type: inbox.channel_type
      },
      created_at: willo_inbox.created_at,
      updated_at: willo_inbox.updated_at
    }
  end
end
