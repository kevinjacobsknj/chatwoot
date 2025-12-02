class Api::V1::Accounts::Willo::ServicesController < Api::V1::Accounts::Willo::BaseController
  before_action :ensure_contact
  before_action :set_service, only: [:update, :destroy]

  def index
    @services = @contact.willo_services
                        .includes(:stylist)
                        .order(appointment_date: :desc)
    @client_metrics = client_metrics
  end

  def create
    @service = @contact.willo_services.create!(service_params)
  end

  def update
    @service.update!(service_params)
  end

  def destroy
    @service.destroy!
    head :no_content
  end

  private

  def set_service
    @service = @contact.willo_services.find(params[:id])
  end

  def service_params
    params.require(:service).permit(
      :service_name,
      :service_category,
      :duration_minutes,
      :price,
      :stylist_id,
      :appointment_date,
      :notes
    ).merge(account_id: Current.account.id)
  end

  def client_metrics
    preference = @contact.willo_client_preference
    return default_metrics unless preference

    {
      total_lifetime_spending: preference.total_lifetime_spending.to_f,
      visit_count: preference.visit_count,
      average_ticket: preference.average_ticket.to_f,
      last_service_date: preference.last_service_date&.iso8601
    }
  end

  def default_metrics
    {
      total_lifetime_spending: 0.0,
      visit_count: 0,
      average_ticket: 0.0,
      last_service_date: nil
    }
  end
end
