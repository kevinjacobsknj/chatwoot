<script setup>
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';

import WilloAPI from 'dashboard/api/willo';
import Button from 'dashboard/components-next/button/Button.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

const { t } = useI18n();

const isLoading = ref(true);
const overview = ref({
  total_revenue: 0,
  total_services: 0,
  unique_clients: 0,
  average_ticket: 0,
  revenue_this_month: 0,
  services_this_month: 0,
});
const revenueData = ref([]);
const topServices = ref([]);
const lowStockItems = ref([]);

const formatCurrency = value => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(value || 0);
};

const formatMonth = monthStr => {
  const date = new Date(monthStr + '-01');
  return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' });
};

const maxRevenue = computed(() => {
  if (revenueData.value.length === 0) return 1;
  return Math.max(...revenueData.value.map(d => d.revenue)) || 1;
});

const fetchDashboardData = async () => {
  isLoading.value = true;
  try {
    const [overviewRes, revenueRes, topServicesRes, inventoryRes] =
      await Promise.all([
        WilloAPI.getDashboard(),
        WilloAPI.getRevenue(),
        WilloAPI.getTopServices(),
        WilloAPI.getInventoryAlerts(),
      ]);

    overview.value = overviewRes.data.overview || overview.value;
    revenueData.value = revenueRes.data.revenue_data || [];
    topServices.value = topServicesRes.data.top_services || [];
    lowStockItems.value = inventoryRes.data.low_stock_items || [];
  } catch {
    useAlert(t('WILLO.DASHBOARD.LOAD_ERROR'));
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchDashboardData();
});
</script>

