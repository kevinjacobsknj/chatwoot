json.top_services do
  json.array! @top_services do |service|
    json.service_name service.service_name
    json.count service.count
    json.total_revenue service.total_revenue.to_f
  end
end
