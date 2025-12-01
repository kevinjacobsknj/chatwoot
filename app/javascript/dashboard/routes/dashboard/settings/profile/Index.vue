<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { useFontSize } from 'dashboard/composables/useFontSize';
import { useBranding } from 'shared/composables/useBranding';
import { clearCookiesOnLogout } from 'dashboard/store/utils/api.js';
import { copyTextToClipboard } from 'shared/helpers/clipboard';
import { parseAPIErrorResponse } from 'dashboard/store/utils/api';
import { parseBoolean } from '@chatwoot/utils';
import UserProfilePicture from './UserProfilePicture.vue';
import UserBasicDetails from './UserBasicDetails.vue';
import MessageSignature from './MessageSignature.vue';
import FontSize from './FontSize.vue';
import UserLanguageSelect from './UserLanguageSelect.vue';
import HotKeyCard from './HotKeyCard.vue';
import ChangePassword from './ChangePassword.vue';
import NotificationPreferences from './NotificationPreferences.vue';
import AudioNotifications from './AudioNotifications.vue';
import FormSection from 'dashboard/components/FormSection.vue';
import AccessToken from './AccessToken.vue';
import MfaSettingsCard from './MfaSettingsCard.vue';
import Policy from 'dashboard/components/policy.vue';
import {
  ROLES,
  CONVERSATION_PERMISSIONS,
} from 'dashboard/constants/permissions.js';

export default {
  components: {
    MessageSignature,
    FormSection,
    FontSize,
    UserLanguageSelect,
    UserProfilePicture,
    Policy,
    UserBasicDetails,
    HotKeyCard,
    ChangePassword,
    NotificationPreferences,
    AudioNotifications,
    AccessToken,
    MfaSettingsCard,
  },
  setup() {
    const { isEditorHotKeyEnabled, updateUISettings } = useUISettings();
    const { currentFontSize, updateFontSize } = useFontSize();
    const { replaceInstallationName } = useBranding();

    return {
      currentFontSize,
      updateFontSize,
      isEditorHotKeyEnabled,
      updateUISettings,
      replaceInstallationName,
    };
  },
  data() {
    return {
      avatarFile: '',
      avatarUrl: '',
      name: '',
      displayName: '',
      email: '',
      messageSignature: '',
      googleCalendarUrl: '',
      hotKeys: [
        {
          key: 'enter',
          title: this.$t(
            'PROFILE_SETTINGS.FORM.SEND_MESSAGE.CARD.ENTER_KEY.HEADING'
          ),
          description: this.$t(
            'PROFILE_SETTINGS.FORM.SEND_MESSAGE.CARD.ENTER_KEY.CONTENT'
          ),
          lightImage: '/assets/images/dashboard/profile/hot-key-enter.svg',
          darkImage: '/assets/images/dashboard/profile/hot-key-enter-dark.svg',
        },
        {
          key: 'cmd_enter',
          title: this.$t(
            'PROFILE_SETTINGS.FORM.SEND_MESSAGE.CARD.CMD_ENTER_KEY.HEADING'
          ),
          description: this.$t(
            'PROFILE_SETTINGS.FORM.SEND_MESSAGE.CARD.CMD_ENTER_KEY.CONTENT'
          ),
          lightImage: '/assets/images/dashboard/profile/hot-key-ctrl-enter.svg',
          darkImage:
            '/assets/images/dashboard/profile/hot-key-ctrl-enter-dark.svg',
        },
      ],
      notificationPermissions: [...ROLES, ...CONVERSATION_PERMISSIONS],
      audioNotificationPermissions: [...ROLES, ...CONVERSATION_PERMISSIONS],
    };
  },
  computed: {
    ...mapGetters({
      currentUser: 'getCurrentUser',
      currentUserId: 'getCurrentUserID',
      globalConfig: 'globalConfig/get',
    }),
    isMfaEnabled() {
      return parseBoolean(window.chatwootConfig?.isMfaEnabled);
    },
  },
  mounted() {
    if (this.currentUserId) {
      this.initializeUser();
    }
  },
  methods: {
    initializeUser() {
      this.name = this.currentUser.name;
      this.email = this.currentUser.email;
      this.avatarUrl = this.currentUser.avatar_url;
      this.displayName = this.currentUser.display_name;
      this.messageSignature = this.currentUser.message_signature;
      this.googleCalendarUrl = this.currentUser.google_calendar_url || '';
    },
    async dispatchUpdate(payload, successMessage, errorMessage) {
      let alertMessage = '';
      try {
        await this.$store.dispatch('updateProfile', payload);
        alertMessage = successMessage;

        return true; // return the value so that the status can be known
      } catch (error) {
        alertMessage = parseAPIErrorResponse(error) || errorMessage;

        return false; // return the value so that the status can be known
      } finally {
        useAlert(alertMessage);
      }
    },
    async updateProfile(userAttributes) {
      const { name, email, displayName } = userAttributes;
      const hasEmailChanged = this.currentUser.email !== email;
      this.name = name || this.name;
      this.email = email || this.email;
      this.displayName = displayName || this.displayName;

      const updatePayload = {
        name: this.name,
        email: this.email,
        displayName: this.displayName,
        avatar: this.avatarFile,
      };

      const success = await this.dispatchUpdate(
        updatePayload,
        hasEmailChanged
          ? this.$t('PROFILE_SETTINGS.AFTER_EMAIL_CHANGED')
          : this.$t('PROFILE_SETTINGS.UPDATE_SUCCESS'),
        this.$t('RESET_PASSWORD.API.ERROR_MESSAGE')
      );

      if (hasEmailChanged && success) clearCookiesOnLogout();
    },
    async updateSignature(signature) {
      const payload = { message_signature: signature };
      let successMessage = this.$t(
        'PROFILE_SETTINGS.FORM.MESSAGE_SIGNATURE_SECTION.API_SUCCESS'
      );
      let errorMessage = this.$t(
        'PROFILE_SETTINGS.FORM.MESSAGE_SIGNATURE_SECTION.API_ERROR'
      );

      await this.dispatchUpdate(payload, successMessage, errorMessage);
    },
    async updateCalendarUrl() {
      const payload = { google_calendar_url: this.googleCalendarUrl };
      let successMessage = this.$t(
        'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.API_SUCCESS',
        'Calendar URL updated successfully'
      );
      let errorMessage = this.$t(
        'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.API_ERROR',
        'Failed to update calendar URL'
      );

      await this.dispatchUpdate(payload, successMessage, errorMessage);
    },
    updateProfilePicture({ file, url }) {
      this.avatarFile = file;
      this.avatarUrl = url;
    },
    async deleteProfilePicture() {
      try {
        await this.$store.dispatch('deleteAvatar');
        this.avatarUrl = '';
        this.avatarFile = '';
        useAlert(this.$t('PROFILE_SETTINGS.AVATAR_DELETE_SUCCESS'));
      } catch (error) {
        useAlert(this.$t('PROFILE_SETTINGS.AVATAR_DELETE_FAILED'));
      }
    },
    toggleHotKey(key) {
      this.hotKeys = this.hotKeys.map(hotKey =>
        hotKey.key === key ? { ...hotKey, active: !hotKey.active } : hotKey
      );
      this.updateUISettings({ editor_message_key: key });
      useAlert(this.$t('PROFILE_SETTINGS.FORM.SEND_MESSAGE.UPDATE_SUCCESS'));
    },
    async onCopyToken(value) {
      await copyTextToClipboard(value);
      useAlert(this.$t('COMPONENTS.CODE.COPY_SUCCESSFUL'));
    },
    async resetAccessToken() {
      const success = await this.$store.dispatch('resetAccessToken');
      if (success) {
        useAlert(this.$t('PROFILE_SETTINGS.FORM.ACCESS_TOKEN.RESET_SUCCESS'));
      } else {
        useAlert(this.$t('PROFILE_SETTINGS.FORM.ACCESS_TOKEN.RESET_ERROR'));
      }
    },
  },
};
</script>

