<template>
  <div class="crm-pipeline-board">
    <div class="pipeline-header">
      <h2 class="pipeline-title">{{ pipeline?.name || 'Pipeline Padrão' }}</h2>
    </div>
    
    <div class="stages-container" v-if="stages.length > 0">
      <StageColumn
        v-for="stage in stages"
        :key="stage.id"
        :stage="stage"
        :contacts="getContactsForStage(stage.id)"
        @move-contact="handleMoveContact"
        @edit-stage="handleEditStage"
        @contact-clicked="handleContactClick"
      />
    </div>
    
    <div v-else class="loading-state">
      Carregando pipeline...
    </div>

    <!-- Modal de Edição de Stage -->
    <StageEditModal
      v-if="editingStage"
      :stage="editingStage"
      @close="editingStage = null"
      @saved="handleStageSaved"
    />

    <!-- Modal de Contato -->
    <ContactModal
      v-if="selectedContact"
      :contact="selectedContact"
      @close="selectedContact = null"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore, useMapGetter } from 'dashboard/composables/store';
import { useRoute } from 'vue-router';
/* global axios */
import StageColumn from './StageColumn.vue';
import StageEditModal from './StageEditModal.vue';
import ContactModal from './ContactModal.vue';

const store = useStore();
const route = useRoute();
const currentAccount = useMapGetter('getCurrentAccount');

const pipeline = ref(null);
const stages = ref([]);
const contactsByStage = ref({});
const editingStage = ref(null);
const selectedContact = ref(null);

const getContactsForStage = (stageId) => {
  return contactsByStage.value[stageId] || [];
};

const loadPipeline = async () => {
  try {
    const accountId = currentAccount.value?.id || route.params.accountId;
    const response = await axios.get(`/api/v1/accounts/${accountId}/crm/pipelines/default`);
    pipeline.value = response.data.pipeline;
    stages.value = response.data.stages;
    
    // Organizar contatos por stage
    stages.value.forEach(stage => {
      contactsByStage.value[stage.id] = stage.contacts || [];
    });
  } catch (error) {
    console.error('Erro ao carregar pipeline:', error);
  }
};

const handleMoveContact = async ({ contactId, fromStageId, toStageId }) => {
  try {
    const accountId = currentAccount.value?.id || route.params.accountId;
    await axios.post(
      `/api/v1/accounts/${accountId}/crm/contacts/${contactId}/move_to_stage`,
      { stage_id: toStageId }
    );

    // Atualizar localmente
    const fromContacts = contactsByStage.value[fromStageId] || [];
    const contactIndex = fromContacts.findIndex(c => c.id === contactId);
    
    if (contactIndex !== -1) {
      const contact = fromContacts[contactIndex];
      fromContacts.splice(contactIndex, 1);
      
      const toContacts = contactsByStage.value[toStageId] || [];
      toContacts.push(contact);
    }

    // Recarregar pipeline para garantir sincronização
    await loadPipeline();
  } catch (error) {
    console.error('Erro ao mover contato:', error);
  }
};

const handleEditStage = (stage) => {
  editingStage.value = stage;
};

const handleStageSaved = async (updatedStage) => {
  const index = stages.value.findIndex(s => s.id === updatedStage.id);
  if (index !== -1) {
    stages.value[index] = updatedStage;
  }
  editingStage.value = null;
  await loadPipeline();
};

const handleContactClick = (contact) => {
  selectedContact.value = contact;
};

onMounted(() => {
  loadPipeline();
});
</script>

<style scoped>
.crm-pipeline-board {
  padding: 20px;
  height: 100%;
  overflow-x: auto;
}

.pipeline-header {
  margin-bottom: 20px;
}

.pipeline-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
}

.stages-container {
  display: flex;
  gap: 16px;
  min-height: 500px;
}

.loading-state {
  text-align: center;
  padding: 40px;
  color: #6b7280;
}
</style>
