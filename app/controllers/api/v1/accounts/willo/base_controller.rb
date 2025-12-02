class Api::V1::Accounts::Willo::BaseController < Api::V1::Accounts::BaseController
  private

  def ensure_contact
    @contact = Current.account.contacts.find(params[:contact_id])
  end
end