<template>
  <div class="grid py-16 px-5 font-inter mx-auto gap-16 sm:max-w-screen-md">
    <div class="flex flex-col gap-6">
      <h2 class="text-2xl font-medium text-n-slate-12">
        {{ $t('PROFILE_SETTINGS.TITLE') }}
      </h2>
      <UserProfilePicture
        :src="avatarUrl"
        :name="name"
        @change="updateProfilePicture"
        @delete="deleteProfilePicture"
      />
      <UserBasicDetails
        :name="name"
        :display-name="displayName"
        :email="email"
        :email-enabled="!globalConfig.disableUserProfileUpdate"
        @update-user="updateProfile"
      />
    </div>
    <FormSection
      :title="$t('PROFILE_SETTINGS.FORM.INTERFACE_SECTION.TITLE')"
      :description="
        replaceInstallationName(
          $t('PROFILE_SETTINGS.FORM.INTERFACE_SECTION.NOTE')
        )
      "
    >
      <FontSize
        :value="currentFontSize"
        :label="$t('PROFILE_SETTINGS.FORM.INTERFACE_SECTION.FONT_SIZE.TITLE')"
        :description="
          $t('PROFILE_SETTINGS.FORM.INTERFACE_SECTION.FONT_SIZE.NOTE')
        "
        @change="updateFontSize"
      />
      <UserLanguageSelect
        :label="$t('PROFILE_SETTINGS.FORM.INTERFACE_SECTION.LANGUAGE.TITLE')"
        :description="
          $t('PROFILE_SETTINGS.FORM.INTERFACE_SECTION.LANGUAGE.NOTE')
        "
      />
    </FormSection>
    <FormSection
      :title="$t('PROFILE_SETTINGS.FORM.MESSAGE_SIGNATURE_SECTION.TITLE')"
      :description="$t('PROFILE_SETTINGS.FORM.MESSAGE_SIGNATURE_SECTION.NOTE')"
    >
      <MessageSignature
        :message-signature="messageSignature"
        @update-signature="updateSignature"
      />
    </FormSection>
    <FormSection
      :title="
        $t(
          'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.TITLE',
          'Calendar Integration'
        )
      "
      :description="
        $t(
          'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.NOTE',
          'Connect your Google Calendar to view your schedule within Willo'
        )
      "
    >
      <div class="flex flex-col gap-4">
        <div class="flex flex-col gap-2">
          <label
            for="google-calendar-url"
            class="text-sm font-medium text-slate-700 dark:text-slate-300"
          >
            {{
              $t(
                'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.LABEL',
                'Google Calendar Embed URL'
              )
            }}
          </label>
          <input
            id="google-calendar-url"
            v-model="googleCalendarUrl"
            type="text"
            class="block w-full rounded-md border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 shadow-sm focus:border-woot-500 focus:ring-woot-500 sm:text-sm px-3 py-2"
            :placeholder="
              $t(
                'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.PLACEHOLDER',
                'Paste your Google Calendar public URL or embed code here'
              )
            "
          />
          <p class="text-sm text-slate-500 dark:text-slate-400">
            {{
              $t(
                'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.HELP_TEXT',
                'Get your calendar URL from'
              )
            }}
            <a
              href="https://support.google.com/calendar/answer/41207"
              target="_blank"
              rel="noopener noreferrer"
              class="text-woot-500 hover:text-woot-600 underline"
            >
              {{
                $t(
                  'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.HELP_LINK',
                  'Google Calendar settings'
                )
              }}
            </a>
          </p>
        </div>
        <div>
          <button
            type="button"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-woot-500 hover:bg-woot-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-woot-500 transition-colors"
            @click="updateCalendarUrl"
          >
            {{
              $t(
                'PROFILE_SETTINGS.FORM.CALENDAR_SECTION.SAVE_BUTTON',
                'Save Calendar URL'
              )
            }}
          </button>
        </div>
      </div>
    </FormSection>
    <FormSection
      :title="$t('PROFILE_SETTINGS.FORM.SEND_MESSAGE.TITLE')"
      :description="$t('PROFILE_SETTINGS.FORM.SEND_MESSAGE.NOTE')"
    >
      <div
        class="flex flex-col justify-between w-full gap-5 sm:gap-4 sm:flex-row"
      >
        <button
          v-for="hotKey in hotKeys"
          :key="hotKey.key"
          class="px-0 reset-base w-full sm:flex-1 rounded-xl outline-1 outline"
          :class="
            isEditorHotKeyEnabled(hotKey.key)
              ? 'outline-n-brand/30'
              : 'outline-n-weak'
          "
        >
          <HotKeyCard
            :key="hotKey.title"
            :title="hotKey.title"
            :description="hotKey.description"
            :light-image="hotKey.lightImage"
            :dark-image="hotKey.darkImage"
            :active="isEditorHotKeyEnabled(hotKey.key)"
            @click="toggleHotKey(hotKey.key)"
          />
        </button>
      </div>
    </FormSection>
    <FormSection
      v-if="!globalConfig.disableUserProfileUpdate"
      :title="$t('PROFILE_SETTINGS.FORM.PASSWORD_SECTION.TITLE')"
    >
      <ChangePassword />
    </FormSection>
    <FormSection
      v-if="isMfaEnabled"
      :title="$t('PROFILE_SETTINGS.FORM.SECURITY_SECTION.TITLE')"
      :description="$t('PROFILE_SETTINGS.FORM.SECURITY_SECTION.NOTE')"
    >
      <MfaSettingsCard />
    </FormSection>
    <Policy :permissions="audioNotificationPermissions">
      <FormSection
        :title="$t('PROFILE_SETTINGS.FORM.AUDIO_NOTIFICATIONS_SECTION.TITLE')"
        :description="
          $t('PROFILE_SETTINGS.FORM.AUDIO_NOTIFICATIONS_SECTION.NOTE')
        "
      >
        <AudioNotifications />
      </FormSection>
    </Policy>
    <Policy :permissions="notificationPermissions">
      <FormSection :title="$t('PROFILE_SETTINGS.FORM.NOTIFICATIONS.TITLE')">
        <NotificationPreferences />
      </FormSection>
    </Policy>
    <FormSection
      :title="$t('PROFILE_SETTINGS.FORM.ACCESS_TOKEN.TITLE')"
      :description="
        replaceInstallationName($t('PROFILE_SETTINGS.FORM.ACCESS_TOKEN.NOTE'))
      "
    >
      <AccessToken
        :value="currentUser.access_token"
        @on-copy="onCopyToken"
        @on-reset="resetAccessToken"
      />
    </FormSection>
  </div>
</template>
