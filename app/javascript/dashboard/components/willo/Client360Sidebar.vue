<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';

import WilloAPI from 'dashboard/api/willo';
import Button from 'dashboard/components-next/button/Button.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import AddServiceModal from './AddServiceModal.vue';
import EditPreferencesModal from './EditPreferencesModal.vue';

const props = defineProps({
  contactId: {
    type: [String, Number],
    required: true,
  },
});

const { t } = useI18n();

const isLoading = ref(true);
const services = ref([]);
const clientMetrics = ref({
  total_lifetime_spending: 0,
  visit_count: 0,
  average_ticket: 0,
  last_service_date: null,
});
const preferences = ref({
  color_formula: '',
  allergies: '',
  service_notes: '',
  preferred_products: [],
});

const showAddServiceModal = ref(false);
const showEditPreferencesModal = ref(false);

const formattedLifetimeValue = computed(() => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(clientMetrics.value.total_lifetime_spending || 0);
});

const formattedAverageTicket = computed(() => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(clientMetrics.value.average_ticket || 0);
});

const formattedLastVisit = computed(() => {
  if (!clientMetrics.value.last_service_date) return 'Never';
  const date = new Date(clientMetrics.value.last_service_date);
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
});

const hasAllergies = computed(() => {
  return (
    preferences.value.allergies && preferences.value.allergies.trim() !== ''
  );
});

const fetchData = async () => {
  isLoading.value = true;
  try {
    const [servicesResponse, preferencesResponse] = await Promise.all([
      WilloAPI.getServices(props.contactId),
      WilloAPI.getClientPreferences(props.contactId).catch(() => ({
        data: {},
      })),
    ]);

    services.value = servicesResponse.data.services || [];
    clientMetrics.value = servicesResponse.data.client_metrics || {
      total_lifetime_spending: 0,
      visit_count: 0,
      average_ticket: 0,
      last_service_date: null,
    };

    if (preferencesResponse.data) {
      preferences.value = {
        color_formula: preferencesResponse.data.color_formula || '',
        allergies: preferencesResponse.data.allergies || '',
        service_notes: preferencesResponse.data.service_notes || '',
        preferred_products: preferencesResponse.data.preferred_products || [],
      };
    }
  } catch {
    // Silently fail - data will show as empty
  } finally {
    isLoading.value = false;
  }
};

const handleServiceCreated = () => {
  showAddServiceModal.value = false;
  fetchData();
  useAlert(t('WILLO.SERVICES.CREATE_SUCCESS'));
};

const handlePreferencesUpdated = () => {
  showEditPreferencesModal.value = false;
  fetchData();
  useAlert(t('WILLO.PREFERENCES.UPDATE_SUCCESS'));
};

const formatServiceDate = dateString => {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
};

const formatPrice = price => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(price || 0);
};

watch(
  () => props.contactId,
  () => {
    if (props.contactId) {
      fetchData();
    }
  }
);

onMounted(() => {
  if (props.contactId) {
    fetchData();
  }
});
</script>

