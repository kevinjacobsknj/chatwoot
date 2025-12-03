class Api::V1::Accounts::Captain::BaseController < Api::V1::Accounts::BaseController
  before_action :check_feature_enabled

  private

  def check_feature_enabled
    return if current_account.feature_enabled?('captain_integration')

    render json: { error: 'Willo AI feature is not enabled for this account' }, status: :forbidden
  end

  def current_assistant
    @current_assistant ||= Current.account.willo_ai_assistants.find(params[:assistant_id])
  end
end
