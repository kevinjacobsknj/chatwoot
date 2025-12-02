json.overview do
  json.total_revenue @overview[:total_revenue]
  json.total_services @overview[:total_services]
  json.unique_clients @overview[:unique_clients]
  json.average_ticket @overview[:average_ticket]
  json.revenue_this_month @overview[:revenue_this_month]
  json.services_this_month @overview[:services_this_month]
end
