<template>
  <div class="stage-column" :data-stage-id="stage.id" :style="{ borderTopColor: stage.color || '#3b82f6' }">
    <div class="stage-header">
      <h3 class="stage-name">{{ stage.name }}</h3>
      <button 
        class="edit-stage-btn" 
        @click="$emit('edit-stage', stage)"
        title="Editar stage"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
        </svg>
      </button>
    </div>
    
    <div class="stage-count">{{ contacts.length }} contatos</div>
    
    <button 
      class="add-contact-btn" 
      @click="$emit('add-contact', stage)"
      title="Adicionar contato"
    >
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      Adicionar Contato
    </button>
    
    <draggable
      v-model="localContacts"
      :group="'contacts'"
      :animation="200"
      class="contacts-list"
      @end="handleDragEnd"
      item-key="id"
    >
      <template #item="{ element: contact }">
        <ContactCard
          :contact="contact"
          @click="$emit('contact-clicked', contact)"
        />
      </template>
    </draggable>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';
import draggable from 'vuedraggable';
import ContactCard from './ContactCard.vue';

const props = defineProps({
  stage: {
    type: Object,
    required: true
  },
  contacts: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['move-contact', 'edit-stage', 'contact-clicked', 'add-contact']);

const localContacts = ref([...props.contacts]);
const previousContacts = ref([...props.contacts]); // Guardar estado anterior para comparação

watch(() => props.contacts, (newContacts) => {
  localContacts.value = [...newContacts];
  previousContacts.value = [...newContacts];
}, { immediate: true });

const handleDragEnd = (event) => {
  console.log('[CRM StageColumn] Drag end event completo:', {
    added: event.added,
    removed: event.removed,
    from: event.from,
    to: event.to,
    item: event.item,
    newIndex: event.newIndex,
    oldIndex: event.oldIndex
  });
  
  // Comparar listas antes e depois para detectar mudanças
  const previousIds = previousContacts.value.map(c => c.id);
  const currentIds = localContacts.value.map(c => c.id);
  
  // Encontrar contatos adicionados (estão em currentIds mas não em previousIds)
  const addedContactIds = currentIds.filter(id => !previousIds.includes(id));
  
  // Encontrar contatos removidos (estão em previousIds mas não em currentIds)
  const removedContactIds = previousIds.filter(id => !currentIds.includes(id));
  
  console.log('[CRM StageColumn] Comparação de listas:', {
    previousIds,
    currentIds,
    addedContactIds,
    removedContactIds,
    stageId: props.stage.id
  });
  
  // Se um contato foi adicionado a esta coluna
  if (addedContactIds.length > 0) {
    const contactId = addedContactIds[0]; // Pegar o primeiro (normalmente só um)
    
    // Encontrar o stage de origem
    let fromStageId = null;
    if (event.from) {
      fromStageId = findStageIdByElement(event.from);
    }
    
    // Se não encontrou, tentar pelo item
    if (!fromStageId && event.item) {
      const fromColumn = event.item.closest('.stage-column');
      if (fromColumn && fromColumn.dataset && fromColumn.dataset.stageId) {
        fromStageId = parseInt(fromColumn.dataset.stageId);
      }
    }
    
    // Se ainda não encontrou, tentar pegar do dataset do item
    if (!fromStageId && event.item && event.item.dataset) {
      // O item pode ter informação sobre o stage anterior
      const contactCard = event.item.querySelector('.contact-card');
      if (contactCard && contactCard.dataset && contactCard.dataset.contactId) {
        // Não temos o stage anterior, mas não importa - o backend vai descobrir
      }
    }
    
    console.log('[CRM StageColumn] Contato adicionado detectado:', {
      contactId,
      fromStageId,
      toStageId: props.stage.id
    });
    
    // Só emitir se realmente veio de outro stage
    if (fromStageId !== props.stage.id) {
      console.log('[CRM StageColumn] Emitindo evento move-contact');
      emit('move-contact', {
        contactId: contactId,
        fromStageId: fromStageId,
        toStageId: props.stage.id
      });
    } else {
      console.log('[CRM StageColumn] Contato não mudou de stage, ignorando');
    }
  }
  
  // Atualizar lista anterior para próxima comparação
  previousContacts.value = [...localContacts.value];
};

const findStageIdByElement = (element) => {
  if (!element) return null;
  
  // Tentar encontrar a coluna pai
  let column = element.closest ? element.closest('.stage-column') : null;
  
  // Se não encontrou, tentar pelo parentElement
  if (!column && element.parentElement) {
    column = element.parentElement.closest('.stage-column');
  }
  
  // Se ainda não encontrou, tentar procurar pelo dataset diretamente
  if (!column && element.dataset && element.dataset.stageId) {
    return parseInt(element.dataset.stageId);
  }
  
  if (column && column.dataset && column.dataset.stageId) {
    const stageId = parseInt(column.dataset.stageId);
    console.log('[CRM StageColumn] Stage ID encontrado:', stageId);
    return stageId;
  }
  
  console.log('[CRM StageColumn] Não foi possível encontrar stage ID do elemento:', element);
  return null;
};
</script>

<style scoped>
.stage-column {
  flex: 0 0 300px;
  background: #f9fafb;
  border-radius: 8px;
  border-top: 4px solid #3b82f6;
  padding: 16px;
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 200px);
}

.stage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.stage-name {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.edit-stage-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  color: #6b7280;
  transition: color 0.2s;
  display: flex;
  align-items: center;
}

.edit-stage-btn:hover {
  color: #3b82f6;
}

.stage-count {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 12px;
}

.add-contact-btn {
  width: 100%;
  padding: 8px 12px;
  margin-bottom: 16px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  transition: background-color 0.2s;
}

.add-contact-btn:hover {
  background: #2563eb;
}

.add-contact-btn svg {
  width: 16px;
  height: 16px;
}

.contacts-list {
  flex: 1;
  overflow-y: auto;
  min-height: 200px;
}

.contacts-list::-webkit-scrollbar {
  width: 6px;
}

.contacts-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.contacts-list::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.contacts-list::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
