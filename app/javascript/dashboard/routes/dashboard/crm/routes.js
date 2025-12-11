import { frontendURL } from '../../../helper/URLHelper';
import CrmPipelineView from './pages/CrmPipelineView.vue';
import { FEATURE_FLAGS } from '../../../featureFlags';

const commonMeta = {
  featureFlag: FEATURE_FLAGS.CRM,
  permissions: ['administrator', 'agent'],
};

export const routes = [
  {
    path: frontendURL('accounts/:accountId/crm'),
    component: CrmPipelineView,
    name: 'crm_pipeline_index',
    meta: commonMeta,
  },
];




