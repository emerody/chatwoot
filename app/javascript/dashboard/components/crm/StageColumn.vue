<template>
  <div class="stage-column" :style="{ borderTopColor: stage.color || '#3b82f6' }">
    <div class="stage-header">
      <h3 class="stage-name">{{ stage.name }}</h3>
      <button 
        class="edit-stage-btn" 
        @click="$emit('edit-stage', stage)"
        title="Editar stage"
      >
        <i class="icon-edit"></i>
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

<script>
import draggable from 'vuedraggable'
import ContactCard from './ContactCard.vue'

export default {
  name: 'StageColumn',
  components: {
    draggable,
    ContactCard
  },
  props: {
    stage: {
      type: Object,
      required: true
    },
    contacts: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      localContacts: []
    }
  },
  watch: {
    contacts: {
      immediate: true,
      handler(newContacts) {
        this.localContacts = [...newContacts]
      }
    }
  },
  methods: {
    handleDragEnd(event) {
      if (event.added) {
        // Contato foi adicionado a esta coluna
        const contact = event.added.element
        this.$emit('move-contact', {
          contactId: contact.id,
          fromStageId: event.from ? this.findStageIdByElement(event.from) : null,
          toStageId: this.stage.id
        })
      } else if (event.removed) {
        // Contato foi removido desta coluna
        const contact = event.removed.element
        this.$emit('move-contact', {
          contactId: contact.id,
          fromStageId: this.stage.id,
          toStageId: event.to ? this.findStageIdByElement(event.to) : null
        })
      }
    },
    findStageIdByElement(element) {
      // Encontrar stage ID pelo elemento DOM
      const column = element.closest('.stage-column')
      if (column) {
        return parseInt(column.dataset.stageId)
      }
      return null
    }
  }
}
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

