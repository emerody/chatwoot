<template>
  <div class="crm-pipeline-board">
    <div class="pipeline-header">
      <h2 class="pipeline-title">{{ pipeline.name }}</h2>
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

<script>
import StageColumn from './StageColumn.vue'
import StageEditModal from './StageEditModal.vue'
import ContactModal from './ContactModal.vue'
import { mapGetters } from 'vuex'

export default {
  name: 'PipelineBoard',
  components: {
    StageColumn,
    StageEditModal,
    ContactModal
  },
  data() {
    return {
      pipeline: null,
      stages: [],
      contactsByStage: {},
      editingStage: null,
      selectedContact: null
    }
  },
  computed: {
    ...mapGetters({
      currentAccount: 'getCurrentAccount'
    })
  },
  mounted() {
    this.loadPipeline()
  },
  methods: {
    async loadPipeline() {
      try {
        const response = await this.$axios.get(`/api/v1/accounts/${this.currentAccount.id}/crm/pipelines/default`)
        this.pipeline = response.data.pipeline
        this.stages = response.data.stages
        
        // Organizar contatos por stage
        this.stages.forEach(stage => {
          this.$set(this.contactsByStage, stage.id, stage.contacts || [])
        })
      } catch (error) {
        console.error('Erro ao carregar pipeline:', error)
        this.$toast.error('Erro ao carregar pipeline')
      }
    },
    getContactsForStage(stageId) {
      return this.contactsByStage[stageId] || []
    },
    async handleMoveContact({ contactId, fromStageId, toStageId }) {
      try {
        const response = await this.$axios.post(
          `/api/v1/accounts/${this.currentAccount.id}/crm/contacts/${contactId}/move_to_stage`,
          { stage_id: toStageId }
        )

        // Atualizar localmente
        const contact = this.findContactInStage(contactId, fromStageId)
        if (contact) {
          // Remove do stage anterior
          const fromContacts = this.contactsByStage[fromStageId] || []
          const fromIndex = fromContacts.findIndex(c => c.id === contactId)
          if (fromIndex !== -1) {
            fromContacts.splice(fromIndex, 1)
          }

          // Adiciona ao novo stage
          const toContacts = this.contactsByStage[toStageId] || []
          toContacts.push(contact)
        }

        this.$toast.success('Contato movido com sucesso')
      } catch (error) {
        console.error('Erro ao mover contato:', error)
        this.$toast.error('Erro ao mover contato')
      }
    },
    findContactInStage(contactId, stageId) {
      const contacts = this.contactsByStage[stageId] || []
      return contacts.find(c => c.id === contactId)
    },
    handleEditStage(stage) {
      this.editingStage = stage
    },
    async handleStageSaved(updatedStage) {
      const index = this.stages.findIndex(s => s.id === updatedStage.id)
      if (index !== -1) {
        this.$set(this.stages, index, updatedStage)
      }
      this.editingStage = null
      this.$toast.success('Stage atualizado com sucesso')
    },
    handleContactClick(contact) {
      this.selectedContact = contact
    }
  }
}
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

