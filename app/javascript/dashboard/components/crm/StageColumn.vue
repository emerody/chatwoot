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

watch(() => props.contacts, (newContacts) => {
  localContacts.value = [...newContacts];
}, { immediate: true });

const handleDragEnd = (event) => {
  console.log('[CRM StageColumn] Drag end event completo:', {
    added: event.added,
    removed: event.removed,
    from: event.from,
    to: event.to,
    item: event.item
  });
  
  // Quando um contato é adicionado a esta coluna, significa que foi movido PARA aqui
  if (event.added && event.added.element) {
    const contact = event.added.element;
    let fromStageId = null;
    
    // Tentar encontrar o stage de origem de várias formas
    if (event.from) {
      fromStageId = findStageIdByElement(event.from);
    }
    
    // Se não encontrou pelo elemento, tentar pelo item
    if (!fromStageId && event.item) {
      const fromColumn = event.item.closest('.stage-column');
      if (fromColumn) {
        fromStageId = parseInt(fromColumn.dataset.stageId);
      }
    }
    
    console.log('[CRM StageColumn] Contato adicionado:', {
      contactId: contact.id,
      contactName: contact.name,
      fromStageId,
      toStageId: props.stage.id,
      fromElement: event.from?.className,
      itemElement: event.item?.className
    });
    
    // Só emitir se realmente veio de outro stage (ou se não sabemos de onde veio, mas está vindo para cá)
    if (fromStageId !== props.stage.id) {
      console.log('[CRM StageColumn] Emitindo evento move-contact');
      emit('move-contact', {
        contactId: contact.id,
        fromStageId: fromStageId,
        toStageId: props.stage.id
      });
    } else {
      console.log('[CRM StageColumn] Contato não mudou de stage, ignorando');
    }
  } else {
    console.log('[CRM StageColumn] Nenhum contato adicionado ou elemento inválido');
  }
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
