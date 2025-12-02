<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';

import WilloAPI from 'dashboard/api/willo';
import Modal from 'dashboard/components/Modal.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';

const props = defineProps({
  contactId: {
    type: [String, Number],
    required: true,
  },
});

const emit = defineEmits(['close', 'created']);

const { t } = useI18n();

const showModal = ref(true);
const isSubmitting = ref(false);

const agents = useMapGetter('agents/getAgents');

const formData = ref({
  service_name: '',
  service_category: '',
  price: '',
  duration_minutes: '',
  stylist_id: '',
  appointment_date: new Date().toISOString().slice(0, 16),
  notes: '',
});

const SERVICE_CATEGORIES = [
  { value: 'Color', label: t('WILLO.SERVICES.CATEGORIES.COLOR') },
  { value: 'Cut', label: t('WILLO.SERVICES.CATEGORIES.CUT') },
  { value: 'Style', label: t('WILLO.SERVICES.CATEGORIES.STYLE') },
  { value: 'Treatment', label: t('WILLO.SERVICES.CATEGORIES.TREATMENT') },
];

const COMMON_SERVICES = [
  { name: 'Haircut', category: 'Cut', duration: 45, price: 45 },
  { name: "Women's Haircut", category: 'Cut', duration: 60, price: 65 },
  { name: "Men's Haircut", category: 'Cut', duration: 30, price: 35 },
  { name: 'Full Color', category: 'Color', duration: 120, price: 150 },
  { name: 'Root Touch-Up', category: 'Color', duration: 90, price: 95 },
  { name: 'Highlights', category: 'Color', duration: 150, price: 175 },
  { name: 'Balayage', category: 'Color', duration: 180, price: 225 },
  { name: 'Blowout', category: 'Style', duration: 45, price: 55 },
  { name: 'Updo', category: 'Style', duration: 60, price: 85 },
  { name: 'Deep Conditioning', category: 'Treatment', duration: 30, price: 35 },
  {
    name: 'Keratin Treatment',
    category: 'Treatment',
    duration: 180,
    price: 300,
  },
];

const isFormValid = computed(() => {
  return (
    formData.value.service_name.trim() !== '' &&
    formData.value.appointment_date !== ''
  );
});

const selectCommonService = service => {
  formData.value.service_name = service.name;
  formData.value.service_category = service.category;
  formData.value.duration_minutes = service.duration;
  formData.value.price = service.price;
};

const handleClose = () => {
  showModal.value = false;
  emit('close');
};

const handleSubmit = async () => {
  if (!isFormValid.value || isSubmitting.value) return;

  isSubmitting.value = true;
  try {
    const serviceData = {
      service_name: formData.value.service_name,
      service_category: formData.value.service_category || null,
      price: formData.value.price ? parseFloat(formData.value.price) : null,
      duration_minutes: formData.value.duration_minutes
        ? parseInt(formData.value.duration_minutes, 10)
        : null,
      stylist_id: formData.value.stylist_id || null,
      appointment_date: formData.value.appointment_date,
      notes: formData.value.notes || null,
    };

    await WilloAPI.createService(props.contactId, serviceData);
    emit('created');
  } catch {
    useAlert(t('WILLO.SERVICES.CREATE_ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<template>
  <Modal v-model:show="showModal" :on-close="handleClose">
    <div class="p-6">
      <h2 class="mb-6 text-lg font-semibold text-n-slate-12">
        {{ t('WILLO.SERVICES.ADD_TITLE') }}
      </h2>

      <!-- Quick Select Common Services -->
      <div class="mb-6">
        <p class="mb-2 text-sm font-medium text-n-slate-11">
          {{ t('WILLO.SERVICES.QUICK_SELECT') }}
        </p>
        <div class="flex flex-wrap gap-2">
          <Button
            v-for="service in COMMON_SERVICES.slice(0, 6)"
            :key="service.name"
            variant="faded"
            color="slate"
            size="xs"
            :label="service.name"
            @click="selectCommonService(service)"
          />
        </div>
      </div>

      <form class="space-y-4" @submit.prevent="handleSubmit">
        <!-- Service Name -->
        <Input
          v-model="formData.service_name"
          :label="t('WILLO.SERVICES.FORM.NAME')"
          :placeholder="t('WILLO.SERVICES.FORM.NAME_PLACEHOLDER')"
          autofocus
        />

        <!-- Service Category -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-slate-12">
            {{ t('WILLO.SERVICES.FORM.CATEGORY') }}
          </label>
          <select
            v-model="formData.service_category"
            class="block w-full h-10 px-3 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
          >
            <option value="">
              {{ t('WILLO.SERVICES.FORM.SELECT_CATEGORY') }}
            </option>
            <option
              v-for="category in SERVICE_CATEGORIES"
              :key="category.value"
              :value="category.value"
            >
              {{ category.label }}
            </option>
          </select>
        </div>

        <!-- Price and Duration Row -->
        <div class="grid grid-cols-2 gap-4">
          <Input
            v-model="formData.price"
            type="number"
            :label="t('WILLO.SERVICES.FORM.PRICE')"
            placeholder="0.00"
            min="0"
            step="0.01"
          />
          <Input
            v-model="formData.duration_minutes"
            type="number"
            :label="t('WILLO.SERVICES.FORM.DURATION')"
            placeholder="60"
            min="0"
          />
        </div>

        <!-- Appointment Date -->
        <Input
          v-model="formData.appointment_date"
          type="datetime-local"
          :label="t('WILLO.SERVICES.FORM.DATE')"
        />

        <!-- Stylist -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-slate-12">
            {{ t('WILLO.SERVICES.FORM.STYLIST') }}
          </label>
          <select
            v-model="formData.stylist_id"
            class="block w-full h-10 px-3 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
          >
            <option value="">
              {{ t('WILLO.SERVICES.FORM.SELECT_STYLIST') }}
            </option>
            <option v-for="agent in agents" :key="agent.id" :value="agent.id">
              {{ agent.name }}
            </option>
          </select>
        </div>

        <!-- Notes -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-slate-12">
            {{ t('WILLO.SERVICES.FORM.NOTES') }}
          </label>
          <textarea
            v-model="formData.notes"
            :placeholder="t('WILLO.SERVICES.FORM.NOTES_PLACEHOLDER')"
            rows="3"
            class="block w-full px-3 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
          />
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3 pt-4">
          <Button
            variant="faded"
            color="slate"
            :label="t('WILLO.COMMON.CANCEL')"
            @click="handleClose"
          />
          <Button
            variant="solid"
            color="blue"
            :label="t('WILLO.SERVICES.FORM.SAVE')"
            :is-loading="isSubmitting"
            :disabled="!isFormValid || isSubmitting"
            @click="handleSubmit"
          />
        </div>
      </form>
    </div>
  </Modal>
</template>
