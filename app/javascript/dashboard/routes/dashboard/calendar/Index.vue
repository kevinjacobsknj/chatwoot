<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const currentUser = useMapGetter('getCurrentUser');

// Extract iframe src from the calendar URL
// Handles both direct URLs and full iframe HTML embed codes
const calendarSrc = computed(() => {
  const calendarUrl = currentUser.value?.google_calendar_url;

  if (!calendarUrl) {
    return null;
  }

  // If the URL contains an iframe tag, extract the src attribute
  if (calendarUrl.includes('<iframe')) {
    const srcMatch = calendarUrl.match(/src=["']([^"']+)["']/);
    return srcMatch ? srcMatch[1] : null;
  }

  // Otherwise, use the URL directly
  return calendarUrl;
});

const hasCalendarUrl = computed(() => !!calendarSrc.value);
</script>

<template>
  <div class="flex flex-col h-full bg-white dark:bg-slate-900">
    <!-- Page Header -->
    <div class="border-b border-slate-200 dark:border-slate-700 px-8 py-6">
      <!-- eslint-disable-next-line vue/no-bare-strings-in-template, @intlify/vue-i18n/no-raw-text -->
      <h1 class="text-2xl font-semibold text-slate-900 dark:text-slate-100">
        {{ t('CALENDAR.TITLE', '📅 Your Calendar') }}
      </h1>
      <p class="mt-1 text-sm text-slate-600 dark:text-slate-400">
        {{ t('CALENDAR.DESCRIPTION', 'View and manage your schedule') }}
      </p>
    </div>

    <!-- Calendar Content -->
    <div class="flex-1 overflow-hidden p-8">
      <!-- Show Calendar if URL is set -->
      <div
        v-if="hasCalendarUrl"
        class="h-full rounded-lg border border-slate-200 dark:border-slate-700 overflow-hidden shadow-sm"
      >
        <iframe
          :src="calendarSrc"
          class="w-full h-full"
          frameborder="0"
          scrolling="yes"
          :title="t('CALENDAR.IFRAME_TITLE', 'Google Calendar')"
        />
      </div>

      <!-- Show Setup Instructions if no URL -->
      <div v-else class="flex items-center justify-center h-full">
        <div class="max-w-md text-center space-y-6">
          <!-- Icon -->
          <!-- eslint-disable vue/no-bare-strings-in-template, @intlify/vue-i18n/no-raw-text -->
          <div class="flex justify-center">
            <div
              class="w-20 h-20 rounded-full bg-woot-50 dark:bg-slate-800 flex items-center justify-center"
            >
              <span class="text-4xl">📅</span>
            </div>
          </div>
          <!-- eslint-enable vue/no-bare-strings-in-template, @intlify/vue-i18n/no-raw-text -->

          <!-- Title -->
          <div>
            <h2
              class="text-xl font-semibold text-slate-900 dark:text-slate-100"
            >
              {{ t('CALENDAR.SETUP.TITLE', 'Connect Your Calendar') }}
            </h2>
            <p class="mt-2 text-sm text-slate-600 dark:text-slate-400">
              {{
                t(
                  'CALENDAR.SETUP.DESCRIPTION',
                  'Add your Google Calendar URL to view your schedule right here in Willo.'
                )
              }}
            </p>
          </div>

          <!-- Instructions -->
          <div
            class="bg-slate-50 dark:bg-slate-800 rounded-lg p-6 text-left space-y-4"
          >
            <h3 class="font-medium text-slate-900 dark:text-slate-100">
              {{ t('CALENDAR.SETUP.HOW_TO', 'How to connect:') }}
            </h3>
            <!-- eslint-disable vue/no-bare-strings-in-template, @intlify/vue-i18n/no-raw-text -->
            <ol class="space-y-3 text-sm text-slate-600 dark:text-slate-400">
              <li class="flex items-start">
                <span
                  class="flex-shrink-0 w-6 h-6 rounded-full bg-woot-500 text-white flex items-center justify-center text-xs font-medium mr-3"
                >
                  1
                </span>
                <span>
                  {{
                    t(
                      'CALENDAR.SETUP.STEP_1',
                      'Open Google Calendar and click the settings icon for the calendar you want to share'
                    )
                  }}
                </span>
              </li>
              <li class="flex items-start">
                <span
                  class="flex-shrink-0 w-6 h-6 rounded-full bg-woot-500 text-white flex items-center justify-center text-xs font-medium mr-3"
                >
                  2
                </span>
                <span>
                  {{
                    t(
                      'CALENDAR.SETUP.STEP_2',
                      'Scroll down to "Integrate calendar" and copy the "Public URL" or embed code'
                    )
                  }}
                </span>
              </li>
              <li class="flex items-start">
                <span
                  class="flex-shrink-0 w-6 h-6 rounded-full bg-woot-500 text-white flex items-center justify-center text-xs font-medium mr-3"
                >
                  3
                </span>
                <span>
                  {{
                    t(
                      'CALENDAR.SETUP.STEP_3',
                      'Go to your profile settings and paste the URL in the "Google Calendar URL" field'
                    )
                  }}
                </span>
              </li>
            </ol>
            <!-- eslint-enable vue/no-bare-strings-in-template, @intlify/vue-i18n/no-raw-text -->
          </div>

          <!-- Action Button -->
          <div>
            <router-link
              :to="`/app/accounts/${currentUser.account_id}/profile/settings`"
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-woot-500 hover:bg-woot-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-woot-500 transition-colors"
            >
              {{ t('CALENDAR.SETUP.GO_TO_SETTINGS', 'Go to Profile Settings') }}
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Additional custom styles if needed */
iframe {
  border: none;
}
</style>
