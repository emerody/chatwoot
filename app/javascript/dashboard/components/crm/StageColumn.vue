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

const emit = defineEmits(['move-contact', 'edit-stage', 'contact-clicked']);

const localContacts = ref([...props.contacts]);

watch(() => props.contacts, (newContacts) => {
  localContacts.value = [...newContacts];
}, { immediate: true });

const handleDragEnd = (event) => {
  if (event.added) {
    const contact = event.added.element;
    emit('move-contact', {
      contactId: contact.id,
      fromStageId: event.from ? findStageIdByElement(event.from) : null,
      toStageId: props.stage.id
    });
  } else if (event.removed) {
    const contact = event.removed.element;
    emit('move-contact', {
      contactId: contact.id,
      fromStageId: props.stage.id,
      toStageId: event.to ? findStageIdByElement(event.to) : null
    });
  }
};

const findStageIdByElement = (element) => {
  const column = element.closest('.stage-column');
  if (column) {
    return parseInt(column.dataset.stageId);
  }
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
  margin-bottom: 16px;
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
