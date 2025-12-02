import { frontendURL } from '../../../helper/URLHelper';

const WilloDashboard = () => import('./Dashboard.vue');

export const routes = [
  {
    path: frontendURL('accounts/:accountId/willo'),
    name: 'willo_dashboard',
    component: WilloDashboard,
    meta: {
      permissions: ['administrator', 'agent'],
    },
  },
];
