<script setup>
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';

import WilloAPI from 'dashboard/api/willo';
import Modal from 'dashboard/components/Modal.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';

const props = defineProps({
  contactId: {
    type: [String, Number],
    required: true,
  },
  initialPreferences: {
    type: Object,
    default: () => ({
      color_formula: '',
      allergies: '',
      service_notes: '',
      preferred_products: [],
    }),
  },
});

const emit = defineEmits(['close', 'updated']);

const { t } = useI18n();

const showModal = ref(true);
const isSubmitting = ref(false);

const formData = ref({
  color_formula: '',
  allergies: '',
  service_notes: '',
  preferred_products_text: '',
});

const handleClose = () => {
  showModal.value = false;
  emit('close');
};

const handleSubmit = async () => {
  if (isSubmitting.value) return;

  isSubmitting.value = true;
  try {
    const preferences = {
      color_formula: formData.value.color_formula || null,
      allergies: formData.value.allergies || null,
      service_notes: formData.value.service_notes || null,
      preferred_products: formData.value.preferred_products_text
        ? formData.value.preferred_products_text
            .split(',')
            .map(p => p.trim())
            .filter(p => p !== '')
        : [],
    };

    await WilloAPI.updateClientPreferences(props.contactId, preferences);
    emit('updated');
  } catch {
    useAlert(t('WILLO.PREFERENCES.UPDATE_ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};

onMounted(() => {
  formData.value = {
    color_formula: props.initialPreferences.color_formula || '',
    allergies: props.initialPreferences.allergies || '',
    service_notes: props.initialPreferences.service_notes || '',
    preferred_products_text: Array.isArray(
      props.initialPreferences.preferred_products
    )
      ? props.initialPreferences.preferred_products.join(', ')
      : '',
  };
});
</script>

<template>
  <Modal v-model:show="showModal" :on-close="handleClose">
    <div class="p-6">
      <h2 class="mb-6 text-lg font-semibold text-n-slate-12">
        {{ t('WILLO.PREFERENCES.EDIT_TITLE') }}
      </h2>

      <form class="space-y-4" @submit.prevent="handleSubmit">
        <!-- Color Formula -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-slate-12">
            {{ t('WILLO.PREFERENCES.FORM.COLOR_FORMULA') }}
          </label>
          <textarea
            v-model="formData.color_formula"
            :placeholder="t('WILLO.PREFERENCES.FORM.COLOR_FORMULA_PLACEHOLDER')"
            rows="3"
            class="block w-full px-3 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
          />
          <p class="mt-1 text-xs text-n-slate-11">
            {{ t('WILLO.PREFERENCES.FORM.COLOR_FORMULA_HINT') }}
          </p>
        </div>

        <!-- Allergies -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-ruby-11">
            {{ t('WILLO.PREFERENCES.FORM.ALLERGIES') }}
          </label>
          <Input
            v-model="formData.allergies"
            :placeholder="t('WILLO.PREFERENCES.FORM.ALLERGIES_PLACEHOLDER')"
            custom-input-class="!outline-n-ruby-6 focus:!outline-n-ruby-8"
          />
          <p class="mt-1 text-xs text-n-ruby-10">
            {{ t('WILLO.PREFERENCES.FORM.ALLERGIES_HINT') }}
          </p>
        </div>

        <!-- Preferred Products -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-slate-12">
            {{ t('WILLO.PREFERENCES.FORM.PREFERRED_PRODUCTS') }}
          </label>
          <Input
            v-model="formData.preferred_products_text"
            :placeholder="
              t('WILLO.PREFERENCES.FORM.PREFERRED_PRODUCTS_PLACEHOLDER')
            "
          />
          <p class="mt-1 text-xs text-n-slate-11">
            {{ t('WILLO.PREFERENCES.FORM.PREFERRED_PRODUCTS_HINT') }}
          </p>
        </div>

        <!-- Service Notes -->
        <div>
          <label class="mb-1 text-sm font-medium text-n-slate-12">
            {{ t('WILLO.PREFERENCES.FORM.SERVICE_NOTES') }}
          </label>
          <textarea
            v-model="formData.service_notes"
            :placeholder="t('WILLO.PREFERENCES.FORM.SERVICE_NOTES_PLACEHOLDER')"
            rows="4"
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
            :label="t('WILLO.PREFERENCES.FORM.SAVE')"
            :is-loading="isSubmitting"
            :disabled="isSubmitting"
            @click="handleSubmit"
          />
        </div>
      </form>
    </div>
  </Modal>
</template>
