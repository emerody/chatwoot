<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h3>Mover Contato para CRM</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>

      <div class="modal-body">
        <div v-if="isLoading" class="loading-state">
          Carregando stages...
        </div>
        <div v-else>
          <p class="instruction-text">Selecione o stage para mover o contato:</p>
          <div class="stages-list">
            <div
              v-for="stage in stages"
              :key="stage.id"
              class="stage-item"
              @click="selectStage(stage)"
            >
              <div class="stage-info">
                <div class="stage-name">{{ stage.name }}</div>
                <div class="stage-count">{{ stage.contacts_count || 0 }} contatos</div>
              </div>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useMapGetter } from 'dashboard/composables/store';
/* global axios */

const props = defineProps({
  contactId: {
    type: [Number, String],
    required: true
  }
});

const emit = defineEmits(['close', 'stage-selected']);

const route = useRoute();
const currentAccount = useMapGetter('getCurrentAccount');

const stages = ref([]);
const isLoading = ref(false);

const loadStages = async () => {
  try {
    isLoading.value = true;
    const accountId = currentAccount.value?.id || route.params.accountId;
    
    const response = await axios.get(
      `/api/v1/accounts/${accountId}/crm/pipelines/default`
    );
    
    if (response.data.stages) {
      stages.value = response.data.stages.map(stage => ({
        ...stage,
        contacts_count: stage.contacts?.length || 0
      }));
    }
  } catch (error) {
    console.error('Erro ao carregar stages:', error);
  } finally {
    isLoading.value = false;
  }
};

const selectStage = (stage) => {
  emit('stage-selected', stage);
  emit('close');
};

onMounted(() => {
  loadStages();
});
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  color: #6b7280;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #1f2937;
}

.modal-body {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}

.instruction-text {
  margin-bottom: 16px;
  color: #6b7280;
  font-size: 14px;
}

.stages-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.stage-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.stage-item:hover {
  background-color: #f9fafb;
  border-color: #3b82f6;
}

.stage-info {
  flex: 1;
}

.stage-name {
  font-weight: 600;
  color: #1f2937;
  font-size: 15px;
  margin-bottom: 4px;
}

.stage-count {
  font-size: 12px;
  color: #6b7280;
}

.loading-state {
  text-align: center;
  padding: 40px;
  color: #6b7280;
}
</style>