<template>
  <div class="flex flex-col h-full bg-n-background overflow-auto">
    <!-- Page Header -->
    <div class="border-b border-n-weak px-8 py-6">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-semibold text-n-slate-12">
            {{ t('WILLO.DASHBOARD.TITLE') }}
          </h1>
          <p class="mt-1 text-sm text-n-slate-11">
            {{ t('WILLO.DASHBOARD.DESCRIPTION') }}
          </p>
        </div>
        <Button
          variant="faded"
          color="slate"
          icon="i-lucide-refresh-cw"
          :label="t('WILLO.DASHBOARD.REFRESH')"
          :is-loading="isLoading"
          @click="fetchDashboardData"
        />
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center flex-1">
      <Spinner />
    </div>

    <!-- Dashboard Content -->
    <div v-else class="flex-1 p-8 space-y-8">
      <!-- Overview Metrics -->
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        <!-- Total Revenue -->
        <div class="p-4 rounded-xl bg-n-solid-3 border border-n-weak">
          <p
            class="text-xs font-medium text-n-slate-11 uppercase tracking-wide"
          >
            {{ t('WILLO.DASHBOARD.METRICS.TOTAL_REVENUE') }}
          </p>
          <p class="mt-2 text-2xl font-bold text-n-teal-11">
            {{ formatCurrency(overview.total_revenue) }}
          </p>
        </div>

        <!-- Revenue This Month -->
        <div class="p-4 rounded-xl bg-n-solid-3 border border-n-weak">
          <p
            class="text-xs font-medium text-n-slate-11 uppercase tracking-wide"
          >
            {{ t('WILLO.DASHBOARD.METRICS.REVENUE_THIS_MONTH') }}
          </p>
          <p class="mt-2 text-2xl font-bold text-n-blue-text">
            {{ formatCurrency(overview.revenue_this_month) }}
          </p>
        </div>

        <!-- Total Services -->
        <div class="p-4 rounded-xl bg-n-solid-3 border border-n-weak">
          <p
            class="text-xs font-medium text-n-slate-11 uppercase tracking-wide"
          >
            {{ t('WILLO.DASHBOARD.METRICS.TOTAL_SERVICES') }}
          </p>
          <p class="mt-2 text-2xl font-bold text-n-slate-12">
            {{ overview.total_services }}
          </p>
        </div>

        <!-- Services This Month -->
        <div class="p-4 rounded-xl bg-n-solid-3 border border-n-weak">
          <p
            class="text-xs font-medium text-n-slate-11 uppercase tracking-wide"
          >
            {{ t('WILLO.DASHBOARD.METRICS.SERVICES_THIS_MONTH') }}
          </p>
          <p class="mt-2 text-2xl font-bold text-n-slate-12">
            {{ overview.services_this_month }}
          </p>
        </div>

        <!-- Unique Clients -->
        <div class="p-4 rounded-xl bg-n-solid-3 border border-n-weak">
          <p
            class="text-xs font-medium text-n-slate-11 uppercase tracking-wide"
          >
            {{ t('WILLO.DASHBOARD.METRICS.UNIQUE_CLIENTS') }}
          </p>
          <p class="mt-2 text-2xl font-bold text-n-slate-12">
            {{ overview.unique_clients }}
          </p>
        </div>

        <!-- Average Ticket -->
        <div class="p-4 rounded-xl bg-n-solid-3 border border-n-weak">
          <p
            class="text-xs font-medium text-n-slate-11 uppercase tracking-wide"
          >
            {{ t('WILLO.DASHBOARD.METRICS.AVG_TICKET') }}
          </p>
          <p class="mt-2 text-2xl font-bold text-n-slate-12">
            {{ formatCurrency(overview.average_ticket) }}
          </p>
        </div>
      </div>

      <!-- Charts Row -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Revenue Chart -->
        <div class="p-6 rounded-xl bg-n-solid-3 border border-n-weak">
          <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
            {{ t('WILLO.DASHBOARD.CHARTS.REVENUE_TREND') }}
          </h3>
          <div v-if="revenueData.length > 0" class="space-y-3">
            <div
              v-for="month in revenueData"
              :key="month.month"
              class="flex items-center gap-4"
            >
              <span class="w-20 text-xs text-n-slate-11 text-right">
                {{ formatMonth(month.month) }}
              </span>
              <div class="flex-1 h-6 bg-n-alpha-2 rounded overflow-hidden">
                <div
                  class="h-full bg-n-teal-9 rounded transition-all duration-500"
                  :style="{
                    width: `${(month.revenue / maxRevenue) * 100}%`,
                  }"
                />
              </div>
              <span class="w-24 text-sm font-medium text-n-slate-12 text-right">
                {{ formatCurrency(month.revenue) }}
              </span>
            </div>
          </div>
          <p v-else class="text-center text-n-slate-11 py-8">
            {{ t('WILLO.DASHBOARD.CHARTS.NO_DATA') }}
          </p>
        </div>

        <!-- Top Services -->
        <div class="p-6 rounded-xl bg-n-solid-3 border border-n-weak">
          <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
            {{ t('WILLO.DASHBOARD.CHARTS.TOP_SERVICES') }}
          </h3>
          <div v-if="topServices.length > 0" class="space-y-3">
            <div
              v-for="(service, index) in topServices"
              :key="service.service_name"
              class="flex items-center justify-between p-3 rounded-lg bg-n-alpha-2"
            >
              <div class="flex items-center gap-3">
                <span
                  class="w-6 h-6 rounded-full bg-n-brand text-white text-xs font-bold flex items-center justify-center"
                >
                  {{ index + 1 }}
                </span>
                <div>
                  <p class="text-sm font-medium text-n-slate-12">
                    {{ service.service_name }}
                  </p>
                  <p class="text-xs text-n-slate-11">
                    {{ service.count }}
                    {{ t('WILLO.DASHBOARD.CHARTS.APPOINTMENTS') }}
                  </p>
                </div>
              </div>
              <p class="text-sm font-semibold text-n-teal-11">
                {{ formatCurrency(service.total_revenue) }}
              </p>
            </div>
          </div>
          <p v-else class="text-center text-n-slate-11 py-8">
            {{ t('WILLO.DASHBOARD.CHARTS.NO_SERVICES') }}
          </p>
        </div>
      </div>

      <!-- Inventory Alerts -->
      <div
        v-if="lowStockItems.length > 0"
        class="p-6 rounded-xl bg-n-ruby-3 border border-n-ruby-6"
      >
        <div class="flex items-center gap-2 mb-4">
          <span class="i-lucide-alert-triangle text-n-ruby-11 w-5 h-5" />
          <h3 class="text-lg font-semibold text-n-ruby-12">
            {{ t('WILLO.DASHBOARD.INVENTORY.LOW_STOCK_ALERT') }}
          </h3>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="item in lowStockItems"
            :key="item.id"
            class="flex items-center justify-between p-3 rounded-lg bg-n-ruby-4"
          >
            <div>
              <p class="text-sm font-medium text-n-ruby-12">
                {{ item.product_name }}
              </p>
              <p class="text-xs text-n-ruby-11">
                {{ item.product_category }}
              </p>
            </div>
            <div class="text-right">
              <p class="text-lg font-bold text-n-ruby-12">
                {{ item.current_stock }}
              </p>
              <p class="text-xs text-n-ruby-11">
                {{
                  t('WILLO.DASHBOARD.INVENTORY.THRESHOLD', {
                    threshold: item.reorder_threshold,
                  })
                }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
