/* global axios */
import ApiClient from './ApiClient';

class WilloAPI extends ApiClient {
  constructor() {
    super('willo', { accountScoped: true });
  }

  // Services API
  getServices(contactId) {
    return axios.get(`${this.url}/contacts/${contactId}/services`);
  }

  createService(contactId, serviceData) {
    return axios.post(`${this.url}/contacts/${contactId}/services`, {
      service: serviceData,
    });
  }

  updateService(contactId, serviceId, serviceData) {
    return axios.patch(
      `${this.url}/contacts/${contactId}/services/${serviceId}`,
      {
        service: serviceData,
      }
    );
  }

  deleteService(contactId, serviceId) {
    return axios.delete(
      `${this.url}/contacts/${contactId}/services/${serviceId}`
    );
  }

  // Client Preferences API
  getClientPreferences(contactId) {
    return axios.get(`${this.url}/contacts/${contactId}/client_preference`);
  }

  updateClientPreferences(contactId, preferences) {
    return axios.patch(`${this.url}/contacts/${contactId}/client_preference`, {
      client_preference: preferences,
    });
  }

  // Dashboard API
  getDashboard() {
    return axios.get(`${this.url}/dashboard`);
  }

  getRevenue() {
    return axios.get(`${this.url}/dashboard/revenue`);
  }

  getTopServices() {
    return axios.get(`${this.url}/dashboard/top_services`);
  }

  getInventoryAlerts() {
    return axios.get(`${this.url}/dashboard/inventory_alerts`);
  }

  // Inventory API
  getInventoryItems(params = {}) {
    const queryParams = new URLSearchParams();
    if (params.category) queryParams.append('category', params.category);
    if (params.low_stock) queryParams.append('low_stock', 'true');
    const queryString = queryParams.toString();
    return axios.get(
      `${this.url}/inventory_items${queryString ? `?${queryString}` : ''}`
    );
  }

  createInventoryItem(itemData) {
    return axios.post(`${this.url}/inventory_items`, {
      inventory_item: itemData,
    });
  }

  updateInventoryItem(itemId, itemData) {
    return axios.patch(`${this.url}/inventory_items/${itemId}`, {
      inventory_item: itemData,
    });
  }

  deleteInventoryItem(itemId) {
    return axios.delete(`${this.url}/inventory_items/${itemId}`);
  }
}

export default new WilloAPI();
