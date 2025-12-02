json.id resource.id
json.contact_id resource.contact_id
json.account_id resource.account_id
json.color_formula resource.color_formula
json.allergies resource.allergies
json.preferred_products resource.preferred_products
json.service_notes resource.service_notes
json.last_service_date resource.last_service_date&.iso8601
json.total_lifetime_spending resource.total_lifetime_spending.to_f
json.visit_count resource.visit_count
json.average_ticket resource.average_ticket.to_f
json.created_at resource.created_at.to_i
json.updated_at resource.updated_at.to_i

if resource.preferred_stylist.present?
  json.preferred_stylist do
    json.partial! 'api/v1/models/agent', formats: [:json], resource: resource.preferred_stylist
  end
end
