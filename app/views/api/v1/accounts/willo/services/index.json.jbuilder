json.services do
  json.array! @services do |service|
    json.partial! 'api/v1/models/willo_service', formats: [:json], resource: service
  end
end

json.client_metrics @client_metrics