<template>
  <div class="flex flex-col gap-6 py-6">
    <!-- Loading State -->
    <div
      v-if="isLoading"
      class="flex items-center justify-center py-10 text-n-slate-11"
    >
      <Spinner />
    </div>

    <template v-else>
      <!-- Client Metrics Cards -->
      <div class="px-6">
        <h3 class="mb-4 text-sm font-semibold text-n-slate-12">
          {{ t('WILLO.CLIENT_METRICS.TITLE') }}
        </h3>
        <div class="grid grid-cols-2 gap-3">
          <!-- Lifetime Value -->
          <div class="p-3 rounded-lg bg-n-alpha-2">
            <p class="text-xs text-n-slate-11">
              {{ t('WILLO.CLIENT_METRICS.LIFETIME_VALUE') }}
            </p>
            <p class="text-lg font-semibold text-n-teal-11">
              {{ formattedLifetimeValue }}
            </p>
          </div>

          <!-- Visit Count -->
          <div class="p-3 rounded-lg bg-n-alpha-2">
            <p class="text-xs text-n-slate-11">
              {{ t('WILLO.CLIENT_METRICS.VISITS') }}
            </p>
            <p class="text-lg font-semibold text-n-slate-12">
              {{ clientMetrics.visit_count }}
            </p>
          </div>

          <!-- Average Ticket -->
          <div class="p-3 rounded-lg bg-n-alpha-2">
            <p class="text-xs text-n-slate-11">
              {{ t('WILLO.CLIENT_METRICS.AVG_TICKET') }}
            </p>
            <p class="text-lg font-semibold text-n-slate-12">
              {{ formattedAverageTicket }}
            </p>
          </div>

          <!-- Last Visit -->
          <div class="p-3 rounded-lg bg-n-alpha-2">
            <p class="text-xs text-n-slate-11">
              {{ t('WILLO.CLIENT_METRICS.LAST_VISIT') }}
            </p>
            <p class="text-lg font-semibold text-n-slate-12">
              {{ formattedLastVisit }}
            </p>
          </div>
        </div>
      </div>

      <!-- Preferences Section -->
      <div class="px-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-sm font-semibold text-n-slate-12">
            {{ t('WILLO.PREFERENCES.TITLE') }}
          </h3>
          <Button
            variant="ghost"
            color="blue"
            size="xs"
            icon="i-lucide-pencil"
            @click="showEditPreferencesModal = true"
          />
        </div>

        <div class="space-y-3">
          <!-- Color Formula -->
          <div
            v-if="preferences.color_formula"
            class="p-3 rounded-lg bg-n-alpha-2"
          >
            <p class="text-xs text-n-slate-11">
              {{ t('WILLO.PREFERENCES.COLOR_FORMULA') }}
            </p>
            <p class="text-sm text-n-slate-12">
              {{ preferences.color_formula }}
            </p>
          </div>

          <!-- Allergies Alert -->
          <div
            v-if="hasAllergies"
            class="p-3 rounded-lg bg-n-ruby-3 border border-n-ruby-6"
          >
            <p class="text-xs font-semibold text-n-ruby-11">
              {{ t('WILLO.PREFERENCES.ALLERGIES') }}
            </p>
            <p class="text-sm text-n-ruby-12">
              {{ preferences.allergies }}
            </p>
          </div>

          <!-- Service Notes -->
          <div
            v-if="preferences.service_notes"
            class="p-3 rounded-lg bg-n-alpha-2"
          >
            <p class="text-xs text-n-slate-11">
              {{ t('WILLO.PREFERENCES.SERVICE_NOTES') }}
            </p>
            <p class="text-sm text-n-slate-12">
              {{ preferences.service_notes }}
            </p>
          </div>

          <!-- Empty State -->
          <p
            v-if="
              !preferences.color_formula &&
              !hasAllergies &&
              !preferences.service_notes
            "
            class="text-sm text-center text-n-slate-11 py-4"
          >
            {{ t('WILLO.PREFERENCES.EMPTY_STATE') }}
          </p>
        </div>
      </div>

      <!-- Service History -->
      <div class="px-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-sm font-semibold text-n-slate-12">
            {{ t('WILLO.SERVICES.TITLE') }}
          </h3>
          <Button
            variant="faded"
            color="blue"
            size="xs"
            icon="i-lucide-plus"
            :label="t('WILLO.SERVICES.ADD')"
            @click="showAddServiceModal = true"
          />
        </div>

        <div v-if="services.length > 0" class="space-y-2">
          <div
            v-for="service in services"
            :key="service.id"
            class="p-3 rounded-lg bg-n-alpha-2 hover:bg-n-alpha-3 transition-colors"
          >
            <div class="flex items-start justify-between">
              <div>
                <p class="text-sm font-medium text-n-slate-12">
                  {{ service.service_name }}
                </p>
                <p class="text-xs text-n-slate-11">
                  {{ formatServiceDate(service.appointment_date) }}
                  <template v-if="service.stylist">
                    {{ ` - ${service.stylist.name}` }}
                  </template>
                </p>
              </div>
              <p class="text-sm font-semibold text-n-teal-11">
                {{ formatPrice(service.price) }}
              </p>
            </div>
            <p v-if="service.notes" class="mt-2 text-xs text-n-slate-11">
              {{ service.notes }}
            </p>
          </div>
        </div>

        <p v-else class="text-sm text-center text-n-slate-11 py-6">
          {{ t('WILLO.SERVICES.EMPTY_STATE') }}
        </p>
      </div>
    </template>

    <!-- Add Service Modal -->
    <AddServiceModal
      v-if="showAddServiceModal"
      :contact-id="contactId"
      @close="showAddServiceModal = false"
      @created="handleServiceCreated"
    />

    <!-- Edit Preferences Modal -->
    <EditPreferencesModal
      v-if="showEditPreferencesModal"
      :contact-id="contactId"
      :initial-preferences="preferences"
      @close="showEditPreferencesModal = false"
      @updated="handlePreferencesUpdated"
    />
  </div>
</template>
