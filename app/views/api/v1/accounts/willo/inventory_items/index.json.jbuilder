json.array! @inventory_items do |item|
  json.partial! 'api/v1/models/willo_inventory_item', formats: [:json], resource: item
end
