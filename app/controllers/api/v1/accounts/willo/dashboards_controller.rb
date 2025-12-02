class Api::V1::Accounts::Willo::DashboardsController < Api::V1::Accounts::Willo::BaseController
  def show
    @overview = {
      total_revenue: total_revenue,
      total_services: total_services,
      unique_clients: unique_clients,
      average_ticket: average_ticket,
      revenue_this_month: revenue_this_month,
      services_this_month: services_this_month
    }
  end

  def revenue
    @revenue_data = revenue_breakdown
  end

  def top_services
    @top_services = Willo::Service
                    .where(account_id: Current.account.id)
                    .group(:service_name)
                    .select('service_name, COUNT(*) as count, SUM(price) as total_revenue')
                    .order('count DESC')
                    .limit(10)
  end

  def inventory_alerts
    @low_stock_items = Current.account.willo_inventory_items.low_stock.order(:current_stock)
  end

  private

  def total_revenue
    Current.account.willo_services.sum(:price).to_f
  end

  def total_services
    Current.account.willo_services.count
  end

  def unique_clients
    Current.account.willo_services.distinct.count(:contact_id)
  end

  def average_ticket
    count = total_services
    return 0.0 if count.zero?

    (total_revenue / count).round(2)
  end

  def revenue_this_month
    Current.account.willo_services
           .where(appointment_date: Time.current.beginning_of_month..Time.current.end_of_month)
           .sum(:price).to_f
  end

  def services_this_month
    Current.account.willo_services
           .where(appointment_date: Time.current.beginning_of_month..Time.current.end_of_month)
           .count
  end

  def revenue_breakdown
    last_12_months = 12.months.ago.beginning_of_month..Time.current.end_of_month

    Current.account.willo_services
           .where(appointment_date: last_12_months)
           .group("DATE_TRUNC('month', appointment_date)")
           .select("DATE_TRUNC('month', appointment_date) as month, SUM(price) as revenue, COUNT(*) as service_count")
           .order('month ASC')
           .map do |record|
             {
               month: record.month.strftime('%Y-%m'),
               revenue: record.revenue.to_f,
               service_count: record.service_count
             }
           end
  end
end
