json.id resource.id
json.service_name resource.service_name
json.service_category resource.service_category
json.duration_minutes resource.duration_minutes
json.price resource.price.to_f
json.appointment_date resource.appointment_date.iso8601
json.notes resource.notes
json.contact_id resource.contact_id
json.account_id resource.account_id
json.created_at resource.created_at.to_i
json.updated_at resource.updated_at.to_i

if resource.stylist.present?
  json.stylist do
    json.partial! 'api/v1/models/agent', formats: [:json], resource: resource.stylist
  end
end
