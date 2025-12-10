<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h3>Editar Stage</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>
      
      <form @submit.prevent="handleSave" class="modal-body">
        <div class="form-group">
          <label for="stage-name">Nome do Stage</label>
          <input
            id="stage-name"
            v-model="stageName"
            type="text"
            class="form-input"
            placeholder="Digite o nome do stage"
            required
          />
        </div>
        
        <div class="form-actions">
          <button type="button" class="btn-cancel" @click="$emit('close')">
            Cancelar
          </button>
          <button type="submit" class="btn-save">
            Salvar
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'StageEditModal',
  props: {
    stage: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      stageName: ''
    }
  },
  computed: {
    ...mapGetters({
      currentAccount: 'getCurrentAccount'
    })
  },
  mounted() {
    this.stageName = this.stage.name
  },
  methods: {
    async handleSave() {
      try {
        const response = await this.$axios.patch(
          `/api/v1/accounts/${this.currentAccount.id}/crm/stages/${this.stage.id}`,
          {
            stage: {
              name: this.stageName
            }
          }
        )

        this.$emit('saved', response.data)
      } catch (error) {
        console.error('Erro ao salvar stage:', error)
        this.$toast.error('Erro ao salvar stage')
      }
    }
  }
}
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
  max-height: 90vh;
  overflow: auto;
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
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #374151;
}

.form-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn-cancel,
.btn-save {
  padding: 10px 20px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel {
  background: white;
  border: 1px solid #d1d5db;
  color: #374151;
}

.btn-cancel:hover {
  background: #f9fafb;
}

.btn-save {
  background: #3b82f6;
  border: none;
  color: white;
}

.btn-save:hover {
  background: #2563eb;
}
</style>

