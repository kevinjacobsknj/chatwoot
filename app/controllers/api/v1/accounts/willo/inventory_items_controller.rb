class Api::V1::Accounts::Willo::InventoryItemsController < Api::V1::Accounts::Willo::BaseController
  before_action :set_inventory_item, only: [:show, :update, :destroy]

  def index
    @inventory_items = Current.account.willo_inventory_items.order(:product_name)
    @inventory_items = @inventory_items.by_category(params[:category]) if params[:category].present?
    @inventory_items = @inventory_items.low_stock if params[:low_stock] == 'true'
  end

  def show; end

  def create
    @inventory_item = Current.account.willo_inventory_items.create!(inventory_item_params)
  end

  def update
    @inventory_item.update!(inventory_item_params)
  end

  def destroy
    @inventory_item.destroy!
    head :no_content
  end

  private

  def set_inventory_item
    @inventory_item = Current.account.willo_inventory_items.find(params[:id])
  end

  def inventory_item_params
    params.require(:inventory_item).permit(
      :product_name,
      :product_category,
      :current_stock,
      :reorder_threshold,
      :unit_cost,
      :supplier
    )
  end
end
