class Api::V1::Accounts::Willo::ClientPreferencesController < Api::V1::Accounts::Willo::BaseController
  before_action :ensure_contact
  before_action :set_or_initialize_preference

  def show; end

  def update
    @preference.update!(preference_params)
  end

  private

  def set_or_initialize_preference
    @preference = @contact.willo_client_preference ||
                  @contact.build_willo_client_preference(account_id: Current.account.id)
  end

  def preference_params
    params.require(:client_preference).permit(
      :color_formula,
      :allergies,
      :preferred_stylist_id,
      :service_notes,
      preferred_products: []
    ).merge(account_id: Current.account.id)
  end
end
